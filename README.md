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
- **Note:** The script-runner always normalizes the webroot to an absolute path internally, regardless of whether you pass a relative or absolute path. All output and script execution will use this normalized absolute path.

### Basic Usage

Default `ant` will run the `sample/index.cfm` file

![image](https://user-images.githubusercontent.com/426404/122402355-b0dbf980-cf7d-11eb-8837-37dec47d0713.png)

### Parameters

#### Lucee Version

- `-DluceeVersion=` - Lucee version (default: `6.2.2.91`). Examples: `6.2.2.91`, `light-6.2.2.91`, `zero-6.2.2.91`
- `-DluceeVersionQuery=` - Query-based version (optional, overrides luceeVersion). Format: `(version)/(stable/rc/snapshot)/(jar/light/zero)`. Example: `5.4/stable/light`
- `-DluceeJar=` - Path to custom Lucee JAR (optional, overrides both luceeVersion and luceeVersionQuery). Example: `/full-path/to/lucee.jar`

#### Paths and Execution

- `-Dwebroot=` - Directory containing CFML code (default: `tests/`). On Windows, trailing backslashes (`\`) will be rejected with an error
- `-Dexecute=` - CFML script to run (default: `index.cfm`). Relative to webroot, no leading `/` needed
- `-DexecuteScriptByInclude=` - Use include instead of _internalRequest (default: false). Set to `true` to skip Application.cfc

#### Extensions and Configuration

- `-Dextensions=` - List of extension GUIDs to install (default: empty)
- `-DextensionDir=` - Directory containing manual extension files (`*.lex`) to install (default: empty)
- `-Dcompile=` - Compile all CFML under webroot (default: false). Set to `true` to enable
- `-DluceeCFConfig=` - Path to full .CFConfig.json file for additional Lucee configuration

#### Working Directory

Lucee deploys to a working directory, default is `temp/`. By default it clears the directory when it starts and finishes (unless it crashes and exits!).

- `-DpreCleanup=` - Clear Lucee working directory before starting (default: true). Set to `false` to preserve
- `-DpostCleanup=` - Clear Lucee working directory after finishing (default: true). Set to `false` to preserve
- `-DuniqueWorkingDir=` - Working directory mode:
  - `false` (default): Uses `temp/lucee`. One run at a time. Fast, but not for parallel jobs
  - `true`: Uses `temp-unique/{VERSION}-{TIMESTAMP}-{RANDOM}` (timestamp: `yyMMdd-HHmmss`). Enables concurrent execution
  - `/custom/path`: Uses your specified directory. You're on your own for cleanup and collisions

These options are good for inspecting after a run, or setting up the `/lucee-server/context` dir with `password.txt` or `.CFConfig.json`.

#### Debugging and Profiling

- `-Ddebugger=` - Enable Java debugger on port 5000 with suspend=y (default: false)
- `-DFlightRecording=` - Enable Java Flight Recorder profiling (default: false). Saves `.jfr` files to `logs/` directory
- `-DFlightRecordingFilename=` - Custom output path for JFR recording file
- `-DjfrExports=` - Add JFR module exports for Lucee JFR API access (default: false)

### Java Flight Recorder (JFR) Profiling

Enable JFR to capture detailed performance data during script execution:

- Java Flight Recorder `-DFlightRecording="true"` enables JFR profiling, saves .jfr files to `logs/` directory
- JFR module access `-DjfrExports="true"` adds `--add-exports` and `--add-opens` for `jdk.jfr` module (for Lucee JFR API access)
- Custom JFR filename `-DFlightRecordingFilename="/path/to/output.jfr"` specify custom output path for JFR recording

```bash
ant -DFlightRecording=true -Dwebroot="." -Dexecute="yourscript.cfm"
```

**What it does:**

- Creates JFR recording files in `logs/{timestamp}-j{java.version}.jfr`
- Captures CPU usage, memory allocation, garbage collection, thread activity
- Settings: disk=true, dumponexit=true, maxsize=1024m, maxage=1d, settings=profile, path-to-gc-roots=true, stackdepth=128

**Custom JFR output path:**

```bash
ant -DFlightRecording=true -DFlightRecordingFilename="D:/my-logs/custom.jfr" -Dwebroot="." -Dexecute="yourscript.cfm"
```

**JFR API access for Lucee:**

If you need Lucee to access JFR APIs directly (not just record), add the JFR module exports:

```bash
ant -DjfrExports=true -Dwebroot="." -Dexecute="yourscript.cfm"
```

This adds `--add-exports=jdk.jfr/jdk.jfr=ALL-UNNAMED` and `--add-opens=jdk.jfr/jdk.jfr=ALL-UNNAMED` to allow Lucee code to use the JFR API.

**Analyzing JFR files:**

```bash
# Print summary
jfr print logs/250101-120530-j21.jfr

# Print specific events
jfr print --events CPULoad,GarbageCollection logs/250101-120530-j21.jfr

# Convert to JSON
jfr print --json logs/250101-120530-j21.jfr > output.json
```

The `jfr` command-line tool is included in the JDK bin directory. For visual analysis, use JDK Mission Control (JMC) or import into profiling tools.

### TL;DR: Quoting & Paths (Stop Overthinking It)

**If your path has spaces, use quotes. If not, don’t.**

**Quick Reference:**

| Shell          | Example Command                                                                                                   |
|--------------- |------------------------------------------------------------------------------------------------------------------|
| PowerShell     | `ant -buildfile "C:\tools\script-runner\build.xml" -Dwebroot="C:\work\my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true` |
| Command Prompt | `ant -buildfile=C:\tools\script-runner\build.xml -Dwebroot=C:\work\myproject -Dexecute=test.cfm -DuniqueWorkingDir=true`        |
| Bash/WSL       | `ant -buildfile /mnt/d/work/script-runner/build.xml -Dwebroot=/mnt/d/work/myproject -Dexecute=test.cfm -DuniqueWorkingDir=true`     |

**PowerShell:** Use double quotes for paths with spaces. Single quotes also work (especially in scripts to avoid variable expansion). Don’t mix and match.

**Command Prompt:** Quotes only if the path has spaces. You can quote just the value or the whole parameter (the latter is handy in batch files).

**Bash/WSL:** Use forward slashes. Quotes only if the path has spaces. Don’t use Windows backslashes or drive letters.

**Blunt Warnings:**
- Don’t use trailing backslashes on Windows. Ever.
- Don’t escape quotes unless you like pain.
- If Ant can’t find your file, your path or quotes are wrong. Period.

---

**Pro tip:** If you don’t know what you want, use `true` for CI or parallel runs, `false` for local dev.



**Command Prompt (Windows):**

Quotes are only needed if the path contains spaces. You can either quote just the value, or the entire parameter (both are valid). See the examples below:

- **No spaces in paths (no quotes needed):**

  ```cmd
  ant -buildfile=C:\tools\script-runner\build.xml -Dwebroot=C:\work\myproject -Dexecute=test.cfm -DuniqueWorkingDir=true
  ```

- **Spaces in paths (quotes required):**

  ```cmd
  ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="C:\work\my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true

  REM Or quote the entire parameter (especially useful in batch files):
  ant "-buildfile=C:\Program Files\script-runner\build.xml" "-Dwebroot=C:\My Projects\test" -Dexecute=test.cfm
  ```

**Bash/WSL (Linux):**

- Use forward slashes and Linux-style paths.

Quotes are only needed if the path contains spaces. See the two examples below:

- **No spaces in paths (no quotes needed):**

  ```bash
  ant -buildfile /mnt/d/work/script-runner/build.xml -Dwebroot=/mnt/d/work/myproject -Dexecute=test.cfm -DuniqueWorkingDir=true
  ```

- **Spaces in paths (quotes required):**

  ```bash
  ant -buildfile "/mnt/d/work/script-runner/build.xml" -Dwebroot="/mnt/d/work/my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true
  ```

**Quick Reference Table:**

| Shell          | Example Command                                                                                                   |
|--------------- |------------------------------------------------------------------------------------------------------------------|
| PowerShell     | `ant -buildfile "C:\tools\script-runner\build.xml" -Dwebroot="C:\work\my project" -Dexecute="test.cfm" -DuniqueWorkingDir=true` |
| Command Prompt | `ant -buildfile=C:\tools\script-runner\build.xml -Dwebroot=C:\work\myproject -Dexecute=test.cfm -DuniqueWorkingDir=true`        |
| Bash/WSL       | `ant -buildfile /mnt/d/work/script-runner/build.xml -Dwebroot=/mnt/d/work/myproject -Dexecute=test.cfm -DuniqueWorkingDir=true`     |

---

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

- Creates unique directories: `temp-unique/{VERSION}-{TIMESTAMP}-{RANDOM}` (timestamp format: `yyMMdd-HHmmss`)
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
ant -DuniqueWorkingDir=true          # Uses: temp-unique/6.2.2.91-250913-142530-123
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

Each instance will use a unique working directory named `temp-unique/{VERSION}-{TIMESTAMP}-{RANDOM}` (timestamp format: `yyMMdd-HHmmss`) to prevent conflicts.

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

**Problem**: "Could not locate build file" from other directories
**Solution**: Use absolute path to build.xml:

```bash
# ✅ Correct - specify script-runner location
ant -buildfile="C:\tools\script-runner\build.xml" -Dwebroot="." -Dexecute="test.cfm"

# ❌ Wrong - looking for build.xml in current directory
ant -Dwebroot="." -Dexecute="/test.cfm"

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
# ✅ Correct - Windows Command Prompt (no quotes needed for paths without spaces)
ant -buildfile=d:\work\script-runner\build.xml -Dwebroot=D:\work\project -Dexecute=test.cfm

# ✅ Correct - Windows with spaces in paths (use quotes around entire parameter)
ant "-buildfile=C:\Program Files\script-runner\build.xml" "-Dwebroot=C:\My Projects\test" -Dexecute=test.cfm

# ✅ Correct - PowerShell (use single quotes to avoid variable expansion)
ant -buildfile='d:\work\script-runner\build.xml' -Dwebroot='D:\work\project' -Dexecute='test.cfm'

# ❌ Wrong - excessive escaping or nested quotes
ant -buildfile=\"d:\work\script-runner\" -Dwebroot=\"D:\work\project\"

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

[GitHub Action Workflow Example](https://github.com/lucee/extension-pdf/blob/master/.github/workflows/main.yml)

This will do the following steps

- checkout a copy of the Lucee Code base
- install any extension(s) (`*.lex`) found in `${{ github.workspace }}/dist`
- run all tests with the label of "pdf"
- run any additional tests found in the `/tests` directory of the current repository

## As a BitBucket Pipeline

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
          - ant -buildfile script-runner/build.xml -DluceeVersion="light-6.2.2.91" -Dwebroot="$BITBUCKET_CLONE_DIR/lucee/test" -DextensionDir="$BITBUCKET_CLONE_DIR/dist" -Dexecute="bootstrap-tests.cfm" -DtestAdditional="$BITBUCKET_CLONE_DIR/tests"
```
