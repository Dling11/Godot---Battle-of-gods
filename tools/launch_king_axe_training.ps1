param(
    [string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe',
    [string]$LogPath = ''
)
$ErrorActionPreference = 'Stop'
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
$trainingArgs = @('--path', ('"' + $projectPath + '"'), '--rendering-method', 'gl_compatibility', '--resolution', '1280x720', '--script', 'res://tools/launch_king_axe_training.gd')
if ($LogPath) { $trainingArgs += @('--log-file', ('"' + $LogPath + '"')) }
# Explicitly requested interactive weapon test, using normal training controls.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $trainingArgs -PassThru | Select-Object Id,ProcessName
