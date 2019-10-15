-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "10/09/2019 16:31:34"
                                                            
-- Vhdl Test Bench template for design  :  IMAGE_SENSOR_SIM
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY IMAGE_SENSOR_SIM_vhd_tst IS
END IMAGE_SENSOR_SIM_vhd_tst;
ARCHITECTURE IMAGE_SENSOR_SIM_arch OF IMAGE_SENSOR_SIM_vhd_tst IS
-- constants  
constant clock_period : time := 10 ps;                                               
-- signals                                                   
SIGNAL active_lin : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL active_pix : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL CLK : STD_LOGIC;
SIGNAL CLK_fast : STD_LOGIC;
SIGNAL DATA_IMX_OUT : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL DATA_IMX_OUT_B : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA_IMX_OUT_G : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DATA_IMX_OUT_R : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL IMX_DDR_CLK : STD_LOGIC;
SIGNAL IMX_DDR_CLK_N : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_CLK_P : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO : STD_LOGIC;
SIGNAL IMX_DDR_VIDEO_CH_0_N : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO_CH_0_P : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO_CH_1_N : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO_CH_1_P : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO_CH_2_N : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO_CH_2_P : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO_CH_3_N : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL IMX_DDR_VIDEO_CH_3_P : STD_LOGIC_VECTOR(0 DOWNTO 0);
SIGNAL MAIN_ENABLE : STD_LOGIC;
SIGNAL MAIN_reset : STD_LOGIC;
SIGNAL mode_IMAGE_SENSOR : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL n_pix_IS : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL n_strok : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL START_PIX : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL START_STR : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL SYNC_H : STD_LOGIC;
SIGNAL SYNC_V : STD_LOGIC;
SIGNAL XHS_Imx_Sim : STD_LOGIC;
SIGNAL XVS_Imx_Sim : STD_LOGIC;
COMPONENT IMAGE_SENSOR_SIM
	PORT (
	active_lin : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	active_pix : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	CLK : IN STD_LOGIC;
	CLK_fast : IN STD_LOGIC;
	DATA_IMX_OUT : BUFFER STD_LOGIC_VECTOR(9 DOWNTO 0);
	DATA_IMX_OUT_B : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	DATA_IMX_OUT_G : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	DATA_IMX_OUT_R : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
	IMX_DDR_CLK : BUFFER STD_LOGIC;
	IMX_DDR_CLK_N : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_CLK_P : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO : BUFFER STD_LOGIC;
	IMX_DDR_VIDEO_CH_0_N : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO_CH_0_P : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO_CH_1_N : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO_CH_1_P : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO_CH_2_N : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO_CH_2_P : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO_CH_3_N : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	IMX_DDR_VIDEO_CH_3_P : BUFFER STD_LOGIC_VECTOR(0 DOWNTO 0);
	MAIN_ENABLE : IN STD_LOGIC;
	MAIN_reset : IN STD_LOGIC;
	mode_IMAGE_SENSOR : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	n_pix_IS : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	n_strok : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	START_PIX : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	START_STR : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	SYNC_H : BUFFER STD_LOGIC;
	SYNC_V : BUFFER STD_LOGIC;
	XHS_Imx_Sim : BUFFER STD_LOGIC;
	XVS_Imx_Sim : BUFFER STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : IMAGE_SENSOR_SIM
	PORT MAP (
-- list connections between master ports and signals
	active_lin => active_lin,
	active_pix => active_pix,
	CLK => CLK,
	CLK_fast => CLK_fast,
	DATA_IMX_OUT => DATA_IMX_OUT,
	DATA_IMX_OUT_B => DATA_IMX_OUT_B,
	DATA_IMX_OUT_G => DATA_IMX_OUT_G,
	DATA_IMX_OUT_R => DATA_IMX_OUT_R,
	IMX_DDR_CLK => IMX_DDR_CLK,
	IMX_DDR_CLK_N => IMX_DDR_CLK_N,
	IMX_DDR_CLK_P => IMX_DDR_CLK_P,
	IMX_DDR_VIDEO => IMX_DDR_VIDEO,
	IMX_DDR_VIDEO_CH_0_N => IMX_DDR_VIDEO_CH_0_N,
	IMX_DDR_VIDEO_CH_0_P => IMX_DDR_VIDEO_CH_0_P,
	IMX_DDR_VIDEO_CH_1_N => IMX_DDR_VIDEO_CH_1_N,
	IMX_DDR_VIDEO_CH_1_P => IMX_DDR_VIDEO_CH_1_P,
	IMX_DDR_VIDEO_CH_2_N => IMX_DDR_VIDEO_CH_2_N,
	IMX_DDR_VIDEO_CH_2_P => IMX_DDR_VIDEO_CH_2_P,
	IMX_DDR_VIDEO_CH_3_N => IMX_DDR_VIDEO_CH_3_N,
	IMX_DDR_VIDEO_CH_3_P => IMX_DDR_VIDEO_CH_3_P,
	MAIN_ENABLE => MAIN_ENABLE,
	MAIN_reset => MAIN_reset,
	mode_IMAGE_SENSOR => mode_IMAGE_SENSOR,
	n_pix_IS => n_pix_IS,
	n_strok => n_strok,
	START_PIX => START_PIX,
	START_STR => START_STR,
	SYNC_H => SYNC_H,
	SYNC_V => SYNC_V,
	XHS_Imx_Sim => XHS_Imx_Sim,
	XVS_Imx_Sim => XVS_Imx_Sim
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;  
clock_process :process
  begin
  CLK <= '0';
  wait for clock_period/2;
  CLK <= '1';
  wait for clock_period/2;
end process;
   
clock_process2 :process
begin
  CLK_fast <= '0';
  wait for clock_period/4;
  CLK_fast <= '1';
  wait for clock_period/4;
end process;

MAIN_ENABLE <= '1';
MAIN_reset	<= '0';
mode_IMAGE_SENSOR <= x"00";
n_strok		<= "011110000000";
n_pix_IS	<= "010000111000";
START_STR	<= "000001011010";
START_PIX	<= "000001001110";
active_lin	<= "001010100010";
active_pix	<= "001110000100";                                         
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
WAIT;                                                        
END PROCESS always;                                          
END IMAGE_SENSOR_SIM_arch;
