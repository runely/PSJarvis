$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

# Dot source functions
$functions = Get-ChildItem -Path $ScriptPath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue

foreach ($function in $functions) {
    try {
        . $function.FullName
    }
    catch {
        throw "Failed to dot source '$($_.FullName)'"
    }
}

Export-ModuleMember $functions.BaseName
