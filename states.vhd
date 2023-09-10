library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity FSM is 
port(clk:in std_logic;
		c_flag_d2,z_flag_d2,flag_carry,flag_zero,flag_equal: in std_logic;
		mem_write,c_flag_d1,c_flag_write,z_flag_d1,z_flag_write,flag_op,rf_write,t1_write,t2_write,t3_write,t4_write,instr_write:out std_logic;
		mem_d2,instr_d2,t1_d2,t2_d2,t3_d2,t4_d2,alu_c,rf_d1,rf_d2, sig_pc:in std_logic_vector(15 downto 0);     	 -- outputs
		mem_a1,mem_d1,instr_d1,t1_d1,t2_d1,t3_d1,t4_d1,alu_a,alu_b,rf_d3:out std_logic_vector(15 downto 0); 		 -- inputs
		rf_a1,rf_a2,rf_a3:out std_logic_vector(2 downto 0);
		state: out std_logic_vector(4 downto 0));
end entity;

architecture fsm_arc of FSM is

   constant OC_ADDR : std_logic_vector(3 downto 0)	    :="0000";		-- ADD,ADC,ADZ
	constant OC_ADDI : std_logic_vector(3 downto 0)	    :="0001";
	constant OC_NNDR : std_logic_vector(3 downto 0)	    :="0010";		-- NDU,NDC,NDZ
	constant OC_LHI  : std_logic_vector(3 downto 0)	    :="0011";
	constant OC_LW   : std_logic_vector(3 downto 0)		 :="0100";
	constant OC_SW   : std_logic_vector(3 downto 0)		 :="0101";
	constant OC_LM   : std_logic_vector(3 downto 0)		 :="0110";
	constant OC_SM   : std_logic_vector(3 downto 0)		 :="0111";
	constant OC_JAL  : std_logic_vector(3 downto 0)	    :="1000";
	constant OC_JLR  : std_logic_vector(3 downto 0)	    :="1001";
	constant OC_BEQ  : std_logic_vector(3 downto 0)	    :="1100";

begin
	process(clk,c_flag_d2,z_flag_d2,flag_carry,flag_zero,flag_equal,mem_d2,instr_d2,t1_d2,t2_d2,t3_d2,t4_d2,alu_c,rf_d1,rf_d2)
			variable nextstate:std_logic_vector(4 downto 0);
			variable crntstate:std_logic_vector(4 downto 0):="00000";
			variable opcode:std_logic_vector(3 downto 0);	
	begin
		case crntstate is
		
	----------------------------------------state0------------------------------	
			when "00000" =>
				state<=crntstate;
				mem_write<='0';
				c_flag_write<='0';
				z_flag_write<='0';
				rf_write<='0';
				t1_write<='0';
				t2_write<='0';
				t3_write<='0';
				instr_write<='0';
				nextstate:="00001";
				
	-----------------------------------------state1--------------------------------			
			when "00001" =>
				state<=crntstate;
				rf_write<='0';
				rf_a3 <= "111";
				instr_write<='1';
				mem_a1<=sig_pc;
				instr_d1<=mem_d2;
				opcode:=mem_d2(15 downto 12);
				nextstate:="00010";
				
	----------------------------------------state2----------------------------------			
			when "00010" =>
				state<=crntstate;
				instr_write<='0';
				rf_write<='0';
				rf_a3 <= "111";
				alu_a<=sig_pc;
				alu_b<="0000000000000010";
				flag_op<='0';
				nextstate:="00011";
				
	----------------------------------------state3----------------------------------	
			when "00011" =>
				rf_write<='1';
				rf_a3 <= "111";
				rf_d3<=alu_c;	
				if(opcode= OC_LHI) then
					nextstate:="01000";
				elsif(opcode= OC_LW) then
					nextstate:="01001";
				elsif(opcode= OC_SW or opcode= OC_BEQ) then
					nextstate:="01011";
				elsif(opcode= OC_JAL) then
					nextstate:="10000";
				elsif(opcode = OC_LM) then
					nextState:="10101";
				elsif(opcode = OC_SM) then
					nextState:="10101";
				else
					nextstate:="00100";
				end if;

----------------------------------------state4----------------------------------------
			when "00100" =>
				state<=crntstate;
				instr_write<='0';
				rf_write<='0';
				t1_write<='1';
				t2_write<='1';
				rf_a1<=instr_d2(11 downto 9);
				rf_a2<=instr_d2(8 downto 6);
				t1_d1<=rf_d1;
				t2_d1<=rf_d2;	
				if(opcode = OC_ADDR) then
					nextState:="00101";
				elsif(opcode = OC_ADDI) then
					nextState:= "00111";
				elsif(opcode = OC_NNDR) then
					nextState:= "00101";
				elsif(opcode = OC_JLR) then
					nextState:= "10000" ;
				end if;				

