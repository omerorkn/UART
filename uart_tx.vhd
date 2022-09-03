-- Author / Engineer 	: omerorkn
-- Date 		: 13.06.2022

-- TX Sub-module of UART Transceiver
------------------------------------------------------------------------------------------------------------------------------------------------
-- 1 start bit
-- No parity bit
-- 1 stop bit
-- 8 data bits 				(PARAMETRIC)
-- System Clock 	 : 50 MHz	(PARAMETRIC)
-- Baud Rate		 : 9600 bps 	(PARAMETRIC)
------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_tx is
	
	generic (
					CLK_FREQ 	: integer 	:= 50_000_000;  	-- System Clock (Hz)
					BAUD_RATE 	: integer 	:= 9600;		-- Baud Rate
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
end uart_tx;

architecture rtl of uart_tx is

	constant CLK_PER_BIT : integer := CLK_FREQ / BAUD_RATE;
	
	type tx_states_t is (IDLE, START, DATA, STOP);
	signal current_state : tx_states_t := IDLE;
	
	-- 'i' suffix = 'internal' signal for output buffering
	signal tx_finish_i 		: std_logic := '0';
	signal tx_busy_i 		: std_logic  := '0';
	signal tx_data_out_i 		: std_logic := '1';
	signal bit_counter 		: integer range 0 to DATA_WIDTH - 1 := 0;
	signal clk_counter 		: integer range 0 to CLK_PER_BIT - 1 := 0;
	
begin
	
	tx_p : process (clk)
	begin
		
		if (rst_n = '0') then
			
			tx_finish_i 		<= '0';
			tx_busy_i 		<= '0';
			tx_data_out_i 		<= '1';
			bit_counter 		<=  0 ;
			clk_counter		<=  0 ;
			
		elsif (rising_edge(clk)) then
		
			case current_state is
				
				when IDLE =>							-- FSM reset
					
					tx_finish_i 	<= '0';
					tx_busy_i 	<= '0';
					tx_data_out_i 	<= '1';
					bit_counter 	<= 0;
				    	clk_counter	<= 0;
					
					if (tx_start = '1') then
						current_state <= START;
					else
						current_state <= IDLE;
					end if;
					
				when START =>							-- Start bit sending
					
					tx_data_out_i 	<= '0';
					tx_busy_i 	<= '1';
					
					if (clk_counter = CLK_PER_BIT - 1) then
						current_state 	<= DATA;
						clk_counter 	<= 0;
					else
						clk_counter 	<= clk_counter + 1;
						current_state 	<= START;
					end if;
				
				when DATA =>								-- Data transmitting bit-by-bit
				
					tx_data_out_i <= tx_data_in (bit_counter);
					
					if (clk_counter = CLK_PER_BIT - 1) then
						if (bit_counter = DATA_WIDTH - 1) then
							clk_counter 	<= 0;
							bit_counter 	<= 0;
							current_state 	<= STOP;
						else
							clk_counter 	<= 0;
							bit_counter 	<= bit_counter + 1;
							current_state 	<= DATA;
						end if;
					else
						clk_counter 	<= clk_counter + 1;
						current_state 	<= DATA;
					end if;
				
				when STOP =>								-- Data transmitting finished
					
					tx_data_out_i 	<= '1';
					tx_finish_i 	<= '1';
					
					if (clk_counter = CLK_PER_BIT - 1) then
						current_state <= IDLE;
					else
					    clk_counter 	<= clk_counter + 1;
						current_state 	<= STOP;
					end if;
				
				when others =>
					
					current_state <= IDLE;
			end case;
		end if;
	end process tx_p;
	
	-- Output buffering
	tx_data_out 	<= tx_data_out_i;
	tx_busy 	<= tx_busy_i;
	tx_finish 	<= tx_finish_i;

end rtl;
