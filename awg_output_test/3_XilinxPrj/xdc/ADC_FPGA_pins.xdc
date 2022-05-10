################################################################################
## 25M Clock & Reset Pins Interface
#Bank-45
set_property PACKAGE_PIN AM26 [get_ports FPGA_25M]
set_property IOSTANDARD LVCMOS18 [get_ports FPGA_25M]

#Bank-65
set_property PACKAGE_PIN AL14 [get_ports SYSTEM_RSTn]
set_property IOSTANDARD LVCMOS33 [get_ports SYSTEM_RSTn]

################################################################################
## Clock Generate By PLL HMC7044 Interface
set_property PACKAGE_PIN AH10 [get_ports ADC0_REF_CLKP]
set_property PACKAGE_PIN AH9 [get_ports ADC0_REF_CLKN]
set_property PACKAGE_PIN AT10 [get_ports ADC1_REF_CLKP]
set_property PACKAGE_PIN AT9 [get_ports ADC1_REF_CLKN]

## Clock Generate By PLL Si5338 Interface
set_property PACKAGE_PIN AD32 [get_ports GTH_REF_CLKP]
set_property PACKAGE_PIN AD33 [get_ports GTH_REF_CLKN]
set_property PACKAGE_PIN AP36 [get_ports REFCLK_P]
set_property PACKAGE_PIN AR36 [get_ports REFCLK_N]
set_property IOSTANDARD LVDS [get_ports REFCLK_*]

## SI5338 I2C Interface
set_property PACKAGE_PIN AT39 [get_ports SI5338_SCL]
set_property PACKAGE_PIN AU39 [get_ports SI5338_SDA]
set_property IOSTANDARD LVCMOS18 [get_ports SI5338*]

##HMC7044 Control PIns
#Bank-65
set_property PACKAGE_PIN AT14 [get_ports HMC7044_PWR_EN]
set_property PACKAGE_PIN AP14 [get_ports HMC7044_SYNC]
set_property PACKAGE_PIN AP15 [get_ports HMC7044_RESET]
set_property PACKAGE_PIN AP13 [get_ports HMC7044_SLENn]
set_property PACKAGE_PIN AR12 [get_ports HMC7044_SCLK]
set_property PACKAGE_PIN AT12 [get_ports HMC7044_SDATA]
set_property IOSTANDARD LVCMOS33 [get_ports HMC7044*]

#Bank-65
set_property PACKAGE_PIN AU14 [get_ports ADC_PWR_EN]
set_property IOSTANDARD LVCMOS33 [get_ports ADC_PWR_EN]
set_property PACKAGE_PIN AT14 [get_ports CLK_PWR_EN]
set_property IOSTANDARD LVCMOS33 [get_ports CLK_PWR_EN]


#Bank-65
set_property PACKAGE_PIN AE13 [get_ports {VPX_GA[0]}]
set_property PACKAGE_PIN AF13 [get_ports {VPX_GA[1]}]
set_property PACKAGE_PIN AF15 [get_ports {VPX_GA[2]}]
set_property PACKAGE_PIN AG15 [get_ports {VPX_GA[3]}]
set_property PACKAGE_PIN AG12 [get_ports {VPX_GA[4]}]
set_property PACKAGE_PIN AH12 [get_ports {VPX_GAP}]
set_property IOSTANDARD LVCMOS33 [get_ports VPX_GA*]

