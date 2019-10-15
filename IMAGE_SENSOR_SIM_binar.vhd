library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

entity IMAGE_SENSOR_SIM is
generic (

		bit_data_imx	: integer := 10;			--старт активных строк
		bit_strok		: integer := 12;			--бит на счетчик строк 
		bit_pix			: integer := 12;			--бит на счетчик пикселей 
		bit_frame		: integer := 8;				--бит на счетчик кадров
		Address_cell_width			: integer := 24;		--разрядность одной ячейки памяти
		Address_width				: integer := 20;			--разрядность числа ячеек памяти 
		Separating_width			: integer := 8			--разрядность выходной шины одного цвета
			);
------------------------------------модуль управления ФП-----------------------------------------------------
port (
------------------------------------входные сигналы-----------------------------------------------------
	CLK					: in std_logic;  								-- тактовый 
	CLK_fast			: in std_logic;  								-- тактовый 
	MAIN_reset			: in std_logic;  								-- MAIN_reset
	MAIN_ENABLE			: IN std_logic;									--MAIN_ENABLE
	mode_IMAGE_SENSOR	: in std_logic_vector (7 downto 0):=x"00";  	-- изменение режимов
	n_strok				: in std_logic_vector (bit_strok-1 downto 0);	-- изменение режимов
	n_pix_IS			: in std_logic_vector (bit_pix-1 downto 0);		-- изменение режимов
	START_STR			: in std_logic_vector (bit_strok-1 downto 0);	-- изменение режимов
	START_PIX			: in std_logic_vector (bit_pix-1 downto 0);		-- изменение режимов
	active_pix			: in std_logic_vector (bit_pix-1 downto 0);		-- изменение режимов
	active_lin			: in std_logic_vector (bit_strok-1 downto 0);	-- изменение режимов
------------------------------------выходные сигналы-----------------------------------------------------
	SYNC_V				: out std_logic; 								-- синхронизация
	SYNC_H				: out std_logic; 								-- синхронизация
	XVS_Imx_Sim			: out std_logic; 								-- синхронизация
	XHS_Imx_Sim			: out std_logic; 								-- синхронизация
	IMX_DDR_VIDEO		: out std_logic; 								-- синхронизация
	-- IMX_DDR_VIDEO_P		: out std_logic_vector (3 downto 0);			-- синхронизация
	-- IMX_DDR_VIDEO_N		: out std_logic_vector (3 downto 0);			-- синхронизация
	IMX_DDR_VIDEO_CH_0_P: out std_logic_vector (0 downto 0);			-- синхронизация
	IMX_DDR_VIDEO_CH_0_N: out std_logic_vector (0 downto 0);			-- синхронизация
	IMX_DDR_VIDEO_CH_1_P: out std_logic_vector (0 downto 0);			-- синхронизация
	IMX_DDR_VIDEO_CH_1_N: out std_logic_vector (0 downto 0);			-- синхронизация	
	IMX_DDR_VIDEO_CH_2_P: out std_logic_vector (0 downto 0);			-- синхронизация
	IMX_DDR_VIDEO_CH_2_N: out std_logic_vector (0 downto 0);			-- синхронизация	
	IMX_DDR_VIDEO_CH_3_P: out std_logic_vector (0 downto 0);			-- синхронизация
	IMX_DDR_VIDEO_CH_3_N: out std_logic_vector (0 downto 0);			-- синхронизация		
	IMX_DDR_CLK			: out std_logic; 								-- синхронизация
	IMX_DDR_CLK_P		: out std_logic_vector (0 downto 0);			-- синхронизация
	IMX_DDR_CLK_N		: out std_logic_vector (0 downto 0);			-- синхронизация
	DATA_IMX_OUT_R		: out  std_logic_vector ((Address_cell_width / 3) - 1 downto 0); 			-- выходной сигнал
	DATA_IMX_OUT_G		: out  std_logic_vector ((Address_cell_width / 3) - 1 downto 0);
	DATA_IMX_OUT_B		: out  std_logic_vector ((Address_cell_width / 3) - 1 downto 0);
	DATA_IMX_OUT		: out  std_logic_vector (bit_data_imx-1 downto 0)
		);
