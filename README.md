# Lucee Ant Script Runner

Quickly run Lucee cfml applications headless (without a http server) via the command line

[![CI](https://github.com/lucee/script-runner/actions/workflows/main.yml/badge.svg)](https://github.com/lucee/script-runner/actions/workflows/main.yml)

Please report any issues, etc in the [Lucee Issue Tracker](https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22script-runner%22)

## Command line Usage

Default `ant` will run the `sample/index.cfm` file

![image](https://user-images.githubusercontent.com/426404/122402355-b0dbf980-cf7d-11eb-8837-37dec47d0713.png)

You can specify:

- Lucee version `-DluceeVersion=` (default `5.4.2.17` )
- Lucee version by query `-DluceeVersionQuery="5.4/stable/light`
- Webroot `-Dwebroot=`  (default `tests/`)
- CFML Script to run, `-Dexecute=` (default `/index.cfm`)
- run script via include or _internalRequest (which runs the Application.cfc if present, default ) `-DexecuteScriptByInclude="true"`
- any extra extensions `-Dextensions=` (default ``)
- manual extension install (`*.lex`) from a directory `-DextensionDir=` (default ``)
- compile all cfml under webroot `-Dcompile="true"`
- pass in a .CFconfig.json `-DluceeCFconfig="/path/to/.CFconfig.json`
- use a java debugger `-Ddebugger="true"` opens a java debugging port 5000, with suspend=y

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -Dwebroot="C:\work\lucee-docs" -Dexecute="import.cfm" -Dlucee.extensions=""`

`ant -DluceeVersion="6.0.0.95-SNAPSHOT" -DextensionDir="C:\work\lucee-extensions\extension-hibernate\dist"`

If no webroot is specfied, you can run the provided debug script, to see which extensions are available and all the env / sys properties

`ant -buildfile="C:\work\script-runner" -Dexecute="/debug.cfm"`

`ant -buildfile="C:\work\script-runner" -Dexecute="/debug.cfm" -DluceeVersion="light-6.0.0.95-SNAPSHOT"` (`light` has no bundled extensions, `zero` has no extension or admin)

## As a GitHub Action

To use as a GitHub Action, to run the PDF tests after building the PDF Extension, just add the following yaml

```
    - name: Checkout Lucee
      uses: actions/checkout@v2
      with:
        repository: lucee/lucee
        path: lucee
    - name: Cache Maven packages
      uses: actions/cache@v3
      with:
        path: ~/.m2
        key: lucee-script-runner-maven-cache
    - name: Cache Lucee files
      uses: actions/cache@v3
      with:
        path: _actions/lucee/script-runner/main/lucee-download-cache
        key: lucee-downloads
    - name: Run Lucee Test Suite
      uses: lucee/script-runner@main
      with:
        webroot: ${{ github.workspace }}/lucee/test
        execute: /bootstrap-tests.cfm
        luceeVersion: ${{ env.luceeVersion }} (ie. 6.3.0.1, light-6.3.0.1, zero-6.3.0.1)
        luceeVersionQuery: 5.4/stable/light (optional, overrides luceeVersion. (version)/(stable/rc/snapshot)/(jar,light/zero) )
        extensions: (optional list of extension guids to install)
        extensionDir: ${{ github.workspace }}/dist (for testing building an extension with CI)
        antFlags: -d or -v etc (optional, good for debugging any ant issues)
        compile: true (optional, compiles all the cfml under the webroot)
        luceeCFconfig: /path/to/.CFconfig.json pass in additional configuration
        debugger: true (optional) runs with java debugging enabled on port 5000
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

## As a BitBucket Pipeline

```
image: atlassian/default-image:3

pipelines:
  default:
    - step:
        name: Build and Test
        caches:
          - maven
        script:
          - ant -noinput -verbose -buildfile build.xml
        artifacts:
          - dist/**
    - step:
        name: Checkout Lucee Script-runner, Lucee and run tests
        script:
          - git clone https://github.com/lucee/script-runner
          - git clone https://github.com/lucee/lucee
          - export testLabels="PDF"
          - echo $testLabels
          - ant -buildfile script-runner/build.xml -DluceeVersion="light-6.0.0.152-SNAPSHOT" -Dwebroot="$BITBUCKET_CLONE_DIR/lucee/test" -DextensionDir="$BITBUCKET_CLONE_DIR/dist" -Dexecute="/bootstrap-tests.cfm" -DtestAdditional="$BITBUCKET_CLONE_DIR/tests"
```
