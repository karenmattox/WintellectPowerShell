﻿#requires -version 2.0
###############################################################################
# WintellectPowerShell Module
# Copyright (c) 2013 - John Robbins/Wintellect
# 
# Do whatever you want with this module, but please do give credit.
###############################################################################

# Always make sure all variables are defined and all best practices are 
# followed.
Set-StrictMode -version Latest

function Invoke-CmdScript 
{
<#
.SYNOPSIS
Executes the specified command script and imports the environment into current
PowerShell instance.

.DESCRIPTION
Running development tools at the command line in PowerShell can be a hassle since 
they rely on environment varibles and those are set through batch files. This 
cmdlet runs those batch files and imports any set environment variables into
the running PowerShell instance. 

.PARAMETER script
The required batch file to run.

.PARAMETER parameters
The optional parameters to pass to the batch file.

.NOTES
The original script is by Lee Holmes. I updated the script to make removing environment variables
work.

.LINK
http://www.leeholmes.com/blog/2006/05/11/nothing-solves-everything-%e2%80%93-powershell-and-other-technologies/
https://github.com/Wintellect/WintellectPowerShell
#>
    param
    (
        [Parameter(Mandatory=$true,
                   Position=0,
                   HelpMessage="Please specify the command script to execute.")]
        [string] $script, 
        [Parameter(Position=1)]
        [string] $parameters
    )  

    # Save off the current environment variables in case there's an issue
    $oldVars = $(dir env:\)
    $tempFile = [IO.Path]::GetTempFileName()  
    
    try
    {
        ## Store the output of cmd.exe.  We also ask cmd.exe to output   
        ## the environment table after the batch file completes  
        cmd /c " `"$script`" $parameters && set > `"$tempFile`" "

        if ($LASTEXITCODE -ne 0)
        {
            throw "Error executing CMD.EXE: $LASTEXITCODE"
        }
        
        # Before we delete the environment variables get the output into a string
        # array.
        $vars = Get-Content $tempFile
    
        # Clear out all current environment variables in PowerShell.
        dir env:\ | Foreach-Object { 
                        set-item -force -path "ENV:\$($_.Name)" -value "" 
                    }
 

        ## Go through the environment variables in the temp file.  
        ## For each of them, set the variable in our local environment.  
        $vars | Foreach-Object {   
                            if($_ -match "^(.*?)=(.*)$")  
                            { 
                                Set-Content "env:\$($matches[1])" $matches[2]  
                            } 
                        }
    }
    catch
    {
        "ERROR: $_"

        # Any problems, restore the old environment variables.
        $oldVars | ForEach-Object { Set-Item -Force -Path "ENV:\$($_.Name)" -value $_.Value }
    }
    finally
    {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}

# SIG # Begin signature block
# MIIYSwYJKoZIhvcNAQcCoIIYPDCCGDgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUol76t3TBzYa23uNRpvc0gwZb
# lF6gghM8MIIEhDCCA2ygAwIBAgIQQhrylAmEGR9SCkvGJCanSzANBgkqhkiG9w0B
# AQUFADBvMQswCQYDVQQGEwJTRTEUMBIGA1UEChMLQWRkVHJ1c3QgQUIxJjAkBgNV
# BAsTHUFkZFRydXN0IEV4dGVybmFsIFRUUCBOZXR3b3JrMSIwIAYDVQQDExlBZGRU
# cnVzdCBFeHRlcm5hbCBDQSBSb290MB4XDTA1MDYwNzA4MDkxMFoXDTIwMDUzMDEw
# NDgzOFowgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2Fs
# dCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8G
# A1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNF
# UkZpcnN0LU9iamVjdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM6q
# gT+jo2F4qjEAVZURnicPHxzfOpuCaDDASmEd8S8O+r5596Uj71VRloTN2+O5bj4x
# 2AogZ8f02b+U60cEPgLOKqJdhwQJ9jCdGIqXsqoc/EHSoTbL+z2RuufZcDX65OeQ
# w5ujm9M89RKZd7G3CeBo5hy485RjiGpq/gt2yb70IuRnuasaXnfBhQfdDWy/7gbH
# d2pBnqcP1/vulBe3/IW+pKvEHDHd17bR5PDv3xaPslKT16HUiaEHLr/hARJCHhrh
# 2JU022R5KP+6LhHC5ehbkkj7RwvCbNqtMoNB86XlQXD9ZZBt+vpRxPm9lisZBCzT
# bafc8H9vg2XiaquHhnUCAwEAAaOB9DCB8TAfBgNVHSMEGDAWgBStvZh6NLQm9/rE
# JlTvA73gJMtUGjAdBgNVHQ4EFgQU2u1kdBScFDyr3ZmpvVsoTYs8ydgwDgYDVR0P
# AQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wEQYDVR0gBAowCDAGBgRVHSAAMEQG
# A1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9BZGRUcnVz
# dEV4dGVybmFsQ0FSb290LmNybDA1BggrBgEFBQcBAQQpMCcwJQYIKwYBBQUHMAGG
# GWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEFBQADggEBAE1C
# L6bBiusHgJBYRoz4GTlmKjxaLG3P1NmHVY15CxKIe0CP1cf4S41VFmOtt1fcOyu9
# 08FPHgOHS0Sb4+JARSbzJkkraoTxVHrUQtr802q7Zn7Knurpu9wHx8OSToM8gUmf
# ktUyCepJLqERcZo20sVOaLbLDhslFq9s3l122B9ysZMmhhfbGN6vRenf+5ivFBjt
# pF72iZRF8FUESt3/J90GSkD2tLzx5A+ZArv9XQ4uKMG+O18aP5cQhLwWPtijnGMd
# ZstcX9o+8w8KCTUi29vAPwD55g1dZ9H9oB4DK9lA977Mh2ZUgKajuPUZYtXSJrGY
# Ju6ay0SnRVqBlRUa9VEwggSTMIIDe6ADAgECAhBHio77WeHYPwzhQtKihwe+MA0G
# CSqGSIb3DQEBBQUAMIGVMQswCQYDVQQGEwJVUzELMAkGA1UECBMCVVQxFzAVBgNV
# BAcTDlNhbHQgTGFrZSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdv
# cmsxITAfBgNVBAsTGGh0dHA6Ly93d3cudXNlcnRydXN0LmNvbTEdMBsGA1UEAxMU
# VVROLVVTRVJGaXJzdC1PYmplY3QwHhcNMTAwNTEwMDAwMDAwWhcNMTUwNTEwMjM1
# OTU5WjB+MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVy
# MRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEk
# MCIGA1UEAxMbQ09NT0RPIFRpbWUgU3RhbXBpbmcgU2lnbmVyMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvDWgNnAigRHDsoO50yjGNs0la6l7shz2m1Gc
# 7zX07QiOXjgI+Hc8CkLg83Dco9fK9UwLz/8inAp+aNYJoiqEe6adtKnBM+LvHxdI
# yjrNRubFqne943ea+kdTQChZQ5PxpIHq74C1T6cIzrpuvMp2DJdkWYYkuz2CkKhV
# sZLToKcFrJ9TJQgQR5nNmN5o5bRQeKOvAcxZQ1jkdm5+rMfinh9PsEctyAyjSSeA
# dYy7BpFlD5Cb9LrRgchcauwU6SUJvyMW9JVGQEAhu4OW/YYfesgNEI6i+BkHWH+f
# vTcCYPKk6Z1EPzAF5KdwmVGa6BfxVcqyYYllRqdq8lhGfqqgBwIDAQABo4H0MIHx
# MB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2LPMnYMB0GA1UdDgQWBBQuLbAK
# RErTh8ACB86XfVBiIP0PgzAOBgNVHQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADAW
# BgNVHSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8v
# Y3JsLnVzZXJ0cnVzdC5jb20vVVROLVVTRVJGaXJzdC1PYmplY3QuY3JsMDUGCCsG
# AQUFBwEBBCkwJzAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0LmNv
# bTANBgkqhkiG9w0BAQUFAAOCAQEAyPtj+At1dSw68fITpy22oxqcrQEH0zSOd+DC
# bq4CXUhPpNIhtjb9KjVDfGvfgIcLFfB2MgC0zrVnpC8vIBucVJ6DPx9fFJVigg8i
# QSIfcLPz90LebFHNS/ghrJs7jLHl5iiPziqK+apSTYxbd7pNWljbu2oEzFIeneIo
# Nw675w6Rx/jb8YGY6803sw6rZdNi7DqldusTqDWTyS4KAezA6Mw9frbr4sHs0xSS
# gmaHUNz9UJess0p2cwbEhhE6s19DBFJv6rPQdDZMyvEbeYQ3cGOtdLmqDvOYsIYI
# 69vgH4wQ8jlkm65PCiySik8YtZHljRqTXx+u8abwLpfQ0vYrPDCCBOcwggPPoAMC
# AQICEBBwnU/1VAjXMGAB2OqRdbswDQYJKoZIhvcNAQEFBQAwgZUxCzAJBgNVBAYT
# AlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtlIENpdHkxHjAcBgNV
# BAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMYaHR0cDovL3d3dy51
# c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0LU9iamVjdDAeFw0x
# MTA4MjQwMDAwMDBaFw0yMDA1MzAxMDQ4MzhaMHsxCzAJBgNVBAYTAkdCMRswGQYD
# VQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGjAYBgNV
# BAoTEUNPTU9ETyBDQSBMaW1pdGVkMSEwHwYDVQQDExhDT01PRE8gQ29kZSBTaWdu
# aW5nIENBIDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDL+Oen6PGX
# KEBogDfSyD+OkoqSN4dHgOpMmc9u+RVHve519ESs0MPUTfcZwNM8TcFHuVllFpOM
# 2QqEm5/o9mpjWP5f3NF/S1GfABwAh1QgB1eggskvmK8zirt7gCIlamyvwixseRO9
# oypI1rWOYVXpa+g9gL8UA4UYjn5M6cIZiHOScs36/1BNyyymexpzsQCQLNky4vv9
# rJVCNuw0xRNTaLLBn0Cf2nvInWJsk6JC13mfl08xW1Ahoauv2RyyznW+WyxWACSN
# EcF1H/D+0pX+8OExIxhnwFsT/VqYlJT//1kCHwCs5vHy+jpzsx1C/FR1z1ExL+Pb
# gdl3IypPWc4jAgMBAAGjggFKMIIBRjAfBgNVHSMEGDAWgBTa7WR0FJwUPKvdmam9
# WyhNizzJ2DAdBgNVHQ4EFgQUHsWxLH2H2gJofCW8DAeEP7bP3vEwDgYDVR0PAQH/
# BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# EQYDVR0gBAowCDAGBgRVHSAAMEIGA1UdHwQ7MDkwN6A1oDOGMWh0dHA6Ly9jcmwu
# dXNlcnRydXN0LmNvbS9VVE4tVVNFUkZpcnN0LU9iamVjdC5jcmwwdAYIKwYBBQUH
# AQEEaDBmMD0GCCsGAQUFBzAChjFodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVRO
# QWRkVHJ1c3RPYmplY3RfQ0EuY3J0MCUGCCsGAQUFBzABhhlodHRwOi8vb2NzcC51
# c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQCViXeTaAFefNktNweQXVpC
# XgxktDa1D/ar1Tkn3iJGpEkcZktGGVkueUkD9pyS321QNVwMkS5gA1nQ8WT3aQn2
# fv7rNLNtsb9mnKO6MXi5hzVhPZIxG+/06J7WrEX6DDY8gGe7ve8uwpDhPXEvO8Gw
# WH5Fw1JxAwf28zlNizYhGwHf2dpeK+sOl4AeRBxQiPXGEjNKqE2ljS+UDHvGv5os
# wzLNvYwnJvDhMANQBoK89Duzg3UGxu+67tOA+FLGrMt58jiee7CSWEKRBciWIa25
# SxaBFGnxN7D+NPfcsN+X9UMQm3aPtGX16J8Ttx6sb8Rpil+6PGF+XkmGIxMurxVI
# MIIFLjCCBBagAwIBAgIQcX+oqSFbgNLgcUZ+Dxnw8jANBgkqhkiG9w0BAQUFADB7
# MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
# VQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEhMB8GA1UE
# AxMYQ09NT0RPIENvZGUgU2lnbmluZyBDQSAyMB4XDTEzMTAyODAwMDAwMFoXDTE4
# MTAyODIzNTk1OVowgZ0xCzAJBgNVBAYTAlVTMQ4wDAYDVQQRDAUzNzkzMjELMAkG
# A1UECAwCVE4xEjAQBgNVBAcMCUtub3h2aWxsZTESMBAGA1UECQwJU3VpdGUgMzAy
# MR8wHQYDVQQJDBYxMDIwNyBUZWNobm9sb2d5IERyaXZlMRMwEQYDVQQKDApXaW50
# ZWxsZWN0MRMwEQYDVQQDDApXaW50ZWxsZWN0MIIBIjANBgkqhkiG9w0BAQEFAAOC
# AQ8AMIIBCgKCAQEAwVChJi7aiU+FAZeCy6rQcHAexAGgVu4Chh9fdZWnbDx2+OKS
# pL7jzoKZPHYQwf94puBqtU/ScYgDbroE1DkZfHOIYoaTlj6Dvh0Hbr2LwbYHbhdZ
# dlBzDQ1NyHqhRxe6raQ6RynWyuHg+n4dAH+pHfepBbMRbvIyWmgj5LA2hr2nVZBo
# 4/OgB8l2JKAidYaCuUDFXBwRPQCZVBApDaWAnLNCRcgCJHHIk9KAptmuFNrv8Eyb
# fdJaYb0rkaUVrDvocVXV7j2/yGtMMUknsIBDPrkhxrOOodNoo59iGw+GIWub8CmQ
# 9S4lvjkx4Q+azwPMPyVNJB+jt4uQbaE23GRGZwIDAQABo4IBiTCCAYUwHwYDVR0j
# BBgwFoAUHsWxLH2H2gJofCW8DAeEP7bP3vEwHQYDVR0OBBYEFASL4+TI2KlI7ozS
# jFNcSGhsQ9pbMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMBEGCWCGSAGG+EIBAQQEAwIEEDBGBgNVHSAEPzA9MDsGDCsG
# AQQBsjEBAgEDAjArMCkGCCsGAQUFBwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8u
# bmV0L0NQUzBBBgNVHR8EOjA4MDagNKAyhjBodHRwOi8vY3JsLmNvbW9kb2NhLmNv
# bS9DT01PRE9Db2RlU2lnbmluZ0NBMi5jcmwwcgYIKwYBBQUHAQEEZjBkMDwGCCsG
# AQUFBzAChjBodHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9Db2RlU2lnbmlu
# Z0NBMi5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTAN
# BgkqhkiG9w0BAQUFAAOCAQEAHibwVe5iTcPaZVhne++CGpFJFWASomYbtgEG/Z5A
# KT0Jgwvfu5uliKAfckPNYwgNLyx+/qHMnNji2BG5jb2skEzJpZHDbbwgQ4uQtmpK
# L8k7E5Pg07Ithpw5IPUMcfrdgWeUMWm35lEA4ps9q8bua5b3sVlPd5sK8sIlisuV
# hLKbgTwf/LsgJKKNtogG3/Me0VfxEm9XtuKO/FkjXGqorLH2HIX/iA1Yyr25CITA
# gbXdVP9SY0JzcpwKzL1+qdat4WHvoS4j1quPVVE4bYVphB1rEPY772eX67EWY4x4
# 4eqFBaW/nt4712js8jo+JUYxOSILZ4VN4EQdbKUJQUOQMjGCBHkwggR1AgEBMIGP
# MHsxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAO
# BgNVBAcTB1NhbGZvcmQxGjAYBgNVBAoTEUNPTU9ETyBDQSBMaW1pdGVkMSEwHwYD
# VQQDExhDT01PRE8gQ29kZSBTaWduaW5nIENBIDICEHF/qKkhW4DS4HFGfg8Z8PIw
# CQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFDJd2uRwlNhWdKjSqZgUAI4+/8qQMA0GCSqGSIb3DQEB
# AQUABIIBACNvqFRP75hU4zv1BCp+mc/6ElYq8sTwBp8ZJBfhDEU8Y50AFWkfvij4
# QSWq3+IFkY6f70hWaUUswVodIUcdGRpTErwZXDq98hfwhgvBUCKKKAqT+kf0b7w3
# dq67IpjnVzu1jU9jBBMdwO+FWIrCMspBoCZVUXE1pbPcQj8v9qpBzXIdsFM2JxKX
# ylZqlbOcE72bTt9FsWiI/Zvirn/hRPGLCmH0nHHoPRm7/1RuEXQF569UN0JFjpAh
# qA0Ffq8uep9Qz40/pqPyt45FdvQs6xfNSuP39AF1fgy42yh7lIT9uZB34RGAW+/s
# hcf5lOlCgn1smVjGWbfQIugu8OQO11uhggJEMIICQAYJKoZIhvcNAQkGMYICMTCC
# Ai0CAQAwgaowgZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMO
# U2FsdCBMYWtlIENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEh
# MB8GA1UECxMYaHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4t
# VVNFUkZpcnN0LU9iamVjdAIQR4qO+1nh2D8M4ULSoocHvjAJBgUrDgMCGgUAoF0w
# GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTMxMTA4
# MjIxMTA0WjAjBgkqhkiG9w0BCQQxFgQUs50mlfeR/LTQ5Y7yXFF9QzpPmUMwDQYJ
# KoZIhvcNAQEBBQAEggEAZzUph40WhzHqS3j8CN9kvhpcie371ctGxOPfYi/VIRjR
# BGAjhH3ay4jjqNH8ABCYGuD00op2QkDyrSDs7mvWOE1sT0CW/KfDgZMQTmJZTqt1
# /7unVH3cFfT95tI3ZIVwOuXp3sw5mPzUVRsCArwmWdJwSKcXbiGUZY8DRWsdFyAN
# WbhMztqdare+i5yxe557Gglf+tATMqYOb5oXe4C8Zgcyccq+WQicf/4ea9rEAvJ3
# ZpwCsPnEi1dWS++XXuTZyOeUcTfo1fYPl3i1zS1xFSr+jLlEbE1lohowoNVB/USk
# hheWViDp6WOAAo0LCdP/XO55QqAAEqC7uky+porHqw==
# SIG # End signature block