end IMAGE_SENSOR_SIM;

architecture beh of IMAGE_SENSOR_SIM is 
---------Модуль, работающий с памятью (запись из файла в память, чтение данных из памяти и разделение шины на R, G, и B) ----------
Component TestingStripes
generic(
	bit_pix							: integer;		--бит на счетчик пикселей
	bit_strok						: integer;		--бит на счетчик строк
	Address_cell_width				: integer;		--разрядность одной ячейки памяти
	Separating_width				: integer		--разрядность выходной шины одного из цветов
);
port(
	clock                       : IN STD_LOGIC;
	active_pix					: IN std_logic_vector(bit_pix - 1 downto 0);
	active_lin					: IN std_logic_vector(bit_strok - 1 downto 0);
	Enable                      : IN STD_logic;

	Data_R				    	: OUT std_logic_vector((Address_cell_width / 3) - 1 downto 0);
	Data_G				    	: OUT std_logic_vector((Address_cell_width / 3) - 1 downto 0);
	Data_B				    	: OUT std_logic_vector((Address_cell_width / 3) - 1 downto 0)
    );
end component;

-----------------------------------------------------------------
----------------Запись разделенных данных в выходной файл--------
-- Component Write_to_file
-- Generic(
-- 	Separating_width		: integer
-- 	);
-- port (
-- 		clk				: IN std_logic;
-- 		DATA_IMX_IN_R	: IN std_logic_vector((Separating_width - 1) downto 0);
-- 		DATA_IMX_IN_G	: IN std_logic_vector((Separating_width - 1) downto 0);
-- 		DATA_IMX_IN_B	: IN std_logic_vector((Separating_width - 1) downto 0);
-- 		Enable			: IN std_logic
-- 	);
-- end component;
-----------------------------------------------------------------
----------------------------------шахматы------------------------
component Checker 
Generic(
	bit_pix						: integer;		--бит на счетчик пикселей
	bit_strok					: integer		--бит на счетчик строк
);
Port(
	clock                       : IN STD_LOGIC;
	active_pix					: IN std_logic_vector(bit_pix - 1 downto 0);
	active_lin					: IN std_logic_vector(bit_strok - 1 downto 0);
	Enable                      : IN STD_logic
);
end component;
-----------------------------------------------------------------
----------------------------------счетчик -----------------------
component count_n_modul
generic (n		: integer);
port (
		clk,
		reset,
		en			:	in std_logic;
		modul		: 	in std_logic_vector (n-1 downto 0);
		qout		: 	out std_logic_vector (n-1 downto 0);
		cout		:	out std_logic);
end component;
	
signal ena_str_cnt				: std_logic;
signal ena_kadr_cnt				: std_logic;
signal ena_pix_IS_cnt			: std_logic;	
signal ena_pix_total_cnt		: std_logic;	
signal div_clk_in				: std_logic_vector (7 downto 0);
signal stroka_in				: std_logic;
signal kadr_in					: std_logic;
signal ena_clk_x2_in			: std_logic;
signal ena_clk_x4_in			: std_logic;
signal ena_clk_x8_in			: std_logic;
signal ena_clk_x16_in			: std_logic;
signal ena_clk_in				: std_logic;
signal qout_clk_IS				: std_logic_vector (bit_pix-1 downto 0);
signal qout_V					: std_logic_vector (bit_strok-1 downto 0);
signal max_str					: std_logic_vector (bit_strok-1 downto 0);
-------------------------------------------------------------------------------
--signal START_SIMULATION_ENABLE	: std_logic := '0';
signal from_Memory_to_Separating: std_logic_vector(Address_cell_width-1 downto 0);
signal START_ACTIVE_FRAME		: std_logic := '0';
signal DATA_IMX_OUT_R_signal	: std_logic_vector(Separating_width - 1 downto 0);
signal DATA_IMX_OUT_G_signal	: std_logic_vector(Separating_width - 1 downto 0);
signal DATA_IMX_OUT_B_signal	: std_logic_vector(Separating_width - 1 downto 0);
signal Number_of_addr_cells		: integer;
signal flag_control_writing_in_mem	: std_logic := '0';
signal read_enable_signal		: std_logic := '1';
-------------------------------------------------------------------------------
signal n_pix_IS_in				: std_logic_vector (bit_pix-1 downto 0);
signal START_PIX_in				: std_logic_vector (bit_pix-1 downto 0);
signal active_pix_in			: std_logic_vector (bit_pix-1 downto 0);

