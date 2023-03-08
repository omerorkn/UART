------------------------------------------------------------------------------------------------------------------------------------------
-- File Name: uart_rx.vhd
-- Title & Purpose: Receiver Sub-Module for UART Communication
-- Author: omerorkn
-- Date of Creation: 21.06.2022
-- Version: 01
-- Description: 
-- This sub-module is receiver of UART module
-- 1 start bit
-- Data width is 8-bits 
-- No parity bit & 1 stop bit
-- Module works at 100 MHz system clock & 25 Mbps baud rate  
--
-- File history:
-- 00   	: 21.06.2022 : File created.
-- 01 		: 19.09.2022 : Comments added to code.
------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_rx is 
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
		rx_busy		: out std_logic;                                           					-- busy flag
		rx_error 	: out std_logic                                             				-- error flag
	);
end uart_rx;

architecture rtl of uart_rx is
	
	type states_rx_t is (IDLE, START, DATA, STOP);												-- all RX states
	signal current_state : states_rx_t := IDLE;													-- current state signal definition
	
	signal rx_data_in_d1	: std_logic := '1';													-- delaying for input signal #1
	signal rx_data_in_d2	: std_logic := '1';													-- delaying for input signal #2
	signal rx_data_out_i 	: std_logic_vector (DATA_WIDTH - 1 downto 0) := (others => '0');	-- internal signal of "rx_data_out" port for output buffering
	signal rx_busy_i		: std_logic := '0';													-- internal signal of "rx_busy" port for output buffering
	signal rx_error_i 		: std_logic := '0';													-- internal signal of "rx_error" port for output buffering
	signal clk_counter 		: integer range 0 to CLK_PER_BIT - 1 := 0;							-- integer counter for clock cycle count
	signal bit_counter 		: integer range 0 to DATA_WIDTH - 1 := 0;                        	-- integer counter for received data bits
	
begin

	rx_p : process (clk, rst_n)																	-- RX main process block
	begin
	
		rx_data_in_d1 <= rx_data_in;
		rx_data_in_d2 <= rx_data_in_d1;
		
		if (rst_n = '0') then																	-- reset activated
			rx_data_out_i 	<= (others => '0');
			rx_error_i 		<= '0';
			rx_busy_i		<= '0';
			clk_counter 	<= 0;
			bit_counter 	<= 0;
			current_state 	<= IDLE;
			
		elsif (rising_edge(clk)) then
			case current_state is
			
				when IDLE =>																	-- idle state for FSM reset
					
					rx_error_i 		<= '0';
					rx_busy_i		<= '0';
					clk_counter 	<= 0;
					bit_counter 	<= 0;
					
					if (rx_data_in_d2 = '0') then
						current_state <= START;
					else
						current_state <= IDLE;
					end if;		
					
				when START =>																	-- start bit detection
					
					rx_error_i <= '0';
					
					if (clk_counter = CLK_PER_BIT / 2 - 1) then
						if (rx_data_in_d2 = '0') then
							clk_counter 	<= 0;
							current_state 	<= DATA;
						else	
							current_state 	<= IDLE;
						end if;
					else
						clk_counter <= clk_counter + 1;
						current_state <= START;
					end if;
				
				when DATA =>																	-- receiving all bits
					
					rx_busy_i <= '1';
					
					if (clk_counter = CLK_PER_BIT - 1) then
						rx_data_out_i(bit_counter) <= rx_data_in_d2;
						if (bit_counter = DATA_WIDTH - 1) then
							clk_counter 	<= 0;
							current_state 	<= STOP;
						else
							clk_counter 	<= 0;
							bit_counter 	<= bit_counter + 1;
							current_state 	<= DATA;
						end if;
					else
						clk_counter 		<= clk_counter + 1;
						current_state 		<= DATA;
					end if;
						
				when STOP =>																	-- stop bit detection
				
                    rx_data_out <= rx_data_out_i;
					bit_counter <= 0;
					
					if (clk_counter = CLK_PER_BIT - 1) then
						if (rx_data_in_d2 = '1') then
							rx_error_i 		<= not rx_data_in_d2;
							rx_busy_i		<= '0';
							clk_counter 	<= 0;
							current_state 	<= IDLE;
						else
							clk_counter 	<= clk_counter + 1;
							current_state 	<= STOP;
						end if;
					else
						clk_counter 		<= clk_counter + 1;
						current_state 		<= STOP;	
					end if;

				when others =>																	-- unknown state condition
				
					current_state <= IDLE;
			end case;		
		end if;
	end process;
	
	rx_busy 	<= rx_busy_i;																	-- output buffering
	rx_error 	<= rx_error_i;																	-- output buffering
	
end rtl;
