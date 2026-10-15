$ErrorActionPreference = 'Stop'
$artifactRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$analysisRoot = Join-Path $artifactRoot 'experiment_data\analysis'

$jsonFiles = Get-ChildItem -LiteralPath (Join-Path $artifactRoot 'experiment_data') -Recurse -File -Filter '*.json'
foreach ($file in $jsonFiles) {
    $null = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
}

$csvFiles = Get-ChildItem -LiteralPath (Join-Path $artifactRoot 'experiment_data') -Recurse -File -Filter '*.csv'
foreach ($file in $csvFiles) {
    if (@(Import-Csv -LiteralPath $file.FullName).Count -eq 0) {
        throw "Empty CSV: $($file.FullName)"
    }
}

$sbCount = (Get-ChildItem -LiteralPath (Join-Path $artifactRoot 'experiment_data\datasets\smartbugs_curated') -Recurse -File -Filter '*.sol').Count
$ercCount = (Get-ChildItem -LiteralPath (Join-Path $artifactRoot 'experiment_data\datasets\erc_semantic_suite\contracts') -File -Filter '*.sol').Count
if ($sbCount -ne 143) { throw "Expected 143 SmartBugs inputs, found $sbCount" }
if ($ercCount -ne 35) { throw "Expected 35 ERC inputs, found $ercCount" }

$payload = Join-Path $analysisRoot 'rq6_replay_traceability\evidence\frozen\finding_payloads.json'
if (-not (Test-Path -LiteralPath $payload)) { throw 'RQ6 frozen payload is missing' }

$legacyMatches = Get-ChildItem -LiteralPath (Join-Path $artifactRoot 'system_source') -Recurse -File |
    Where-Object { $_.Extension -in @('.py', '.sol', '.md', '.json', '.txt', '.toml', '.yml', '.yaml') } |
    Select-String -Pattern 'confuzzius' -CaseSensitive:$false
if ($legacyMatches) { throw 'Legacy product branding remains in system_source' }

$forbiddenTitle = ('Con' + 'Fuzzius') + ' Full-' + 'System Release'
$forbidden = Get-ChildItem -LiteralPath $artifactRoot -Recurse -File |
    Where-Object { $_.Length -lt 10MB -and $_.Extension -in @('.py', '.sol', '.md', '.json', '.txt', '.toml', '.yml', '.yaml', '.csv') } |
    Select-String -SimpleMatch $forbiddenTitle
if ($forbidden) { throw 'Forbidden release title remains in the artifact' }

$junk = Get-ChildItem -LiteralPath $artifactRoot -Recurse -Force |
    Where-Object { $_.Name -in @('.env', '.git', '__pycache__', '.pytest_cache') -or $_.Extension -in @('.pyc', '.pyo') }
if ($junk) { throw "Generated/private entries found: $($junk.FullName -join ', ')" }

python -B (Join-Path $PSScriptRoot 'audit_reported_results.py') | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Reported-result audit failed' }

Write-Output "JSON_VALIDATED=$($jsonFiles.Count)"
Write-Output "CSV_VALIDATED=$($csvFiles.Count)"
Write-Output "SMARTBUGS_INPUTS=$sbCount"
Write-Output "ERC_INPUTS=$ercCount"
Write-Output 'REPORTED_RESULTS=PASS_WITH_ONE_DOCUMENTED_RQ4_SOURCE_SNAPSHOT_DISCREPANCY'
Write-Output 'ARTIFACT_VERIFY=PASS'
