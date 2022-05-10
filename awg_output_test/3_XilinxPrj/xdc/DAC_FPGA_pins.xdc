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
set_property PACKAGE_PIN AH9 [get_ports DAC0_REF_CLKN]
set_property PACKAGE_PIN AH10 [get_ports DAC0_REF_CLKP]
set_property PACKAGE_PIN AT9 [get_ports DAC1_REF_CLKN]
set_property PACKAGE_PIN AT10 [get_ports DAC1_REF_CLKP]

## Clock Generate By PLL Si5338 Interface
set_property PACKAGE_PIN AD33 [get_ports GTH_REF_CLKN]
set_property PACKAGE_PIN AD32 [get_ports GTH_REF_CLKP]
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

#Bank-65
set_property PACKAGE_PIN AE13 [get_ports {VPX_GA[0]}]
set_property PACKAGE_PIN AF13 [get_ports {VPX_GA[1]}]
set_property PACKAGE_PIN AF15 [get_ports {VPX_GA[2]}]
set_property PACKAGE_PIN AG15 [get_ports {VPX_GA[3]}]
set_property PACKAGE_PIN AG12 [get_ports {VPX_GA[4]}]
set_property PACKAGE_PIN AH12 [get_ports VPX_GAP]
set_property IOSTANDARD LVCMOS33 [get_ports VPX_GA*]

#Bank-24
set_property PACKAGE_PIN AL30 [get_ports VPX_DCO_CLKP]
set_property PACKAGE_PIN AM30 [get_ports VPX_DCO_CLKN]
set_property PACKAGE_PIN AK32 [get_ports VPX_ID_I_DVLD]
set_property PACKAGE_PIN AK30 [get_ports VPX_ID_I_DATA]

set_property PACKAGE_PIN AJ30 [get_ports VPX_ID_O_DVLD]
set_property PACKAGE_PIN AF28 [get_ports VPX_ID_O_DATA]

set_property PACKAGE_PIN AL32 [get_ports VPX_CMD_I_DVLD]
set_property PACKAGE_PIN AR32 [get_ports {VPX_CMD_I_DATA[0]}]
set_property PACKAGE_PIN AR31 [get_ports {VPX_CMD_I_DATA[1]}]
set_property PACKAGE_PIN AE28 [get_ports VPX_CMD_O_DVLD]
set_property PACKAGE_PIN AF30 [get_ports {VPX_CMD_O_DATA[0]}]
set_property PACKAGE_PIN AE30 [get_ports {VPX_CMD_O_DATA[1]}]
set_property PACKAGE_PIN AM31 [get_ports {VPX_TRIG_P[0]}]
set_property PACKAGE_PIN AN31 [get_ports {VPX_TRIG_N[0]}]
set_property PACKAGE_PIN AM32 [get_ports {VPX_TRIG_P[1]}]
set_property PACKAGE_PIN AN32 [get_ports {VPX_TRIG_N[1]}]
set_property PACKAGE_PIN AH29 [get_ports TEST1_P]
set_property PACKAGE_PIN AJ29 [get_ports TEST1_N]
set_property IOSTANDARD LVDS [get_ports VPX_DCO_CLK*]
set_property IOSTANDARD LVDS [get_ports VPX_TRIG*]
set_property IOSTANDARD LVDS [get_ports TEST1*]
set_property IOSTANDARD LVCMOS18 [get_ports VPX_ID_*]
set_property IOSTANDARD LVCMOS18 [get_ports VPX_CMD_I*]
set_property IOSTANDARD LVCMOS18 [get_ports VPX_CMD_O*]



#Bank-65
set_property PACKAGE_PIN AU12 [get_ports TEMP_DQ]
set_property PACKAGE_PIN AU15 [get_ports UART_RX]
set_property PACKAGE_PIN AT15 [get_ports UART_TX]
set_property IOSTANDARD LVCMOS33 [get_ports UART*]
set_property IOSTANDARD LVCMOS33 [get_ports TEMP_DQ*]

