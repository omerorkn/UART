# UART
UART Transceiver for FPGA
  - Engineer : omerorkn

My Working Environments (OS and IDE) : 
  
  - Windows 10        - Microsemi Libero SoC (Contains simulation, synthesis and implementation on FPGA)
  - Ubuntu 20.04 LTS  - Xilinx Vivado 2020.2 (Contains simulation and synthesis)

Module Features :

  - 1 start bit
  - No parity bit
  - 1 stop bit
  - 8 data bits 					    (PARAMETRIC)
  - System Clock 	: 100 MHz	  (PARAMETRIC)
  - Baud Rate		  : 25 Mbps 	(PARAMETRIC)
  - Compatibility with different UART modules (TESTED)

This module tested on these projects :
  
  - Byte packet generating and sending to PC
  - Byte packet receiving from PC
  - Sending data with CRC to PC
  - Receiving data with CRC from PC
    
By the way when i implemented my designs to FPGA, i used fast baud rates and my designs with my UART module worked without a problem.

Best Regards.
