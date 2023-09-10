library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity flagreg is
	port(
    flag_d2: out std_logic;
    flag_d1: in  std_logic;
    flag_write,clk: in  std_logic);
end flagreg;

architecture flagreg_arc of flagreg is
	signal data: std_logic:='0';
begin
	flag_d2<=data;
	process(clk) 
	begin
		if(rising_edge(clk)) then
			if(flag_write='1') then
				data<=flag_d1;
			end if;
		end if;
	end process;
end architecture;