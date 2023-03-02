------------------------------------------------------------------------------------------------------------------------------------------
-- File Name: uart_top_tb.vhd
-- Title & Purpose: Testbench for UART Communication
-- Author: omerorkn
-- Date of Creation: 25.06.2022
-- Version: 01
-- Description: 
-- Test of UART module
-- 1 start bit
-- Data width is 8-bits
-- No parity bit & 1 stop bit
-- Module works at 100 MHz system clock & 25 Mbps baud rate  
--
-- File history:
-- 00   	: 25.06.2022 : File created.
-------------------------------------------------------------------------------------------------------------------
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
		tx_start 		: in std_logic;
		tx_data_in 		: in std_logic_vector(7 downto 0) ;
		rx_data_in		: in std_logic;
					
		-- Output Ports
		tx_busy 		: out std_logic;
		tx_data_out 		: out std_logic;
		rx_busy			: out std_logic;
		rx_error		: out std_logic;
		rx_data_out 		: out std_logic_vector(7 downto 0)
	);
	end component;

	constant CLK_FREQ 	: integer 	:= 50_000_000;
	constant CLK_PERIOD 	: time 		:= 1000 ms / CLK_FREQ;

	signal clk 			: std_logic := '0';
	signal rst_n 			: std_logic := '1';
	signal tx_start_tb 		: std_logic := '0';
	signal tx_data_in_tb 		: std_logic_vector(7 downto 0) := ("11001010");
	signal rx_data_in_tb		: std_logic := '0';					-- unused signal
	signal tx_busy_tb 		: std_logic := '0';
	signal tx_data_out_tb 		: std_logic := '1';
	signal rx_busy_tb		: std_logic := '0';
	signal rx_error_tb		: std_logic := '0';
	signal rx_data_out_tb 		: std_logic_vector(7 downto 0) := (others => '0');
	
begin

	uut : top_module
	port map (
		clk 			=> clk,
	        rst_n 			=> rst_n,
	        tx_start 		=> tx_start_tb,
	        tx_data_in 		=> tx_data_in_tb,
	        rx_data_in		=> tx_data_out_tb,
		tx_busy 		=> tx_busy_tb,
		tx_data_out	 	=> tx_data_out_tb,
		rx_busy			=> rx_busy_tb,
		rx_error		=> rx_error_tb,
		rx_data_out	 	=> rx_data_out_tb
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
