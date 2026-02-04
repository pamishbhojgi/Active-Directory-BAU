# Import Active Directory module with error handling
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "Active Directory module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to import Active Directory module. Please ensure RSAT-AD-PowerShell is installed."
    exit 1
}

# Server and credential setup

$server="domainControllerName"

# Get credentials with validation
try {
    $cred = Get-Credential -Admin_UserName "domainName uid" -Message "Enter Password"
    if (-not $cred) {
        Write-Error "Credential input was cancelled or invalid."
        exit 1
    }
    Write-Host "Credentials obtained successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to get credentials: $($_.Exception.Message)"
    exit 1
}

# Test server connectivity
try {
    Write-Host "Testing connection to AD server: $server" -ForegroundColor Yellow
    $testConnection = Test-NetConnection -ComputerName $server -Port 389 -WarningAction SilentlyContinue
    if (-not $testConnection.TcpTestSucceeded) {
        Write-Error "Cannot connect to AD server $server on port 389"
        exit 1
    }
    Write-Host "Successfully connected to AD server" -ForegroundColor Green
}
catch {
    Write-Warning "Could not test server connectivity: $($_.Exception.Message)"
}

# Check account lockout status
Write-Host "`n--- Checking Account Lockout Status ---" -ForegroundColor Cyan
try {
    $user = Get-ADUser userName -Server $server -Credential $cred -Properties LockedOut
    if ($user.LockedOut) {
        Write-Host "Account 'username' is locked out." -ForegroundColor Red
        
        # Unlock the account
        Write-Host "`n--- Unlocking Account ---" -ForegroundColor Yellow
        Unlock-ADAccount -Identity userName-Server $server -Credential $cred
        Write-Host "Account 'userName' has been unlocked successfully." -ForegroundColor Green
    } else {
        Write-Host "Account 'userName' is not locked out." -ForegroundColor Green
    }
}
catch {
    Write-Error "Failed to process account 'userName': $($_.Exception.Message)"
}


 