<cfscript>
	systemOutput( "Hello World, Lucee Script Engine Runner, Debugger", true );
	systemOutput( "#getCurrentTemplatePath()#", true );
	systemOutput( "", true );
	systemOutput( "--------- variables -------", true );
	loop collection=#variables# key="key" value="value"{
		systemOutput( "#key#=#serializeJson(value)#", true );
	}

	systemOutput( "", true );
	systemOutput( "--------- URL variables -------", true );
	loop collection=#url# key="key" value="value"{
		systemOutput( "url.#key#=#serializeJson(value)#", true );
	}

	systemOutput( "", true );
	systemOutput( "--------- System properties (lucee.*) -------", true );
	for ( p in server.system.properties ){
		if ( listFirst( p, "." ) eq "lucee" ){
			if ( p contains "password" or p contains "secret"){
				systemOutput( p & ": (not shown coz it's a password)", true );
			} else {
				systemOutput( p & ": " & server.system.properties[ p ], true );
			}
		}
	}

	systemOutput( "", true );
	systemOutput( "--------- Environment variables (lucee* && ant*) -------", true );
	for ( e in server.system.environment ){
		if ( left( e, 5 ) eq "lucee" || left( e, 3 ) eq "ant" ){
			if ( e contains "password" or e contains "secret" ){
				systemOutput( e & ": (not shown coz it's a password)", true );
			} else {
				systemOutput( e & ": " & server.system.environment[ e ], true );
			}
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