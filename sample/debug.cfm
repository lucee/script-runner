<cfscript>

	function safelyReportVar( name, value ){
		if ( arguments.name contains "password" or arguments.name contains "secret" or arguments.name contains "token"){
			systemOutput( arguments.name & ": (not shown coz it's a password/secret/token)", true );
		} else {
			systemOutput( arguments.name & ": " & arguments.value, true );
		}
	}

	systemOutput( "Hello World, Lucee Script Engine Runner, Debugger", true );
	systemOutput( "#getCurrentTemplatePath()#", true );
	systemOutput( "", true );
	systemOutput( "--------- variables -------", true );

	loop collection=#variables# key="key" value="value"{
		if ( isSimpleValue( value ) )
			safelyReportVar( key, serializeJson( value ) );
	}

	systemOutput( "", true );
	systemOutput( "--------- URL variables -------", true );
	loop collection=#url# key="key" value="value"{
		safelyReportVar( key, serializeJson( value ) );
	}

	systemOutput( "", true );
	systemOutput( "--------- System properties (lucee.*) -------", true );
	for ( p in server.system.properties ){
		if ( listFirst( p, "." ) eq "lucee" ){
			safelyReportVar( p, server.system.properties[ p ] );
		}
	}

	systemOutput( "", true );
	systemOutput( "--------- Environment variables (lucee*,github*) -------", true );
	for ( e in server.system.environment ){
		if ( left( e, 5 ) eq "lucee" or left( e, 6 ) eq "github" ){
			safelyReportVar( e, server.system.environment[ e ] );
		}
	}

	systemOutput( "", true );
	systemOutput( "--------- Installed Extensions -------", true );
	q_ext = extensionList();
	loop query="q_ext"{
		systemOutput( "#q_ext.name#, #q_ext.version#", true );
	}

	systemOutput( "", true );
	systemOutput( "--------- Directories -------", true );
	q_ext = extensionList();
	loop list="{lucee-web},{lucee-server},{lucee-config},{temp-directory},{home-directory},{web-root-directory},{system-directory},{web-context-hash},{web-context-label}"
		item="dir" {
		systemOutput( "#dir#, #expandPath(dir)#", true );
	}

	systemOutput( "", true );
	systemOutput( "--------- context cfcs -------", true );

	cfcs = directoryList(path=expandPath("{lucee-server}"), recurse=true, filter="*.cfc");
	for (c in cfcs){
		systemOutput(c, true );
	}

	systemOutput( "", true );

</cfscript>