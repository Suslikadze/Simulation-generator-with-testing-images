ibrary ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Write_to_file_binar is
Port(
		clk				: IN std_logic;
        Enable			: IN std_logic;
        in_pix          : in std_logic
);
end Write_to_file_binar;

architecture Arch of Write_to_file is
	file f					: text open write_mode is "TEST_PICTURE_BINAR.TXT";
end