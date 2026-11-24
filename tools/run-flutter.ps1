param(
    [Parameter(Mandatory)]
    [ValidateSet('Web', 'Android')]
    [string] $Target
)

$ErrorActionPreference = 'Stop'
$projectDir = Split-Path -Parent $PSScriptRoot
$sdkEntry = Select-String -LiteralPath (Join-Path $projectDir 'android/local.properties') `
    -Pattern '^flutter\.sdk=(.+)$' -ErrorAction SilentlyContinue | Select-Object -First 1

if ($sdkEntry) {
    $sdkPath = $sdkEntry.Matches[0].Groups[1].Value.Replace('\\', '\').Replace('\:', ':')
    $flutter = Join-Path $sdkPath 'bin/flutter.bat'
} else {
    $flutter = (Get-Command flutter.bat -ErrorAction SilentlyContinue).Source
}

if (!$flutter -or !(Test-Path -LiteralPath $flutter -PathType Leaf)) {
    throw 'Flutter SDK not found. Set flutter.sdk in android/local.properties or add Flutter to PATH.'
}

Push-Location -LiteralPath $projectDir
try {
    $device = 'chrome'
    if ($Target -eq 'Android') {
        $deviceJson = & $flutter devices --machine
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

        $devices = ($deviceJson -join "`n") | ConvertFrom-Json
        $androidDevices = @($devices | Where-Object { $_.targetPlatform -like 'android-*' })
        if ($androidDevices.Count -eq 0) {
            throw 'No Android device detected. Start the emulator in Device Manager or connect a phone with USB debugging.'
        }
        if ($androidDevices.Count -gt 1) {
            $choices = ($androidDevices | ForEach-Object { "$($_.name) ($($_.id))" }) -join ', '
            throw "Multiple Android devices detected: $choices. Use the Flutter configuration to select one."
        }
        $device = $androidDevices[0].id
    }

    & $flutter run -d $device -t lib/core/main.dart
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
