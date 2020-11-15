Function Get-ScriptCommentBlock
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        $Content
    )

    $commentBlock = New-Object PSObject
    $indexStart = -1
    $commentBlockSection = ""
    [int]$commentBlockSections = 0

    for ($i = 0; $i -lt $Content.Count; $i++) {
        $line = $Content[$i].Trim()

        if (($i -ge 0 -and $i -le 5) -and $indexStart -eq -1 -and $line.StartsWith('<#')) {
            $indexStart = $i
            Write-Verbose "Found start of help comment block at index $i"
            continue;
        }
        elseif ($i -gt 0 -and $indexStart -gt -1 -and $line -eq "#>") {
            Write-Verbose "Found end of help comment block at index $i"
            break;
        }

        if ($indexStart -gt -1 -and $line.StartsWith(".")) {
            $commentBlockSection = $line.Substring(1, ($line.Length - 1))
            $commentBlockSections++

            [int]$sectionNr = 1
            [bool]$sectionAdded = $False
            do {
                try {
                    if ($sectionNr -gt 1) {
                        $commentBlockSection = "$($line.Substring(1, ($line.Length - 1)))$($sectionNr)"
                    }
                    $commentBlock | Add-Member -MemberType NoteProperty -Name $commentBlockSection -Value @() -TypeName String[] -ErrorAction Stop
                    $sectionAdded = $True
                }
                catch {
                    $sectionNr++
                }
            } while (!$sectionAdded)

            Write-Verbose "Found help comment block section '$commentBlockSection' at index $i. This is section nr $commentBlockSections found"
        }
        elseif ($indexStart -gt -1 -and !$line.StartsWith(".")) {
            $commentBlock.$commentBlockSection += $line
            Write-Verbose "Adding info to comment block section '$commentBlockSection' from index $i"
        }
    }

    if ($commentBlockSections -eq 0) {
        Write-Verbose "Help comment block not found. Return null"
        return $null
    }
    else {
        Write-Verbose "Help comment block found with $commentBlockSections sections"
        return $commentBlock
    }
}