----------------------------------------state5------------------------------------------
			when "00101" =>
				state<=crntstate;
				t1_write<='0';
				t2_write<='0';
				t3_write<='1';
				alu_a<=t1_d2;
				alu_b<=t2_d2;
				t3_d1<=alu_c;
				if(opcode= OC_ADDR) then   -- only writing carry and zero signals to flagreg
					flag_op<='0';
					c_flag_write<='1';
					z_flag_write<='1';
					c_flag_d1<=flag_carry;
					z_flag_d1<=flag_zero;
					nextstate:="00110";
				elsif(opcode= OC_NNDR) then
					flag_op<='1';              -------------nand
					z_flag_write<='1';
					z_flag_d1<=flag_zero;	   -------------checking for zero flag
					nextstate:="00110";			
					end if;
				nextstate:="00001";
				
				
----------------------------------------------state6------------------------------------------------				
			when "00110" =>
				state<=crntstate;
				t3_write<='0';
				c_flag_write<='0';
				z_flag_write<='0';
				rf_write<='1';
				if(opcode= OC_ADDR or opcode= OC_NNDR) then
				case instr_d2(1 downto 0) is
						when "00" =>
								rf_d3<=t3_d2;
				            rf_a3<=instr_d2(5 downto 3);							 
						when "01" =>
							if(z_flag_d2 = '0') then
								nextstate:="00001";
							else
								rf_d3<=t3_d2;
				            rf_a3<=instr_d2(5 downto 3);
							end if;
						when "10" =>
							if(c_flag_d2 = '0') then
								nextstate:="00001";
							else
								rf_d3<=t3_d2;
				            rf_a3<=instr_d2(5 downto 3);
							end if;
						when others =>
							null;
					end case;
				end if;	
				nextstate:="00001";

--------------------------------------state7------------------------------------------	
         when "00111" =>
            state<=crntstate;
				t2_write<='0';	
				rf_write<='1';
				alu_a<=t2_d2;
				alu_b<="0000000000" & instr_d2(5 downto 0);
				flag_op<='0';
            rf_d3<= alu_c;
            rf_a3<= instr_d2(8 downto 6);	
	         nextstate:= "00010";		

--------------------------------------state8-----------------------------------------
			when "01000" =>
				state<=crntstate;
				rf_a3<=instr_d2(11 downto 9);
				rf_d3<=instr_d2(8 downto 0) & "0000000";
				rf_write<='1';
				nextstate:="00001";			
		
---------------------------------------state9------------------------------------------
			when "01001" =>
				state<=crntstate;
				t1_write<='0';
				t2_write<='1';
				rf_write<='0';
				rf_a2<=instr_d2(8 downto 6);
				t2_d1<=rf_d2;
				nextstate:="01010";
				
--------------------------------------state10--------------------------------------------				
			when "01010" =>
				state<=crntstate;
				t1_write<='0';
				t2_write<='0';
				rf_a3<=instr_d2(11 downto 9);
				alu_b<="0000000000" & instr_d2(5 downto 0);
				alu_a<=t2_d2;
				flag_op<='0';
				z_flag_write<='1'; ----------modifies zflag
				z_flag_d1<=flag_zero;
				mem_a1<=alu_c;
				rf_d3<=mem_d2;
				rf_write<='1';
				nextstate:="00001";
				
---------------------------------------state11--------------------------------------------			
			when "01011" =>
			   state<=crntstate;
				rf_write<='0';
				t1_write<='1';
				t2_write<='1';
				rf_a1<=instr_d2(11 downto 9);
				rf_a2<=instr_d2(8 downto 6);
				t1_d1<=rf_d1;
				t2_d1<=rf_d2;
				if(opcode= OC_BEQ) then
					nextstate:="01101";
				elsif(opcode= OC_SW) then
			      nextstate:="01100";
				end if;	
				
--------------------------------------state12-----------------------------------------				
			when "01100" =>
			   state<=crntstate;
				t1_write<='0';
				t2_write<='0';
				alu_b<="0000000000" & instr_d2(5 downto 0);
				alu_a<=t2_d2;
				flag_op<='0';
				mem_write<='1';
				mem_d1<=t1_d2;
				mem_a1<=alu_c;
				nextstate:= "00010";			
			
