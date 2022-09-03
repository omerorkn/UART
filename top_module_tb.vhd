-- Author / Engineer 	: omerorkn
-- Date 		: 17.06.2022

-- Testbench of UART Transceiver
------------------------------------------------------------------------------------------------------------------------------------------------
-- 1 start bit
-- No parity bit
-- 1 stop bit
-- 8 data bits 				(PARAMETRIC)
-- System Clock 	: 50 MHz	(PARAMETRIC)
-- Baud Rate		: 9600 bps 	(PARAMETRIC)

-- Compatibility with different UART modules (TESTED)
------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity top_module_tb is
end top_module_tb;

architecture testbench of top_module_tb is

	component top_module is
	port (
					-- Input Ports
					clk 			: in std_logic;
					rst_n 			: in std_logic;
					tx_start_top 		: in std_logic;
					tx_data_in_top 		: in std_logic_vector(7 downto 0) ;
					rx_data_in_top		: in std_logic;
					
					-- Output Ports
					tx_busy_top 		: out std_logic;
					tx_finish_top 		: out std_logic;
					tx_data_out_top 	: out std_logic;
					rx_data_out_top 	: out std_logic_vector(7 downto 0);
					rx_finish_top		: out std_logic
	);
	end component;

	constant CLK_FREQ 	: integer 	:= 50_000_000;
	constant CLK_PERIOD 	: time 		:= 1000 ms / CLK_FREQ;

	signal clk 			: std_logic := '0';
	signal rst_n 			: std_logic := '1';
	signal tx_start_tb 		: std_logic := '0';
	signal tx_data_in_tb 		: std_logic_vector(7 downto 0) := ("11001010");
	signal rx_data_in_tb		: std_logic;
	signal tx_busy_tb 		: std_logic := '0';	
	signal tx_finish_tb 		: std_logic := '0';
	signal tx_data_out_tb 		: std_logic := '1';
	signal rx_data_out_tb 		: std_logic_vector(7 downto 0) := (others => '0');	
	signal rx_finish_tb		: std_logic := '0';
	
begin

	uut : top_module
	port map (
			clk 			=> clk,
	                rst_n 			=> rst_n,
	                tx_start_top 		=> tx_start_tb,
	                tx_data_in_top 		=> tx_data_in_tb,
	                rx_data_in_top		=> tx_data_out_tb,
			tx_busy_top 		=> tx_busy_tb,
			tx_finish_top 		=> tx_finish_tb,
			tx_data_out_top 	=> tx_data_out_tb,
			rx_data_out_top 	=> rx_data_out_tb,
			rx_finish_top		=> rx_finish_tb
	);
	
	clk_p : process
	begin
	   clk <= '0';
	   wait for clk_period / 2;
	   clk <= '1';
	   wait for clk_period / 2;
    end process;
	
	test_p : process
	begin
		rst_n <= '0';
		wait for 40 ns;
		rst_n <= '1';
		wait for 40 ns;
		tx_start_tb <= '1';
		wait for 40 ns;
		tx_start_tb <= '0';
		wait;
	end process;
	
end testbench;
