param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')
$projectPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
# Visible window is the requested interactive game test.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList @('--path', ('"' + $projectPath + '"'), '--resolution', '1280x720', '--script', 'res://tools/launch_king_skills.gd') -PassThru | Select-Object Id, ProcessName
