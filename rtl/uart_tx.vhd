------------------------------------------------------------------------------------------------------------------------------------------
-- File Name: uart_tx.vhd
-- Title & Purpose: Transmitter Sub-Module for UART Communication
-- Author: omerorkn
-- Date of Creation: 20.06.2022
-- Version: 01
-- Description: 
-- This sub-module is transmitter of UART module
-- 1 start bit
-- Data width is 8-bits
-- No parity bit & 1 stop bit
-- Module works at 100 MHz system clock & 25 Mbps baud rate  
--
-- File history:
-- 00   	: 20.06.2022 : File created.
-- 01 		: 19.09.2022 : Comments added to code.
------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_tx is
	generic (
		CLK_FREQ 	: integer := 100_000_000; 					-- system clock value
		BAUD_RATE 	: integer := 25_000_000;  					-- baud rate value for sync
		DATA_WIDTH 	: integer := 8;							-- data width value
		CLK_PER_BIT : integer := CLK_FREQ / BAUD_RATE 					-- clock per bit value for clock counter
	);				
	port (				
		-- Input Ports				
		clk 		: in std_logic;							-- clock input
		rst_n		: in std_logic;							-- active low reset
		tx_start 	: in std_logic;							-- start trigger for TX
		tx_data_in 	: in std_logic_vector(DATA_WIDTH - 1 downto 0);			-- 8-bit data input
						
		-- Output Ports				
		tx_busy		: out std_logic;						-- busy flag
		tx_data_out	: out std_logic							-- data out port
	);
end uart_tx;

architecture rtl of uart_tx is
	
	type states_tx_t is (IDLE, START, DATA, STOP);						-- all TX states
	signal current_state 	: states_tx_t := IDLE;						-- current state signal definition
	
	signal tx_data_out_i1 	: std_logic := '1';						-- internal signal of "tx_data_out" port for output buffering #1
	signal tx_data_out_i2	: std_logic := '1';						-- internal signal of "tx_data_out" port for output buffering #2
	signal tx_busy_i	: std_logic := '0';						-- internal signal of "tx_busy" port for output buffering
	signal clk_counter	: integer range 0 to CLK_PER_BIT - 1 := 0;			-- integer counter for clock cycle count
	signal bit_counter	: integer range 0 to DATA_WIDTH - 1 := 0;			-- integer counter for transmitted data bits
	
begin
	
	tx_p : process (clk)									-- TX main process block
	begin
	
		if (rst_n = '0') then
			tx_data_out_i2 	<= '1';
			tx_busy_i	<= '0'; 
		    	clk_counter	<= 0;
		    	bit_counter	<= 0;
			current_state 	<= IDLE;
			
		elsif (rising_edge(clk)) then
		
			case current_state is
			
				when IDLE =>							-- idle mode
					
					clk_counter <= 0;
					bit_counter <= 0;
					
					if (tx_start = '1') then
						tx_busy_i		<= '1';
						current_state <= START;
					else
						current_state <= IDLE;	
					end if;
					
				when START =>							-- start bit sending
					
					tx_data_out_i2 	<= '0';
					
					if (clk_counter = CLK_PER_BIT - 1) then
						clk_counter 	<= 0;
						current_state 	<= DATA;
					else
						clk_counter 	<= clk_counter + 1;
						current_state 	<= START;
					end if;

				when DATA =>							-- transmitting all bits
				
					tx_data_out_i2 <= tx_data_in(bit_counter);
					
					if (clk_counter = CLK_PER_BIT - 1) then
						if (bit_counter = DATA_WIDTH - 1) then
							clk_counter 	<= 0;
							bit_counter 	<= 0;
							current_state 	<= STOP;
						else
							bit_counter 	<= bit_counter + 1;
							clk_counter 	<= 0;
							current_state 	<= DATA;
						end if;
					else
						clk_counter 	<= clk_counter + 1;
						current_state 	<= DATA;
					end if;
				
				when STOP =>							-- stop bit sending
					
					tx_data_out_i2 	<= '1';
					
					if (clk_counter = CLK_PER_BIT - 1) then
						clk_counter 	<= 0;
						tx_busy_i 		<= '0';
						current_state 	<= IDLE;
					else
						clk_counter 	<= clk_counter + 1;
						current_state 	<= STOP;
					end if;
				
				when others =>							-- unknown state condition
					
					current_state <= IDLE;
			end case;
		end if;
	end process;
	
	tx_data_out_i1 	<= tx_data_out_i2;							-- output buffering
	tx_data_out	<= tx_data_out_i1;							-- output buffering
	tx_busy 	<= tx_busy_i;								-- output buffering
	
end rtl;
