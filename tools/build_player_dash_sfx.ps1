param(
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\assets\audio\sfx\player_dash_grounded.wav')
)

# Deterministic short boot/cloth movement cue. No rising tone or repeated pulses.
$sampleRate = 44100
$sampleCount = [int]($sampleRate * 0.19)
$samples = [double[]]::new($sampleCount)
$random = [System.Random]::new(73821)
$filteredNoise = 0.0
$peak = 0.001

for ($index = 0; $index -lt $sampleCount; $index++) {
    $time = $index / $sampleRate
    $rawNoise = $random.NextDouble() * 2.0 - 1.0
    $filteredNoise += ($rawNoise - $filteredNoise) * 0.16
    $onset = 1.0 - [math]::Exp(-900.0 * $time)
    $boot = [math]::Sin(2.0 * [math]::PI * (145.0 * $time - 140.0 * $time * $time))
    $boot *= $onset * [math]::Exp(-27.0 * $time) * 0.46
    $cloth = $filteredNoise * (1.0 - [math]::Exp(-120.0 * $time)) * [math]::Exp(-20.0 * $time) * 0.28
    $air = ($rawNoise - $filteredNoise) * (1.0 - [math]::Exp(-85.0 * $time)) * [math]::Exp(-25.0 * $time) * 0.09
    $sample = $boot + $cloth + $air
    $samples[$index] = $sample
    $peak = [math]::Max($peak, [math]::Abs($sample))
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
[System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($resolvedOutput)) | Out-Null
$writer = [System.IO.BinaryWriter]::new([System.IO.File]::Create($resolvedOutput))
try {
    $byteCount = $sampleCount * 2
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes('RIFF'))
    $writer.Write([int](36 + $byteCount))
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes('WAVE'))
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes('fmt '))
    $writer.Write([int]16)
    $writer.Write([int16]1)
    $writer.Write([int16]1)
    $writer.Write([int]$sampleRate)
    $writer.Write([int]($sampleRate * 2))
    $writer.Write([int16]2)
    $writer.Write([int16]16)
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes('data'))
    $writer.Write([int]$byteCount)
    foreach ($sample in $samples) {
        $limited = [math]::Max(-1.0, [math]::Min(1.0, $sample * 0.62 / $peak))
        $writer.Write([int16][math]::Round($limited * 32767.0))
    }
} finally {
    $writer.Dispose()
}

Write-Output "Built $resolvedOutput"
