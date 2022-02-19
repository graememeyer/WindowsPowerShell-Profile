### 
# Prompt Customisation
### 

function Prompt {
    Write-Output "PS > "
}

# function global:prompt {
#     $PwdPath = Split-Path -Path $pwd -Leaf
#     Write-Host -Object "$PwdPath" -NoNewline -ForegroundColor Magenta
#  
#     return "> "
# }


###
# General Aliases
###

# Remove the curl alias so that curl refers to curl.exe instead of Invoke-WebRequest
Remove-Item alias:curl

#
Set-Alias -Name windowsterminal -Value "wt -d $($pwd)"

# Touch-File
Function Touch-File {
    $file = $args[0]
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else
    {
        echo $null > $file
    }
}

Set-Alias -Name touch -Value "Touch-File"

###
# Miscilaneous 
###

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Install Chocolatey
function Install-Chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
