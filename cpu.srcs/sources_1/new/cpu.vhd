----------------------------------------------------------------------------------
-- Company: Grand Valley State University
-- Engineer: Jason Hunter
-- 
-- Create Date: 03/16/2017 05:19:26 PM
-- Design Name: 
-- Module Name: cpu - Behavioral
-- Project Name: EGR-426-Project-3
-- Target Devices: Artix 7
-- Description: This component is the CPU itself with the state machine and the 
--  logic behind each phase.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity cpu is
PORT(clk : in STD_LOGIC;
	 reset : in STD_LOGIC;
	 Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
	 Ledport0, Ledport1	: out STD_LOGIC_VECTOR(7 downto 0);
	 Outport0, Outport1 : out STD_LOGIC_VECTOR (6 downto 0);
	 PWMout : out STD_LOGIC_VECTOR(7 downto 0)
	 );
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
--component microram is
--port (  CLOCK   : in STD_LOGIC ;
--		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
--		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
--		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
--		WE	: in STD_LOGIC 
--	 );
--end component;

component microram_sim is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	 );
end component;

-- -----------------------------------------------------
-- SIGNAL DECLARATIONS
-- -----------------------------------------------------
-- ---------- Declare signals interfacing to RAM ---------------
signal RAM_DATA_OUT : STD_LOGIC_VECTOR(7 downto 0);  -- DATAOUT output of RAM
signal ADDR : STD_LOGIC_VECTOR(8 downto 0);	         -- ADDRESS input of RAM
signal RAM_WE : STD_LOGIC;

-- ---------- Declare the state names and state variable -------------
type STATE_TYPE is (Fetch, Operand, Memory, Load, Execute, WriteBack, SetAddr, CheckIR, SetAddr2);
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

-- --------- Declare variables that indicate which registers are to be written --------
-- --------- from the DATA bus at the start of the next Fetch cycle. ------------------
signal Exc_RegWrite : STD_LOGIC;        -- Latch data bus in A or B
signal Exc_CCWrite : STD_LOGIC;         -- Latch ALU status bits in CCR
signal Exc_IOWrite : STD_LOGIC;         -- Latch data bus in I/O
signal Exc_BCDO : STD_LOGIC;
signal Exc_PWM : STD_LOGIC;
signal Exc_CLRB : STD_LOGIC;

--------------------Temp Outport variables and flags----------------------
signal tempOut0, tempOut1 : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal tempBitNum : STD_LOGIC_VECTOR(2 downto 0);
signal tempWriteBack : UNSIGNED(7 downto 0);
signal fourPhaseFlag : STD_LOGIC;
signal sevenPhaseFlag : STD_LOGIC;
signal decmFlag : STD_LOGIC;
signal resetFlag : STD_LOGIC := '0';
signal countWhenReset : STD_LOGIC_VECTOR(1 downto 0) := "00";
-- -----------------------------------------------------
-- END SIGNAL DECLARATIONS
-- -----------------------------------------------------


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
-- This function returns TRUE if the given op code is a
-- 7-phase instruction rather than a 2-phase instruction
-- -----------------------------------------------------	
function Is7Phase(constant DATA : STD_LOGIC_VECTOR(7 downto 0)) return BOOLEAN is
variable MSB4 : STD_LOGIC_VECTOR(2 downto 0);
variable MSB6 : STD_LOGIC_VECTOR(6 downto 0);
variable RETVAL : BOOLEAN;
begin
  MSB4 := DATA(7 downto 5);
  MSB6 := DATA(7 downto 1);
  if(MSB4 = "001" or MSB6 = "0111110") then
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
-- This function returns the decoded number of the register
-- -----------------------------------------------------	
function DecoderBit(constant num : STD_LOGIC_VECTOR(2 downto 0)) return INTEGER is

variable retval : INTEGER;
begin
   case num is
    when "000" => retval := 0; --0
    when "001" => retval := 1; --1
    when "010" => retval := 2; --2
    when "011" => retval := 3; --3
    when "100" => retval := 4; --4
    when "101" => retval := 5; --5
    when "110" => retval := 6; --6
    when "111" => retval := 7; --7
    when others => retval := 0; -- 0
    end case;

return retval;

end function;
	
begin
-- ------------ Instantiate the ALU component ---------------
U1 : alu PORT MAP (ALU_A, ALU_B, ALU_FUNC, ALU_OUT, ALU_N, ALU_V, ALU_Z);
			
