#########################################
# Copyright (C):2025
# File Name:makefile
# Author:niuzhaoyi
# Date:Sat 31 May 2025 23:52:00 PM CST
# Description: makefile for de flow
# Modified by: niuzhaoyi
# Email: nzy15854811501@163.com
#########################################
TOP_MODULE = tb_lz4_compressor
FILE_LIST = vcs_filelist.f
DC_FLOW_ROOT = /home/ICer/FLOW/dc_flow

DC_WORK_DIR = dc
DC_CONFIG_FILE = dc_config.py

run_all:
	./vcs_simulation_script ${TOP_MODULE} ${FILE_LIST}

run_com:
	./vcs_simulation_script ${TOP_MODULE} ${FILE_LIST} --compile

run_sim:
	./vcs_simulation_script ${TOP_MODULE} ${FILE_LIST} --simulate

clean:
	rm -rf *.log sim* csrc/ ucli.key *.pvl *.syn *.mr *.svf *.fsdb *.rpt

dc_env_gen:
	python3 ${DC_FLOW_ROOT}/dc_env_gen.py --output ${DC_WORK_DIR} --config ${DC_CONFIG_FILE}
run_dc:
	cd dc/work && dc_shell -f ../scripts/dc_run.tcl | tee ../../dc.log

