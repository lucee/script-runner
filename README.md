# Lucee Ant Script Runner

A simple js-223 script runner for Lucee cfml

[![CI](https://github.com/lucee/script-runner/actions/workflows/main.yml/badge.svg)](https://github.com/lucee/script-runner/actions/workflows/main.yml)

Please report any issues, etc in the [Lucee Issue Tracker](https://luceeserver.atlassian.net/)

## Command line Usage

Default `ant` will run the `sample/index.cfm` file

![image](https://user-images.githubusercontent.com/426404/122402355-b0dbf980-cf7d-11eb-8837-37dec47d0713.png)

You can specify:

- Lucee version `-DluceeVersion=` (default `5.3.8.189` )
- Webroot `-Dwebroot=`  (default `tests/`)
- File to run, `-Dexecute=` (default `index.cfm`)
- any extra extensions `-Dextensions=` (default ``)
- manual extension install from a directory `-DextensionDir=` (default ``)

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -Dwebroot="C:\work\lucee-docs" -Dexecute="import.cfm" -Dlucee.extensions=""`

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -DextensionDir="C:\work\lucee-extensions\extension-hibernate\dist"`

## As a GitHub Action

To use as a GitHub Action, to run the PDF tests after building the PDF Extension, just add the following yaml 

```
    - name: Checkout Lucee
      uses: actions/checkout@v2
      with:
        repository: lucee/lucee
        path: lucee
    - name: Run Lucee Test Suite
      uses: lucee/script-runner@main
      with:
        webroot: ${{ github.workspace }}/lucee/test
        execute: /bootstrap-tests.cfm
        luceeVersion: ${{ env.luceeVersion }}
        extensionDir: ${{ github.workspace }}/dist
      env:
        testLabels: pdf
        testAdditional: ${{ github.workspace }}/tests
```

https://github.com/lucee/extension-pdf/blob/master/.github/workflows/main.yml

This will do the following steps

- checkout a copy of the Lucee Code base
- install any extension(s) (`*.lex`) found in `${{ github.workspace }}/dist`
- run all tests with the label of "pdf"
- run any additional tests found in the `/tests` directory of the current repository