-- ------------ Drive the ALU_FUNC input ----------------
ALU_FUNC <= IR(6 downto 4);
	
-- ------------ Instantiate the RAM component -------------
--U2 : microram PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

U2 : microram_sim PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

-- ---------------- Generate RAM write enable ---------------------
-- The address and data are presented to the RAM during the Memory phase, 
-- hence this is when we need to set RAM_WE high.
process (CurrState,IR)
begin
  if( ((CurrState = Memory) and (IR(7 downto 2) = "000001")) or ( (CurrState = WriteBack) and (IR(7 downto 5) = "001"))
        or ( (CurrState = WriteBack) and (IR(7 downto 1) = "0111110"))  ) then
	  RAM_WE <= '1';
  else
	  RAM_WE <= '0';
  end if;
end process;
	
-- ---------------- Generate address bus --------------------------

process (CurrState)
begin

--If current state is Fetch then set Address to the PC
if (CurrState = Fetch) then
    ADDR <= STD_LOGIC_VECTOR(PC);

--If current state is Operand then set Address to the PC
elsif (CurrState = Operand) then
    ADDR <= STD_LOGIC_VECTOR(PC);

--If current state is Memory then set Address to the memory location
elsif (CurrState = Memory) then
    ADDR <= IR(1) & MDR;
    
--If current state is Load then set Address to the memory location  
elsif (CurrState = Load) then
   ADDR <= IR(1) & MDR;

--If current state is Fetch then set Address to the PC        
elsif (CurrState = Execute) then
    --If instruction is a 2 or 4 phase then set address to PC
    if(sevenPhaseFlag = '0') then
    ADDR <= STD_LOGIC_VECTOR(PC);    
    
    --If instruction has 7 phases then set address to the memory location
    else
    ADDR <= IR(1) & MDR;
    end if;    

--If current state is WriteBack then set Address to the memory location
-- This is important because this address will need to be the address that
-- we are writing back to
elsif (CurrState = WriteBack) then
    ADDR <= IR(1) & MDR;  

--If current state is SetAddr then set Address to the PC    
-- This is important because we need to set the address to the PC
-- the clock cycle before we check the instruction.
elsif (CurrState = SetAddr) then
    ADDR <= STD_LOGIC_VECTOR(PC); 
    
--If current state is CheckIR then set Address to the PC    
 elsif (CurrState = CheckIR) then
    ADDR <= STD_LOGIC_VECTOR(PC);
     
--If current state is SetAddr2 then set Address to the PC    
    -- This is important because we need to set the address to the PC
    -- the clock cycle before the next instruction's fetch phase.
 elsif (CurrState = SetAddr2) then
    ADDR <= STD_LOGIC_VECTOR(PC);     

--Just in case
else
    ADDR <= STD_LOGIC_VECTOR(PC);            

end if;

end process;
				
-- --------------------------------------------------------------------
-- This is the next-state logic for the 7-phase state machine.
-- --------------------------------------------------------------------
process (clk,reset)
variable temp : integer;
begin
    --If user pressed reset
  if(reset = '1' or resetFlag = '1') then
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
     PWMout <= (others => '0');
	 temp := 0;
	 fourPhaseFlag <= '0';
	 sevenPhaseFlag <= '0';
	 decmFlag <= '0';
	 
	 --Wait a second to reset CPU
	 if(resetFlag = '1') then
	   if(rising_edge(clk)) then
	   countWhenReset <= countWhenReset + 1;
	   else
	   countWhenReset <= countWhenReset;
	   end if;
	 end if;
	 
	 --Turn off reset
	 if( countWhenReset = "01") then
	 resetFlag <= '0';
	 end if;
  elsif(rising_edge(clk)) then
	 case CurrState is
