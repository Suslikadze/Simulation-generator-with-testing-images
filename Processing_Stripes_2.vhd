library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

Entity TestingStripes is
    Generic(
        bit_pix						: integer;		--бит на счетчик пикселей
        bit_strok					: integer;		--бит на счетчик строк
        Address_cell_width			: integer;		--разрядность одной ячейки памяти
	    Separating_width			: integer		--разрядность выходной шины одного из цветов
    );
    Port(
        clock                       : IN STD_LOGIC;
        active_pix					: IN std_logic_vector(bit_pix - 1 downto 0);
        active_lin					: IN std_logic_vector(bit_strok - 1 downto 0);
        Enable                      : IN STD_logic;

        Data_R				    	: OUT std_logic_vector((Address_cell_width / 3) - 1 downto 0);
	    Data_G				    	: OUT std_logic_vector((Address_cell_width / 3) - 1 downto 0);
	    Data_B				    	: OUT std_logic_vector((Address_cell_width / 3) - 1 downto 0)
    );
end TestingStripes;

architecture arch of TestingStripes is
    -------------------------Подключаемые модули-----------------------------
    -------------------------------------------------------------------------
    component count_n_modul
    generic (n		: integer);
    port (
        clk,
        reset,
        en			:	in std_logic;
        modul		: 	in std_logic_vector (n-1 downto 0);
        qout		: 	out std_logic_vector (n-1 downto 0);
        cout		:	out std_logic
    );
    end component;
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------
    signal strip_count                          : std_logic_vector(bit_pix - 1 downto 0);
    signal strip_line_count                     : std_logic_vector(9 downto 0);
    signal strip_line_length                    : std_logic_vector(9 downto 0); 
    signal one_strip_width                      : std_logic_vector(7 downto 0);
    signal one_strip_count                      : std_logic_vector(7 downto 0);                 
    signal R_intensity_1, R_intensity_2         : integer := 0;
    signal G_intensity_1, G_intensity_2         : integer := 0;
    signal B_intensity_1, B_intensity_2         : integer := 0; 
    signal number_of_strip                      : integer := 0;
    signal big_flag, small_flag, flag_part      : std_logic;
    signal part_of_picture                      : std_logic := '0';
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------     
    BEGIN
    one_strip_width <= std_logic_vector(to_unsigned((to_integer(unsigned(active_pix)) / 7), 8));
    strip_line_length <= std_logic_vector(to_unsigned((to_integer(unsigned(active_lin)) - 150), 10));
    -------------------------------------------------------------------------
    RGB_intensity_counter   :count_n_modul
    Generic map(bit_pix)
    Port map(
        clk         => clock,
        reset       => '0',
        en          => Enable,
        modul       => active_pix,
        qout        => strip_count,
        cout        => big_flag
    );
    ------------------------------------------------------------------------- 
    -------------------------------------------------------------------------
    Counter_of_one_strip   :count_n_modul
    Generic map(8)
    Port map(
        clk         => clock,
        reset       => big_flag,
        en          => Enable,
        modul       => one_strip_width,
        qout        => one_strip_count,
        cout        => small_flag
    );
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------
    Counter_of_lines   :count_n_modul
    Generic map(10)
    Port map(
        clk         => big_flag,
        reset       => '0',
        en          => Enable,
        modul       => strip_line_length,
        qout        => strip_line_count,
        cout        => flag_part
    );
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------
    Process(clock)
    Begin   
        If rising_edge(clock) then
            if big_flag = '1' then
                number_of_strip <= 0;
            elsif small_flag = '1' then
                number_of_strip <= number_of_strip + 1;
            end if;
            if flag_part = '1' then
                part_of_picture <= '1';
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------
    Process(clock)
    Begin
        If rising_edge(clock) then
            if Enable = '1' then
                if number_of_strip = 0 then
                    R_intensity_1 <= 255;
                    G_intensity_1 <= 255;
                    B_intensity_1 <= 255;
                    ---------------
                    R_intensity_2 <= 0;
                    G_intensity_2 <= 0;
                    B_intensity_2 <= 255;
                elsif number_of_strip = 1 then
                    R_intensity_1 <= 255;
                    G_intensity_1 <= 255;
                    B_intensity_1 <= 0;
                    ---------------
                    R_intensity_2 <= 0;
                    G_intensity_2 <= 0;
                    B_intensity_2 <= 0;
                elsif number_of_strip = 2 then
                    R_intensity_1 <= 0;
                    G_intensity_1 <= 255;
                    B_intensity_1 <= 255;
                    ---------------
                    R_intensity_2 <= 199;
                    G_intensity_2 <= 32;
                    B_intensity_2 <= 133;
                elsif number_of_strip = 3 then
                    R_intensity_1 <= 0;
                    G_intensity_1 <= 128;
                    B_intensity_1 <= 255;
                    ---------------
                    R_intensity_2 <= 0;
                    G_intensity_2 <= 0;
                    B_intensity_2 <= 0;
                elsif number_of_strip = 4 then
                    R_intensity_1<= 199;
                    G_intensity_1<= 32;
                    B_intensity_1<= 133;
                    ---------------
                    R_intensity_2 <= 0;
                    G_intensity_2 <= 255;
                    B_intensity_2 <= 255;
                elsif number_of_strip = 5 then
                    R_intensity_1 <= 255;
                    G_intensity_1 <= 0;
                    B_intensity_1 <= 0;
                    ---------------
                    R_intensity_2 <= 0;
                    G_intensity_2 <= 0;
                    B_intensity_2 <= 0;
                elsif number_of_strip = 6 then
                    R_intensity_1 <= 0;
                    G_intensity_1 <= 0;
                    B_intensity_1 <= 255;
                    ---------------
                    R_intensity_2 <= 255;
                    G_intensity_2 <= 255;
                    B_intensity_2 <= 255;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------
   Process(clock)
    Begin
        if rising_edge(clock) then
            if Enable = '1' then
                if part_of_picture = '0' then 
                    Data_R <= std_logic_vector(to_unsigned(R_intensity_1, Separating_width));
                    Data_G <= std_logic_vector(to_unsigned(G_intensity_1, Separating_width));
                    Data_B <= std_logic_vector(to_unsigned(B_intensity_1, Separating_width));
                else
                    Data_R <= std_logic_vector(to_unsigned(R_intensity_2, Separating_width));
                    Data_G <= std_logic_vector(to_unsigned(G_intensity_2, Separating_width));
                    Data_B <= std_logic_vector(to_unsigned(B_intensity_2, Separating_width));
                end if;
            end if;
        end if;
    end Process;
