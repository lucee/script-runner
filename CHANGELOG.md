# Changelog

All notable changes to the Lucee Script Runner project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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

### Changed
- **Updated Lucee Version**: Standardized all references to version 6.2.2.91 across codebase
- **JFR Filename Format**: Changed from `lucee-version.jar-javaversion.jfr` to descriptive format with timestamp and context
- **Documentation**: Updated README.md with comprehensive working directory behavior explanations

### Fixed
- **File Path Validation Bug**: Fixed concatenation logic for execute script validation
- **Git Bash Path Conversion Issues**: Added detection and helpful error messages for MSYS path conversion problems
- **Build Script Path Resolution**: Fixed relative path issues when using unique working directories

### Technical Details

#### New Ant Properties
- `uniqueWorkingDir`: Controls working directory behavior
- `webroot.name`: Extracted basename of webroot for JFR filenames
- `execute.clean`: Cleaned execute path (removes leading slashes) for JFR filenames
- `execute.fullpath`: Properly concatenated full path for file validation

#### Build Process Improvements
- Added `set-unique-working-dir` target with timestamp generation and race condition checks
- Enhanced `run-cfml` target with improved validation and path handling
- Updated GitHub Actions workflow with concurrent execution tests

#### Error Handling
- Early validation of execute script existence under webroot
- Specific error messages for common Git Bash issues
- Clear guidance on workarounds and solutions

### Migration Notes
- Existing usage remains unchanged (backward compatible)
- New JFR files will appear in `logs/` directory instead of project root
- Git users should add `logs/` to their `.gitignore` if not already present