-------------------------------------------------------------------------------
signal SAV_EAV_F0_V0_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F0_V0_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F0_V1_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F0_V1_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V0_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V0_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V1_H0		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_F1_V1_H1		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_SYNC_3FF		: std_logic_vector (bit_data_imx-1 downto 0);
signal SAV_EAV_SYNC_0		: std_logic_vector (bit_data_imx-1 downto 0);
signal VALID_DATA			: std_logic;
signal data_imx_video		: std_logic_vector (bit_data_imx-1 downto 0);
signal data_imx_anc			: std_logic_vector (bit_data_imx-1 downto 0);
signal DATA_IMX_OUT_in		: std_logic_vector (bit_data_imx-1 downto 0);
signal IMX_DDR_VIDEO_in		: std_logic;
signal IMX_DDR_CLK_in		: std_logic;




-------------------------------------------------------------------------------
component parall_to_serial is
generic 
	(
		bit_data		: integer :=8			--bit na stroki
	);
     port(
 		 dir        : in STD_LOGIC;
 		 ena        : in STD_LOGIC;
         clk        : in STD_LOGIC;
         data       : in STD_LOGIC_VECTOR(bit_data-1 downto 0);
         load       : in STD_LOGIC;
         shiftout   : out STD_LOGIC
         );
end component;
signal load_ddr_video_imx	: std_logic;
signal q_load_ddr_video_imx	: std_logic_vector (7 downto 0);
-------------------------------------------------------------------------------
-- component OUTBUF_DIFF
    -- -- generic (IOSTD:string := "");
-- port( 	D    : in std_logic;
		-- PADP : out std_logic;
		-- PADN : out std_logic 
	-- );
-- end component;


-------------------------------------------------------------------------------

signal ena_CLK_fast	: std_logic;
signal ena_CLK_fast_x2_in	: std_logic;
signal ena_CLK_fast_x4_in	: std_logic;
signal ena_CLK_fast_x8_in	: std_logic;
signal ena_CLK_fast_x16_in	: std_logic;
signal div_CLK_fast_in	: std_logic_vector (7 downto 0);
signal IMX_DDR_VIDEO_in_b	: std_logic_vector (3 downto 0);

begin
 
----------------------------------сигналы разрешения для счетчиков-----------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	-- SAV_EAV_F0_V0_H0	<=	x"80" & "0000" ;		
	-- SAV_EAV_F0_V0_H1	<=	x"9D" & "0000" ;		
	-- SAV_EAV_F0_V1_H0	<=	x"AB" & "0000" ;		
	-- SAV_EAV_F0_V1_H1	<=	x"B6" & "0000" ;		

	-- SAV_EAV_SYNC_3FF	<=	x"FF" & "1111" ;		
	-- SAV_EAV_SYNC_0		<=	x"00" & "0000" ;

	SAV_EAV_F0_V0_H0	<=	x"80" & "00" ;		
	SAV_EAV_F0_V0_H1	<=	x"9D" & "00" ;		
	SAV_EAV_F0_V1_H0	<=	x"AB" & "00" ;		
	SAV_EAV_F0_V1_H1	<=	x"B6" & "00" ;		

	SAV_EAV_SYNC_3FF	<=	x"FF" & "11" ;		
	SAV_EAV_SYNC_0		<=	x"00" & "00" ;
