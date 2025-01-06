# Ensure the script runs as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    exit
}

# Check for Python installation
Write-Host "Checking for Python installation..."
try {
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Write-Host "Python is not installed. Downloading Python 3.13.1..."
        $pythonInstaller = "https://www.python.org/ftp/python/3.13.1/python-3.13.1-amd64.exe"
        $installerPath = "$env:TEMP\python-3.13.1-amd64.exe"
        Invoke-WebRequest -Uri $pythonInstaller -OutFile $installerPath
        Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
        Remove-Item $installerPath
        Write-Host "Python installed successfully."
    } else {
        Write-Host "Python is already installed."
    }
} catch {
    Write-Host "Error checking or installing Python: $_" -ForegroundColor Red
    exit
}

# Clone the repository
Write-Host "Cloning the repository..."
try {
    if (-not (Test-Path "Automated-AI-Web-Researcher-Ollama")) {
        git clone https://github.com/hafeezhmha/Automated-AI-Web-Researcher-Ollama.git
    }
    Set-Location Automated-AI-Web-Researcher-Ollama
} catch {
    Write-Host "Error cloning the repository: $_" -ForegroundColor Red
    exit
}

# Checkout the feature branch
Write-Host "Checking out the feature/windows-support branch..."
try {
    git checkout -b feature/windows-support origin/feature/windows-support
} catch {
    Write-Host "Error checking out the branch: $_" -ForegroundColor Red
    exit
}

# Create and activate virtual environment
Write-Host "Setting up the virtual environment..."
try {
    python -m venv venv
    & .\venv\Scripts\activate
} catch {
    Write-Host "Error setting up virtual environment: $_" -ForegroundColor Red
    exit
}

# Install dependencies
Write-Host "Installing dependencies..."
try {
    pip install -r requirements.txt
} catch {
    Write-Host "Error installing dependencies: $_" -ForegroundColor Red
    exit
}

# Check for Ollama installation
Write-Host "Checking for Ollama installation..."
try {
    $ollamaPath = Get-Command ollama -ErrorAction SilentlyContinue
    if (-not $ollamaPath) {
        Write-Host "Ollama is not installed. Downloading and installing Ollama..."
        $ollamaInstaller = "https://ollama.ai/download/windows"
        $installerPath = "$env:TEMP\OllamaInstaller.exe"
        Invoke-WebRequest -Uri $ollamaInstaller -OutFile $installerPath
        Start-Process -FilePath $installerPath -ArgumentList "/quiet" -Wait
        Remove-Item $installerPath
        Write-Host "Ollama installed successfully."
    } else {
        Write-Host "Ollama is already installed."
    }
} catch {
    Write-Host "Error checking or installing Ollama: $_" -ForegroundColor Red
    exit
}

# Configure the model
Write-Host "Configuring the custom Ollama model..."
try {
    $modelfilePath = "modelfile"
    $modelName = Read-Host "Enter your chosen model name (e.g., phi3:medium-128k)"
    $modelfileContent = @"
FROM $modelName

PARAMETER num_ctx 38000
"@
    Set-Content -Path $modelfilePath -Value $modelfileContent
} catch {
    Write-Host "Error configuring the model file: $_" -ForegroundColor Red
    exit
}

# Create the model
Write-Host "Creating the custom Ollama model..."
try {
    ollama create research-phi3 -f $modelfilePath
    Write-Host "Setup complete! You are ready to use the Automated-AI-Web-Researcher-Ollama."
} catch {
    Write-Host "Error creating the Ollama model: $_" -ForegroundColor Red
    exit
}
