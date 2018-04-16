----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2018 05:03:30 PM
-- Design Name: 
-- Module Name: clk_divider - Behavioral
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_divider is
    port ( clkin, reset : in STD_LOGIC;
           clkout_1Hz, clkout_500Hz : out STD_LOGIC
          );
end clk_divider;

architecture Behavioral of clk_divider is

--Since 100MHz = 1 second we want 0.5 seconds so make counter count up to 49,999,999 cycles
-- Since we start at 0, we want to count up to 49,999,999

signal clkPreScaler: STD_LOGIC_VECTOR (27 downto 0) := X"2FAF07F"; --Hex value of 99,999,999 cycles 5F5E0FF
signal clkPreScaler1: STD_LOGIC_VECTOR (19 downto 0) := X"30D3F"; --Hex value of 199,999 cycles

signal clkCounter: STD_LOGIC_VECTOR (27 downto 0) := (others => '0'); --Clock counter
signal clkCounter1: STD_LOGIC_VECTOR (19 downto 0) := (others => '0'); --Clock counter

signal count0, count1 : STD_LOGIC := '0'; --output

begin

newClock_1Hz: process (clkin, count0)
begin
    --Increment the counter every rising edge of clock
    if rising_edge(clkin) then
    clkCounter <= clkCounter + 1;
    --If the counter reached maximum value then reset clock counter and toggle count
        if (clkCounter > clkPreScaler) then
        count0 <= not count0;
        clkCounter <= (others => '0');
        end if;
    end if;
end process;

newClock2_500Hz: process (clkin, count1)
begin
    --Increment the counter every rising edge of clock
    if rising_edge(clkin) then
    clkCounter1 <= clkCounter1 + 1;
    --If the counter reached maximum value then reset clock counter and toggle count
        if (clkCounter1 > clkPreScaler1) then
        count1 <= not count1;
        clkCounter1 <= (others => '0');
        end if;
    end if;
end process;

--Assign count to output
clkout_1Hz <= count0;
clkout_500Hz <= count1;

end Behavioral;