end if;
end process;


Process(CLK)
begin
if rising_edge(CLK) then
	max_str		<=	n_strok ;
	case  mode_IMAGE_SENSOR(3 downto 0)	is
		when x"0"	=>
			n_pix_IS_in		<= n_pix_IS;	
			START_PIX_in	<= START_PIX;
			active_pix_in	<= active_pix;
			ena_clk_in		<= ena_clk_x2_in;			
		when x"1"	=> 
			n_pix_IS_in		<= std_logic_vector(to_unsigned(to_integer(unsigned (n_pix_IS))/2,bit_pix));	
			START_PIX_in	<= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX))/2,bit_pix));	
			active_pix_in	<= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix))/2,bit_pix));				
			ena_clk_in		<= ena_clk_x4_in;	
		when x"2"	=> 
			n_pix_IS_in		<= std_logic_vector(to_unsigned(to_integer(unsigned (n_pix_IS))/4,bit_pix));	
			START_PIX_in	<= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX))/4,bit_pix));	
			active_pix_in	<= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix))/4,bit_pix));				
			ena_clk_in		<=	ena_clk_x8_in;		
		when x"3"	=> 
			n_pix_IS_in		<= std_logic_vector(to_unsigned(to_integer(unsigned (n_pix_IS))/8,bit_pix));	
			START_PIX_in	<= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX))/8,bit_pix));	
			active_pix_in	<= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix))/8,bit_pix));				
			ena_clk_in		<=	ena_clk_x16_in;	
		WHEN others	=>  		
			n_pix_IS_in		<= n_pix_IS;	
			START_PIX_in	<= START_PIX;
			active_pix_in	<= active_pix;
			ena_clk_in		<= ena_clk_x2_in;	
		END case;	
	end if;
end process;

Process(CLK_fast)
begin
if rising_edge(CLK_fast) then
	case  mode_IMAGE_SENSOR(3 downto 0)	is
		when x"0"	=>			ena_CLK_fast	<= '1';
		when x"1"	=> 			ena_CLK_fast	<= ena_CLK_fast_x2_in;
		when x"2"	=> 			ena_CLK_fast	<= ena_CLK_fast_x4_in;
		when x"3"	=> 			ena_CLK_fast	<= ena_CLK_fast_x8_in;
		WHEN others	=>  		ena_CLK_fast	<= '1';
	END case;	
end if;
end process;
 
------------------------------------счетчик тактов для формирования сигналов разрешения-----------------------------------------------------
div_clk_q: count_n_modul                    
generic map (8) 
port map (
			clk			=>	CLK,			
			reset		=>	MAIN_reset ,
			en			=>	MAIN_ENABLE,		
			modul		=> 	std_logic_vector(to_unsigned(256,8)) ,
			qout		=>	div_clk_in);
			
Process(CLK)
begin
if rising_edge(CLK) then
---------------------------------------clk в 2 раза меньше---------------------------------------
	if div_clk_in( 0)='0' 			
		then 	 ena_clk_x2_in<='1';
		else 	 ena_clk_x2_in<='0';
	end if;
---------------------------------------clk в 4 раза меньше---------------------------------------
	if div_clk_in(1 downto 0)="00"		
		then 	ena_clk_x4_in<='1';
		else  	ena_clk_x4_in<='0';
	end if;
---------------------------------------clk в 8 раза меньше---------------------------------------
	if div_clk_in(2 downto 0)="000"		
		then 	ena_clk_x8_in<='1';
		else	ena_clk_x8_in<='0';
	end if;
