# ==============================================================================
# Ansible Lab Windows Host Setup Script (PowerShell)
# Installs Vagrant, checks Hyper-V/VirtualBox, and prepares Windows environment
# ==============================================================================

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "   Ansible Lab - Windows Host Environment Setup      " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# 1. Check Administrator Privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Please run this script in PowerShell as Administrator for full setup (required for Hyper-V features)."
}

# 2. Check Package Manager (winget / choco)
Write-Host "`n[1/4] Checking Package Manager (winget)..." -ForegroundColor Yellow
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue

# 3. Check / Install Vagrant
Write-Host "`n[2/4] Checking Vagrant installation..." -ForegroundColor Yellow
if (-not (Get-Command vagrant -ErrorAction SilentlyContinue)) {
    if ($hasWinget) {
        Write-Host "Installing HashiCorp Vagrant via winget..." -ForegroundColor Green
        winget install -e --id HashiCorp.Vagrant --accept-package-agreements --accept-source-agreements
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Installing Vagrant via Chocolatey..." -ForegroundColor Green
        choco install vagrant -y
    } else {
        Write-Warning "Neither winget nor choco found. Please download Vagrant from: https://developer.hashicorp.com/vagrant/install"
    }
} else {
    $vVersion = vagrant --version
    Write-Host "✓ Vagrant is already installed: $vVersion" -ForegroundColor Green
}

# 4. Check Hypervisor (Hyper-V / VirtualBox)
Write-Host "`n[3/4] Checking Hypervisors..." -ForegroundColor Yellow

$hypervFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
if ($hypervFeature -and $hypervFeature.State -eq "Enabled") {
    Write-Host "✓ Hyper-V is enabled and available." -ForegroundColor Green
} else {
    Write-Host "ℹ Hyper-V is not enabled. You can enable it with: Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All" -ForegroundColor Gray
}

$vbox = Get-Command VBoxManage -ErrorAction SilentlyContinue
if ($vbox) {
    Write-Host "✓ VirtualBox is detected: $($vbox.Source)" -ForegroundColor Green
}

# 5. Check OpenSSH Client
Write-Host "`n[4/4] Checking Windows OpenSSH Client..." -ForegroundColor Yellow
if (Get-Command ssh -ErrorAction SilentlyContinue) {
    Write-Host "✓ OpenSSH Client is ready." -ForegroundColor Green
} else {
    Write-Host "Installing OpenSSH Client..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 -ErrorAction SilentlyContinue
}

Write-Host "`n=====================================================" -ForegroundColor Cyan
Write-Host "✓ Windows environment check complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "To launch the lab, run:"
Write-Host "  vagrant up --provider=hyperv" -ForegroundColor Yellow
Write-Host "  (or: vagrant up --provider=virtualbox)" -ForegroundColor Yellow
