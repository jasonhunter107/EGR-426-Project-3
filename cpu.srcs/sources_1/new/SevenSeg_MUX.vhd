----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2018 05:03:12 PM
-- Design Name: 
-- Module Name: SevenSeg_MUX - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SevenSeg_MUX is
  port (clk, reset : in STD_LOGIC;
        LeftSeg, RightSeg : in STD_LOGIC_VECTOR (6 downto 0);
        an : out STD_LOGIC_VECTOR(3 downto 0); 
        Seg_out : out STD_LOGIC_VECTOR (6 downto 0)
        );
end SevenSeg_MUX;

architecture Behavioral of SevenSeg_MUX is

signal tempSeg : STD_LOGIC_VECTOR (6 downto 0);
signal tempAn : STD_LOGIC_VECTOR (3 downto 0);
signal count : STD_LOGIC_VECTOR (1 downto 0);

begin

process (clk, reset)
begin
    if(reset = '1') then
    count <= "00";
    elsif (clk'event and rising_edge(clk)) then
    
     if (count = "11") then
     count <= "00";
        else
        count <= count + 1;
    end if;
    
    else
    count <= count; 
    end if;

end process;

process (count)
begin
    --Switch statement for select signal. Counter repeatedly switchs s to make it look like
    --  all seven segment LED's are on
    case count is
    when "00" => tempSeg <= "0000001"; tempAn <= "0111"; --Display letter on first sev seg
    when "01" => tempSeg <= LeftSeg; tempAn <= "1011"; --Display letter on second sev seg
    when "10" => tempSeg <= "0000001"; tempAn <= "1101"; --Display letter on third sev seg
    when others => tempSeg <= RightSeg; tempAn <= "1110"; --Display letter on fourth sev seg
    end case;
end process;

Seg_out <= tempSeg;
an <= tempAn;

end Behavioral;