#Bank-24
set_property PACKAGE_PIN AL30	[get_ports {VPX_DCO_CLKP}]
set_property PACKAGE_PIN AM30	[get_ports {VPX_DCO_CLKN}]
set_property PACKAGE_PIN AK32	[get_ports {VPX_ID_I_DVLD}]
set_property PACKAGE_PIN AK30	[get_ports {VPX_ID_I_DATA}]
set_property PACKAGE_PIN AL32	[get_ports {VPX_CMD_I_DVLD}]
set_property PACKAGE_PIN AR32	[get_ports {VPX_CMD_I_DATA[0]}]
set_property PACKAGE_PIN AR31	[get_ports {VPX_CMD_I_DATA[1]}]
set_property PACKAGE_PIN AE28	[get_ports {VPX_CMD_O_DVLD}]
set_property PACKAGE_PIN AF30	[get_ports {VPX_CMD_O_DATA[0]}]
set_property PACKAGE_PIN AE30	[get_ports {VPX_CMD_O_DATA[1]}]
set_property PACKAGE_PIN AM31	[get_ports {VPX_TRIG_P[0]}]
set_property PACKAGE_PIN AN31	[get_ports {VPX_TRIG_N[0]}]
set_property PACKAGE_PIN AM32	[get_ports {VPX_TRIG_P[1]}]
set_property PACKAGE_PIN AN32	[get_ports {VPX_TRIG_N[1]}]
set_property PACKAGE_PIN AH29	[get_ports {TEST1_P}]
set_property PACKAGE_PIN AJ29	[get_ports {TEST1_N}]
set_property IOSTANDARD LVDS [get_ports {VPX_DCO_CLK*}]
set_property IOSTANDARD LVDS [get_ports {VPX_TRIG*}]
set_property IOSTANDARD LVDS [get_ports {TEST1*}]
set_property IOSTANDARD LVCMOS18 [get_ports {VPX_ID_I*}]
set_property IOSTANDARD LVCMOS18 [get_ports {VPX_CMD_I*}]
set_property IOSTANDARD LVCMOS18 [get_ports {VPX_CMD_O*}]



#Bank-65
set_property PACKAGE_PIN AK13 [get_ports {TEMP_DQ}]
set_property PACKAGE_PIN AU15 [get_ports {UART_RX}]
set_property PACKAGE_PIN AT15 [get_ports {UART_TX}]
set_property IOSTANDARD LVCMOS33 [get_ports UART*]
set_property IOSTANDARD LVCMOS33 [get_ports TEMP_DQ*]

