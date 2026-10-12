param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe')
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
$reviewArgs = @('--path', ('"' + $projectPath + '"'), '--resolution', '1280x720', '--script', 'res://tools/launch_combat_impact_review.gd')
# Owner-facing interactive review with isolated storage and rewardless enemies.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $reviewArgs -PassThru | Select-Object Id,ProcessName
