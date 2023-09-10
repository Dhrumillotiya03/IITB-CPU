library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity temp16reg is
	port(
    temp16_d2: out std_logic_vector(15 downto 0);
    temp16_d1: in  std_logic_vector(15 downto 0);
    temp16_write,clk: in  std_logic);
end temp16reg;

architecture temp16reg_arc of temp16reg is
	signal data: std_logic_vector(15 downto 0):="0000000000000000";
begin
	temp16_d2<=data;
	process(clk) 
	begin
		if(rising_edge(clk)) then
			if(temp16_write='1') then
				data<=temp16_d1;
			end if;
		end if;
	end process;
end architecture;