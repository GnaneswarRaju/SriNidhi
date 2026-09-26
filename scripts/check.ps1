param([string]$Flutter = 'flutter', [string]$Dart = 'dart')
$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '../app')
try {
  & $Flutter pub get --enforce-lockfile
  if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed' }
  & $Dart run build_runner build
  if ($LASTEXITCODE -ne 0) { throw 'Code generation failed' }
  & $Flutter gen-l10n
  if ($LASTEXITCODE -ne 0) { throw 'Localization generation failed' }
  & $Dart format --output=none --set-exit-if-changed lib test tool
  if ($LASTEXITCODE -ne 0) { throw 'Formatting failed' }
  & $Flutter analyze --fatal-infos
  if ($LASTEXITCODE -ne 0) { throw 'Analysis failed' }
  & $Flutter test
  if ($LASTEXITCODE -ne 0) { throw 'Tests failed' }
  & $Flutter build web --release --no-web-resources-cdn
  if ($LASTEXITCODE -ne 0) { throw 'Web build failed' }
} finally { Pop-Location }
