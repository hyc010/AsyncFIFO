# ============================================================
# AsyncFIFO UVM simulation script (Vivado XSim 2024.2)
# PowerShell version - works around .bat quirks
# Usage:  powershell -ExecutionPolicy Bypass -File .\run_xsim.ps1
# Or:     .\run_xsim.ps1   (if execution policy allows)
# Edit TEST_NAME / SIM_TIME below to switch test or duration
# ============================================================

param(
    [string]$TestName = $(if ($env:UVM_TESTNAME) { $env:UVM_TESTNAME } else { "basic_1w1r_test" }),
    [string]$SimTime  = "10us",
    [string]$CoverageDir = "cov_runs"
)

$ErrorActionPreference = "Stop"

$VivadoBin = "D:\Xilinx\Vivado\2024.2\bin"
$SimDir    = $PSScriptRoot

$env:Path = "$VivadoBin;$env:Path"
Set-Location $SimDir

Write-Host "=== Step 1: xvlog compile ===" -ForegroundColor Cyan
if (Test-Path xsim.dir) { Remove-Item -Recurse -Force xsim.dir }
New-Item -ItemType Directory -Force -Path $CoverageDir | Out-Null
$testCovDb = Join-Path $CoverageDir "xsim.covdb\$TestName"
if (Test-Path $testCovDb) { Remove-Item -Recurse -Force $testCovDb }
"``define SELECTED_TEST `"$TestName`"" | Out-File -FilePath "..\tb\test_select.svh" -Encoding ascii
& xvlog -sv -f filelist.f -L uvm
if ($LASTEXITCODE -ne 0) { throw "xvlog failed" }

Write-Host "`n=== Step 2: xelab elaborate ===" -ForegroundColor Cyan
& xelab -L uvm -debug typical --cov_db_dir $CoverageDir --cov_db_name $TestName tb_top
if ($LASTEXITCODE -ne 0) { throw "xelab failed" }

Write-Host "`n=== Step 3: xsim run test=$TestName time=$SimTime coverage=$CoverageDir ===" -ForegroundColor Cyan

# Write TCL script (use relative path to avoid TCL backslash escaping issues)
$tclFile = "run_tmp.tcl"
"run $SimTime" | Out-File -FilePath $tclFile -Encoding ascii
"quit"          | Out-File -FilePath $tclFile -Append -Encoding ascii

# Run simulation and save this test's functional coverage database
& xsim --cov_db_dir $CoverageDir --cov_db_name $TestName --tclbatch $tclFile work.tb_top
if ($LASTEXITCODE -ne 0) { throw "xsim failed" }

Remove-Item $tclFile -ErrorAction SilentlyContinue
Write-Host "`n=== Simulation done ===" -ForegroundColor Green
