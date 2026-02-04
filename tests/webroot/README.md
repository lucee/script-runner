# Webroot Test Scripts

This folder contains test CFML scripts for verifying webroot and execute argument handling in the script-runner.

## Rules and What We Are Testing

- All scripts in this folder are used by automated tests to ensure that:
	- The `-Dwebroot` argument (relative or absolute, quoted or unquoted) is always normalized and used correctly.
	- The `-Dexecute` argument (relative to webroot, with or without subfolders) is resolved and executed as expected.
- The `index.cfm` and `test.cfm` scripts are for basic webroot resolution.
- The `sub/test.cfm` script is for testing relative execute paths within a subfolder.
- Output from these scripts is checked in CI to confirm correct path resolution and script execution.

**Do not remove or rename these files unless you update the corresponding tests and workflows.**
