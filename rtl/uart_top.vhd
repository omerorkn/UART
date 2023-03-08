------------------------------------------------------------------------------------------------------------------------------------------
-- File Name: uart_top.vhd
-- Title & Purpose: Top Module for UART Communication
-- Author: omerorkn
-- Date of Creation: 22.06.2022
-- Version: 01
-- Description: 
-- Top Module of UART module
-- 1 start bit
-- Data width is 8-bits
-- No parity bit & 1 stop bit
-- Module works at 100 MHz system clock & 25 Mbps baud rate  
--
-- File history:
-- 00   	: 22.06.2022 : File created.
-- 01		: 15.09.2022 : Comments added to code.
------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_top is
generic (
	CLK_FREQ 	: integer := 100_000_000;														-- system clock value
	BAUD_RATE 	: integer := 25_000_000;                                                        -- baud rate value for sync
	DATA_WIDTH 	: integer := 8;                                                                 -- data width value
	CLK_PER_BIT : integer := CLK_FREQ / BAUD_RATE                                               -- clock per bit value for clock counter
);
port (
	-- Input Ports
	clk 		: in std_logic;																	-- clock input
	rst_n 		: in std_logic;																	-- active low reset
	tx_start 	: in std_logic;																	-- start trigger for TX
	tx_data_in 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);									-- 8-bit data input
	rx_data_in 	: in std_logic;																	-- data input for receiving data from TX
	
	-- Output Ports
	tx_busy 	: out std_logic;																-- busy flag
	tx_data_out : out std_logic;																-- data out port
	rx_busy		: out std_logic;																-- busy flag
	rx_error	: out std_logic;																-- error flag
	rx_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)									-- Data out port
);
end entity;

architecture rtl of uart_top is
	
	component uart_tx is
	generic (
		CLK_FREQ 	: integer := 100_000_000; 													-- system clock value
		BAUD_RATE 	: integer := 25_000_000;  													-- baud rate value for sync
		DATA_WIDTH 	: integer := 8;																-- data width value
		CLK_PER_BIT : integer := CLK_FREQ / BAUD_RATE 											-- clock per bit value for clock counter
	);										
	port (										
		-- Input Ports										
		clk 		: in std_logic;																-- clock input
		rst_n		: in std_logic;																-- active low reset
		tx_start 	: in std_logic;																-- start trigger for TX
		tx_data_in 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);								-- 8-bit data input
												
		-- Output Ports										
		tx_busy		: out std_logic;															-- busy flag
		tx_data_out	: out std_logic																-- data out port
	);
	end component;
	
	component uart_rx is
		generic (
		CLK_FREQ 	: integer := 100_000_000; 													-- system clock value
		BAUD_RATE 	: integer := 25_000_000;  													-- baud rate value for sync
		DATA_WIDTH 	: integer := 8;																-- data width value
		CLK_PER_BIT : integer := CLK_FREQ / BAUD_RATE 											-- clock per bit value for clock counter
	);				
	port (				
		-- Input Ports				
		clk 		: in std_logic;																-- clock input
		rst_n 		: in std_logic;                                             				-- active low reset
		rx_data_in 	: in std_logic;                                             				-- data input for receiving data from TX
																								
		-- Output Ports                                                         				
		rx_data_out : out std_logic_vector (DATA_WIDTH - 1 downto 0);          					-- data out port
		rx_busy		: out std_logic;                                            				-- busy flag
		rx_error	: out std_logic																-- error flag
	);
	end component;

	begin
		
		uart_tx_inst : uart_tx																	-- instantiation of TX sub-module
		generic map (	
			CLK_FREQ 	=> CLK_FREQ,	
			BAUD_RATE 	=> BAUD_RATE,
			DATA_WIDTH 	=> DATA_WIDTH,
			CLK_PER_BIT => CLK_PER_BIT
		)
		port map (
			clk 		=> clk,
			rst_n 		=> rst_n,
			tx_start	=> tx_start,
			tx_data_in 	=> tx_data_in,
			tx_busy 	=> tx_busy,
			tx_data_out => tx_data_out
		);

		uart_rx_inst : uart_rx																	-- instantiation of RX sub-module
		generic map (
			CLK_FREQ 	=> CLK_FREQ,	
			BAUD_RATE 	=> BAUD_RATE,
			DATA_WIDTH 	=> DATA_WIDTH,
			CLK_PER_BIT => CLK_PER_BIT
		)
		port map (
			clk 		=> clk,
			rst_n 		=> rst_n,
			rx_data_in 	=> rx_data_in,
			rx_data_out => rx_data_out,
			rx_busy 	=> rx_busy,
			rx_error 	=> rx_error
		);
		
end rtl;
