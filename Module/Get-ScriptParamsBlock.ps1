Function Get-ScriptParamsBlock
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        $Content
    )

    $paramBlock = New-Object PSObject
    $indexStart = -1
    $paramBlockSectionName = ""
    $paramBlockSectionValue = $null
    $paramBlockSection = $null
    $paramBlockSectionFinished = $False
    [int]$paramBlockSections = 0

    for ($i = 0; $i -lt $Content.Count; $i++) {
        $line = $Content[$i].Trim()

        if ($indexStart -eq -1 -and ($line.StartsWith("param(") -or $line.StartsWith("param *("))) {
            $indexStart = $i
            Write-Verbose "Found start of param block at index $i"
            continue;
        }
        elseif ($indexStart -gt -1 -and $line -eq ")") {
            Write-Verbose "Found end of param block at index $i"
            break;
        }

        if ($indexStart -gt -1 -and ($line.StartsWith("[Parameter(") -or $line.StartsWith("[Parameter ("))) {
            $paramBlockSections++
            $paramBlockSection = @{}
            $paramBlockSectionFinished = $False
            $paramSettingsStr = $null
            Write-Verbose "Found param block section start at index $i"

            $paramSettingsStart = $line.IndexOf("(")
            $paramSettingsEnd = $line.IndexOf(")]")
            if ($paramSettingsStart -gt -1 -and $paramSettingsEnd -gt -1) {
                Write-Verbose "Found param settings block at index $i"
                $paramBlockSectionFinished = $True
                if (($paramSettingsEnd - $paramSettingsStart) -eq 1) {
                    Write-Verbose "No param settings found for settings block"
                    continue;
                }

                $paramSettingsStr = $line.Substring(($paramSettingsStart + 1), ($line.Length - ($paramSettingsStart+3)))
            }
            elseif ($paramSettingsStart -gt -1 -and $paramSettingsEnd -eq -1) {
                Write-Verbose "Param settings block end not found on this line..."
                $paramSettingsStr = $line.Substring(($paramSettingsStart + 1), ($line.Length - ($paramSettingsStart+1)))
            }
            elseif ($paramSettingsStart -eq -1 -and $paramSettingsEnd -eq -1) {
                Write-Verbose "Invalid param block..."
            }

            if (![string]::IsNullOrEmpty($paramSettingsStr)) {
                $paramSettingsArr = $paramSettingsStr.Split(',')

                $paramSettingsArr | % {
                    $split = $_.Split("=") | % { $_.Trim() }

                    if ($split -and $split.Count) {
                        $paramBlockSection.Add($split[0], $split[1])
                    }
                    elseif ($split) {
                        $paramBlockSection.Add($split, $True) # all paramter settings have a value, those that don't is implicitly $True?!!
                    }
                }
            }
        }
        elseif ($indexStart -gt -1 -and $null -ne $paramBlockSection -and [string]::IsNullOrEmpty($paramBlockSectionName) -and $line -notlike "*)]" -and !$paramBlockSectionFinished) {
            Write-Verbose "Found continue of param block section at index $i"

            $line.Split(',') | % {
                $split = $_.Split("=") | % { $_.Trim() }

                if ($split -and $split.Count) {
                    Write-Verbose "Adding setting ($($split[0])) = ($($split[1]))"
                    $paramBlockSection.Add($split[0], $split[1])
                }
                elseif ($split) {
                    Write-Verbose "Adding setting ($($split[0])) = ($True)"
                    $paramBlockSection.Add($split, $True) # all paramter settings have a value, those that don't is implicitly $True?!!
                }
            }
        }
        elseif ($indexStart -gt -1 -and $null -ne $paramBlockSection -and [string]::IsNullOrEmpty($paramBlockSectionName) -and $line -like "*)]" -and !$paramBlockSectionFinished) {
            Write-Verbose "Found continue and the end of param block section at index $i"
            
            $paramSettingsStr = $line.Substring(0, ($line.Length - 2))

            if (![string]::IsNullOrEmpty($paramSettingsStr)) {
                $paramSettingsStr.Split(',') | % {
                    $split = $_.Split("=") | % { $_.Trim() }

                    if ($split -and $split.Count) {
                        Write-Verbose "Adding setting ($($split[0])) = ($($split[1]))"
                        $paramBlockSection.Add($split[0], $split[1])
                    }
                    elseif ($split) {
                        Write-Verbose "Adding setting ($($split[0])) = ($True)"
                        $paramBlockSection.Add($split, $True) # all paramter settings have a value, those that don't is implicitly $True?!!
                    }
                }
            }

            $paramBlockSectionFinished = $True
        }
        elseif ($indexStart -gt -1 -and $null -ne $paramBlockSection -and [string]::IsNullOrEmpty($paramBlockSectionName) -and $line -match "(\[.+].+\$)|(\[.+]+\$)|(\$)") {
            Write-Verbose "Found param block section name at index $i"

            if ($line.StartsWith("[")) {
                # get end and set as type
                $paramTypeEnd = $line.IndexOf("]")
                $paramBlockSectionType = $line.Substring(1, ($paramTypeEnd - 1))
                Write-Verbose "Adding setting name type: '$paramBlockSectionType'"
            }
            else {
                Write-Verbose "Setting name type not found"
                $paramBlockSectionType = $null
            }

            $paramNameSplit = $line.Split("=")
            if (![string]::IsNullOrEmpty($paramBlockSectionType)) {
                $paramBlockSectionName = $paramNameSplit[0].Trim().Substring(($paramBlockSectionType.Length + 3), ($paramNameSplit[0].Trim().Length - ($paramBlockSectionType.Length + 3)))
            }
            else {
                $paramBlockSectionName = $paramNameSplit[0].Trim().Substring(1, ($paramNameSplit[0].Trim().Length - 1))
            }
            if ($paramBlockSectionName.EndsWith(",")) {
                $paramBlockSectionName = $paramBlockSectionName.Substring(0, ($paramBlockSectionName.length - 1))
                $paramNameSplit[0] = $paramBlockSectionName
            }
            Write-Verbose "Adding setting name as '$paramBlockSectionName'"

            if ($paramNameSplit.Count -eq 2) {
                $paramBlockSectionValue = $paramNameSplit[1].Trim()
                Write-Verbose "Adding setting name value as '$paramBlockSectionValue'"
            }

            $paramBlock | Add-Member -MemberType NoteProperty -Name $paramBlockSectionName -Value @{
                Type = $paramBlockSectionType
                DefaultValue = $paramBlockSectionValue
                Settings = $paramBlockSection
            }

            $paramBlockSectionName = ""
            $paramBlockSectionValue = $null
            $paramBlockSection = $null
        }
    }

    if ($paramBlockSections -eq 0) {
        Write-Verbose "Param block not found. Return null"
    }
    else {
        Write-Verbose "Param block found with $paramBlockSections sections"
        return $paramBlock
    }
}
