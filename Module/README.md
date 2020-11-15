# PSJarvis Module

PowerShell module to add/edit/remove script files to PSJarvis

## Installation

```powershell
Install-Module -Name PSJarvis
```

## Usage

```powershell
# add script to PSJarvis
Import-Module PSJarvis

Add-PSJarvisFile -FilePath "FullPath-To-ScriptFile" [-Encoding]
```

### ToDo
* Get-ScriptCommentBlock.ps1
    * Add support for having help command block inside function
