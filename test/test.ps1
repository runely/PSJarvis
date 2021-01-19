<#
    .DESCRIPTION
        Morra de er en description
    .SYNOPSIS
        Morra de er en synopsis
    .EXAMPLE
        test
        Kjører driten uten en hilsen
    .EXAMPLE
        test -hei "Kluthue"
        Kjører driten med en hilsen
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
param(
    [Parameter()]
    $hei
)

Write-Host "Hei: $hei"