------------------- Fetch/Operand --------------------------
		  when Fetch => IR <= DATA;
		              --If the instruction has 4 phases then proceed normally and set 4 phase flag
					    if(Is4Phase(DATA)) then
						   PC <= PC + 1;
						   temp := temp + 1;
						   fourPhaseFlag <= '1';
						   sevenPhaseFlag <= '0';
						   CurrState <= Operand;
						   
					--If the instruction has 7 phases then proceed normally and set 7 phase flag	   
						elsif (Is7Phase(DATA)) then
						PC <= PC + 1;
                        temp := temp + 1;
                        fourPhaseFlag <= '0';
                        sevenPhaseFlag <= '1';
                        
                        --Proceed to operand
                        CurrState <= Operand;
                        
                        --If the instruction only has 2 phases then proceed to execute
					    else
					       fourPhaseFlag <= '0';
					       sevenPhaseFlag <= '0';
					       
					       --Check if its at the end
					       if( PC >= 34) then
					       resetFlag <= '1';
					       else
					       PC <= PC;
					       
						   CurrState <= Execute;
						   end if;
					    end if;
------------------- Operand --------------------------
		 when Operand =>
		  MDR <= DATA; --Set the MDR
		 tempBitNum <= IR(4 downto 2); --Last 3 bits of instruction was the bit number to change
		CurrState <= Memory; --Proceed to Memory state

------------------- Memory --------------------------
		 when Memory => 
		 --If instruction has seven phases
		 if(sevenPhaseFlag = '1') then
		 --Converting the 3 bits to an integer
         --Part of the CLRB 
         tempBit <= DecoderBit(tempBitNum);	 
		 CurrState <= Load;

        --If instruction is 4 phase then proceed to execute
		 else
		 CurrState <= Execute;
		 end if;
		 
------------------- Load --------------------------
         when Load => CurrState <= Execute;
	
------------------- Execute --------------------------				
		 when Execute => if(temp = 2) then 
		                    PC <= "000000010";
					    elsif(sevenPhaseFlag = '1') then --Make sure PC does not change if it is going to WriteBack state
					    PC <= PC;			
					    --If instruction is 4 phase then increment PC		    
					    else
                            PC <= PC + 1;
                            temp := temp +1;
					     end if;
					     
					     --Check if instruction needs to go to WriteBack phase
					     if(sevenPhaseFlag = '1') then
					     CurrState <= WriteBack;
					     else
					     CurrState <= Fetch;
					     end if;
					
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
                          
                        if(Exc_PWM = '1') then                                                   
                        PWMout <= DATA; --Set the PWM output to the value that is currently in DATA bus
                        end if;
                       
------------------- WriteBack --------------------------
    when WriteBack => 
    
    --If instruction is not DECMSZ
    if(decmFlag <= '0') then
    --Check the condition flags after clearing a certain bit number
    if(DATA = X"00") then
    Z <= '1';
    elsif ( DATA(7) = '1') then
    N <= '1';
    else
    Z <= '0';
    N <= '0';
    end if;
    
    end if;
    
    --Go to SetAddr phase
    CurrState <= SetAddr;   
     
------------------- SetAddr --------------------------
     when SetAddr => 
     --If the decrement value went to zero
     if(DATA = X"00") then
     CurrState <= CheckIR;
     
     --If the new decremented value was not zero then
     -- proceed to normal and go to fetch state
     else
     CurrState <= Fetch;    
     
     end if;    
        
------------------- CheckIR --------------------------     
     when CheckIR =>
     --If the instruction that needs to be skipped has 4 or 7 phases then increment 
     -- PC by 2 to skip memory location
       if(Is4Phase(DATA) or Is7Phase(DATA)) then
        PC <= PC + 2;
     --If the instruction that needs to be skipped only has 2 phases then increment 
     -- PC by 1
       else
       PC <= PC + 1;
       
       end if;
       
    CurrState <= SetAddr2;
    
    
 ------------------- SetAddr2 --------------------------
   when SetAddr2 => CurrState <= Fetch;
         
         
         
         
when Others => CurrState <= Fetch;
			

		end case;
	end if;
end process;

-- --------------------------------------------------------------------
-- Combinational logic for FSM
-- --------------------------------------------------------------------	
process (CurrState,RAM_DATA_OUT,A,B,ALU_OUT,Inport0,Inport1,IR) 
begin
-- Set these to 0 in each phase unless overridden, just so we don't
-- generate latches (which are unnecessary).
Exc_RegWrite <= '0';
Exc_CCWrite <= '0';
Exc_IOWrite <= '0';
Exc_BCDO <= '0';
Exc_PWM <= '0';
Exc_CLRB <= '0';

-- Same idea
ALU_A <= A;
ALU_B <= B;

-- Same idea
DATA <= RAM_DATA_OUT;

