----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2018 03:32:06 PM
-- Design Name: 
-- Module Name: Microprocessor_Top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Microprocessor_Top is
    port (
    clk, reset : in STD_LOGIC;
    Inport0, Inport1 : in STD_LOGIC_VECTOR (7 downto 0);
    Ledport0, Ledport1 : out STD_LOGIC_VECTOR (7 downto 0);
    an : out STD_LOGIC_VECTOR (3 downto 0);
    Seg_out : out STD_LOGIC_VECTOR (6 downto 0)
    );
end Microprocessor_Top;

architecture Behavioral of Microprocessor_Top is

component cpu
PORT(clk : in STD_LOGIC;
	 reset : in STD_LOGIC;
	 Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
	 Ledport0, Ledport1	: out STD_LOGIC_VECTOR(7 downto 0);
	 Outport0, Outport1 : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component SevenSeg_MUX 
  port (clk, reset : in STD_LOGIC;
        LeftSeg, RightSeg : in STD_LOGIC_VECTOR (6 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0); 
        Seg_out : out STD_LOGIC_VECTOR (6 downto 0)
        );
end component;

component clk_divider 
    port ( clkin, reset : in STD_LOGIC;
           clkout_1Hz, clkout_500Hz : out STD_LOGIC
          );
end component;

signal outport0,outport1 : STD_LOGIC_VECTOR(6 downto 0);
signal clkout_1Hz, clkout_500Hz : STD_LOGIC;

begin
                                            --Instantiating components
---------------------------------------------------------------------------------------------------------------------
c1: cpu port map (Inport0 => Inport0, Inport1 => Inport1, clk => clkout_1Hz, reset => reset, 
                    Ledport0 => Ledport0, Ledport1 => Ledport1, outport0 => Outport0, outport1 => Outport1); 
                    
cd1: clk_divider port map (clkin => clk, reset => reset, clkout_1Hz => clkout_1Hz, clkout_500Hz => clkout_500Hz);

M1: SevenSeg_Mux port map(clk => clkout_500Hz, reset => reset, LeftSeg => outport1, RightSeg => outport0, an => an, Seg_out => Seg_out);


end Behavioral;
