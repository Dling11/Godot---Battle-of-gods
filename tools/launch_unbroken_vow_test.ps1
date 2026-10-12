param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')

$projectPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
# Visible window is intentional: this is the owner's interactive test launcher.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList @('--path', ('"' + $projectPath + '"'), '--script', 'res://tools/launch_unbroken_vow_test.gd') -PassThru | Select-Object Id, ProcessName
