----------------------------------------------------------------------------------
-- Engineer: Francesco Romeo
--
-- Create Date: 12.09.2018 10:24:14
-- Module Name: project_reti_logiche
-- Project Name: Prova Finale di Reti Logiche
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity project_reti_logiche is
	port (
		i_clk     : in STD_LOGIC;
		i_start   : in STD_LOGIC;
		i_rst     : in STD_LOGIC;
		i_data    : in STD_LOGIC_VECTOR(7 downto 0);
		o_address : out STD_LOGIC_VECTOR(15 downto 0);
		o_done    : out STD_LOGIC;
		o_en      : out STD_LOGIC;
		o_we      : out STD_LOGIC;
		o_data    : out STD_LOGIC_VECTOR(7 downto 0)
	);
end project_reti_logiche;
architecture Behavioral of project_reti_logiche is
	type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S_ADDRESS_UPDATER, S_PRE_BUFFER, S_BUFFER, S_LOOP, S_IF, S_CONTINUE, S_CONTINUE_3, S_INIT, S_INIT2, S_INIT3, S_INIT4, S_WRITE, S_TRIGGER, S_VOID, S_WRITE2, S_WRITE3, S_WRITE4, S_FINAL, S_DONE, S_VOID2, S_VOID3, S_ADDRESS_UPDATER2);
	signal next_state               : state_type;
	signal N_COLUMN, N_ROW, TRIGGER : UNSIGNED(7 downto 0) := (others => '0');
	signal LAST                     : integer := 0;
	signal TMP_BUFFER               : UNSIGNED(7 downto 0) := (others => '0');
	signal X0, X1, Y0, Y1           : integer := - 1;
	signal AREA                     : UNSIGNED(15 downto 0) := (others => '0');
	signal INDEX                    : integer := 4;
	signal OFFSET                   : integer := 0;
	signal TMP_COORD_0, TMP_COORD_1 : integer := 0;
begin
	state_reg : process (i_clk, i_rst)
	begin
		if (i_rst = '1') then
			o_done     <= '0';
			o_data     <= (others => '0');
			o_en       <= '1';
			o_we       <= '0';
			o_address  <= STD_LOGIC_VECTOR(TO_UNSIGNED(2, 16));
			next_state <= S0;
		elsif rising_edge(i_clk) then
			case next_state is
			
				when S0 =>
					if (i_start = '1') then
						next_state <= S1;
					else
						next_state <= S0;
					end if;
					
				when S1 =>
					N_COLUMN   <= UNSIGNED(i_data);
					next_state <= S2;
					
				when S2 =>
					o_address  <= STD_LOGIC_VECTOR(TO_UNSIGNED(3, 16));
					next_state <= S3;
					
				when S3 =>

					next_state <= S4;
					
				when S4 =>
					N_ROW      <= UNSIGNED(i_data);
					next_state <= S5;
					
				when S5 =>
					o_address  <= STD_LOGIC_VECTOR(TO_UNSIGNED(4, 16));
					next_state <= S6;
					
				when S6 =>

					next_state <= S7;
					
				when S7 =>
					TRIGGER    <= UNSIGNED(i_data);
					LAST       <= TO_INTEGER(N_COLUMN * N_ROW);
					next_state <= S_ADDRESS_UPDATER;
					
				when S_ADDRESS_UPDATER =>
					INDEX      <= INDEX + 1;
					next_state <= S_ADDRESS_UPDATER2;
					
				when S_ADDRESS_UPDATER2 =>
					OFFSET     <= INDEX - 5;
					o_address  <= STD_LOGIC_VECTOR(TO_UNSIGNED(INDEX, o_address'length));
					next_state <= S_PRE_BUFFER;
					
				when S_PRE_BUFFER =>

					next_state <= S_BUFFER;
					
				when S_BUFFER =>
					TMP_BUFFER  <= UNSIGNED(i_data);
					TMP_COORD_0 <= OFFSET mod TO_INTEGER(N_COLUMN) + 1;
					TMP_COORD_1 <= OFFSET / TO_INTEGER(N_COLUMN);
					next_state  <= S_IF;
					
				when S_IF =>
					if OFFSET < LAST then
						next_state <= S_TRIGGER;
					else
						o_we       <= '1';
						next_state <= S_WRITE;
					end if;
					
				when S_TRIGGER =>
					if TMP_BUFFER >= TRIGGER then
						next_state <= S_LOOP;
					else
						next_state <= S_ADDRESS_UPDATER;
					end if;
					
				when S_LOOP =>
					if (X0 =- 1) then
						next_state <= S_INIT;
					else
						next_state <= S_CONTINUE;
					end if;
					
				when S_INIT =>
					X0         <= (TMP_COORD_0);
					next_state <= S_INIT2;
					
				when S_INIT2 =>
					X1         <= (TMP_COORD_0);
					next_state <= S_INIT3;
					
				when S_INIT3 =>
					Y0         <= (TMP_COORD_1);
					next_state <= S_INIT4;
					
				when S_INIT4 =>
					Y1         <= (TMP_COORD_1);
					next_state <= S_ADDRESS_UPDATER;
					
				when S_CONTINUE =>
					if TMP_COORD_0 < X0 then
						X0 <= (TMP_COORD_0);
					elsif TMP_COORD_0 > X1 then
						X1 <= (TMP_COORD_0);
					else
						next_state <= S_CONTINUE_3;
					end if;
					next_state <= S_CONTINUE_3;
					
				when S_CONTINUE_3 =>
					if (TMP_COORD_1) > Y1 then
						Y1 <= (TMP_COORD_1);
					else
						next_state <= S_ADDRESS_UPDATER;
					end if;
					next_state <= S_ADDRESS_UPDATER;

				when S_WRITE =>
					o_address <= (others => '0');
					if X1 - X0 = 0 or Y1 - Y0 = 0 then
						next_state <= S_VOID;
					else
						AREA       <= TO_UNSIGNED(((X1 - X0 + 1) * (Y1 - Y0 + 1)), AREA'length);
						next_state <= S_WRITE2;
					end if;
					
				when S_WRITE2 =>
					o_data     <= STD_LOGIC_VECTOR(AREA(7 downto 0));
					next_state <= S_WRITE3;
					
				when S_WRITE3 =>
					o_address  <= (0 => '1', others => '0');
					next_state <= S_WRITE4;
					
				when S_WRITE4 =>
					o_data     <= STD_LOGIC_VECTOR(AREA(15 downto 8));
					next_state <= S_FINAL;
					
				when S_VOID =>
					o_data     <= (others => '0');
					next_state <= S_VOID2;
					
				when S_VOID2 =>
					o_address  <= (0 => '1', others => '0');
					next_state <= S_VOID3;
					
				when S_VOID3 =>
					o_data     <= (others => '0');
					next_state <= S_FINAL;
					
				when S_FINAL =>
					o_we       <= '0';
					o_done     <= '1';
					next_state <= S_DONE;
					
				when S_DONE =>
					o_done     <= '0';
					next_state <= S0;
					
			end case;
		end if;
	end process;
end Behavioral;
