param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')
$ErrorActionPreference = 'Stop'
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) { throw "Godot executable not found: $GodotPath" }
$gameProcess = Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList @('--path', ('"' + $projectPath + '"'), 'res://levels/combat_lab/combat_lab.tscn', '--', '--weapon-review=weapon_king_iron_reaper') -PassThru
Write-Output "Iron Reaper Combat Lab launched, PID $($gameProcess.Id). WASD, hold LMB, Tab Bag; Weapons tab switches equipment."
