##------------------------------------------------------------------
## 1) MASTER CLOCK (100 MHz)
##    The on-board 100 MHz clock pin is W5 on Basys 3.
##------------------------------------------------------------------
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports {clk_100MHz}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk_100MHz}]

##------------------------------------------------------------------
## 2) PUSH BUTTONS
##    Basys 3 has 5 buttons: btnC, btnU, btnD, btnL, btnR
##    We'll map:
##     - btn_reset -> the center push button (pin U18)
##     - btn_pause -> the up push button (pin T18)
##------------------------------------------------------------------
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {btn_reset}]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports {btn_pause}]

## NOTE: If you prefer different physical buttons, change the pin references:
##    U18 = Center, T18 = Up, U17 = Down, W19 = Left, T17 = Right
## Just keep the top-level port names consistent with your Verilog code.

##------------------------------------------------------------------
## 3) SLIDER SWITCHES
##    Basys 3 has 16 slide switches: sw[0] at pin V17, sw[1] at V16, etc.
##    We'll use two of them for ADJ and SEL.
##------------------------------------------------------------------
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {sw_adj}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {sw_sel}]

## If you prefer different switches (e.g., sw[8] or sw[9]), just pick the corresponding pins.

##------------------------------------------------------------------
## 4) SEVEN-SEGMENT DISPLAY
##    Basys 3 has four 7-segment displays with the following pin mapping:
##      seg[0] -> W7,  seg[1] -> W6,  seg[2] -> U8,  seg[3] -> V8,
##      seg[4] -> U5,  seg[5] -> V5,  seg[6] -> U7,
##      dp     -> V7 (if you need the decimal point)
##    The anodes are:
##      an[0] -> U2, an[1] -> U4, an[2] -> V4, an[3] -> W4
##------------------------------------------------------------------
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]

## If you want to drive the decimal point, uncomment and connect dp in your Verilog:
## set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports {dp}]

## The common anodes (active-low):
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]

##------------------------------------------------------------------
## 5) OPTIONAL: LEDs
##    If you want to drive an LED for debug, map it here. For instance:
##    set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {led}]
##    and so on, if you have an output [15:0] led or just a single led.
##------------------------------------------------------------------

##------------------------------------------------------------------
## 6) BOARD CONFIGURATION OPTIONS
##------------------------------------------------------------------
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO     [current_design]

## If you program from the on-board SPI flash, these help:
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
