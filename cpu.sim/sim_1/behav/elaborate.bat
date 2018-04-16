@echo off
set xv_path=C:\\Xilinx\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto dfad7b2dc76c43a29158bebdcbde4fa8 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L secureip -L xpm --snapshot cputb1_behav xil_defaultlib.cputb1 -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
