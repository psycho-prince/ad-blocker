# Set Error Action Preference
$ErrorActionPreference = 'SilentlyContinue'

# Elevate privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator" -ForegroundColor Red
    exit
}

# Set script root directory
$scriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Set-Location -Path $scriptRoot

# Ad blocker project info
Write-Host "Implementing simeononsecurity/System-Wide-Windows-Ad-Blocker" -ForegroundColor Green
Write-Host "https://github.com/simeononsecurity/System-Wide-Windows-Ad-Blocker" -ForegroundColor Green

# Hosts file path
$hostsFilePath = if ($IsWindows) {
    "$env:SystemRoot\System32\drivers\etc\hosts"
} else {
    "/etc/hosts"
}

# Download hosts file
$repoUrl1 = 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
$outputFilePath = Join-Path $scriptRoot "hosts.txt"

try {
    Invoke-WebRequest -Uri $repoUrl1 -OutFile $outputFilePath
    Write-Host "Downloaded hosts file to $outputFilePath" -ForegroundColor Green

    # Replace system hosts file
    if (Test-Path $hostsFilePath) {
        Copy-Item -Path $outputFilePath -Destination $hostsFilePath -Force
        Write-Host "System hosts file updated successfully." -ForegroundColor Green
    } else {
        Write-Host "Hosts file path not found: $hostsFilePath" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: Unable to download or update hosts file." -ForegroundColor Red
}

# DNS cache handling
if ($IsWindows) {
    Write-Host "Flushing DNS cache (Windows)..."
    Stop-Service -Name Dnscache
    Start-Service -Name Dnscache
} else {
    Write-Host "Flushing DNS cache (Unix-based)..."
    sudo systemd-resolve --flush-caches
}
