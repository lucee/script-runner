# Lucee Ant Script Runner

A simple js-223 script runner for Lucee cfml

## Usage

Default `ant` will run the `sample/index.cfm` file

![image](https://user-images.githubusercontent.com/426404/122402355-b0dbf980-cf7d-11eb-8837-37dec47d0713.png)

You can specify:

- Lucee version  (default `5.3.8.184-SNAPSHOT` )
- Webroot  (default `tests/`)
- File to run (default `index.cfm`)
- any extra extensions (default ``)

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -Dwebroot="C:\work\lucee-docs" -Dexecute="import.cfm" -Dlucee.extensions=""`


