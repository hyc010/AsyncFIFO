@echo off
REM ============================================================
REM AsyncFIFO UVM simulation script (Vivado XSim 2024.2)
REM Usage: run_xsim.bat
REM Edit TEST_NAME / SIM_TIME below to switch test or duration
REM Output: sim_output.txt in this directory
REM ============================================================

setlocal

set VIVADO_BIN=D:\Xilinx\Vivado\2024.2\bin
set SIM_DIR=%~dp0
set TEST_NAME=basic_1w1r_test
set SIM_TIME=1us

set PATH=%VIVADO_BIN%;%PATH%

echo === Step 1: xvlog compile ===
cd /d "%SIM_DIR%"
if exist xsim.dir rmdir /s /q xsim.dir
xvlog -sv -f filelist.f -L uvm

echo.
echo === Step 2: xelab elaborate ===
xelab -L uvm -debug typical tb_top

echo.
echo === Step 3: xsim run test=%TEST_NAME% time=%SIM_TIME% ===
(
    echo run %SIM_TIME%
    echo quit
) > run_tmp.tcl

xsim --tclbatch run_tmp.tcl work.tb_top

del run_tmp.tcl
echo.
echo === Simulation done. ===

endlocal