case CurrState is
------------------- Fetch/Operand --------------------------
	 when Fetch | Operand => DATA <= RAM_DATA_OUT;

------------------- Memory --------------------------						
	 when Memory => 
	                --If its a 7 phase instruction then get DATA out of RAM
	                if(sevenPhaseFlag = '1') then
	                --Recieving DATA from RAM
                    DATA <= RAM_DATA_OUT; 
	               else
	               
	                if(IR(0) = '0') then
					   DATA <= STD_LOGIC_VECTOR(A);
				    else
					   DATA <= STD_LOGIC_VECTOR(B);
				    end if;

                   end if;

------------------- Load --------------------------						
	 when Load => DATA <= RAM_DATA_OUT;  --If its a 7 phase instruction then get DATA out of RAM

                   
------------------- Execute --------------------------				
	 when Execute => 
	                   case IR(7 downto 1) is
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
                               --Exc_IOWrite <= '1'; 
                               Exc_BCDO <= '1';      
                               
                        when "0111000" | "0111001" =>          -- DEB 0, R, ; DEB 1, R,  
                        if(IR(1) = '0') then
                                 
                            if(Debounce0 = "00") then
                              DATA <= X"01";
                              tempOut0 <= DATA(3 downto 0);
                              else
                              DATA <= X"00";
                              tempOut0 <= DATA(3 downto 0);
                              end if;
                        else
                            if(Debounce1 = "00") then
                            DATA <= X"01";
                            tempOut0 <= DATA(3 downto 0);
                            else
                            DATA <= X"00";
                            tempOut0 <= DATA(3 downto 0);
                            end if;
                        end if;
                        Exc_BCDO <= '1'; --Output result to DATA
                        
                        when "0111010" =>          -- PWM R
                          if(IR(0) = '0') then
                          DATA <= STD_LOGIC_VECTOR(A);
                          else
                          DATA <= STD_LOGIC_VECTOR(B);
                         end if;
                          Exc_PWM <= '1';
                          
                        when "0111110" =>          -- DECMSZ
                        
                        --If the DATA is already at zero then don't
                        -- do anything
                          if(DATA = X"00") then
                          DATA <= X"00";
                          
                        --Decrement DATA
                          else
                          DATA <= DATA - 1;
                          end if;
                        --Set the flag is the instruction was DECMSZ
                          decmFlag <= '1';
                          
            ------------------- CLRB M B instruction case --------------------------
                      when "0010000" |
                           "0010010" |
                           "0010100" |
                           "0010110" |
                           "0011000" |
                           "0011010" |
                           "0011100" |
                           "0011110" =>
                           
                        --Changing particular bit number of DATA
                        --If clearing 7th bit then concatenate with 0
                        if (tempBit = 7) then
                            DATA <= '0' & DATA(6 downto 0);
                        --If clearing 0th bit then concatenate with 0
                        elsif(tempBit = 0) then
                            DATA <= DATA(7 downto 1) & '0';
                        else
                        
                        --Go through all remaining bit numbers (1 - 6) and clear them
                        -- by concatenatig 0 at the bit number location
                        case tempBit is
                        when 1 => DATA <= ( DATA(7 downto 2) & '0' ) & DATA(0);
                        when 2 => DATA <= ( DATA(7 downto 3) & '0' ) & DATA(1 downto 0);
                        when 3 => DATA <= ( DATA(7 downto 4) & '0' ) & DATA(2 downto 0);
                        when 4 => DATA <= ( DATA(7 downto 5) & '0' ) & DATA(3 downto 0);
                        when 5 => DATA <= ( DATA(7 downto 6) & '0' ) & DATA(4 downto 0);
                        when 6 => DATA <= ( DATA(7) & '0' ) & DATA(5 downto 0);
                        when others => DATA <= X"01";                             
                        end case;
                          
                       end if;  
						
					      when "0000010"|"0000011" =>	       -- STOR R,M
						        null;
								
					      when others => null;
				    end case;
                               
 ------------------- WriteBack --------------------------	                              
     when WriteBack => DATA <= DATA;
 
  ------------------- SetAddr --------------------------	    
     when SetAddr => null;
  
 ------------------- SetAddr --------------------------	    
   when CheckIR => null;
        
  ------------------- SetAddr2 --------------------------	    
   when SetAddr2 => null;
   
   
     when others => null;
     
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

