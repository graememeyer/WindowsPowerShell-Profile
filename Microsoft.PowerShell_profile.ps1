### 
# Prompt Customisation
### 
$FormatEnumerationLimit = 16 # Show more values in Format(-Table) output

function Prompt {
    Write-Output "PS > "
}

###
# PowerShell History Customisation
###

# Use the same history file as ConsoleHost (e.g., Windows Terminal, regular terminal)
if ($Host.Name -eq 'Visual Studio Code Host') {
    Set-PSReadLineOption -HistorySavePath "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
}

function Get-BetterHistory {
    [alias("h")]
    param (
        [Parameter(Mandatory=$False)]
        [Alias("Lines")]
        [Int32]
        $NumberOfLines = 10000,

        [Parameter(Mandatory=$False)]
        [String]
        $Filter = "*"
    )
    process {
        $historyPath = (Get-PSReadlineOption).HistorySavePath
        Get-Content $historyPath -Tail $NumberOfLines | Where-Object { $_ -like $Filter }
    }
}

# function global:prompt {
#     $PwdPath = Split-Path -Path $pwd -Leaf
#     Write-Host -Object "$PwdPath" -NoNewline -ForegroundColor Magenta
#  
#     return "> "
# }

###
# Environment Variables
###

$env:PYTHONDONTWRITEBYTECODE=1 # Don't write .pyc or __pycache__ files

# General Aliases
###

# Remove the curl alias so that curl refers to curl.exe instead of Invoke-WebRequest
if (test-path alias:curl) {
    Remove-Item alias:curl
}

Set-Alias -Name windowsterminal -Value "wt -d $($pwd)"
Set-Alias -Name Splunk -Value "C:\Program Files\Splunk\bin\splunk.exe"
Set-Alias -Name ll -Value "Get-ChildItem"

# Touch-File
Function New-EmptyFile {
    [alias("Touch-File")]
    [alias("touch")]
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

# Add-ToPath
function Add-ToPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$Path,

        [ValidateSet('User', 'System')]
        [string]$PathType = 'User',

        [switch]$Force
    )

    begin {
        $currentPath = $env:PATH -split ';'
    }

    process {
        foreach ($PathItem in $Path) {
            $fullPath = Resolve-Path $PathItem -ErrorAction Stop

            if ($currentPath -notcontains $fullPath) {
                $env:PATH += ";$fullPath"
                Write-Host "Added to PATH (current session): $fullPath" -ForegroundColor Green

                # Modify permanent PATH
                $currentStoredPath = [Environment]::GetEnvironmentVariable('PATH', $PathType)

                if (-not ($currentStoredPath -split ';' -contains $fullPath)) {
                    if ($PathType -eq 'System' -and -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                        throw "Administrator privileges required to modify System PATH"
                    }

                    if ($Force -or $Host.UI.PromptForChoice("Confirm", "Add $fullPath to $PathType PATH?", @("&Yes", "&No"), 1) -eq 0) {
                        [Environment]::SetEnvironmentVariable('PATH', "$currentStoredPath;$fullPath", $PathType)
                        Write-Host "Added to $PathType PATH permanently: $fullPath" -ForegroundColor Cyan
                    }
                }
            }
            else {
                Write-Host "Path already exists in PATH: $fullPath" -ForegroundColor Yellow
            }
        }
    }
}

###
# Miscellaneous 
###

