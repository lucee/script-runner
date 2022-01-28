<cfscript>
	systemOutput("Hello World, Lucee Script Engine Runner", true);
	systemOutput("#getCurrentTemplatePath()#", true);
	systemoutput("---------system properties (lucee.*)-------", true);
	for (p in server.system.properties){
		if ( listFirst(p, ".") eq "lucee")
			systemOutput(p & ": " & server.system.properties[p], true);
	}
	//systemoutput("---------env-------", true);
	//for (p in server.system.environment)
	//	systemOutput(p & ": " & server.system.environment[p], true);

	systemoutput("---------installed extensions-------", true);
	q_ext = extensionList();
	loop query="q_ext"{
		systemoutput("#q_ext.name#, #q_ext.version#", true);
	}
</cfscript>