# ============================================================
# AsyncFIFO UVM regression + merged functional coverage report
# Vivado XSim 2024.2
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\run_regression.ps1
#   .\run_regression.ps1 -Tests basic_1w1r_test,write_full_test,read_empty_test
# ============================================================

param(
    [string[]]$Tests = @("basic_1w1r_test", "write_full_test", "read_empty_test"),
    [string]$SimTime = "10us",
    [string]$CoverageDir = "cov_runs",
    [string]$MergeDir = "cov_merged",
    [string]$MergeDbName = "asyncfifo_regression_merged",
    [string]$ReportDir = "cov_report"
)

$ErrorActionPreference = "Stop"
$SimDir = $PSScriptRoot
Set-Location $SimDir

$VivadoRoot = "D:\Xilinx\Vivado\2024.2"
$VivadoBin = Join-Path $VivadoRoot "bin"
$env:XILINX_VIVADO = $VivadoRoot
$env:Path = "$VivadoBin;$env:Path"

Write-Host "=== AsyncFIFO regression start ===" -ForegroundColor Cyan
Write-Host "Tests       : $($Tests -join ', ')"
Write-Host "SimTime     : $SimTime"
Write-Host "CoverageDir : $CoverageDir"
Write-Host "MergeDir    : $MergeDir"
Write-Host "ReportDir   : $ReportDir"

# Clean previous regression artifacts.
foreach ($path in @($CoverageDir, $MergeDir, $ReportDir, "regression_logs")) {
    if (Test-Path $path) { Remove-Item -Recurse -Force $path }
}
New-Item -ItemType Directory -Force -Path "regression_logs" | Out-Null

foreach ($test in $Tests) {
    Write-Host "`n=== Running $test ===" -ForegroundColor Cyan
    & .\run_xsim.ps1 -TestName $test -SimTime $SimTime -CoverageDir $CoverageDir
    if ($LASTEXITCODE -ne 0) { throw "Test failed: $test" }

    if (Test-Path "xsim.log") {
        Copy-Item "xsim.log" "regression_logs\$test.xsim.log" -Force
    }
}

Write-Host "`n=== Merge coverage databases with xcrg ===" -ForegroundColor Cyan

$covDbList = "covdblist.txt"
$Tests | ForEach-Object { "$CoverageDir/xsim.covdb/$_" } | Out-File -FilePath $covDbList -Encoding ascii

& xcrg -file $covDbList `
       -merge_dir $MergeDir `
       -merge_db_name $MergeDbName `
       -report_dir $ReportDir `
       -report_format all `
       -log "regression_logs\xcrg.log"
if ($LASTEXITCODE -ne 0) { throw "xcrg coverage merge/report failed" }

$textReport = Join-Path $ReportDir "functionalCoverageReport\xcrg_func_cov_report.txt"
$htmlReport = Join-Path $ReportDir "functionalCoverageReport\dashboard.html"
$mergedDb   = Join-Path $MergeDir "xsim.covdb\$MergeDbName"

if (!(Test-Path $textReport)) { throw "Coverage text report was not generated: $textReport" }

Write-Host "`n=== Regression done ===" -ForegroundColor Green
Write-Host "Merged DB   : $mergedDb"
Write-Host "Report dir  : $ReportDir\functionalCoverageReport"
Write-Host "Text report : $textReport"
Write-Host "HTML report : $htmlReport"

Write-Host "`n=== Coverage report summary grep ===" -ForegroundColor Cyan
Select-String -Path $textReport -Pattern "Coverage Score|Number of Tests|afifo_test_pkg::afifo_coverage::wr_cg|afifo_test_pkg::afifo_coverage::rd_cg|cross_winc_wfull|cross_rinc_rempty|cp_wdata|cp_rdata" | Select-Object -First 80
