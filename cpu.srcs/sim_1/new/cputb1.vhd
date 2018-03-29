----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 06:53:38 PM
-- Design Name: 
-- Module Name: cputb1 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
entity cputb1 is
end cputb1;
 
architecture behavior of cputb1 is 
-- Component Declaration for the Unit Under Test (UUT)
component cpu
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         Inport0 : IN  std_logic_vector(7 downto 0);
         Inport1 : IN  std_logic_vector(7 downto 0);
         Outport0 : OUT  std_logic_vector(7 downto 0);
         Outport1 : OUT  std_logic_vector(7 downto 0)
        );
end component;

--Inputs
signal clk : std_logic := '0';
signal reset : std_logic := '1';
signal Inport0 : std_logic_vector(7 downto 0) := (others => '0');
signal Inport1 : std_logic_vector(7 downto 0) := (others => '0');

--Outputs
signal Outport0 : std_logic_vector(7 downto 0);
signal Outport1 : std_logic_vector(7 downto 0);

-- Clock period definitions
constant clk_period : time := 10ns;
 
begin
-- Instantiate the Unit Under Test (UUT)
C1 : cpu PORT MAP (clk => clk, reset => reset, Inport0 => Inport0, Inport1 => Inport1,
                   Outport0 => Outport0, Outport1 => Outport1);

-- Clock process 
clk_process : process begin
              clk <= '0'; wait for clk_period/2;
		      clk <= '1'; wait for clk_period/2;
              end process;

-- Stimulus process
stim_proc : process begin		
            wait for 100ns;     -- hold reset state for 100ns.
            reset <= '0';
            wait;
            end process;

end;

