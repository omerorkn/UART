-- Author / Engineer 	: omerorkn
-- Date 		: 14.06.2022

-- Top Module of UART Transceiver
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

entity top_module is

	generic (
					CLK_FREQ 	: integer 	:= 50_000_000;  	-- System Clock (Hz)
					BAUD_RATE 	: integer 	:= 9600;		-- Baud Rate (bps)
					DATA_WIDTH	: integer range 5 to 9 := 8		-- Parametric Data Width Value
	);
	port (
					-- Input Ports
					clk 				: in std_logic;
					rst_n 				: in std_logic;
					tx_start_top 			: in std_logic;
					tx_data_in_top 			: in std_logic_vector(7 downto 0) ;
					rx_data_in_top			: in std_logic;
					
					-- Output Ports
					tx_busy_top 			: out std_logic;
					tx_finish_top 			: out std_logic;
					tx_data_out_top 		: out std_logic;
					rx_data_out_top 		: out std_logic_vector(7 downto 0);
					rx_finish_top			: out std_logic
	);
end top_module;

architecture rtl of top_module is

	component uart_tx is
	
	generic (
					CLK_FREQ 	: integer 	:= 50_000_000;  	-- System Clock (Hz)
					BAUD_RATE 	: integer 	:= 9600;		-- Baud Rate (bps)
					DATA_WIDTH	: integer range 5 to 9 := 8		-- Parametric Data Width Value
	);
	port (
					-- Input Ports
					clk 			: in std_logic;
					rst_n 			: in std_logic;
					tx_start 		: in std_logic;
					tx_data_in 		: in std_logic_vector(7 downto 0) ;
					
					-- Output Ports
					tx_busy 		: out std_logic;
					tx_finish 		: out std_logic;
					tx_data_out 		: out std_logic
	);
	end component;
	
	component uart_rx is
	
	generic (
					CLK_FREQ 	: integer 	:= 50_000_000;  	-- System Clock (Hz)
					BAUD_RATE 	: integer 	:= 9600;		-- Baud Rate (bps)
					DATA_WIDTH	: integer range 5 to 9 := 8		-- Parametric Data Width Value
	);
	port (
					-- Input Ports
					clk 		: in std_logic;
					rst_n 		: in std_logic;
					rx_data_in	: in std_logic;
					
					-- Output Ports
					rx_data_out 	: out std_logic_vector(7 downto 0);
					rx_finish	: out std_logic
	) ;
end component;

begin

	uart_tx_inst : uart_tx
	generic map (
							CLK_FREQ 	=> CLK_FREQ,
							BAUD_RATE 	=> BAUD_RATE,
							DATA_WIDTH	=> DATA_WIDTH
	)
	port map(
							clk 		=> clk,
							rst_n 		=> rst_n,
							tx_start 	=> tx_start_top,
							tx_data_in 	=> tx_data_in_top,
							tx_busy 	=> tx_busy_top,
							tx_finish 	=> tx_finish_top,
							tx_data_out 	=> tx_data_out_top
	);

	uart_rx_inst : uart_rx
	generic map (
		CLK_FREQ 	=> CLK_FREQ,
		BAUD_RATE 	=> BAUD_RATE,
		DATA_WIDTH	=> DATA_WIDTH
		)
		port map(
			clk 		=> clk,
			rst_n 		=> rst_n,
			rx_data_in 	=> rx_data_in_top,
			rx_data_out 	=> rx_data_out_top,
			rx_finish 	=> rx_finish_top
		);
			
end rtl;
