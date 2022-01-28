<cfscript>
	systemOutput("Hello World, Lucee Script Engine Runner, Debugger", true);
	systemOutput("#getCurrentTemplatePath()#", true);
	systemoutput("--------- System properties (lucee.*) -------", true);
	for ( p in server.system.properties ){
		if ( listFirst( p, "." ) eq "lucee" ){
			if (p contains "password"){
				systemOutput( p & ": (not shown coz it's a password)", true);
			} else {
				systemOutput( p & ": " & server.system.properties[p], true);
			}
		}
	}
	systemoutput("--------- Environment variables (lucee*) -------", true);
	for ( e in server.system.environment ){
		if ( left( e, 5 ) eq "lucee"){
			if ( e contains "password" ){
				systemOutput( e & ": (not shown coz it's a password)", true);
			} else {
				systemOutput( e & ": " & server.system.environment[e], true);
			}
		}
	}

	systemoutput("--------- Installed Extensions -------", true);
	q_ext = extensionList();
	loop query="q_ext"{
		systemoutput("#q_ext.name#, #q_ext.version#", true);
	}
</cfscript>