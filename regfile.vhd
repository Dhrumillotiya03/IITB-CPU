library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity RF is
port(	rf_write:in std_logic;
		rf_a1:in std_logic_vector(2 downto 0); --A
		rf_a2:in std_logic_vector(2 downto 0); --B
		rf_a3:in std_logic_vector(2 downto 0); --D
		rf_d1:out std_logic_vector(15 downto 0);
		rf_d2:out std_logic_vector(15 downto 0);
		rf_d3:in std_logic_vector(15 downto 0);
		pc:out std_logic_vector(15 downto 0);
		clk:in std_logic);
end RF;

architecture reg_arc of RF is
	type typereg is array (0 to 7) of std_logic_vector(15 downto 0);    -- 	8 Registers of 16 bits each
	signal registers: typereg:= (others=>"0000000000000000");				-- initialized to 0
begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(rf_write='1') then
				case rf_a3 is
					when "000" =>
						registers(0)<=rf_d3;
					when "001" =>
						registers(1)<=rf_d3;
					when "010" =>
						registers(2)<=rf_d3;
					when "011" =>
						registers(3)<=rf_d3;
					when "100" =>
						registers(4)<=rf_d3;
					when "101" =>
						registers(5)<=rf_d3;
					when "110" =>
						registers(6)<=rf_d3;
					when "111" =>
						registers(7)<=rf_d3;
					when others =>
						null;
				end case;
     elsif(rf_write='0') then
          if(rf_a3="111") then
            pc<=registers(7);
         else
            rf_d1<=registers(to_integer(unsigned(rf_a1)));     --000 means registers(0) and so on
	          rf_d2<=registers(to_integer(unsigned(rf_a2)));
         end if;    
			end if;
		end if;
	end process;
end architecture;