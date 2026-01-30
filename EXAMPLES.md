# Script Runner Examples

Practical examples and use cases for the Lucee Script Runner.

## Table of Contents

- [Quick Start Examples](#quick-start-examples)
- [Shell-Specific Usage](#shell-specific-usage)
- [Java Flight Recorder (JFR) Profiling](#java-flight-recorder-jfr-profiling)
- [Concurrent Execution](#concurrent-execution)
- [Working Directory Examples](#working-directory-examples)
- [Testing Extensions](#testing-extensions)
- [CI/CD Integration](#cicd-integration)

## Quick Start Examples

### Running from Different Locations

```bash
# From the script-runner directory (simple)
ant -Dwebroot="/path/to/your/project" -Dexecute="yourscript.cfm"

# From your project directory (recommended for external projects)
ant -buildfile="/path/to/script-runner/build.xml" -Dwebroot="." -Dexecute="yourscript.cfm"

# From any directory with absolute paths
ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="C:\work\myproject" -Dexecute="test.cfm"

# Execute a script below the webroot
ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="C:\work\myproject" -Dexecute="extended/index.cfm"
```

### Testing Lucee Extensions

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

## Shell-Specific Usage

### PowerShell

Use double quotes for paths with spaces. Single quotes also work (especially in scripts to avoid variable expansion).

```powershell
# No spaces in paths
ant -buildfile "C:\tools\script-runner\build.xml" -Dwebroot="C:\work\myproject" -Dexecute="test.cfm"

# Paths with spaces
ant -buildfile "C:\tools\script-runner\build.xml" -Dwebroot="C:\work\my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true

# Using single quotes to avoid variable expansion in scripts
ant -buildfile='C:\tools\script-runner\build.xml' -Dwebroot='C:\work\project' -Dexecute='test.cfm'
```

### Command Prompt (Windows)

Quotes are only needed if the path contains spaces. You can quote just the value or the entire parameter.

```cmd
REM No spaces in paths (no quotes needed)
ant -buildfile=C:\tools\script-runner\build.xml -Dwebroot=C:\work\myproject -Dexecute=test.cfm -DuniqueWorkingDir=true

REM Spaces in paths (quotes required)
ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="C:\work\my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true

REM Or quote the entire parameter (especially useful in batch files)
ant "-buildfile=C:\Program Files\script-runner\build.xml" "-Dwebroot=C:\My Projects\test" -Dexecute=test.cfm
```

### Bash/WSL (Linux)

Use forward slashes and Linux-style paths. Quotes only if the path has spaces.

```bash
# No spaces in paths (no quotes needed)
ant -buildfile /mnt/d/work/script-runner/build.xml -Dwebroot=/mnt/d/work/myproject -Dexecute=test.cfm -DuniqueWorkingDir=true

# Spaces in paths (quotes required)
ant -buildfile "/mnt/d/work/script-runner/build.xml" -Dwebroot="/mnt/d/work/my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true
```

### Quick Reference Table

| Shell          | Example Command                                                                                                   |
|--------------- |------------------------------------------------------------------------------------------------------------------|
| PowerShell     | `ant -buildfile "C:\tools\script-runner\build.xml" -Dwebroot="C:\work\my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true` |
| Command Prompt | `ant -buildfile=C:\tools\script-runner\build.xml -Dwebroot=C:\work\myproject -Dexecute=test.cfm -DuniqueWorkingDir=true`        |
| Bash/WSL       | `ant -buildfile /mnt/d/work/script-runner/build.xml -Dwebroot=/mnt/d/work/myproject -Dexecute=test.cfm -DuniqueWorkingDir=true`     |

**Key Points:**

- **PowerShell:** Use double quotes for paths with spaces. Single quotes work too (good for avoiding variable expansion)
- **Command Prompt:** Quotes only if path has spaces. Can quote just the value or the whole parameter
- **Bash/WSL:** Use forward slashes. Quotes only if path has spaces. Don't use Windows backslashes or drive letters
- **Windows:** Never use trailing backslashes. Ever.
- **All shells:** Don't escape quotes unless you like pain
- **Debugging:** If Ant can't find your file, your path or quotes are wrong. Period.

## Java Flight Recorder (JFR) Profiling

Enable JFR to capture detailed performance data during script execution.

### Basic JFR Usage

```bash
ant -DFlightRecording=true -Dwebroot="." -Dexecute="yourscript.cfm"
```

### What JFR Captures

- Creates JFR recording files in `logs/{timestamp}-j{java.version}.jfr`
- Captures CPU usage, memory allocation, garbage collection, thread activity
- Settings: disk=true, dumponexit=true, maxsize=1024m, maxage=1d, settings=profile, path-to-gc-roots=true, stackdepth=128

### Custom JFR Output Path

```bash
ant -DFlightRecording=true -DFlightRecordingFilename="D:/my-logs/custom.jfr" -Dwebroot="." -Dexecute="yourscript.cfm"
```

### JFR API Access for Lucee

If you need Lucee to access JFR APIs directly (not just record), add the JFR module exports:

```bash
ant -DjfrExports=true -Dwebroot="." -Dexecute="yourscript.cfm"
```

This adds `--add-exports=jdk.jfr/jdk.jfr=ALL-UNNAMED` and `--add-opens=jdk.jfr/jdk.jfr=ALL-UNNAMED` to allow Lucee code to use the JFR API.

### Analyzing JFR Files

```bash
# Print summary
jfr print logs/250101-120530-j21.jfr

# Print specific events
jfr print --events CPULoad,GarbageCollection logs/250101-120530-j21.jfr

# Convert to JSON
jfr print --json logs/250101-120530-j21.jfr > output.json
```

The `jfr` command-line tool is included in the JDK bin directory. For visual analysis, use JDK Mission Control (JMC) or import into profiling tools.

## Concurrent Execution

Multiple script-runner instances can be run simultaneously using unique working directories.

### Running Tests in Parallel

```bash
# Run multiple instances concurrently
ant -DuniqueWorkingDir="true" -Dexecute="test1.cfm" &
ant -DuniqueWorkingDir="true" -Dexecute="test2.cfm" &
ant -DuniqueWorkingDir="true" -Dexecute="test3.cfm" &
wait
```

Each instance will use a unique working directory named `temp-unique/{VERSION}-{TIMESTAMP}-{RANDOM}` (timestamp format: `yyMMdd-HHmmss`) to prevent conflicts.

## Working Directory Examples

### Default Mode (Single Instance)

```bash
# Uses temp/lucee - fast, but single instance only
ant -DuniqueWorkingDir=false -Dwebroot=. -Dexecute=test.cfm
```

### Auto-Unique Mode (Concurrent Execution)

```bash
# Uses temp-unique/{VERSION}-{TIMESTAMP}-{RANDOM}
ant -DuniqueWorkingDir=true -Dwebroot=. -Dexecute=test.cfm
```

### Custom Path Mode

```bash
# Uses your specified directory
ant -DuniqueWorkingDir=C:/fast/work -Dwebroot=. -Dexecute=test.cfm
```

### Preserving Working Directory for Inspection

```bash
# Don't cleanup before or after - useful for debugging
ant -DpreCleanup=false -DpostCleanup=false -Dwebroot=. -Dexecute=test.cfm
```

## Testing Extensions

### Testing a Built Extension

```bash
# Install extension from dist/ directory and run tests
ant -buildfile=script-runner/build.xml \
    -DluceeVersion="7.0.1.100" \
    -Dwebroot="$BITBUCKET_CLONE_DIR/lucee/test" \
    -DextensionDir="$BITBUCKET_CLONE_DIR/dist" \
    -Dexecute="bootstrap-tests.cfm" \
    -DtestAdditional="$BITBUCKET_CLONE_DIR/tests"
```

### Testing with Debug Mode

```bash
# Enable Java debugger on port 5000
ant -Ddebugger=true -Dwebroot=. -Dexecute=test.cfm
```

Then connect your IDE debugger to `localhost:5000`.

## CI/CD Integration

### GitHub Actions

```yaml
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
    luceeVersionQuery: 5.4/stable/light # (optional, overrides luceeVersion)
    luceeJar: /path/to/local/lucee.jar # (optional, overrides both luceeVersion and luceeVersionQuery)
    extensions: # (optional list of extension guids to install)
    extensionDir: ${{ github.workspace }}/dist # (for testing building an extension with CI)
    antFlags: -d or -v etc # (optional, good for debugging any ant issues)
    compile: true # (optional, compiles all the cfml under the webroot)
    luceeCFConfig: /path/to/.CFConfig.json # pass in additional configuration
    debugger: true # (optional) runs with java debugging enabled on port 5000
    preCleanup: true # (purges Lucee working directory before starting)
    postCleanup: true # (purges Lucee working directory after finishing)
    uniqueWorkingDir: true # (optional) uses unique working directory for concurrent execution
  env:
    testLabels: pdf
    testAdditional: ${{ github.workspace }}/tests
```

[GitHub Action Workflow Example](https://github.com/lucee/extension-pdf/blob/master/.github/workflows/main.yml)

This will:

- Checkout a copy of the Lucee codebase
- Install any extension(s) (`*.lex`) found in `${{ github.workspace }}/dist`
- Run all tests with the label of "pdf"
- Run any additional tests found in the `/tests` directory of the current repository

### BitBucket Pipeline

```yaml
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
          - ant -buildfile script-runner/build.xml -DluceeVersion="light-7.0.1.100" -Dwebroot="$BITBUCKET_CLONE_DIR/lucee/test" -DextensionDir="$BITBUCKET_CLONE_DIR/dist" -Dexecute="bootstrap-tests.cfm" -DtestAdditional="$BITBUCKET_CLONE_DIR/tests"
```
