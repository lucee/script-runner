<cfscript>
	file_filter="*-results.json";
	files = [];
	out = [];

	if ( !structKeyExists( server.system.environment, "GITHUB_REF_NAME" ) ){
		systemOutput("Not running on github actions, aborting ");
		abort;
	}
	repo = server.system.environment.GITHUB_REPOSITORY;
	branch = server.system.environment.GITHUB_REF_NAME;
	artifact_name = url.artifact_name ?: "";
	artifact_filter = url.artifact_name ?: "";
	variance_threshold = url.variance_threshold ?: 10; // threshold for reporting test case different performance

	github_token = url.githubToken ?: "";
	if ( !len( github_token ) )
		throw "no github token?";
	// fetch artifacts, try and find the last one for this branch
	artifacts_url = "https://api.github.com/repos/#repo#/actions/artifacts?per_page=100&name=#artifact_name#";
	http url=artifacts_url throwOnError=true {
		httpparam type="header" name="Authorization" value="Bearer #github_token#";
	};
	if ( !isJson( cfhttp.filecontent ) )
		throw( message="Github REST API didn't return json", details=cfhttp.filecontent );
	response = deserializeJSON( cfhttp.filecontent );
	artifact_found = [];
	for (a = 1; a LTE len(response.artifacts); a++ ){
		if (response.artifacts[a].name contains artifact_filter
			&& response.artifacts[a].workflow_run.head_branch eq branch){
			systemOutput(response.artifacts[a], true);
			if (response.artifacts[a].expired)
				break;
			artifact_zip = getTempFile(getTempDirectory(),"github-artifact", "zip");
			http url=response.artifacts[a].archive_download_url path=getTempDirectory() file=listLast(artifact_zip,"\/") {
				httpparam type="header" name="Authorization" value="Bearer #github_token#";
			};
			systemOutput( cfhttp, true );
			if ( cfhttp.error )
				throw "download artifact failed [#cfhttp.errordetail#]";
			// dump(cfhttp);
			tmp_dir = getTempDirectory() & createUUID();
			directoryCreate( tmp_dir );
			Extract("zip", artifact_zip, tmp_dir);
			artifacts_files = directoryList( path=dir, filter=file_filter, sort="datelastmodifed desc" );
			if ( len( artifacts_files ) eq 1){
				ArrayAppend( files, artifacts_files[ 1 ] );
				ArrayAppend( artifact_found, response.artifacts[a].workflow_run.id );
			} else {
				systemOutput("No results found in artifacts missing? ")
			}
			if (len(artifact_found) gt 1)
				break; // report on the last two runs if available
		}
	}
	if ( !len( artifact_found ) ) {
		systemOutput("No artifacts found for branch [#branch#]? ")
	} else if ( !arrayContains(artifact_found, server.system.environment.GITHUB_RUN_ID ) ){
		throw "No artifacts from the current run [#server.system.environment.GITHUB_RUN_ID#] found [#artifact_found.toJson()#]";
	}

	if ( len( files ) gt 2 ){
		files = arraySlice( files, 1, 2 );
	} else if ( len( files ) lt 2 ){
		systemOutput( "Not enough artifacts found to compare, [#len(files)#] found", true);
		abort;
	}

	runs = [];

	for ( f in files ){
		systemOutput ( f, true );
		json = deserializeJson( fileRead( f ) );
		q = queryNew( "time,suite,spec,suiteSpec" );

		for ( i=1; i <= len(json.bundleStats); i++ ){
			bundle = json.bundleStats[i];
			for (j = 1; j <= len(bundle.suiteStats); j++){
				s = bundle.suiteStats[ j ];
				for ( p in s.specStats ){
					row = queryAddRow( q );
				//  querySetCell(q, "java", json.javaVersion, row);
				//  querySetCell(q, "version", json.CFMLEngineVersion, row);
					querySetCell(q, "spec", p.name, row);
					querySetCell(q, "suite", bundle.path, row);
					querySetCell(q, "suiteSpec", bundle.path & ", " & p.name, row);
					querySetCell(q, "time", p.totalDuration, row);
				}
			}
		}

		arrayAppend( runs, {
			"java": json.javaVersion,
			"version": json.CFMLEngineVersion,
			"totalDuration": json.totalDuration,
			"stats": queryToStruct(q, "suiteSpec")
		});
	};

	if ( IsEmpty( runs ) ) throw "No json report files found?";

	_logger( "## Summary Report" );

	echo(reportRuns( runs ));

	echo(reportTests( runs ));

	function _logger( string message="", boolean throw=false ){
		if ( !structKeyExists( server.system.environment, "GITHUB_STEP_SUMMARY" ) ){
			systemOutput( arguments.message, true );
			arrayAppend(out, message);
			return;
		}

		if ( !FileExists( server.system.environment.GITHUB_STEP_SUMMARY ) ){
			fileWrite( server.system.environment.GITHUB_STEP_SUMMARY, "#### #server.lucee.version# ");
			//fileAppend( server.system.environment.GITHUB_STEP_SUMMARY, server.system.environment.toJson());
		}

		if ( arguments.throw ) {
			fileAppend( server.system.environment.GITHUB_STEP_SUMMARY, "> [!WARNING]" & chr(10) );
			fileAppend( server.system.environment.GITHUB_STEP_SUMMARY, "> #arguments.message##chr(10)#");
			throw arguments.message;
		} else {
			fileAppend( server.system.environment.GITHUB_STEP_SUMMARY, "#arguments.message##chr(10)#");
		}

	}

	function reportRuns( srcRuns ) localmode=true {

		var runs = duplicate( srcRuns );
		var html="<table border=1 cellpadding=2 cellspacing=0>";
		arraySort(
			runs,
			function (e1, e2){
				if (e1.totalDuration lt e2.totalDuration) return -1;
				else if (e1.totalDuration gt e2.totalDuration) return 1;
				return 0;
			}
		); // fastest to slowest

		var hdr = [ "Version", "Java", "Time" ];
		var div = [ "---", "---", "---:" ];
		_logger( "" );
		_logger( "|" & arrayToList( hdr, "|" ) & "|" );
		_logger( "|" & arrayToList( div, "|" ) & "|" );
		html &= "<thead><tr><th>" & arrayToList( hdr, "<th>" ) & "</tr></thead><tbody>";

		var row = [];
		loop array=runs item="local.run" {
			ArrayAppend( row, run.version );
			ArrayAppend( row, run.java );
			arrayAppend( row, numberFormat( run.totalDuration ) );
			_logger( "|" & arrayToList( row, "|" ) & "|" );
			html &= "<tr><td>" & arrayToList( row, "<td>" ) & "</tr>";
			row = [];
		}
		html &= "</tbody></table>";

		_logger( "" );
		return html;
	}


	function reportTests( runs ) localmode=true {

		var sortedRuns = duplicate(runs);
		var html="<table border=1 cellpadding=2 cellspacing=0>";

		arraySort(
			sortedRuns,
			function (e1, e2){
				return compare(e1.version & e1.java, e2.version & e2.java);
			}
		); // sort runs by oldest version to newest version


		var hdr = [ "Suite", "Spec" ];
		var div = [ "---", "---" ];
		loop array=sortedRuns item="local.run" {
			arrayAppend( hdr, run.version & " " & listFirst(run.java,".") );
			arrayAppend( div, "---:" ); // right align as they are all numeric
		}

		// diff column, first run vs last run
		arrayAppend( hdr, "Difference (oldest vs newest)" );
		arrayAppend( div, "---:" ); // right align as they are all numeric

		_logger( "" );
		_logger( "|" & arrayToList( hdr, "|" ) & "|" );
		_logger( "|" & arrayToList( div, "|" ) & "|" );

		html &= "<thead><tr><th>" & arrayToList( hdr, "<th>" ) & "</tr></thead><tbody>";

		// now sort the tests by the difference in time between the first run and last run

		var suiteSpecs = [];
		var suiteSpecsDiff = {};

		loop collection=runs[1].stats key="title" value="test" {
			// difference between the test time for the newest version minus oldest version
			var diff = sortedRuns[arrayLen(runs)].stats[test.suiteSpec].time - sortedRuns[1].stats[test.suiteSpec].time;
			ArrayAppend( suiteSpecs, {
				suiteSpec: test.suiteSpec,
				diff: diff,
				suite: test.suite,
				spec: test.spec
			});
			suiteSpecsDiff[test.suiteSpec] = diff;
		}

		arraySort(
			suiteSpecs,
			function (e1, e2){
				if (e1.diff gt e2.diff) return -1;
				else if (e1.diff lt e2.diff) return 1;
				return 0;
			}
		); // sort by performance regression

		var row = [];
		loop array=suiteSpecs item="test" {
			// force long names to wrap without breaking markdown
			ArrayAppend( row, REReplace( wrap(test.suite, 70), "\n", " ", "ALL") );
			ArrayAppend( row, REReplace( wrap(test.Spec, 70), "\n", " ", "ALL") );
			loop array=sortedRuns item="local.run" {
				if ( structKeyExists( run.stats, test.suiteSpec ) )
					arrayAppend( row, numberFormat( run.stats[test.suiteSpec].time ) );
				else
					arrayAppend( row, "");
			}
			arrayAppend( row, numberFormat( test.diff ) );
			_logger( "|" & arrayToList( row, "|" ) & "|" );
			if ( abs( test.diff ) gt variance_threshold ){
				html &= "<tr>";
				arrayEach(row, function(el){
					html &= "<td>" & encodeForHtml( el );
				});
				html &= "</tr>";
			}

			row = [];
		}

		html &= "</tbody></table>";

		_logger( "" );
		return html;
	}

