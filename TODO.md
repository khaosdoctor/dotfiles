1. Remove Global as it's not needed anymore, all files are within general/base
2. De-stow files in arch and re-stow them using the new path on `specific`, be aware that some files were moved to base
3. Reorganize MacOS modules in the specific/darwin folder
4. De-stow and re-stow all the files in darwin
5. Create the install script for all files
