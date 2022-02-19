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
if (test-path alias:curl) {
    Remove-Item alias:curl
}


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
# Miscellaneous 
###


function Update-Profile {
    try {
        Write-Host "Getting local profile..."
        $CurrentProfile = Get-Content -Path $PROFILE
        Write-Host "Getting cloud profile..."
        $CloudProfile = Get-Content ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/graememeyer/WindowsPowerShell-Profile/main/Microsoft.PowerShell_profile.ps1'))
        Write-Host "Succesfully downloaded cloud profile."
        Write-Host "Updating local profile..."
        Set-Content -Path $PROFILE -Value $CloudProfile
        Write-Host "Reloading with new profile..."
        
        Write-Host "You must restart your terminal/host for this to take effect."
        ## This isn't working
        ## & $PROFILE
    }
    catch {
        Write-Warning "Something went wrong."
        Write-Error $Error[0]
    }
}


###
# Chocolatey
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

# Chocolatey application lists
$Base = @("7zip", "boxstarter", "firefox", "git", "hashtab", "hxd", "notepadplusplus", "vlc", "windirstat", "microsoft-windows-terminal")
$Development += @($Base, "vscode", "terraform")
$Forensics += @($Base, "sysinternals", "yara")
$Personal += @($Base, "nordvpn", "mkvtoolnix")

# Zimmerman Tools
function Install-ZimmermanTools {
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1'))
}
