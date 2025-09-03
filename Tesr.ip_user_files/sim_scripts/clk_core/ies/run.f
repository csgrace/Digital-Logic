-makelib ies_lib/xil_defaultlib -sv \
  "F:/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "F:/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "F:/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../Tesr.srcs/sources_1/new/clk_core/clk_core_clk_wiz.v" \
  "../../../../Tesr.srcs/sources_1/new/clk_core/clk_core.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