---------------------------------------clk в 16 раза меньше---------------------------------------
	if div_clk_in(3 downto 0)="0000"		
		then	ena_clk_x16_in<='1';
		else	ena_clk_x16_in<='0';
	end if;
end if;
end process;		
----------------------------------------------------------------------------------------------------

------------------------------------сигналы разрешения для счетчиков-----------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	ena_kadr_cnt		<=	kadr_in and stroka_in  and MAIN_ENABLE;
	ena_pix_total_cnt	<=	MAIN_ENABLE and ena_clk_in;
	ena_pix_IS_cnt		<=	MAIN_ENABLE and ena_clk_in;
	ena_str_cnt			<=	stroka_in  and MAIN_ENABLE and ena_clk_in;		
end if;
end process;
----------------------------------------------------------------------------------------------------

------------------------------------счетчик пикселей по строке-----------------------------------------------------
cnt_pix_IS: count_n_modul                    
generic map (bit_pix) 
port map (
			clk			=>	CLK,			
			reset		=>	MAIN_reset ,
			en			=>	ena_pix_IS_cnt,		
			modul		=> 	n_pix_IS_in ,
			qout		=>	qout_clk_IS,
			cout		=>	stroka_in);
----------------------------------------------------------------------------------------------------

------------------------------------счетчик строк по кадру-----------------------------------------------------
cnt_str: count_n_modul                   
generic map (bit_strok) 
port map (
			clk			=>	CLK,	
			reset		=>	MAIN_reset ,
			en			=>	ena_str_cnt,
			modul		=>	max_str,
			qout		=>	qout_V,
			cout		=>	kadr_in);	
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		data_imx_anc	<=std_logic_vector(to_unsigned(3,bit_data_imx));
		data_imx_video	<=qout_clk_IS(bit_data_imx-1 downto 0);

		if 		(to_integer(unsigned (qout_V))	>=	 to_integer(unsigned (START_STR)))	and	(to_integer(unsigned (qout_V))	<	 to_integer(unsigned (START_STR)) + to_integer(unsigned (active_lin)) )
			then
				if 		qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-1,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_F0_V0_H0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-2,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-3,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-4,bit_pix))																		then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+0,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+1,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+2,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+3,bit_pix))									then DATA_IMX_OUT_in <= SAV_EAV_F0_V0_H1;	VALID_DATA<='0';
				elsif	qout_clk_IS	>=START_PIX_in and qout_clk_IS	<	std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in)),bit_pix))	then VALID_DATA<='1';
				else																																								 		 DATA_IMX_OUT_in <= data_imx_anc;	VALID_DATA<='0';
				end if;

			else	
				if 		qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-1,bit_pix))										then DATA_IMX_OUT_in <= SAV_EAV_F0_V1_H0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-2,bit_pix))										then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-3,bit_pix))										then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (START_PIX_in))-4,bit_pix))										then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+0,bit_pix))	then DATA_IMX_OUT_in <= SAV_EAV_SYNC_3FF;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+1,bit_pix))	then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+2,bit_pix))	then DATA_IMX_OUT_in <= SAV_EAV_SYNC_0;	VALID_DATA<='0';
				elsif	qout_clk_IS	= std_logic_vector(to_unsigned(to_integer(unsigned (active_pix_in))+to_integer(unsigned (START_PIX_in))+3,bit_pix))	then DATA_IMX_OUT_in <= SAV_EAV_F0_V1_H1;	VALID_DATA<='0';
				else																																	 	 DATA_IMX_OUT_in <= data_imx_anc;	VALID_DATA<='0';
				end if;
		end if;
	end if;
end if;
end process;




Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		(to_integer(unsigned (qout_V))	=	0)	
			then	XVS_Imx_Sim	<='0';
			else	XVS_Imx_Sim	<='1';
		end if;
	end if;
