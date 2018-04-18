----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2018 09:35:00 PM
-- Design Name: 
-- Module Name: PWM - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PWM is
    Port ( clk : in STD_LOGIC;
           PWMin: in STD_LOGIC_VECTOR(7 downto 0);
           outputSignal : out STD_LOGIC
           );
end PWM;

architecture Behavioral of PWM is

--Signal variables
signal outSignalTemp : STD_LOGIC;
signal counter : Integer;
signal cycleCount : Integer := 0;

begin

-------------------Creating the counter based on duty cycle-------------------
process (clk)
begin
    if(rising_edge(clk)) then
     if(counter <= cycleCount and counter /= 0) then
        outSignalTemp <= '1';
     else
        outSignalTemp <= '0';
     end if;
     
     counter <= counter + 1;
     
     if (counter = 15) then
     counter <= 0;
     end if;
     
   end if;
   
end process;

-------------------Assigning the duty cycle-------------------
process(PWMin)
begin
    if( (PWMin > 0) and (PWMin <= 25)) then
        cycleCount <= 1;
    elsif( (PWMin > 26) and (PWMin <= 50)) then
        cycleCount <= 3;
    elsif( (PWMin > 51) and (PWMin <= 75)) then
        cycleCount <= 7;
    elsif( (PWMin > 80) and (PWMin <= 100)) then
        cycleCount <= 15;
    else
        cycleCount <= 0;
    end if;
end process;

--Outputing the signal when the component is counting up to duty cycle
outputSignal <= outSignalTemp;

end Behavioral;