### 
# Prompt Customisation
### 

function Prompt {
    Write-Output "PS > "
}

function Get-BetterHistory {
    [alias("h")]
    param (
        [Parameter(Mandatory=$False)]
        [Alias("Lines")]
        [Int32]
        $NumberOfLines = 100
    )
    process {
        
        Get-Content (Get-PSReadlineOption).HistorySavePath -Tail $NumberOfLines
    }
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
Set-Alias -Name Splunk -Value "C:\Program Files\Splunk\bin\splunk.exe"
Set-Alias -Name ll -Value "Get-ChildItem"

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
        $CloudProfile = ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/graememeyer/WindowsPowerShell-Profile/main/Microsoft.PowerShell_profile.ps1'))
        Write-Host "Succesfully downloaded cloud profile."
        Write-Host "Updating local profile..."
        Set-Content -Path $PROFILE -Value $CloudProfile
        Write-Host "Reloading with new profile..."

        
        . $PROFILE
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
$Development += @($Base, "vscode", "azure-cli", "awscli", "terraform")
$Forensics += @($Base, "sysinternals", "yara")
$ReverseEngineering += @($Base, "ida-free", "ghidra")
$Personal += @($Base, "mkvtoolnix")

# Zimmerman Tools
function Install-ZimmermanTools {
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1'))
}

