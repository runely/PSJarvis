<#
    .DESCRIPTION
        Morra de er en description
    .SYNOPSIS
        Morra de er en synopsis
    .EXAMPLE
        test
    .EXAMPLE
        test -hei "Kluthue"
    .INPUTS
        hei
    .OUTPUTS
        What am i producing?
    .NOTES
        v 0.0.0.0.0.0.1
    .COMPONENT
        "Morra de"-component
    .ROLE
        "Morra de"-role
    .FUNCTIONALITY
        Morra de er en functionality
#>
#function test {
function test
{
    param(
        [Parameter()]
        $hei,

        [Parameter(Mandatory = $True, Position = 0)]
        $Apeloff,

        [Parameter(
                Mandatory = $True,
                Position = 0
        )]
        $Content,

        [Parameter (
                Mandatory = $True,
                Position = 0)]
        [string]$Saketing,

        [Parameter(
                Mandatory = $True,
                Position = 0
        )]
        [string]$drit = [bool]"true"
    )

    Write-Host "Hei: $hei"
}