end if;
end process;
 
 Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		(to_integer(unsigned (qout_clk_IS))	>=to_integer(unsigned (START_PIX_in))	)	and	(to_integer(unsigned (qout_clk_IS))	<	to_integer(unsigned (START_PIX_in)) +5)
			then	XHS_Imx_Sim	<='0';
			else	XHS_Imx_Sim	<='1';
		end if;
	end if;
end if;
end process;

Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		(to_integer(unsigned (qout_V))	=	0)	
			then
				if 		qout_clk_IS	= START_PIX_in		
					then	SYNC_V			<=	'1';
					else	SYNC_V			<=	'0';
				end if;
			else	SYNC_V			<=	'0';
		end if;
	end if;
end if;
end process;

 Process(CLK)
begin
if rising_edge(CLK) then
	if ena_clk_in='1'	then
		if 		qout_clk_IS	= START_PIX_in			
			then	SYNC_H			<=	'1';
			else	SYNC_H			<=	'0';
		end if;
	end if;
end if;
end process;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------
Process(CLK)
Begin
	If rising_edge(CLK) then
			START_ACTIVE_FRAME <= VALID_DATA;

		-- If VALID_DATA = '0' then
		-- 	DATA_IMX_OUT <= DATA_IMX_OUT_in;
		-- 	START_ACTIVE_FRAME <= '0';
		-- else 
		-- 	START_ACTIVE_FRAME <= '1';
		-- 	DATA_IMX_OUT_R <= DATA_IMX_OUT_R_signal;
		-- 	DATA_IMX_OUT_G <= DATA_IMX_OUT_G_signal;
		-- 	DATA_IMX_OUT_B <= DATA_IMX_OUT_B_signal;
			
		-- end if;
	end if;
end process;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------


------------------------------------------------------------------------------
----------------------------------DDR interface-------------------------------
------------------------------------------------------------------------------
 
------------------------------------счетчик тактов для формирования сигналов разрешения-----------------------------------------------------
div_CLK_fast_q: count_n_modul                    
generic map (8) 
port map (
			clk			=>	CLK_fast,			
			reset		=>	MAIN_reset ,
			en			=>	MAIN_ENABLE,		
			modul		=> 	std_logic_vector(to_unsigned(256,8)) ,
			qout		=>	div_CLK_fast_in);
			
Process(CLK_fast)
begin
if rising_edge(CLK_fast) then
---------------------------------------clk в 2 раза меньше---------------------------------------
	if div_CLK_fast_in( 0)='0' 			
		then 	 ena_CLK_fast_x2_in<='1';
		else 	 ena_CLK_fast_x2_in<='0';
	end if;
---------------------------------------clk в 4 раза меньше---------------------------------------
	if div_CLK_fast_in(1 downto 0)="00"		
		then 	ena_CLK_fast_x4_in<='1';
		else  	ena_CLK_fast_x4_in<='0';
	end if;
---------------------------------------clk в 8 раза меньше---------------------------------------
	if div_CLK_fast_in(2 downto 0)="000"		
		then 	ena_CLK_fast_x8_in<='1';
		else	ena_CLK_fast_x8_in<='0';
	end if;
---------------------------------------clk в 16 раза меньше---------------------------------------
	if div_CLK_fast_in(3 downto 0)="0000"		
		then	ena_CLK_fast_x16_in<='1';
		else	ena_CLK_fast_x16_in<='0';
	end if;
end if;
end process;		
----------------------------------------------------------------------------------------------------



------------------------------------load_ddr_video_imx------------------------
-- load_ddr_video_imx_q: count_n_modul                   
-- generic map (8) 
-- port map (
			-- clk			=>	CLK_fast,	
			-- reset		=>	MAIN_reset ,
			-- en			=>	ena_CLK_fast,
			-- modul		=>	x"0c",
			-- qout		=>	q_load_ddr_video_imx,	
			-- cout		=>	load_ddr_video_imx);	

