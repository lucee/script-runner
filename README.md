# Lucee Ant Script Runner

A simple js-223 script runner for Lucee cfml

[![CI](https://github.com/zspitzer/lucee-script-engine-runner/actions/workflows/main.yml/badge.svg)](https://github.com/zspitzer/lucee-script-engine-runner/actions/workflows/main.yml)

## Usage

Default `ant` will run the `sample/index.cfm` file

![image](https://user-images.githubusercontent.com/426404/122402355-b0dbf980-cf7d-11eb-8837-37dec47d0713.png)

You can specify:

- Lucee version `-DluceeVersion=` (default `5.3.8.184-SNAPSHOT` )
- Webroot `-Dwebroot=`  (default `tests/`)
- File to run, `-Dexecute=` (default `index.cfm`)
- any extra extensions `-Dextensions=` (default ``)
- manual extension install from a directory `-DextensionDir=` (default ``)

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -Dwebroot="C:\work\lucee-docs" -Dexecute="import.cfm" -Dlucee.extensions=""`

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -DextensionDir="C:\work\lucee-extensions\extension-hibernate\dist"`
