library ieee;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

Entity Checker is
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
end Checker;

architecture arch of Checker is
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
signal valid_pix_count                              : std_logic_vector(bit_pix - 1 downto 0);
signal square_count_horiz                           : std_logic_vector(7 downto 0);
signal square_count_vert                            : std_logic_vector(7 downto 0);
signal square_side                                  : std_logic_vector(7 downto 0);
file f				                                : text open write_mode is "TEST_PICTURE_BINAR.TXT";
signal out_pix_signal, first_in_string_pix          : std_logic := '0';
signal big_flag, small_flag_vert,small_flag_horiz   : std_logic;
-------------------------------------------------------------------------
-------------------------------------------------------------------------     
BEGIN
square_side <= std_logic_vector(to_unsigned((to_integer(unsigned(active_pix)) / 8), 8));
-------------------------------------------------------------------------
Valid_pix_counter   :count_n_modul
Generic map(bit_pix)
Port map(
    clk         => clock,
    reset       => '0',
    en          => Enable,
    modul       => active_pix,
    qout        => valid_pix_count,
    cout        => big_flag
);
------------------------------------------------------------------------- 
-------------------------------------------------------------------------
Square_horiz_counter   :count_n_modul
Generic map(8)
Port map(
    clk         => clock,
    reset       => big_flag,
    en          => Enable,
    modul       => square_side,
    qout        => square_count_horiz,
    cout        => small_flag_horiz
);
-------------------------------------------------------------------------
-------------------------------------------------------------------------
Square_vert_counter   :count_n_modul
Generic map(8)
Port map(
    clk         => big_flag,
    reset       => '0',
    en          => Enable,
    modul       => square_side,
    qout        => square_count_vert,
    cout        => small_flag_vert
);
-------------------------------------------------------------------------
Process(clock)
BEGIN
    if rising_edge(clock) then
        if enable = '1' then
            if small_flag_horiz = '1' then
                out_pix_signal <= not out_pix_signal;
            end if;
            if small_flag_vert = '1' then
                out_pix_signal <= first_in_string_pix;
            end if;
        end if;
    end if;
end Process;
-------------------------------------------------------------------------
Process(small_flag_vert)
Begin
    If small_flag_vert'event and small_flag_vert = '1' then
        first_in_string_pix <= not first_in_string_pix;
    end if;
end Process;
-------------------------------------------------------------------------
Process(clock)
variable row 				: line;
Begin
    If rising_edge(clock) then
        if Enable = '1' then
                write(row, out_pix_signal);
                writeline(f, row);
        end if;
    end if;
end Process;
end arch;
