library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity ALU is
port(alu_a:in std_logic_vector(15 downto 0);
		alu_b:in std_logic_vector(15 downto 0);
		flag_op:in std_logic;
		alu_c:out std_logic_vector(15 downto 0);
		flag_carry: out std_logic;
		flag_zero: out std_logic;
		flag_equal: out std_logic);
end ALU;
architecture ALU_arc of ALU is
begin
	process(flag_op,alu_a,alu_b)
		variable temp: std_logic_vector(16 downto 0);
	begin
		--add
		if(flag_op='0') then
			temp:=('0'& alu_a)+('0' & alu_b);
			if(temp(16)='1') then
				flag_carry<='1';
			else
				flag_carry<='0';
			end if;
			if(temp(15 downto 0)="0000000000000000") then
				flag_zero<='1';
			else
				flag_zero<='0';
			end if;
			alu_c<=temp(15 downto 0);
		--nand
		elsif(flag_op='1') then
			temp(15 downto 0):=alu_a nand alu_b;
			if(temp(15 downto 0)="0000000000000000") then
				flag_zero<='1';
			else
				flag_zero<='0';
			end if;
			flag_carry<='0';
			alu_c<=temp(15 downto 0);
		end if;
		if(alu_a=alu_b) then
			flag_equal<='1';
		else
			flag_equal<='0';
		end if;
	end process;
end architecture;