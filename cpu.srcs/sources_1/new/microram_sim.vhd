----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 05:54:30 PM
-- Design Name: 
-- Module Name: microram_sim - Behavioral
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
-- This file simulates a 512x8 synchronous RAM component.
-- The program to be executed is encoded by initializing the "mem_data" signal (see below).
--

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

entity microram_sim is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	);
end entity microram_sim;

architecture a of microram_sim is
type t_mem_data is array(0 to 511) of std_logic_vector(7 downto 0);

-- Your program is entered here, as initialization values for the "mem_data" signal.
signal mem_data : t_mem_data := (0 => "11110000", -- CLR A (dummy first instruction)
	                             1 => "00000000", -- LOAD 51,A  
                                 2 => X"32",      -- ADDRESS -> 6
                                 3 => "00001000", -- OUT A  
	                          --   4 => "00100000", -- CLRB 51,0
	                          --   5 => X"34",      -- ADDRESS -> 6
	                             4 => "00000000", -- LOAD 6,A  
                                 5 => X"34",      -- ADDRESS -> 6
	                           	 6 => "00001000", -- OUT A     
	                           	 7 => "00000000", -- LOAD 51,A  75
                                 8 => X"33",      -- ADDRESS -> 51
                                 9 => "01110100", -- PWM A      
	                    	 -- test data --
                                50 => "11110101", -- memory location 50 set to 245
                                51 => X"4B", -- memory location 51 set to 142
                                52 => "10010101", -- memory location 51 set to 149
                            others => "11110000"); -- all other memory locations set to CLR A instr

begin
RAM_Process : process(CLOCK)
variable memaddr : INTEGER range 0 to 511;
begin
  if(rising_edge(CLOCK)) then
     memaddr := CONV_INTEGER(ADDRESS);
     if(we='1') then
        mem_data(memaddr) <= DATAIN;
        DATAOUT <= DATAIN;
     else
        DATAOUT <= mem_data(memaddr);
     end if;
  end if;
end process;

end architecture a;

