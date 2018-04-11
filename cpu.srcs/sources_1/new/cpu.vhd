----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/16/2017 05:19:26 PM
-- Design Name: 
-- Module Name: cpu - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity cpu is
PORT(clk : in STD_LOGIC;
	 reset : in STD_LOGIC;
	 Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
	 Ledport0, Ledport1	: out STD_LOGIC_VECTOR(7 downto 0);
	 Outport0, Outport1 : out STD_LOGIC_VECTOR (6 downto 0));
end cpu;

architecture a of cpu is
-- ----------- Declare the ALU component ----------
component alu is
port(A, B : in SIGNED(7 downto 0);
        F : in STD_LOGIC_VECTOR(2 downto 0);
        Y : out SIGNED(7 downto 0);
    N,V,Z : out STD_LOGIC);
end component;
-- ------------ Declare signals interfacing to ALU -------------
signal ALU_A, ALU_B : SIGNED(7 downto 0);
signal ALU_FUNC : STD_LOGIC_VECTOR(2 downto 0);
signal ALU_OUT : SIGNED(7 downto 0);
signal ALU_N, ALU_V, ALU_Z : STD_LOGIC;

-- ------------ Declare the 512x8 RAM component --------------
component microram is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	 );
end component;

--component microram_sim is
--port (  CLOCK   : in STD_LOGIC ;
--		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
--		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
--		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
--		WE	: in STD_LOGIC 
--	 );
--end component;
-- ---------- Declare signals interfacing to RAM ---------------
signal RAM_DATA_OUT : STD_LOGIC_VECTOR(7 downto 0);  -- DATAOUT output of RAM
signal ADDR : STD_LOGIC_VECTOR(8 downto 0);	         -- ADDRESS input of RAM
signal RAM_WE : STD_LOGIC;

-- ---------- Declare the state names and state variable -------------
type STATE_TYPE is (Fetch, Operand, Memory, Execute);
signal CurrState : STATE_TYPE;
-- ---------- Declare the internal CPU registers -------------------
signal PC : UNSIGNED(8 downto 0);
signal IR : STD_LOGIC_VECTOR(7 downto 0);
signal MDR : STD_LOGIC_VECTOR(7 downto 0);
	
signal A,B : SIGNED(7 downto 0);
signal N,Z,V : STD_LOGIC;
-- ---------- Declare the common data bus ------------------
signal DATA : STD_LOGIC_VECTOR(7 downto 0);

------------ Declare the debounce variables ------------------
signal Debounce0, Debounce1 : STD_LOGIC_VECTOR(1 downto 0);
signal DEBOUNCE_MAX : STD_LOGIC_VECTOR(1 downto 0) := "01";
signal tempBit : INTEGER;


-- -----------------------------------------------------
-- This function returns TRUE if the given op code is a
-- 4-phase instruction rather than a 2-phase instruction
-- -----------------------------------------------------	
function Is4Phase(constant DATA : STD_LOGIC_VECTOR(7 downto 0)) return BOOLEAN is
variable MSB5 : STD_LOGIC_VECTOR(4 downto 0);
variable RETVAL : BOOLEAN;
begin
  MSB5 := DATA(7 downto 3);
  if(MSB5 = "00000") then
	 RETVAL := true;
  else
	 RETVAL := false;
  end if;
 return RETVAL;
end function;