function Update-Profile {
    try {
        Write-Host "Getting local profile..."
        $CurrentProfile = Get-Content -Path "$PROFILE"
        Write-Host "Getting cloud profile..."
        $CloudProfile = ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/graememeyer/WindowsPowerShell-Profile/main/Microsoft.PowerShell_profile.ps1'))
        Write-Host "Succesfully downloaded cloud profile."
        Write-Host "Updating local profile..."
        Set-Content -Path "$PROFILE" -Value $CloudProfile
        Write-Host "Reloading with new profile..."
      
        . "$PROFILE"
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
$Base = @("7zip", "boxstarter", "firefox", "git", "hashtab", "hxd", "notepadplusplus", "vlc", "windirstat", "python", "vscode", "obsidian")
if ((Get-WmiObject -class Win32_OperatingSystem).Caption -match "Windows 10") {$Base += "microsoft-windows-terminal"}
$Development += @($Base, "azure-cli", "awscli", "terraform")
$Forensics += @($Base, "sysinternals", "yara", "wireshark")
$ReverseEngineering += @($Base, "ida-free", "ghidra", "explorersuite")
$Personal += @($Base, "mkvtoolnix")

# Zimmerman Tools
function Install-ZimmermanTools {
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1'))
}

###
# System customisation + Boxstarter configs
###

# Don't show Edge tabs in Alt-Tab behaviour
if ((Get-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MultiTaskingAltTabFilter | Select-Object -ExpandProperty MultiTaskingAltTabFilter) -ne 3) {
    Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MultiTaskingAltTabFilter -Type DWord -Value 3
}


###
# Terraform
###

function Set-TerraformDebugging {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF")]
        [string]$Level = "TRACE",

        [Parameter(Mandatory=$false)]
        [string]$LogPath,

        [Parameter(Mandatory=$false)]
        [switch]$Disable,

        [Parameter(Mandatory=$false)]
        [switch]$ProviderOnly
    )

    if ($Disable) {
        $env:TF_LOG = $null
        $env:TF_LOG_PROVIDER = $null
        $env:TF_LOG_PATH = $null
        Write-Host "Terraform debugging has been disabled."
    }
    else {
        if ($ProviderOnly) {
            $env:TF_LOG = $null
            $env:TF_LOG_PROVIDER = $Level
            Write-Host "Terraform provider log level set to: $Level"
        }
        else {
            $env:TF_LOG = $Level
            $env:TF_LOG_PROVIDER = $null
            Write-Host "Terraform log level set to: $Level"
        }

        if (-not $LogPath) {
            $logType = if ($ProviderOnly) { "provider" } else { "core" }
            $LogPath = "terraform_${logType}_$($Level.ToLower()).log"
        }

        $env:TF_LOG_PATH = $LogPath
        Write-Host "Terraform log path set to: $LogPath"
    }
}

###
# Terraform providers
###
$env:ARM_SUBSCRIPTION_ID = "abcdefgh-1234567890-abcdefgh" # prod
$env:ARM_SUBSCRIPTION_ID = "abcdefgh-1234567890-abcdefgh" # dev

function dev { az account set --name 'mydev' }
function prod { az account set --name 'myprod' }


function New-AzureSSHKeys {
    param (
        [string]$IPAddress = "*",
        [string]$OutputFile = "azure-sshconfig",
        [string]$KeysDestinationFolder = "azure-keys"
    )
    az ssh config --ip $IPAddress --file $OutputFile --keys-destination-folder $KeysDestinationFolder
}
function Create-AzureSSHKeys {
    New-AzureSSHKeys
}

###
# Miscellaneous shortcut functions
###
function Get-CompiledProjectSummary {
    [CmdletBinding()]
    [Alias('Prepare-OutputForClaude')]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet('Terraform', 'FlaskBootstrap', 'Auto')]
        [string]$ProjectType = 'Auto',

        [Parameter(Mandatory=$false)]
        [string]$OutputFile = "output.md"
    )

    $appName = (Get-Item -Path .).Name
    Remove-Item $OutputFile -ErrorAction SilentlyContinue

    function Detect-ProjectType {
        if (Get-ChildItem -Path . -Recurse -Include *.tf -ErrorAction SilentlyContinue) {
            return 'Terraform'
        }
        elseif (Get-ChildItem -Path . -Recurse -Include *.py -ErrorAction SilentlyContinue) {
            return 'FlaskBootstrap'
        }
        else {
            Write-Host "Unable to detect project type. Please specify manually."
            return $null
        }
    }

    if (-not $PSBoundParameters.ContainsKey('ProjectType') -or $ProjectType -eq 'Auto') {
        $ProjectType = Detect-ProjectType
        if ($null -eq $ProjectType) {
            return
        }
        Write-Host "Detected project type: $ProjectType"
    }

    $fileTypes = @()
    $excludePaths = @()

    switch ($ProjectType) {
        'Terraform' {
            $fileTypes = @("*.tf", "*.conf")
        }
        'FlaskBootstrap' {
            $fileTypes = @("*.py", "*.html")
            $excludePaths = @("*\.venv\*", "*\migrations\*")
        }
    }

    foreach ($fileType in $fileTypes) {
        $files = Get-ChildItem -Path . -Recurse -Include $fileType
        
        if ($excludePaths.Count -gt 0) {
            $files = $files | Where-Object {
                $file = $_
                -not ($excludePaths | Where-Object { $file.FullName -like $_ })
            }
        }

        foreach ($file in $files) {
            $relativePath = $file.FullName.Replace("$PWD\", "")
            $extension = $file.Extension.TrimStart('.')
            
            "## File: $relativePath`n" | Out-File -Append -FilePath $OutputFile
            "``````$extension" | Out-File -Append -FilePath $OutputFile
            Get-Content $file.FullName | Out-File -Append -FilePath $OutputFile
            "``````" | Out-File -Append -FilePath $OutputFile
            "`n" | Out-File -Append -FilePath $OutputFile
        }
    }

    Write-Host "Project summary compiled in $OutputFile"
}
