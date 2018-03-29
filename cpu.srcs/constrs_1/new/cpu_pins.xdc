# BTNU
#set_property PACKAGE_PIN T18 [get_ports clk]    
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
##set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]
#set_property CLOCK_BUFFER_TYPE NONE [get_ports clk]
# Mapping clk
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# BTNC
set_property PACKAGE_PIN U18 [get_ports reset]  
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN L1 [get_ports {Ledport1[7]}]
set_property PACKAGE_PIN P1 [get_ports {Ledport1[6]}]
set_property PACKAGE_PIN N3 [get_ports {Ledport1[5]}]
set_property PACKAGE_PIN P3 [get_ports {Ledport1[4]}]
set_property PACKAGE_PIN U3 [get_ports {Ledport1[3]}]
set_property PACKAGE_PIN W3 [get_ports {Ledport1[2]}]
set_property PACKAGE_PIN V3 [get_ports {Ledport1[1]}]
set_property PACKAGE_PIN V13 [get_ports {Ledport1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport1[0]}]

set_property PACKAGE_PIN V14 [get_ports {Ledport0[7]}]
set_property PACKAGE_PIN U14 [get_ports {Ledport0[6]}]
set_property PACKAGE_PIN U15 [get_ports {Ledport0[5]}]
set_property PACKAGE_PIN W18 [get_ports {Ledport0[4]}]
set_property PACKAGE_PIN V19 [get_ports {Ledport0[3]}]
set_property PACKAGE_PIN U19 [get_ports {Ledport0[2]}]
set_property PACKAGE_PIN E19 [get_ports {Ledport0[1]}]
set_property PACKAGE_PIN U16 [get_ports {Ledport0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Ledport0[0]}]

set_property PACKAGE_PIN R2 [get_ports {Inport1[7]}]
set_property PACKAGE_PIN T1 [get_ports {Inport1[6]}]
set_property PACKAGE_PIN U1 [get_ports {Inport1[5]}]
set_property PACKAGE_PIN W2 [get_ports {Inport1[4]}]
set_property PACKAGE_PIN R3 [get_ports {Inport1[3]}]
set_property PACKAGE_PIN T2 [get_ports {Inport1[2]}]
set_property PACKAGE_PIN T3 [get_ports {Inport1[1]}]
set_property PACKAGE_PIN V2 [get_ports {Inport1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport1[0]}]

set_property PACKAGE_PIN W13 [get_ports {Inport0[7]}]
set_property PACKAGE_PIN W14 [get_ports {Inport0[6]}]
set_property PACKAGE_PIN V15 [get_ports {Inport0[5]}]
set_property PACKAGE_PIN W15 [get_ports {Inport0[4]}]
set_property PACKAGE_PIN W17 [get_ports {Inport0[3]}]
set_property PACKAGE_PIN W16 [get_ports {Inport0[2]}]
set_property PACKAGE_PIN V16 [get_ports {Inport0[1]}]
set_property PACKAGE_PIN V17 [get_ports {Inport0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Inport0[0]}]


#seven-segment LED display
        set_property PACKAGE_PIN W7 [get_ports {Seg_out[6]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {Seg_out[6]}]
        set_property PACKAGE_PIN W6 [get_ports {Seg_out[5]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {Seg_out[5]}]
        set_property PACKAGE_PIN U8 [get_ports {Seg_out[4]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {Seg_out[4]}]
        set_property PACKAGE_PIN V8 [get_ports {Seg_out[3]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {Seg_out[3]}]
        set_property PACKAGE_PIN U5 [get_ports {Seg_out[2]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {Seg_out[2]}]
        set_property PACKAGE_PIN V5 [get_ports {Seg_out[1]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {Seg_out[1]}]
        set_property PACKAGE_PIN U7 [get_ports {Seg_out[0]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {Seg_out[0]}]
            
 #mapping anode signals and decimal signal
        set_property PACKAGE_PIN U2 [get_ports {an[0]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
        set_property PACKAGE_PIN U4 [get_ports {an[1]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
        set_property PACKAGE_PIN V4 [get_ports {an[2]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
        set_property PACKAGE_PIN W4 [get_ports {an[3]}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

