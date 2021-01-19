Function Add-PSJarvisFile
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [ValidateScript({ [System.IO.Path]::GetExtension($_) -eq ".ps1" })]
        [string]$FilePath,

        [Parameter()]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$Encoding = [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]::UTF8
    )

    process {
        # read in script
        $scriptContent = Get-Content -Path $FilePath -Encoding $Encoding

        # determine if script is a function or just a file
        [bool]$isModule = $null -ne ($scriptContent | Where { $_ -like "function *" })

        # get help comment block form script ($null otherwise)
        $helpCommentBlock = Get-ScriptCommentBlock -Content $scriptContent

        # determine if script has a param block
        $paramsBlock = Get-ScriptParamsBlock -Content $scriptContent -Module $isModule
        
        # output json with metadata
    }
}