</cfscript>
<script>
	var tableSorter = function (th, sortDefault){
		var tr = th.parentElement;
		var table = tr.parentElement.parentElement; // table;
		var tbodys = table.getElementsByTagName("tbody");
		var theads = table.getElementsByTagName("thead");
		var rowspans = (table.dataset.rowspan !== "false");

		if (!th.dataset.type)
			th.dataset.type = sortDefault; // otherwise text
		if (!th.dataset.dir){
			th.dataset.dir = "asc";
		} else {
			if (th.dataset.dir == "desc")
				th.dataset.dir = "asc";
			else
				th.dataset.dir = "desc";
		}
		for (var h = 0; h < tr.children.length; h++){
			var cell = tr.children[h].style;
			if (h === th.cellIndex){
				cell.fontWeight = 700;
				cell.fontStyle = (th.dataset.dir == "desc") ? "normal" : "italic";
			} else {
				cell.fontWeight = 300;
				cell.fontStyle = "normal";
			}
		}
		var sortGroup = false;
		var localeCompare = "test".localeCompare ? true : false;
		var data = [];

		for ( var b = 0; b < tbodys.length; b++ ){
			var tbody =tbodys[b];
			for ( var r = 0; r < tbody.children.length; r++ ){
				var row = tbody.children[r];
				var group = false;
				if (row.classList.length > 0){
					// check for class sort-group
					group = row.classList.contains("sort-group");
				}
				// this is to handle secondary rows with rowspans, but this stops two column tables from sorting
				if (group){
					data[data.length-1][1].push(row);
				} else {
					switch (row.childElementCount){
						case 0:
						case 1:
							continue;
						case 2:
							if (!rowspans)
								break;
							if (data.length > 1)
								data[data.length-1][1].push(row);
							continue;
						default:
							break;
					}
					var cell = row.children[th.cellIndex];
					var val = cell.innerText;
					if (localeCompare){
						// hack to handle formatted numbers with commas for thousand separtors
						var tmpNum = val.split(",");
						if (tmpNum.length > 1){
							tmpNum = Number(tmpNum.join(""));
							if (tmpNum !== NaN)
								val = String(tmpNum);
						}
					} else {
						switch (th.dataset.type){
							case "text":
								val = val.toLowerCase();
								break;
							case "numeric":
							case "number":
								switch (val){
									case "":
									case "-":
										val = -1;
										break;
									default:
										val = Number(val);
									break;
								}
								break;
						}
					}
					var _row = row;
					if (r === 0 &&
							theads.length > 1 &&
							tbody.previousElementSibling.nodeName === "THEAD" &&
							tbody.previousElementSibling.children.length){
						data.push([val, [tbody.previousElementSibling, row], tbody]);
						sortGroup = true;
					} else {
						data.push([val, [row]]);
					}

				}
			}
		}

		switch (th.dataset.type){
			case "text":
				data = data.sort(function(a,b){
					if (localeCompare){
						return a[0].localeCompare(b[0],"kn",{numeric:true});
					} else {
						if (a[0] < b[0])
							return -1;
						if (a[0] > b[0])
							return 1;
						return 0;
					}
				});
				break;
			case "numeric":
			case "number":
				data = data.sort(function(a,b){
					return a[0] - b[0];
				});
		}

		//console.log(data);
		if (th.dataset.dir === "asc")
			data.reverse();
		if (!sortGroup){
			for (r = 0; r < data.length; r++){
				for (var rr = 0; rr < data[r][1].length; rr++)
					tbody.appendChild(data[r][1][rr]);
			}
		} else {
			for (r = 0; r < data.length; r++){

				if (data[r].length === 3){
					var _rows = data[r];
					table.appendChild(_rows[1][0]); // thead
					table.appendChild(_rows[2]); // tbody
					var _tbody = _rows[2];
					for (var rr = 1; rr < _rows[1].length; rr++)
						_tbody.appendChild(_rows[1][rr]); // tr

				} else {
					for (var rr = 0; rr < data[r][1].length; rr++)
						table.appendChild(data[r][1][rr]);
				}
			}
		}
	}

	_tableSorter = function (ev){
		tableSorter(ev.target, 'text');
	};

	var sortTables = document.querySelectorAll('TABLE THEAD TR TH');
	for (var st = 0; st < sortTables.length; st++) {
		sortTables[st].addEventListener('click', _tableSorter);
	}

</script>