#Bank64
set_property PACKAGE_PIN AF19 [get_ports {GPIO1_1V8_O[0]}]
set_property PACKAGE_PIN AG19 [get_ports {GPIO1_1V8_O[1]}]
set_property PACKAGE_PIN AD18 [get_ports {GPIO1_1V8_O[2]}]
set_property PACKAGE_PIN AE17 [get_ports {GPIO1_1V8_O[3]}]
set_property PACKAGE_PIN AW19 [get_ports {GPIO1_1V8_I[0]}]
set_property PACKAGE_PIN AU20 [get_ports {GPIO1_1V8_I[1]}]
set_property PACKAGE_PIN AV18 [get_ports {GPIO1_1V8_I[2]}]
set_property PACKAGE_PIN AV17 [get_ports {GPIO1_1V8_I[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO1_1V8*]

#Bank-45
set_property PACKAGE_PIN AE26 [get_ports GPIO0_1V8_I]
set_property PACKAGE_PIN AT27 [get_ports GPIO0_1V8_O]
set_property IOSTANDARD LVCMOS18 [get_ports GPIO0_1V8*]

#Bank-45
set_property PACKAGE_PIN AD25 [get_ports {LVDS_O_P[4]}]
set_property PACKAGE_PIN AE25 [get_ports {LVDS_O_N[4]}]
set_property PACKAGE_PIN AH24 [get_ports {LVDS_O_P[1]}]
set_property PACKAGE_PIN AJ24 [get_ports {LVDS_O_N[1]}]
set_property PACKAGE_PIN AH26 [get_ports {LVDS_O_P[2]}]
set_property PACKAGE_PIN AJ26 [get_ports {LVDS_O_N[2]}]
set_property PACKAGE_PIN AL24 [get_ports {LVDS_O_P[0]}]
set_property PACKAGE_PIN AL25 [get_ports {LVDS_O_N[0]}]
set_property PACKAGE_PIN AJ25 [get_ports {LVDS_O_P[3]}]
set_property PACKAGE_PIN AK25 [get_ports {LVDS_O_N[3]}]
set_property PACKAGE_PIN AL27 [get_ports LVDS_O_CLKP]
set_property PACKAGE_PIN AL28 [get_ports LVDS_O_CLKN]

set_property PACKAGE_PIN AM27 [get_ports LVDS_I_CLKP]
set_property PACKAGE_PIN AN27 [get_ports LVDS_I_CLKN]
set_property PACKAGE_PIN AP25 [get_ports {LVDS_I_P[0]}]
set_property PACKAGE_PIN AR25 [get_ports {LVDS_I_N[0]}]
set_property PACKAGE_PIN AN28 [get_ports {LVDS_I_P[1]}]
set_property PACKAGE_PIN AP28 [get_ports {LVDS_I_N[1]}]
set_property PACKAGE_PIN AM24 [get_ports {LVDS_I_P[2]}]
set_property PACKAGE_PIN AM25 [get_ports {LVDS_I_N[2]}]
set_property PACKAGE_PIN AR26 [get_ports {LVDS_I_P[3]}]
set_property PACKAGE_PIN AR27 [get_ports {LVDS_I_N[3]}]
set_property PACKAGE_PIN AV26 [get_ports {LVDS_I_P[4]}]
set_property PACKAGE_PIN AV27 [get_ports {LVDS_I_N[4]}]
set_property IOSTANDARD LVDS [get_ports LVDS_*]

#Bank-65
set_property PACKAGE_PIN AV14 [get_ports JTAG2_LED]
set_property PACKAGE_PIN AW13 [get_ports FPGA2_LED]
set_property PACKAGE_PIN AW16 [get_ports DAC_LED]
set_property IOSTANDARD LVCMOS33 [get_ports *LED*]

################################################################################
## DAC-AD9173-0 Interface
set_property PACKAGE_PIN AT23 [get_ports {DAC_CFG_IF0\.CSn}]
set_property PACKAGE_PIN AN23 [get_ports {DAC_CFG_IF0\.IRQ0n}]
set_property PACKAGE_PIN AN24 [get_ports {DAC_CFG_IF0\.IRQ1n}]
set_property PACKAGE_PIN AV23 [get_ports {DAC_CFG_IF0\.RESETn}]
set_property PACKAGE_PIN AT24 [get_ports {DAC_CFG_IF0\.SCLK}]
set_property PACKAGE_PIN AP21 [get_ports {DAC_CFG_IF0\.SDI}]
set_property PACKAGE_PIN AR22 [get_ports {DAC_CFG_IF0\.SDO}]
set_property PACKAGE_PIN AT22 [get_ports {DAC_CFG_IF0\.TXEN0}]
#set_property PACKAGE_PIN   [get_ports {DAC_CFG_IF0\.TXEN1}]
set_property PACKAGE_PIN AW8 [get_ports {DAC_204_IF0\.TX_P[0]}]
set_property PACKAGE_PIN AW7 [get_ports {DAC_204_IF0\.TX_N[0]}]
set_property PACKAGE_PIN AV6 [get_ports {DAC_204_IF0\.TX_P[1]}]
set_property PACKAGE_PIN AV5 [get_ports {DAC_204_IF0\.TX_N[1]}]
set_property PACKAGE_PIN AU8 [get_ports {DAC_204_IF0\.TX_P[2]}]
set_property PACKAGE_PIN AU7 [get_ports {DAC_204_IF0\.TX_N[2]}]
set_property PACKAGE_PIN AT6 [get_ports {DAC_204_IF0\.TX_P[3]}]
set_property PACKAGE_PIN AT5 [get_ports {DAC_204_IF0\.TX_N[3]}]
set_property PACKAGE_PIN AR8 [get_ports {DAC_204_IF0\.TX_P[4]}]
set_property PACKAGE_PIN AR7 [get_ports {DAC_204_IF0\.TX_N[4]}]
set_property PACKAGE_PIN AP6 [get_ports {DAC_204_IF0\.TX_P[5]}]
set_property PACKAGE_PIN AP5 [get_ports {DAC_204_IF0\.TX_N[5]}]
set_property PACKAGE_PIN AN8 [get_ports {DAC_204_IF0\.TX_P[6]}]
set_property PACKAGE_PIN AN7 [get_ports {DAC_204_IF0\.TX_N[6]}]
set_property PACKAGE_PIN AM6 [get_ports {DAC_204_IF0\.TX_P[7]}]
set_property PACKAGE_PIN AM5 [get_ports {DAC_204_IF0\.TX_N[7]}]
set_property PACKAGE_PIN AJ20 [get_ports {DAC_204_IF0\.SYNC_P}]
set_property PACKAGE_PIN AJ21 [get_ports {DAC_204_IF0\.SYNC_N}]
set_property PACKAGE_PIN AK23 [get_ports {DAC_204_IF0\.SYSREF_P}]
set_property PACKAGE_PIN AL23 [get_ports {DAC_204_IF0\.SYSREF_N}]


## DAC-AD9173-1 Interface
set_property PACKAGE_PIN AL20 [get_ports {DAC_CFG_IF1\.CSn}]
set_property PACKAGE_PIN AD20 [get_ports {DAC_CFG_IF1\.IRQ0n}]
set_property PACKAGE_PIN AG20 [get_ports {DAC_CFG_IF1\.IRQ1n}]
set_property PACKAGE_PIN AH21 [get_ports {DAC_CFG_IF1\.RESETn}]
set_property PACKAGE_PIN AG22 [get_ports {DAC_CFG_IF1\.SCLK}]
set_property PACKAGE_PIN AF23 [get_ports {DAC_CFG_IF1\.SDI}]
set_property PACKAGE_PIN AE21 [get_ports {DAC_CFG_IF1\.SDO}]
set_property PACKAGE_PIN AF22 [get_ports {DAC_CFG_IF1\.TXEN0}]
#set_property PACKAGE_PIN   [get_ports {DAC_CFG_IF1\.TXEN1}]
set_property PACKAGE_PIN AL8 [get_ports {DAC_204_IF1\.TX_P[0]}]
set_property PACKAGE_PIN AL7 [get_ports {DAC_204_IF1\.TX_N[0]}]
set_property PACKAGE_PIN AK6 [get_ports {DAC_204_IF1\.TX_P[1]}]
set_property PACKAGE_PIN AK5 [get_ports {DAC_204_IF1\.TX_N[1]}]
set_property PACKAGE_PIN AJ8 [get_ports {DAC_204_IF1\.TX_P[2]}]
set_property PACKAGE_PIN AJ7 [get_ports {DAC_204_IF1\.TX_N[2]}]
set_property PACKAGE_PIN AH6 [get_ports {DAC_204_IF1\.TX_P[3]}]
set_property PACKAGE_PIN AH5 [get_ports {DAC_204_IF1\.TX_N[3]}]
set_property PACKAGE_PIN AG8 [get_ports {DAC_204_IF1\.TX_P[4]}]
set_property PACKAGE_PIN AG7 [get_ports {DAC_204_IF1\.TX_N[4]}]
set_property PACKAGE_PIN AF6 [get_ports {DAC_204_IF1\.TX_P[5]}]
set_property PACKAGE_PIN AF5 [get_ports {DAC_204_IF1\.TX_N[5]}]
set_property PACKAGE_PIN AE4 [get_ports {DAC_204_IF1\.TX_P[6]}]
set_property PACKAGE_PIN AE3 [get_ports {DAC_204_IF1\.TX_N[6]}]
set_property PACKAGE_PIN AD6 [get_ports {DAC_204_IF1\.TX_P[7]}]
set_property PACKAGE_PIN AD5 [get_ports {DAC_204_IF1\.TX_N[7]}]
set_property PACKAGE_PIN AU21 [get_ports {DAC_204_IF1\.SYNC_P}]
set_property PACKAGE_PIN AV22 [get_ports {DAC_204_IF1\.SYNC_N}]
set_property PACKAGE_PIN AM22 [get_ports {DAC_204_IF1\.SYSREF_P}]
set_property PACKAGE_PIN AN22 [get_ports {DAC_204_IF1\.SYSREF_N}]

set_property IOSTANDARD LVCMOS18 [get_ports DAC_CFG_IF*]
set_property IOSTANDARD LVDS [get_ports {DAC_204_IF*\.SYNC_N}]
set_property IOSTANDARD LVDS [get_ports {DAC_204_IF*\.SYNC_P}]
set_property IOSTANDARD LVDS [get_ports {DAC_204_IF0\.SYSREF_N}]
set_property IOSTANDARD LVDS [get_ports {DAC_204_IF1\.SYSREF_N}]
set_property IOSTANDARD LVDS [get_ports {DAC_204_IF0\.SYSREF_P}]
set_property IOSTANDARD LVDS [get_ports {DAC_204_IF1\.SYSREF_P}]


set_property PACKAGE_PIN AD36 [get_ports {IBERT_TX_P[3]}]
set_property PACKAGE_PIN AD37 [get_ports {IBERT_TX_N[3]}]
set_property PACKAGE_PIN AE34 [get_ports {IBERT_TX_P[2]}]
set_property PACKAGE_PIN AE35 [get_ports {IBERT_TX_N[2]}]
set_property PACKAGE_PIN AG34 [get_ports {IBERT_TX_P[1]}]
set_property PACKAGE_PIN AG35 [get_ports {IBERT_TX_N[1]}]
set_property PACKAGE_PIN AH36 [get_ports {IBERT_TX_P[0]}]
set_property PACKAGE_PIN AH37 [get_ports {IBERT_TX_N[0]}]

set_property PACKAGE_PIN AC38 [get_ports {IBERT_RX_P[3]}]
set_property PACKAGE_PIN AC39 [get_ports {IBERT_RX_N[3]}]
set_property PACKAGE_PIN AE38 [get_ports {IBERT_RX_P[2]}]
set_property PACKAGE_PIN AE39 [get_ports {IBERT_RX_N[2]}]
set_property PACKAGE_PIN AF36 [get_ports {IBERT_RX_P[1]}]
set_property PACKAGE_PIN AF37 [get_ports {IBERT_RX_N[1]}]
set_property PACKAGE_PIN AG38 [get_ports {IBERT_RX_P[0]}]
set_property PACKAGE_PIN AG39 [get_ports {IBERT_RX_N[0]}]