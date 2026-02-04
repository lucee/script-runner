# Changelog

All notable changes to the Lucee Script Runner project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Local JAR Support**: Added `luceeJar` parameter to test locally built Lucee JARs without publishing
  - Accepts full path to a local JAR file
  - Overrides both `luceeVersion` and `luceeVersionQuery`
  - Perfect for Lucee core developers testing builds
- **Unique Working Directories**: Added `uniqueWorkingDir` parameter with three modes:
  - `false` (default): Uses standard temp/lucee directory
  - `true`: Auto-generates unique directory with timestamp and random ID
  - Custom path: Uses specified directory path
- **Concurrent Execution Support**: Multiple script-runner instances can now run simultaneously without conflicts
- **Race Condition Detection**: Automatic detection and prevention of directory conflicts
- **Improved JFR Logging**:
  - JFR files now output to organized `logs/` directory
  - Descriptive filenames: `timestamp-lucee-version-webroot-script-javaversion.jfr`
  - Added `logs/` to `.gitignore`
- **Enhanced Error Messages**:
  - Git Bash path conversion detection with specific solutions
  - Execute script validation with exact file path shown
  - Windows trailing backslash validation
- **Cross-Platform Path Handling**: Robust path concatenation logic for Windows and Unix systems
- **Version Detection & Servlet API Handling**:
  - Automatic detection of Lucee 5/6 vs 7+ to select correct servlet dependencies
  - New `detect-version-type` target inspects version strings and JAR filenames
  - Split Maven pom files: `pom-javax.xml` (Lucee 5/6) and `pom-jakarta.xml` (Lucee 7+)
  - Seamless handling of javax to jakarta servlet API transition
  - Build target reordering so version detection happens before dependency resolution
- **Java Agent Support**:
  - `-DjavaAgent=` - Path to Java agent JAR (profilers, debuggers like luceedebug)
  - `-DjavaAgentArgs=` - Arguments passed to the agent
  - `-Djdwp=` - Enable JDWP debugging agent with suspend=n (default: false)
  - `-DjdwpPort=` - JDWP port configuration (default: 9999)
  - Automatic `--add-opens=java.base/java.lang=ALL-UNNAMED` when using agents
- **Advanced JVM Options**:
  - `-DjvmArgs=` - Raw JVM arguments string for custom configurations
  - `-DFlightRecordingSettings=` - JFR settings profile (default/profile/custom.jfc)
  - `-DPrintInlining=` - JVM compilation diagnostics (PrintInlining, PrintCompilation, UnlockDiagnosticVMOptions)
  - `-DPrintGCDetails=` - Detailed garbage collection logging
  - `-DUseEpsilonGC=` - Epsilon no-op garbage collector with AlwaysPreTouch for testing
- **Version Query Format Enhancement**:
  - `luceeVersion` now accepts version query format (e.g., `7.0/stable/light`)
  - Maintains backward compatibility with `luceeVersionQuery` parameter
  - Unified version handling logic across both parameters

### Changed

- **Updated Lucee Version**: Standardized all references to version 7.0.1.100 across codebase
- **JFR Filename Format**: Changed from `lucee-version.jar-javaversion.jfr` to descriptive format with timestamp and context
- **Documentation**: Updated README.md with comprehensive working directory behavior explanations
- **Build Process**:
  - Uncommented `include template` execution path in build-run-cfml.xml
  - Build target dependencies reordered: `detect-version-type` now runs before `setEnv`
  - Enhanced conditional property checking for javaAgent, jvmProperties, jvmArgs
  - Echo statements now show which servlet type is selected (javax vs jakarta)
- **Error Handling**:
  - `_internalRequest` now captures and validates HTTP status codes
  - Non-200 status codes throw descriptive errors with LDEV-6086 reference
  - Better debugging information for script execution failures

### Fixed

- **File Path Validation Bug**: Fixed concatenation logic for execute script validation
- **Git Bash Path Conversion Issues**: Added detection and helpful error messages for MSYS path conversion problems
- **Build Script Path Resolution**: Fixed relative path issues when using unique working directories
- **Request Timeout Detection**: Internal requests now properly detect and report non-200 status codes (LDEV-6086)

### Technical Details

#### New Ant Properties

- `uniqueWorkingDir`: Controls working directory behavior
- `webroot.name`: Extracted basename of webroot for JFR filenames
- `execute.clean`: Cleaned execute path (removes leading slashes) for JFR filenames
- `execute.fullpath`: Properly concatenated full path for file validation
- `javaAgent`: Path to Java agent JAR file
- `javaAgentArgs`: Arguments passed to Java agent
- `jdwp`: Enable JDWP debugging agent (suspend=n)
- `jdwpPort`: JDWP port configuration (default: 9999)
- `jvmArgs`: Raw JVM arguments string
- `FlightRecordingSettings`: JFR settings profile configuration
- `PrintInlining`: JVM compilation diagnostics flag
- `PrintGCDetails`: Garbage collection logging flag
- `UseEpsilonGC`: Epsilon no-op GC flag
- `pom.file`: Dynamically selected pom file (pom-javax.xml or pom-jakarta.xml)
- `version.major.extracted`: Extracted major version number for servlet API detection
- `usesJavax`: Boolean flag indicating if javax servlet API is used (vs jakarta)
- `servlet.type`: Servlet API type in use (javax or jakarta)

#### Build Process Improvements

- Added `set-unique-working-dir` target with timestamp generation and race condition checks
- Enhanced `run-cfml` target with improved validation and path handling
- Updated GitHub Actions workflow with concurrent execution tests
- New `detect-version-type` target for automatic servlet API detection:
  - Parses version strings from `luceeVersion`, `luceeVersionQuery`, or `luceeJar` filename
  - Extracts major version number using regex
  - Selects appropriate pom file before dependency resolution
  - Supports various version formats: `7.0.0.1`, `lucee-7.0.jar`, `7/snapshot/zero`, file paths
- Internal request result validation with status code checking

#### Error Handling

- Early validation of execute script existence under webroot
- Specific error messages for common Git Bash issues
- Clear guidance on workarounds and solutions
- HTTP status code validation for internal requests (detects timeouts and failures)

### Migration Notes

- Existing usage remains unchanged (fully backward compatible)
- New JFR files will appear in `logs/` directory instead of project root
- Git users should add `logs/` to their `.gitignore` if not already present
- Lucee 5/6 and 7+ now use different servlet dependencies automatically (javax vs jakarta)
- Version query format can now be used with `luceeVersion` parameter directly
- All new parameters are optional and have sensible defaults
