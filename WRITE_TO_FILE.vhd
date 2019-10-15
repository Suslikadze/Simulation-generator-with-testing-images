Library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Write_to_file is
generic(
	Separating_width			: integer
);
	Port(
		clk				: IN std_logic;
		DATA_IMX_IN_R	: IN std_logic_vector((Separating_width - 1) downto 0);
		DATA_IMX_IN_G	: IN std_logic_vector((Separating_width - 1) downto 0);
		DATA_IMX_IN_B	: IN std_logic_vector((Separating_width - 1) downto 0);
		Enable			: IN std_logic
	);
END Write_to_file;

architecture Arch of Write_to_file is
	file f					: text open write_mode is "HOUSE_IN_BINAR_AFTER.TXT";
	signal solid_data_line	: std_logic_vector ((Separating_width * 3 - 1) downto 0);
	
	Begin
	Process(clk)
	Begin
		If rising_edge(clk) then
			if enable = '1' then
				solid_data_line(Separating_width - 1 downto 0) <= DATA_IMX_IN_B;
				solid_data_line((Separating_width * 2 - 1) downto Separating_width) <= DATA_IMX_IN_G;
				solid_data_line((Separating_width * 3 - 1) downto (Separating_width * 2)) <= DATA_IMX_IN_R;
			end if;
		end if;
	end process;
	
		Process(clk)
		variable row 				: line;
		Begin
			If rising_edge(clk) then
				if Enable = '1' then
					write(row, solid_data_line, right, Separating_width * 3);
					writeline(f, row);
				end if;
			end if;
		end process;
	end Arch;