end arch ; -- arch




    -- Process(clock)
    -- Begin
    --     If rising_edge(clock) then
    --         if Enable = '1' then
    --             If to_integer(unsigned(strip_count)) >= 0 and  to_integer(unsigned(strip_count)) < one_strip_width then
    --                 R_intensity <= 255;
    --                 G_intensity <= 0;
    --                 B_intensity <= 0;
    --                 one_strip_width_2 <= one_strip_width * 4;
    --                         elsif to_integer(unsigned(strip_count)) = one_strip_width then
    --                             one_strip_width_1 <= one_strip_width + one_strip_width;
    --                             R_intensity <= 0;
    --                             G_intensity <= 255;
    --                             B_intensity <= 0;
    --             -- elsif  to_integer(unsigned(strip_count)) > one_strip_width and  to_integer(unsigned(strip_count)) < one_strip_width_1 then
    --             --     R_intensity <= 100;
    --             --     G_intensity <= 255;
    --             --     B_intensity <= 0;
    --                         elsif to_integer(unsigned(strip_count)) = one_strip_width_1 then
    --                             one_strip_width_1 <= one_strip_width_2 + one_strip_width;
    --                             R_intensity <= 0;
    --                             G_intensity <= 0;
    --                             B_intensity <= 255;
    --             -- elsif  to_integer(unsigned(strip_count)) > one_strip_width_1 and  to_integer(unsigned(strip_count)) < one_strip_width_2 then
    --             --     R_intensity <= 200;
    --             --     G_intensity <= 100;
    --             --     B_intensity <= 100;
    --                         elsif to_integer(unsigned(strip_count)) = one_strip_width_2 - 1 then
    --                             one_strip_width_1 <= one_strip_width_2 + one_strip_width;
    --                             R_intensity <= 200;
    --                             G_intensity <= 0;
    --                             B_intensity <= 0;
    --             -- elsif  to_integer(unsigned(strip_count)) > one_strip_width_2 and  to_integer(unsigned(strip_count)) < one_strip_width_1 then
    --             --     R_intensity <= 0;
    --             --     G_intensity <= 0;
    --             --     B_intensity <= 255;
    --                         elsif to_integer(unsigned(strip_count)) = one_strip_width_1 - 1 then
    --                             --one_strip_width_1 <= 0;
    --                             R_intensity <= 0;
    --                             G_intensity <= 25;
    --                             B_intensity <= 0;
    --             -- elsif  to_integer(unsigned(strip_count)) > one_strip_width_1 and  to_integer(unsigned(strip_count)) < to_integer(unsigned(active_pix)) then
    --             --     R_intensity <= 0;
    --             --     G_intensity <= 255;
    --             --     B_intensity <= 0;
    --                         elsif to_integer(unsigned(strip_count)) = to_integer(unsigned(active_pix)) then
    --                             -- R_intensity <= 0;
    --                             -- G_intensity <= 255;
    --                             -- B_intensity <= 0;
    --                             one_strip_width_1 <= 0;
    --             end if;
    --         end if;
    --     end if;
    -- end Process;
    -------------------------------------------------------------------------
 