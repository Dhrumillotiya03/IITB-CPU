library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity memory is
port(	mem_write:in std_logic;
		mem_a1:in std_logic_vector(15 downto 0);
		mem_d1:in std_logic_vector(15 downto 0);
		mem_d2: out std_logic_vector(15 downto 0);
		clk:in std_logic);
end memory;

architecture mem_arc of memory is
	type typemem is array (0 to 65535) of std_logic_vector(15 downto 0);
	signal mem_data:typemem:= (others=>"0000000000000000");
begin
	process(clk)
	begin
		if(falling_edge(clk)) then
			if(mem_write='1') then
				mem_data(to_integer(unsigned(mem_a1)))<=mem_d1;
			end if;
			mem_d2<=mem_data(to_integer(unsigned(mem_a1)));
		end if;
	end process;
end architecture;