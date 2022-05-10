
create_clock -period 40.000 -name CLK_25M [get_ports FPGA_25M]
create_clock -period 3.300 -name DAC0_REF_CLKP [get_ports DAC0_REF_CLKP]
create_clock -period 3.300 -name DAC1_REF_CLKP [get_ports DAC1_REF_CLKP]
create_clock -period 4.000 -name LVDS_I_CLKP [get_ports LVDS_I_CLKP]
create_clock -period 4.000 -name VPX_DCO_CLKP [get_ports VPX_DCO_CLKP]
create_clock -period 10.000 -name CLK_100M_0 [get_ports FPGA_DDR4_100M_CLK0P]
create_clock -period 10.000 -name CLK_100M_1 [get_ports FPGA_DDR4_100M_CLK1P]
create_clock -period 8.000 -name CLK_100M_2 [get_ports GTH_REF_CLKP]
create_clock -period 8.000 -name CLK_100M_3 [get_ports REFCLK_P]


create_generated_clock -name CLK_50M [get_pins U00_CLK_RST_GEN/PLLE2_BASE_inst/CLKOUT0]
create_generated_clock -name SYS_CLK [get_pins U00_CLK_RST_GEN/PLLE2_BASE_inst/CLKOUT1]
create_generated_clock -name CLK_250M [get_pins U00_CLK_RST_GEN/PLLE2_BASE_inst/CLKOUT2]
create_generated_clock -name CLK_125M [get_pins U00_CLK_RST_GEN/PLLE2_BASE_inst/CLKOUT3]
create_generated_clock -name CLK_500M [get_pins U00_CLK_RST_GEN/PLLE2_BASE_inst/CLKOUT4]

set_clock_groups -group [get_clocks CLK_50M -include_generated_clocks] -asynchronous
set_clock_groups -group [get_clocks CLK_100M_2 -include_generated_clocks] -asynchronous
set_clock_groups -group [get_clocks CLK_100M_3 -include_generated_clocks] -asynchronous

set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks CLK_100M_2]
set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks CLK_100M_3]
set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks DAC0_REF_CLKP]
set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks DAC1_REF_CLKP]
set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks VPX_DCO_CLKP]
set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks CLK_100M_0]
set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks CLK_100M_1]
set_clock_groups -asynchronous -group [get_clocks CLK_50M] -group [get_clocks -include_generated_clocks LVDS_I_CLKP]

