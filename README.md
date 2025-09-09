# Lucee Ant Script Runner

Quickly run Lucee CFML applications headless (without a HTTP server) via the command line

[![CI](https://github.com/lucee/script-runner/actions/workflows/main.yml/badge.svg)](https://github.com/lucee/script-runner/actions/workflows/main.yml)

Please report any issues, etc in the [Lucee Issue Tracker](https://luceeserver.atlassian.net/issues/?jql=labels%20%3D%20%22script-runner%22)

## Project Structure

- `build.xml` - Main build file (always use this)
- `build-run-cfml.xml` - Internal file (do not run directly)
- `action.yml` - GitHub Action configuration
- `sample/` - Example CFML files for testing

## Command line Usage

### Running from Different Directories

The script-runner can be used from any directory by specifying the build file location:

```bash
# From the script-runner directory (simple)
ant -Dwebroot="/path/to/your/project" -Dexecute="yourscript.cfm"

# From your project directory (recommended for external projects)
ant -buildfile="/path/to/script-runner/build.xml" -Dwebroot="." -Dexecute="yourscript.cfm"

# From any directory with absolute paths
ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="C:\work\myproject" -Dexecute="test.cfm"

# execute a script below the webroot
ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="C:\work\myproject" -Dexecute="extended/index.cfm"
```

**Key Points:**
- `-buildfile` specifies where script-runner is installed
- `-Dwebroot` is the directory containing your CFML code (can be relative to current directory)
- `-Dexecute` is the CFML script to run (relative to webroot)

### Basic Usage

Default `ant` will run the `sample/index.cfm` file

![image](https://user-images.githubusercontent.com/426404/122402355-b0dbf980-cf7d-11eb-8837-37dec47d0713.png)

You can specify:

- Lucee version `-DluceeVersion=` default `6.2.2.91`, (ie. 6.2.2.91, light-6.2.2.91, zero-6.2.2.91 )
- Lucee version by query `-DluceeVersionQuery="5.4/stable/light` ( optional overrides luceeVersion, (version)/(stable/rc/snapshot)/(jar,light/zero) )
- Local Lucee JAR `-DluceeJar="/full-path/to/lucee.jar"` (optional, overrides both luceeVersion and luceeVersionQuery, perfect for testing locally built JARs)
- Webroot `-Dwebroot=`  (default `tests/`) on Windows, avoid a trailing \ as that is treated as an escape character causes script runner to fail
- CFML Script to run, `-Dexecute=` (default `index.cfm`) a relative path the webroot, no leading `/` is needed, some bash shells like git bash on windows get's confused and tries to expand that to a full path
- run script via include or _internalRequest (which runs the Application.cfc if present, default ) `-DexecuteScriptByInclude="true"`
- any extra extensions `-Dextensions=` (default ``)
- manual extension install (`*.lex`) from a directory `-DextensionDir=` (default ``)
- compile all cfml under webroot `-Dcompile="true"`
- pass in a full .CFConfig.json file `-DluceeCFConfig="/path/to/.CFConfig.json`
- use a java debugger `-Ddebugger="true"` opens a java debugging port 5000, with suspend=y
- preCleanup `-DpreCleanup="true"` purges the Lucee working dir before starting
- postCleanup `-DpostCleanup="true"` purges the Lucee working dir after finishing
- uniqueWorkingDir `-DuniqueWorkingDir=` supports three modes:
  - `"false"` (default): Uses standard `temp/lucee` directory
  - `"true"`: Auto-generates unique directory `temp-unique/lucee-{VERSION}-{TIMESTAMP}-{RANDOM}`
  - `"/custom/path"`: Uses specified custom directory path

`ant -DluceeVersion="6.2.2.91" -Dwebroot="C:\work\lucee-docs" -Dexecute="import.cfm" -Dlucee.extensions=""`

`ant -DluceeVersion="6.2.2.91" -DextensionDir="C:\work\lucee-extensions\extension-hibernate\dist"`

### Quick Reference Examples

```bash
# Testing Lucee Spreadsheet from its directory
cd D:\work\lucee-spreadsheet
ant -buildfile=D:\work\script-runner\build.xml -Dwebroot=. -Dexecute=/test/index.cfm

# Testing with specific Lucee version
ant -buildfile=D:\work\script-runner\build.xml -DluceeVersionQuery=6.2/stable/jar -Dwebroot=D:\work\lucee-spreadsheet -Dexecute=/test/index.cfm

# Testing with a locally built Lucee JAR (for Lucee developers)
ant -buildfile=D:\work\script-runner\build.xml -DluceeJar="D:\work\lucee\loader\target\lucee.jar" -Dwebroot=D:\work\lucee-spreadsheet -Dexecute=/test/index.cfm

# With unique working directory for concurrent runs
ant -buildfile=D:\work\script-runner\build.xml -DuniqueWorkingDir=true -Dwebroot=D:\work\lucee-spreadsheet -Dexecute=/test/index.cfm
```

### Working Directory Behavior

**Default Mode** (`uniqueWorkingDir=false` or not specified):
- Uses a consistent local `temp/lucee` directory relative to script-runner location
- Same directory is reused across runs (cleaned with `preCleanup`/`postCleanup`)
- **Ideal for CI/CD**: Predictable location, faster subsequent runs due to caching
- **Single instance only**: Cannot run multiple concurrent instances

**Auto-Unique Mode** (`uniqueWorkingDir=true`):
- Creates unique directories: `temp-unique/lucee-{VERSION}-{TIMESTAMP}-{RANDOM}`
- Each run gets its own isolated working directory
- **Enables concurrent execution**: Multiple instances can run simultaneously
- **Useful for**: Parallel testing, concurrent builds, isolation requirements

**Custom Path Mode** (`uniqueWorkingDir=/custom/path`):
- Uses your specified directory as the working directory
- Full control over location (e.g., RAM disk, specific drive, shared folder)
- **Race protection**: Still checks for existing directory to prevent conflicts
- **Useful for**: Custom environments, performance optimization, specific storage requirements

```bash
# Examples of the three modes:
ant -DuniqueWorkingDir=false         # Uses: temp/lucee
ant -DuniqueWorkingDir=true          # Uses: temp-unique/lucee-6.2.2.91-20250908-090047-669
ant -DuniqueWorkingDir=C:/fast/work  # Uses: C:/fast/work
```

### Concurrent Execution

Multiple script-runner instances can be run simultaneously using unique working directories:

```bash
# Run multiple instances concurrently
ant -DuniqueWorkingDir="true" -Dexecute="test1.cfm" &
ant -DuniqueWorkingDir="true" -Dexecute="test2.cfm" &
ant -DuniqueWorkingDir="true" -Dexecute="test3.cfm" &
wait
```

Each instance will use a unique working directory named `temp-unique/lucee-{VERSION}-{TIMESTAMP}-{RANDOM}` to prevent conflicts.

## Writing Output in Headless Mode

When running CFML scripts in headless mode (without a web server), you should use `systemOutput()` instead of `writeOutput()` to see output in the console:

```cfm
// ✅ Correct - outputs to console in headless mode
systemOutput("Processing started...", true);  // true adds newline
systemOutput("Item #i# processed", true);

// ❌ Wrong - writeOutput() won't display in console
writeOutput("This won't be visible");

// For debugging, you can also use:
systemOutput(serializeJSON(myData, "struct"), true);
```

**Key Points:**
- `systemOutput()` writes directly to the console (stdout)
- `writeOutput()` is for HTTP response output and won't show in headless mode
- The second parameter `true` adds a newline after the output
- Use `systemOutput()` for progress updates, debugging, and results

## Troubleshooting

### Common Issues on Windows

**Problem**: Build fails with path-related errors
**Solution**: Avoid trailing backslashes in webroot paths:
```bash
# ❌ Wrong - trailing backslash causes escape issues
ant -Dwebroot="C:\work\myproject\"

# ✅ Correct - no trailing backslash
ant -Dwebroot="C:\work\myproject"
ant -Dwebroot="C:/work/myproject/"  # Forward slashes work too
```

**Problem**: "Could not locate build file" from other directories
**Solution**: Use absolute path to build.xml:
```bash
# ❌ Wrong - looking for build.xml in current directory
ant -Dwebroot="." -Dexecute="/test.cfm"

# ✅ Correct - specify script-runner location
ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="." -Dexecute="test.cfm"
```

**Problem**: "File not found" for CFML scripts
**Solution**: Check webroot and execute paths:
```bash
# Verify your paths - execute is relative to webroot
ant -buildfile="/path/to/script-runner/build.xml" -Dwebroot="/your/project" -Dexecute="debug.cfm"
```

**Problem**: "No shell found" or quote/escape errors on Windows
**Solution**: Use proper quote formatting for Windows command line:
```bash
# ❌ Wrong - excessive escaping or nested quotes
ant -buildfile=\"d:\work\script-runner\" -Dwebroot=\"D:\work\project\"

# ✅ Correct - Windows Command Prompt (no quotes needed for paths without spaces)
ant -buildfile=d:\work\script-runner\build.xml -Dwebroot=D:\work\project -Dexecute=test.cfm

# ✅ Correct - Windows with spaces in paths (use quotes around entire parameter)
ant "-buildfile=C:\Program Files\script-runner\build.xml" "-Dwebroot=C:\My Projects\test" -Dexecute=test.cfm

# ✅ Correct - PowerShell (use single quotes to avoid variable expansion)
ant -buildfile='d:\work\script-runner\build.xml' -Dwebroot='D:\work\project' -Dexecute='test.cfm'
```

**Important Windows Tips:**
- When using `-buildfile` with a directory, add `\build.xml` explicitly
- Avoid escaped quotes (`\"`) - they're usually not needed
- Use forward slashes (`/`) or double backslashes (`\\`) in scripts to avoid escape issues
- In batch files, use `%%` instead of `%` for variables

If no webroot is specfied, you can run the provided debug script, to see which extensions are available and all the env / sys properties

`ant -buildfile="C:\work\script-runner" -Dexecute="debug.cfm"`

`ant -buildfile="C:\work\script-runner" -Dexecute="debug.cfm" -DluceeVersion="light-6.2.2.91"` (`light` has no bundled extensions, `zero` has no extension or admin)

## As a GitHub Action

To use as a GitHub Action, to run the PDF tests after building the PDF Extension, just add the following YAML

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
        execute: bootstrap-tests.cfm
        luceeVersion: ${{ env.luceeVersion }}
        luceeVersionQuery: 5.4/stable/light (optional, overrides luceeVersion )
        luceeJar: /path/to/local/lucee.jar (optional, overrides both luceeVersion and luceeVersionQuery)
        extensions: (optional list of extension guids to install)
        extensionDir: ${{ github.workspace }}/dist (for testing building an extension with CI)
        antFlags: -d or -v etc (optional, good for debugging any ant issues)
        compile: true (optional, compiles all the cfml under the webroot)
        luceeCFConfig: /path/to/.CFConfig.json pass in additional configuration
        debugger: true (optional) runs with java debugging enabled on port 5000
        preCleanup: true (purges Lucee working directory before starting)
        postCleanup: true (purges Lucee working directory after finishing)
        uniqueWorkingDir: true (optional) uses unique working directory for concurrent execution
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
          - ant -buildfile script-runner/build.xml -DluceeVersion="light-6.2.2.91" -Dwebroot="$BITBUCKET_CLONE_DIR/lucee/test" -DextensionDir="$BITBUCKET_CLONE_DIR/dist" -Dexecute="bootstrap-tests.cfm" -DtestAdditional="$BITBUCKET_CLONE_DIR/tests"
```
