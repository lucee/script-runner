# Lucee Ant Script Runner

A simple js-223 script runner for Lucee cfml

## Usage

Default `ant` will run the `tests/index.cfm` file

You can specify:

- Lucee version  (default `5.3.8.184-SNAPSHOT` )
- Webroot  (default `tests/`)
- File to run (default `index.cfm`)
- any extra extensions (default ``)

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -Dwebroot="C:\work\lucee-docs" -Dexecute="import.cfm" -Dlucee.extensions=""`