-- parall_to_serial_imx: parall_to_serial                    
-- generic map (bit_data_imx) 
-- port map (
			-- dir			=>	'1',		
			-- ena			=>	ena_CLK_fast,
			-- clk			=>	CLK_fast,			
			-- data		=>	DATA_IMX_OUT_in ,
			-- load		=>	load_ddr_video_imx,		
			-- shiftout	=> 	IMX_DDR_VIDEO_in );

----------------------------------------------------------------------------------------------------
IMX_DDR_VIDEO	<=IMX_DDR_VIDEO_in;
 Process(CLK_fast)
begin
if falling_edge(CLK_fast) then
	IMX_DDR_CLK_in	<=  q_load_ddr_video_imx(0);
	IMX_DDR_CLK		<=  q_load_ddr_video_imx(0);
end if;
end process;

IMX_DDR_VIDEO_in_b	<=IMX_DDR_VIDEO_in & IMX_DDR_VIDEO_in & IMX_DDR_VIDEO_in & IMX_DDR_VIDEO_in;

	
-- OUTBUF_DIFF_q0 : OUTBUF_DIFF
-- port map(
	-- D 		=> IMX_DDR_CLK_in,	
	-- PADP 	=> IMX_DDR_CLK_P(0), 
	-- PADN 	=> IMX_DDR_CLK_N(0) );
-- OUTBUF_DIFF_q1 : OUTBUF_DIFF
-- port map(
	-- D 		=> IMX_DDR_VIDEO_in,	
	-- PADP 	=> IMX_DDR_VIDEO_CH_0_P(0), 
	-- PADN 	=> IMX_DDR_VIDEO_CH_0_N(0) );
-- OUTBUF_DIFF_q2 : OUTBUF_DIFF
-- port map(
	-- D 		=> IMX_DDR_VIDEO_in,	
	-- PADP 	=> IMX_DDR_VIDEO_CH_1_P(0), 
	-- PADN 	=> IMX_DDR_VIDEO_CH_1_N(0) );
-- OUTBUF_DIFF_q3 : OUTBUF_DIFF
-- port map(
	-- D 		=> IMX_DDR_VIDEO_in,	
	-- PADP 	=> IMX_DDR_VIDEO_CH_2_P(0), 
	-- PADN 	=> IMX_DDR_VIDEO_CH_2_N(0) );
-- OUTBUF_DIFF_q4 : OUTBUF_DIFF
-- port map(
	-- D 		=> IMX_DDR_VIDEO_in,	
	-- PADP 	=> IMX_DDR_VIDEO_CH_3_P(0), 
	-- PADN 	=> IMX_DDR_VIDEO_CH_3_N(0) );
	
--------------------------------------------------------------------------------------------------------------------
---------Чтения данных из файла с записью в память --------------
-- Sprite_generator	:	TestingStripes
-- Generic map (
-- 	bit_pix,	
-- 	bit_strok,						
-- 	Address_cell_width,		
-- 	Separating_width
-- 	)
-- Port map (
-- ---------------Входные-------------------------
-- 	clock						=> CLK_fast,
-- 	active_pix					=> active_pix,
-- 	active_lin					=> active_lin,
-- 	enable						=> START_ACTIVE_FRAME,
-- ---------------Выходные-------------------------	
-- 	Data_R						=> DATA_IMX_OUT_R_signal,
-- 	Data_G						=> DATA_IMX_OUT_G_signal,
-- 	Data_B						=> DATA_IMX_OUT_B_signal
-- 	);
------------------------------------------------------------------
-------------------Тестовая картнинка "Шахматы"-------------------
Test_Checker	: Checker
Generic map (
	bit_pix,
	bit_strok
)
Port map(
	clock						=> CLK_fast,
	active_lin					=> active_lin,
	active_pix					=> active_pix,
	Enable						=> START_ACTIVE_FRAME
);
------------------------------------------------------------------
end ;
