#!/bin/bash
# ============================================================
# AsyncFIFO UVM 仿真脚本 (Vivado XSim 2024.2) - Linux/Mac
# 用法:  ./run_xsim.sh
# 改 TEST_NAME 可以切换测试用例
# ============================================================

VIVADO_BIN=${VIVADO_BIN:-/opt/Xilinx/Vivado/2024.2/bin}
SIM_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_NAME=${TEST_NAME:-basic_1w1r_test}
SIM_TIME=${SIM_TIME:-1us}

export PATH="$VIVADO_BIN:$PATH"
cd "$SIM_DIR" || exit 1

echo "=== 1. xvlog 编译 ==="
rm -rf xsim.dir
xvlog -sv -f filelist.f -L uvm || { echo "xvlog 失败"; exit 1; }

echo
echo "=== 2. xelab 链接 ==="
xelab -L uvm -debug typical tb_top || { echo "xelab 失败"; exit 1; }

echo
echo "=== 3. xsim 运行 test=$TEST_NAME ==="
cat > run_tmp.tcl <<EOF
run $SIM_TIME
quit
EOF

xsim --tclbatch run_tmp.tcl work.tb_top
rm -f run_tmp.tcl
echo
echo "=== 仿真结束 ==="