#Bank64
set_property PACKAGE_PIN AF19 [get_ports {GPIO1_1V8_I[0]}]
set_property PACKAGE_PIN AG19 [get_ports {GPIO1_1V8_I[1]}]
set_property PACKAGE_PIN AE17 [get_ports {GPIO1_1V8_I[2]}]
set_property PACKAGE_PIN AF17 [get_ports {GPIO1_1V8_I[3]}]
set_property PACKAGE_PIN AU17 [get_ports {GPIO1_1V8_O[0]}]
set_property PACKAGE_PIN AU16 [get_ports {GPIO1_1V8_O[1]}]
set_property PACKAGE_PIN AW20 [get_ports {GPIO1_1V8_O[2]}]
set_property PACKAGE_PIN AW19 [get_ports {GPIO1_1V8_O[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO1_1V8*]

#Bank-45
set_property PACKAGE_PIN AE26 [get_ports {GPIO0_1V8_I}]
set_property PACKAGE_PIN AT27 [get_ports {GPIO0_1V8_O}]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO0_1V8*]

#Bank-45
set_property PACKAGE_PIN AL24 [get_ports {LVDS_I_P[0]}]
set_property PACKAGE_PIN AL25 [get_ports {LVDS_I_N[0]}]
set_property PACKAGE_PIN AH24 [get_ports {LVDS_I_P[1]}]
set_property PACKAGE_PIN AJ24 [get_ports {LVDS_I_N[1]}]
set_property PACKAGE_PIN AH26 [get_ports {LVDS_I_P[2]}]
set_property PACKAGE_PIN AJ26 [get_ports {LVDS_I_N[2]}]
set_property PACKAGE_PIN AJ25 [get_ports {LVDS_I_P[3]}]
set_property PACKAGE_PIN AK25 [get_ports {LVDS_I_N[3]}]
set_property PACKAGE_PIN AD25 [get_ports {LVDS_I_P[4]}]
set_property PACKAGE_PIN AE25 [get_ports {LVDS_I_N[4]}]
set_property PACKAGE_PIN AL27 [get_ports {LVDS_I_CLKP}]
set_property PACKAGE_PIN AL28 [get_ports {LVDS_I_CLKN}]
set_property PACKAGE_PIN AM27 [get_ports {LVDS_O_CLKP}]
set_property PACKAGE_PIN AN27 [get_ports {LVDS_O_CLKN}]
set_property PACKAGE_PIN AP25 [get_ports {LVDS_O_P[0]}]
set_property PACKAGE_PIN AR25 [get_ports {LVDS_O_N[0]}]
set_property PACKAGE_PIN AN28 [get_ports {LVDS_O_P[1]}]
set_property PACKAGE_PIN AP28 [get_ports {LVDS_O_N[1]}]
set_property PACKAGE_PIN AM24 [get_ports {LVDS_O_P[2]}]
set_property PACKAGE_PIN AM25 [get_ports {LVDS_O_N[2]}]
set_property PACKAGE_PIN AR26 [get_ports {LVDS_O_P[3]}]
set_property PACKAGE_PIN AR27 [get_ports {LVDS_O_N[3]}]
set_property PACKAGE_PIN AV26 [get_ports {LVDS_O_P[4]}]
set_property PACKAGE_PIN AV27 [get_ports {LVDS_O_N[4]}]
set_property IOSTANDARD LVDS [get_ports LVDS_*]

#Bank-65
set_property PACKAGE_PIN AT13 [get_ports ALERT_LED]
set_property PACKAGE_PIN AW13 [get_ports FPGA1_LED]
set_property PACKAGE_PIN AW16 [get_ports AD_LED]
set_property IOSTANDARD LVCMOS33 [get_ports *LED*]

################################################################################
## ADC-ADC3200-0 Interface
set_property PACKAGE_PIN AF22 [get_ports {ADC_CFG_IF0\.NCOA0}]
set_property PACKAGE_PIN AG22 [get_ports {ADC_CFG_IF0\.NCOA1}]
set_property PACKAGE_PIN AV23 [get_ports {ADC_CFG_IF0\.NCOB0}]
set_property PACKAGE_PIN AU21 [get_ports {ADC_CFG_IF0\.NCOB1}]
set_property PACKAGE_PIN AN24 [get_ports {ADC_CFG_IF0\.PD}]
set_property PACKAGE_PIN AL20 [get_ports {ADC_CFG_IF0\.SYNCSEn}]
set_property PACKAGE_PIN AH21 [get_ports {ADC_CFG_IF0\.CSn}]
set_property PACKAGE_PIN AJ21 [get_ports {ADC_CFG_IF0\.SCLK}]
set_property PACKAGE_PIN AR22 [get_ports {ADC_CFG_IF0\.SDO}]
set_property PACKAGE_PIN AV21 [get_ports {ADC_CFG_IF0\.SDI}]
set_property PACKAGE_PIN AW4 [get_ports {ADC_204_IF0\.RX_P[0]}]
set_property PACKAGE_PIN AW3 [get_ports {ADC_204_IF0\.RX_N[0]}]
set_property PACKAGE_PIN AV2 [get_ports {ADC_204_IF0\.RX_P[1]}]
set_property PACKAGE_PIN AV1 [get_ports {ADC_204_IF0\.RX_N[1]}]
set_property PACKAGE_PIN AU4 [get_ports {ADC_204_IF0\.RX_P[2]}]
set_property PACKAGE_PIN AU3 [get_ports {ADC_204_IF0\.RX_N[2]}]
set_property PACKAGE_PIN AT2 [get_ports {ADC_204_IF0\.RX_P[3]}]
set_property PACKAGE_PIN AT1 [get_ports {ADC_204_IF0\.RX_N[3]}]
set_property PACKAGE_PIN AM2 [get_ports {ADC_204_IF0\.RX_P[4]}]
set_property PACKAGE_PIN AM1 [get_ports {ADC_204_IF0\.RX_N[4]}]
set_property PACKAGE_PIN AN4 [get_ports {ADC_204_IF0\.RX_P[5]}]
set_property PACKAGE_PIN AN3 [get_ports {ADC_204_IF0\.RX_N[5]}]
set_property PACKAGE_PIN AP2 [get_ports {ADC_204_IF0\.RX_P[6]}]
set_property PACKAGE_PIN AP1 [get_ports {ADC_204_IF0\.RX_N[6]}]
set_property PACKAGE_PIN AR4 [get_ports {ADC_204_IF0\.RX_P[7]}]
set_property PACKAGE_PIN AR3 [get_ports {ADC_204_IF0\.RX_N[7]}]
set_property PACKAGE_PIN AM21 [get_ports {ADC_204_IF0\.SYNC_P}]
set_property PACKAGE_PIN AN21 [get_ports {ADC_204_IF0\.SYNC_N}]
set_property PACKAGE_PIN AM22 [get_ports {ADC_204_IF0\.SYSREF_P}]
set_property PACKAGE_PIN AN22 [get_ports {ADC_204_IF0\.SYSREF_N}]


## ADC-ADC3200-1 Interface
set_property PACKAGE_PIN AT23 [get_ports {ADC_CFG_IF1\.NCOA0}]
set_property PACKAGE_PIN AP21 [get_ports {ADC_CFG_IF1\.NCOA1}]
set_property PACKAGE_PIN AD20 [get_ports {ADC_CFG_IF1\.NCOB0}]
set_property PACKAGE_PIN AE21 [get_ports {ADC_CFG_IF1\.NCOB1}]
set_property PACKAGE_PIN AT22 [get_ports {ADC_CFG_IF1\.PD}]
set_property PACKAGE_PIN AG20 [get_ports {ADC_CFG_IF1\.SYNCSEn}]
set_property PACKAGE_PIN AK21 [get_ports {ADC_CFG_IF1\.CSn}]
set_property PACKAGE_PIN AH23 [get_ports {ADC_CFG_IF1\.SCLK}]
set_property PACKAGE_PIN AF23 [get_ports {ADC_CFG_IF1\.SDO}]
set_property PACKAGE_PIN AN23 [get_ports {ADC_CFG_IF1\.SDI}]
set_property PACKAGE_PIN AL4 [get_ports {ADC_204_IF1\.RX_P[0]}]
set_property PACKAGE_PIN AL3 [get_ports {ADC_204_IF1\.RX_N[0]}]
set_property PACKAGE_PIN AK2 [get_ports {ADC_204_IF1\.RX_P[1]}]
set_property PACKAGE_PIN AK1 [get_ports {ADC_204_IF1\.RX_N[1]}]
set_property PACKAGE_PIN AJ4 [get_ports {ADC_204_IF1\.RX_P[2]}]
set_property PACKAGE_PIN AJ3 [get_ports {ADC_204_IF1\.RX_N[2]}]
set_property PACKAGE_PIN AH2 [get_ports {ADC_204_IF1\.RX_P[3]}]
set_property PACKAGE_PIN AH1 [get_ports {ADC_204_IF1\.RX_N[3]}]
set_property PACKAGE_PIN AC4 [get_ports {ADC_204_IF1\.RX_P[4]}]
set_property PACKAGE_PIN AC3 [get_ports {ADC_204_IF1\.RX_N[4]}]
set_property PACKAGE_PIN AD2 [get_ports {ADC_204_IF1\.RX_P[5]}]
set_property PACKAGE_PIN AD1 [get_ports {ADC_204_IF1\.RX_N[5]}]
set_property PACKAGE_PIN AF2 [get_ports {ADC_204_IF1\.RX_P[6]}]
set_property PACKAGE_PIN AF1 [get_ports {ADC_204_IF1\.RX_N[6]}]
set_property PACKAGE_PIN AG4 [get_ports {ADC_204_IF1\.RX_P[7]}]
set_property PACKAGE_PIN AG3 [get_ports {ADC_204_IF1\.RX_N[7]}]
set_property PACKAGE_PIN AK22 [get_ports {ADC_204_IF1\.SYNC_P}]
set_property PACKAGE_PIN AL22 [get_ports {ADC_204_IF1\.SYNC_N}]
set_property PACKAGE_PIN AK23 [get_ports {ADC_204_IF1\.SYSREF_P}]
set_property PACKAGE_PIN AL23 [get_ports {ADC_204_IF1\.SYSREF_N}]

set_property IOSTANDARD LVCMOS18 [get_ports ADC_CFG_IF*]
set_property IOSTANDARD LVDS [get_ports {ADC_204_IF*\.SYNC_N}]
set_property IOSTANDARD LVDS [get_ports {ADC_204_IF*\.SYNC_P}]
set_property IOSTANDARD LVDS [get_ports {ADC_204_IF0\.SYSREF_N}]
set_property IOSTANDARD LVDS [get_ports {ADC_204_IF1\.SYSREF_N}]
set_property IOSTANDARD LVDS [get_ports {ADC_204_IF0\.SYSREF_P}]
set_property IOSTANDARD LVDS [get_ports {ADC_204_IF1\.SYSREF_P}]

################################################################################
##DAC Interface

