library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

Entity TestingStripes is
    Generic(
        bit_pix						: integer;		--бит на счетчик пикселей
        bit_strok					: integer;		--бит на счетчик строк
        Address_cell_width			: integer;		--разрядность одной ячейки памяти
	    Address_width				: integer;		--разрядность числа ячеек памяти
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
        signal R_intensity                          : integer := 0;
        signal G_intensity                          : integer := 0;
        signal B_intensity                          : integer := 0; 
        signal one_strip_width                      : integer := 0;
        signal one_strip_width_1, one_strip_width_2 : integer := 0;
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------     
    BEGIN
    one_strip_width <= (to_integer(signed(active_pix)) / 5);

    RGB_intensity_counter   :count_n_modul
        Generic map(bit_pix)
        Port map(
            clk         => clock,
            reset       => '0',
            en          => Enable,
            modul       => active_pix,
            qout        => strip_count
        );
    ------------------------------------------------------------------------- 
    Process(clock)
    Begin
        If rising_edge(clock) then
            if Enable = '1' then
                If to_integer(signed(strip_count)) >= 0 and  to_integer(signed(strip_count)) < one_strip_width then
                    R_intensity <= 0;
                    G_intensity <= 100;
                    B_intensity <= 100;
                            elsif to_integer(signed(strip_count)) = one_strip_width then
                                one_strip_width_1 <= one_strip_width * 2;
                                R_intensity <= 100;
                                G_intensity <= 255;
                                B_intensity <= 0;
                elsif  to_integer(signed(strip_count)) > one_strip_width and  to_integer(signed(strip_count)) < one_strip_width_1 then
                    R_intensity <= 100;
                    G_intensity <= 255;
                    B_intensity <= 0;
                            elsif to_integer(signed(strip_count)) = one_strip_width_1 then
                                one_strip_width_2 <= one_strip_width_1 + one_strip_width;
                                R_intensity <= 200;
                                G_intensity <= 100;
                                B_intensity <= 100;
                elsif  to_integer(signed(strip_count)) > one_strip_width _1 and  to_integer(signed(strip_count)) < one_strip_width_2 then
                    R_intensity <= 200;
                    G_intensity <= 100;
                    B_intensity <= 100;
                            elsif to_integer(signed(strip_count)) = one_strip_width_2 then
                                one_strip_width_1 <= one_strip_width_2 + one_strip_width;
                                R_intensity <= 0;
                                G_intensity <= 0;
                                B_intensity <= 255;
                elsif  to_integer(signed(strip_count)) > one_strip_width_2 and  to_integer(signed(strip_count)) < one_strip_width_1 then
                    R_intensity <= 0;
                    G_intensity <= 0;
                    B_intensity <= 255;
                            elsif to_integer(signed(strip_count)) = one_strip_width_1 then
                                one_strip_width_2 <= (others => '0');
                                R_intensity <= 0;
                                G_intensity <= 255;
                                B_intensity <= 0;
                elsif  to_integer(signed(strip_count)) > one_strip_width_1 and  to_integer(signed(strip_count)) < to_integer(signed(active_pix)) then
                    R_intensity <= 0;
                    G_intensity <= 255;
                    B_intensity <= 0;
                            elsif to_integer(signed(strip_count)) = to_integer(signed(active_pix)) then
                                R_intensity <= 0;
                                G_intensity <= 255;
                                B_intensity <= 0;
                                one_strip_width_1 <= (others => '0');
                end if;
            end if;
        end if;
    end Process;
    -------------------------------------------------------------------------
    Process(clock)
    Begin
        if rising_edge(clock) then
            if Enable = '1' then
                Data_R <= std_logic_vector(to_signed(R_intensity, Separating_width));
                Data_G <= std_logic_vector(to_signed(G_intensity, Separating_width));
                Data_B <= std_logic_vector(to_signed(B_intensity, Separating_width));
            end if;
        end if;
    end Process;
end arch ; -- arch