# Define the KB file names
$kbList = @(
    "windows11.0-kb5046617-x64_1e5d7b716c0747592ae80c218f1d81bbb7b0c7ab.msu",
    "windows11.0-kb5043080-x64_953449672073f8fb99badb4cc6d5d7849b9c83e8.msu"
   
)

foreach ($kbFile in $kbList) {
    # Extract KB number from filename
    $kbId = ($kbFile -split '-')[1]

    # Check if KB is already installed
    if (Get-HotFix | Where-Object { $_.HotFixID -eq $kbId }) {
        Write-Output "$kbId is already installed. Skipping..."
        continue
    }

    # Ensure the KB file exists
    if (!(Test-Path -Path $kbFile)) {
        Write-Error "KB file $kbFile not found. Please download it first."
        exit 1
    }

    # Install the KB update silently
    try {
        Write-Output "Installing $kbFile..."
        $process = Start-Process -FilePath "wusa.exe" -ArgumentList "$kbFile /quiet /norestart" -PassThru -Wait -NoNewWindow
        Write-Output "wusa.exe exited with code $($process.ExitCode)"
    } catch {
        Write-Error "Failed to install ${kbFile}: $_"
        exit 1
    }
}

# Create the Intune flag in the registry
try {
    Write-Output "Creating Intune flag in registry..."
    New-Item -Path "HKLM:\SOFTWARE\IntuneFlags" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\IntuneFlags" -Name "kb5046617" -PropertyType DWORD -Value 1 -Force | Out-Null
    Write-Output "Registry flag created successfully."
} catch {
    Write-Error "Failed to create registry flag: $_"
    exit 1
}

# Script End
Write-Output "Script completed successfully."
