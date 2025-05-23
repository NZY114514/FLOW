
dc_run:
	dc_shell -f ../scripts/dc_run.tcl | tee ../log/$$(log +'%Y-%m-%d')
clean:
	find . -type f ! -name 'makefile' -exec rm -f {} +
	