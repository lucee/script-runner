<cfscript>
	// .CFConfig.json here sets the timezone, CI passes a copy via the LUCEE_BASE_CONFIG env var (Lucee writes its config back to that file)
	tz = getTimeZone();
	systemOutput( "timezone [#tz#]", true );
	if ( tz != "Pacific/Chatham" )
		throw( message="LUCEE_BASE_CONFIG wasn't applied, timezone is [#tz#], expected [Pacific/Chatham]" );
</cfscript>