--------------------------------------state13------------------------------------------
			when "01101" =>
				state<=crntstate;
				t1_write<='0';
				t2_write<='0';
				alu_a<=t1_d2;
				alu_b<=t2_d2;
				if(flag_equal='1') then
					nextstate:="01110";
				else
					nextstate:="00001";
				end if;
				
-------------------------------------state14--------------------------------------------				
			when "01110" =>
				state<=crntstate;
				rf_write<='0';
				rf_a3<="111";
				alu_a<=sig_pc;
				alu_b<="0000000000" & instr_d2(5 downto 0);
				flag_op<='0';
				nextstate:="01111";
				
-------------------------------------state15--------------------------------------------				
			when "01111" =>				
				rf_write<='1';
				rf_a3<="111";
				rf_d3<=alu_c;
				nextstate:="00001";
				
--------------------------------------state16---------------------------------------------				
			when "10000" =>
				state<=crntstate;
				instr_write<='0';
				t1_write<='1';
				rf_write<='0';
				rf_a1<=instr_d2(11 downto 9);
				t1_d1<=rf_d1;
				nextstate:="10001";
				
--------------------------------------state17----------------------------------------------				
			when "10001" =>
				state<=crntstate;
				t1_write<='0';
				alu_a<=t1_d2;
				alu_b<="0000000" & instr_d2(8 downto 0);
				flag_op<='0';
				rf_write<='1';
				rf_a3<="111";
				rf_d3<=alu_c;
				nextstate:="00001";
				
--------------------------------------state18-----------------------------------------------				
			when "10010" =>
            state<=crntstate;
				rf_write<= '0';
				rf_a3<="111";
				t4_write<='1';
				t4_d1<=sig_pc;
				nextstate:="10011";
				
--------------------------------------state19-----------------------------------------------				
			when "10011" =>
            state<=crntstate;
	         instr_write<='0';
				t4_write<= '0';
	         rf_write<='1';	
				rf_a3<=instr_d2(11 downto 9);
		      rf_d3<=t4_d2;
				nextstate:="10100";
				
--------------------------------------state20-----------------------------------------------				
			when "10100" =>
            state<=crntstate;
		      rf_write<='1';
				rf_a3<="111";
		      rf_d3<=t2_d2;
		      nextstate:= "00010";				

------------------------------------------state21-------------------------------------------				
			when "10101" =>
				state<=crntstate;
				rf_a1<=instr_d2(11 downto 9);
				t1_write<='1';
				t1_d1<=rf_d1;
				t2_write<='1';
				t2_d1<="0000000000000000";
				if(opcode=OC_LM) then 
					nextstate:="10110";      ------22 for lm
				elsif(opcode=OC_SM) then
					nextstate:="11001";      ------25 for sm
				end if;
				
----------------------------------------------state22---------------------------------------				
			when "10110" =>
				state<=crntstate;
				t1_write<='0';
				t2_write<='0';
				rf_write<='1';
				if(instr_d2(7 downto 0)(to_integer(unsigned(t2_d2)))='1') then
					mem_a1<=t1_d2;
					rf_d3<=mem_d2;
					rf_a3<=t2_d2(2 downto 0);
				end if;
				nextstate:="10111";
				
--------------------------------------------state23------------------------------------------				
			when "10111" =>
				state<=crntstate;
				rf_write<='0';
				t1_write<='1';
				alu_a<=t1_d2;
				alu_b<="0000000000000010";
				flag_op<='0';
				t1_d1<=alu_c;
				nextstate:="11000";
				
-------------------------------------------state24-------------------------------------------				
			when "11000" =>
				state<=crntstate;
				t1_write<='0';
				alu_a<=t2_d2;
				alu_b<="0000000000000010";
				flag_op<='0';
				t2_write<='1';
				t2_d1<=alu_c;
				if(t2_d2="0000000000000111") then
					nextstate:="00001";
				else
					if(opcode=OC_LM) then
						nextstate:="10110";
					elsif(opcode=OC_SM) then
						nextstate:="11001";
					end if;
				end if;
				
------------------------------------------state25---------------------------------------------				
			when "11001" =>
				state<=crntstate;
				t1_write<='0';
				t2_write<='0';
				mem_write<='1';
				if(instr_d2(7 downto 0)(7-to_integer(unsigned(t2_d2)))='1')  then
				   rf_write<='0';
					rf_a1<=t2_d2(2 downto 0);
					mem_d1<=rf_d1;
					mem_a1<=t1_d2;
				end if;
				nextstate:="10111";
				
-----------------------------------------------------------------------------------------------				
			when others =>
				null;
		end case;
		if rising_edge(clk)  then
			crntstate := nextstate;
		end if;
	end process;
end architecture;