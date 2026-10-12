param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe', [switch]$Stage5)
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
$reviewArgs = @('--path', ('"' + $projectPath + '"'), '--resolution', '1280x720', '--script', 'res://tools/launch_expedition_review.gd')
if ($Stage5) { $reviewArgs += @('--', '--stage-5') }
# Visible window is the requested interactive game review.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $reviewArgs -PassThru | Select-Object Id, ProcessName
