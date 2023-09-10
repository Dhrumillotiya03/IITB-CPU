library work;
use work.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;

entity Testbench is 
end entity;

architecture IITBRisc_test_arc of Testbench is
	component IITBRisc is
	port(wr_addr,instd_towr:in std_logic_vector(15 downto 0);
		clk,rst,mem_write_2:in std_logic;
		state: out std_logic_vector(4 downto 0));
	end component;
	
	signal wr_addr, instd_towr : std_logic_vector(15 downto 0);
	signal clk : std_logic := '1';
	signal rst, mem_write_2 : std_logic;
	signal state: std_logic_vector(4 downto 0);
	
begin
	dut_instance: IITBRisc
		port map (wr_addr => wr_addr, instd_towr => instd_towr, clk => clk, rst => rst, mem_write_2 => mem_write_2,state => state);
	
	
	process 
		
        file in_file: text open read_mode is "../../example_code/input_file.txt";
        variable input_vector_var: std_logic_vector  (15 downto 0);
        variable INPUT_LINE: Line;
        variable count : integer range 0 to 64;
		
		begin
		
			count := 0;
			wr_addr<= "0000000000000000";
			rst <= '1';
				
			-- load instructions in memory
			while not endfile(in_file) loop
				readline (in_file, INPUT_LINE);
				read (INPUT_LINE, input_vector_var);
				clk <= '1';
				instd_towr<= input_vector_var;
				mem_write_2<= '1';
				wait for 100 ns;
				clk <= '0';
				wait for 100 ns;
				wr_addr<= std_logic_vector ( unsigned(wr_addr) + 1);
				count := count + 1;
	
			end loop;
			
			rst <= '1';
			mem_write_2<= '0';
			clk <= '0';
			wait for 100 ns;
			clk <= '1';
			wait for 100 ns;
	
			rst <= '0';
			for i in 1 to 1000 loop
				clk <= '0';
				wait for 100 ns;
				clk <= '1';
				wait for 100 ns;
			end loop;
						
	wait;
	end process;
end architecture;