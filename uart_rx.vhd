-- Author / Engineer 	: omerorkn
-- Date 		: 14.06.2022

-- RX Sub-module of UART Transceiver
------------------------------------------------------------------------------------------------------------------------------------------------
-- 1 start bit
-- No parity bit
-- 1 stop bit
-- 8 data bits 				(PARAMETRIC)
-- System Clock 	: 50 MHz	(PARAMETRIC)
-- Baud Rate		: 9600 bps 	(PARAMETRIC)

-- Sampling on half of bit 	 (OPTIMAL)
------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity uart_rx is
	
	generic (
					CLK_FREQ 	: integer 	:= 50_000_000;  		-- System Clock (Hz)
					BAUD_RATE 	: integer 	:= 9600;			-- Baud Rate (bps)
					DATA_WIDTH	: integer range 5 to 9 := 8			-- Parametric Data Width Value
	);
	port (
					-- Inpıut Ports
					clk 		: in std_logic;
					rst_n 		: in std_logic;
					rx_data_in	: in std_logic;
					
					-- Output Ports
					rx_data_out 	: out std_logic_vector(7 downto 0);
					rx_finish	: out std_logic
	) ;
end uart_rx;

architecture rtl of uart_rx is

	constant CLK_PER_BIT : integer := CLK_FREQ / BAUD_RATE;
	
	type rx_states_t is (IDLE, START, DATA, STOP);
	signal current_state : rx_states_t := IDLE;
	
	-- 'i' suffix = 'internal' signal for output buffering
	signal rx_finish_i 	: std_logic := '0';
	signal rx_data_out_i 	: std_logic_vector(7 downto 0) := (others => '0');
	signal bit_counter 	: integer range 0 to DATA_WIDTH - 1 := 0;
	signal clk_counter 	: integer range 0 to CLK_PER_BIT - 1 := 0;

begin

	rx_p : process (clk)
	begin
	   if (rst_n = '0') then
	   
	   rx_finish_i 		<= '0';
           rx_data_out_i   	<= (others => '0');
           bit_counter 	   	<= 0;
           clk_counter 	   	<= 0;
	   
	   elsif (rising_edge(clk)) then
	       case current_state is
			
			when IDLE =>									-- FSM reset
				
				rx_finish_i 	<= '0';
				rx_data_out_i 	<= (others => '0');
				bit_counter 	<= 0;
				clk_counter 	<= 0;
				if (rx_data_in = '0') then
					current_state <= START;
				else
					current_state <= IDLE;
				end if;
				
			when START =>									-- Start bit detection
				
				rx_finish_i <= '0';
				if (clk_counter = (CLK_PER_BIT / 2 - 1)) then
					if (rx_data_in = '0') then
						clk_counter 	<= 0;
						current_state 	<= DATA;
					else
						current_state <= IDLE;
					end if;
				else
					clk_counter 	<= clk_counter + 1;
					current_state 	<= START;
				end if;
				
			when DATA =>									-- Data receiving bit-by-bit
				
				if (clk_counter = CLK_PER_BIT - 1) then
					rx_data_out_i(bit_counter) <= rx_data_in;
					if (bit_counter = DATA_WIDTH - 1) then
						bit_counter 	<= 0;
						current_state   <= STOP;
					else
						clk_counter 	<= 0;
						bit_counter	 	<= bit_counter + 1;
						current_state 	<= DATA;
					end if;
				else
					clk_counter 	<= clk_counter + 1;
					current_state 	<= DATA;
				end if;
				
			when STOP =>									-- Data received
				
				rx_finish_i <= '1';
				if (clk_counter = CLK_PER_BIT - 1) then
					clk_counter 	<= 0;
					current_state 	<= IDLE;
				else
					clk_counter 	<= clk_counter + 1;
					current_state 	<= STOP;
				end if;
				
			when others =>
				
				current_state <= IDLE;
	       end case;
        end if;
   end process rx_p;
	
	-- Output buffering
	rx_finish 	<= rx_finish_i;
	rx_data_out 	<= rx_data_out_i;
	
end rtl;