-- -----------------------------------------------------
-- This function returns the decoded number of the register
-- -----------------------------------------------------	
function Decoder(constant num : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is

variable retval : STD_LOGIC_VECTOR(6 downto 0);
begin
   case num is
    when "0000" => retval := "0000001"; --0
    when "0001" => retval := "1001111"; --1
    when "0010" => retval := "0010010"; --2
    when "0011" => retval := "0000110"; --3
    when "0100" => retval := "1001100"; --4
    when "0101" => retval := "0100100"; --5
    when "0110" => retval := "0100000"; --6
    when "0111" => retval := "0001111"; --7
    when "1000" => retval := "0000000"; --8
    when "1001" => retval := "0000100"; --9
    when others => retval := "1111110"; -- '-'
    end case;

return retval;

end function;

-- -----------------------------------------------------
-- This function returns TRUE if the given op code is a
-- 5-phase instruction rather than a 2-phase instruction
-- -----------------------------------------------------	
function Is5Phase(constant DATA : STD_LOGIC_VECTOR(7 downto 0)) return BOOLEAN is
variable MSB5 : STD_LOGIC_VECTOR(4 downto 0);
variable RETVAL : BOOLEAN;
begin
  MSB5 := DATA(7 downto 3);
  if(MSB5 = "00010") then
	 RETVAL := true;
  else
	 RETVAL := false;
  end if;
 return RETVAL;
end function;
	
-- --------- Declare variables that indicate which registers are to be written --------
-- --------- from the DATA bus at the start of the next Fetch cycle. ------------------
signal Exc_RegWrite : STD_LOGIC;        -- Latch data bus in A or B
signal Exc_CCWrite : STD_LOGIC;         -- Latch ALU status bits in CCR
signal Exc_IOWrite : STD_LOGIC;         -- Latch data bus in I/O
signal Exc_BCDO : STD_LOGIC;

----------------------------Temp Outport variables----------------------
signal tempOut0, tempOut1 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');


	
begin
-- ------------ Instantiate the ALU component ---------------
U1 : alu PORT MAP (ALU_A, ALU_B, ALU_FUNC, ALU_OUT, ALU_N, ALU_V, ALU_Z);
			
-- ------------ Drive the ALU_FUNC input ----------------
ALU_FUNC <= IR(6 downto 4);
	
-- ------------ Instantiate the RAM component -------------
U2 : microram PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

--U2 : microram_sim PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

-- ---------------- Generate RAM write enable ---------------------
-- The address and data are presented to the RAM during the Memory phase, 
-- hence this is when we need to set RAM_WE high.
process (CurrState,IR)
begin
  if((CurrState = Memory) and (IR(7 downto 2) = "000001")) then
	  RAM_WE <= '1';
  else
	  RAM_WE <= '0';
  end if;
end process;
	
-- ---------------- Generate address bus --------------------------
with CurrState select
	 ADDR <= STD_LOGIC_VECTOR(PC) when Fetch,
			 STD_LOGIC_VECTOR(PC) when Operand,  -- really a don't care
			 IR(1) & MDR when Memory,
			 STD_LOGIC_VECTOR(PC) when Execute,
			 STD_LOGIC_VECTOR(PC) when others;   -- just to be safe
				
-- --------------------------------------------------------------------
-- This is the next-state logic for the 4-phase state machine.
-- --------------------------------------------------------------------
process (clk,reset)
variable temp : integer;
begin
  if(reset = '1') then
	 CurrState <= Fetch;
	 PC <= (others => '0');
	 IR <= (others => '0');
	 MDR <= (others => '0');
	 A <= X"01";
	 B <= (others => '0');
	 N <= '0';
	 Z <= '0';
	 V <= '0';
	 Ledport0 <= (others => '0');
	 Ledport1 <= (others => '0');
	 Outport0 <= "1111110";
     Outport1 <= "1111110";
	 temp := 0;
  elsif(rising_edge(clk)) then
	 case CurrState is
		  when Fetch => IR <= DATA;
					    if(Is4Phase(DATA)) then
						   PC <= PC + 1;
						   temp := temp + 1;
						   CurrState <= Operand;
					    else
						   CurrState <= Execute;
					    end if;

		 when Operand => MDR <= DATA;
					     CurrState <= Memory;

		 when Memory => CurrState <= Execute;
					
		 when Execute => if(temp = 2) then 
		                    PC <= "000000010";
					     else
					        PC <= PC + 1;
					        temp := temp +1;
					     end if;
					     CurrState <= Fetch;
					
					     if(Exc_RegWrite = '1') then   -- Writing result to A or B
						    if(IR(0) = '0') then
							   A <= SIGNED(DATA);
						    else
							   B <= SIGNED(DATA);
						    end if;
					     end if;
					
					     if(Exc_CCWrite = '1') then    -- Updating flag bits
						    V <= ALU_V;
						    N <= ALU_N;
						    Z <= ALU_Z;
					     end if;

					     if(Exc_IOWrite = '1') then    -- Write to Outport0 or OutPort1
						    if(IR(1) = '0') then
							   Ledport0 <= DATA;
						    else
							   Ledport1 <= DATA;
							   end if;
						    end if;
					     
					  	if (Exc_BCDO = '1') then
                          Outport0 <= Decoder(tempOut0); --Call decoder function to decode the number to seven segment
                          Outport1 <= Decoder(tempOut1);
                       end if;
					
			when Others => CurrState <= Fetch;
		end case;
	end if;
end process;

	
process (CurrState,RAM_DATA_OUT,A,B,ALU_OUT,Inport0,Inport1,IR) 
begin
-- Set these to 0 in each phase unless overridden, just so we don't
-- generate latches (which are unnecessary).
Exc_RegWrite <= '0';
Exc_CCWrite <= '0';
Exc_IOWrite <= '0';
Exc_BCDO <= '0';

-- Same idea
ALU_A <= A;
ALU_B <= B;

-- Same idea
DATA <= RAM_DATA_OUT;

case CurrState is
	 when Fetch | Operand => DATA <= RAM_DATA_OUT;
						
	 when Memory => if(IR(0) = '0') then
					   DATA <= STD_LOGIC_VECTOR(A);
				    else
					   DATA <= STD_LOGIC_VECTOR(B);
				    end if;
				
	 when Execute => case IR(7 downto 1) is
					      when "1000000" 			-- ADD R
						     | "1001000"			-- SUB R
						     | "1100000"			-- XOR R
						     | "1111000" =>			-- CLR R
						        DATA <= STD_LOGIC_VECTOR(ALU_OUT);
						        Exc_RegWrite <= '1';
                                Exc_CCWrite <= '1';
						
					      when "1010000"			-- LSL R
						     | "1011000"			-- LSR R
						     | "1101000"			-- COM R
						     | "1110000" =>			-- NEG R
						        if(IR(0) = '0') then
						 	       ALU_A <= A;
						        else
						 	       ALU_A <= B;
						        end if;
						        DATA <= STD_LOGIC_VECTOR(ALU_OUT);
						        Exc_RegWrite <= '1';
						        Exc_CCWrite <= '1';

					      when "0000100"|"0000101" =>          -- OUT R,P
						        if(IR(0) = '0') then
							       DATA <= STD_LOGIC_VECTOR(A);
						        else
							       DATA <= STD_LOGIC_VECTOR(B);
						        end if;
						        Exc_IOWrite <= '1';
						
					      when "0000110"|"0000111" =>	         -- IN P,R
						        if(IR(1) = '0') then
							       DATA <= Inport0;
						        else
							       DATA <= Inport1;
						        end if;
						        Exc_RegWrite <= '1';
						
					      when "0000000"|"0000001" =>          -- LOAD M,R
						        DATA <= RAM_DATA_OUT;
						        Exc_RegWrite <= '1';
						        
						 when "0101000" =>          -- BCDO R
                               if(IR(0) = '0') then
                               DATA <= STD_LOGIC_VECTOR(A);
                               tempOut0 <= DATA(3 downto 0); --Take lower 4 bits
                               tempOut1 <= DATA(7 downto 4); --Tale upper 4 bits
                               else
                               DATA <= STD_LOGIC_VECTOR(B);
                               tempOut0 <= DATA(3 downto 0); --Take lower 4 bits
                               tempOut1 <= DATA(7 downto 4); --Tale upper 4 bits
                               end if;
                               Exc_IOWrite <= '1'; 
                               Exc_BCDO <= '1';      
                               
                        when "0111000" | "0111001" =>          -- DEB 0, R, ; DEB 1, R,  
                        if(IR(1) = '0') then
                                 
                            if(Debounce0 = "00") then
                              DATA <= X"01";
                              else
                              DATA <= X"00";
                              end if;
                        else
                            if(Debounce1 = "00") then
                            DATA <= X"01";
                            else
                            DATA <= X"00";
                            end if;
                        end if;
                        Exc_RegWrite <= '1'; --For me, has to be something else
                        
--                       when "0001000" =>          -- CLRB M, B
--                       DATA <= RAM_DATA_OUT;
                       
--                       --tempBit <= IEEE.NUMERIC_STD.to_integer(unsigned(IR(1 downto 0)));          --Bit number
--                       tempBit <= 0;
--                          if (tempBit = 7) then
--                          DATA <= '0' & DATA(6 downto 0);
--                          elsif(tempBit = 0) then
--                          Data <= Data(7 downto 1) & '0';
--                          else
--                          DATA <= ( DATA(7 downto (tempBit+1) ) & '0' ) & DATA( (tempBit-1) downto 0); 
--                          end if;
--                        Exc_RegWrite <= '1'; --For me, has to be something else
     
						
					      when "0000010"|"0000011" =>	       -- STOR R,M
						        null;
								
					      when others => null;
				    end case;
		end case;	
end process;


-------------------------Debounce timer 0-------------------------------------
process(clk,reset)
begin
if (reset = '1') then
    Debounce0 <= DEBOUNCE_MAX;
elsif(rising_edge(clk)) then
    if(Inport0(0) = '1') then
    Debounce0 <= DEBOUNCE_MAX;
    elsif (Debounce0 > 0) then
        Debounce0 <= Debounce0 - 1;
    else
        Debounce0 <= "00";
    end if;
end if;

end process;

-------------------------Debounce timer 1-------------------------------------
process(clk,reset)
begin
if (reset = '1') then
    Debounce1 <= DEBOUNCE_MAX;
elsif(rising_edge(clk)) then
    if(Inport0(1) = '1') then
    Debounce1 <= DEBOUNCE_MAX;
    elsif (Debounce1 > 0) then
        Debounce1 <= Debounce1 - 1;
    else
        Debounce1 <= "00";
    end if;
end if;

end process;


end a;

