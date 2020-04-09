--------------------------------------------------------------------------------
-- Title       : comma_detection
-- Project     : GSoC-2012 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : comma_detection.vhd
-- Author      : Maria Gorchichko
-- Company     : N/A
-- Platform    : Xilinx Artix-7
-- Standard    : VHDL-2008
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.parameters.all;

entity comma_detection is
    Port (
        clk               : in  STD_LOGIC;
        rst               : in  STD_LOGIC;
        bit_mode          : in  STD_LOGIC_VECTOR(1 downto 0);
        dbl_word          : in  STD_LOGIC_VECTOR(18 downto 0);
        dat_strb          : in  STD_LOGIC;
        comma_dtct_comb   : out STD_LOGIC;
        word_end_pos_comb : out signed(3 downto 0)
    );
end comma_detection;

architecture RTL of comma_detection is

    -- Word start position and the register to store the last value
    signal word_end_pos        : integer range -4 to 7;
    signal word_end_pos_next   : integer range -4 to 7;
    constant word_end_pos_init : integer := 0;
    signal full_word_flag      : STD_LOGIC;

    signal comma_detected     : STD_LOGIC_VECTOR(7 downto 0);
    signal comma_detected_int : integer range 255 downto 0;

begin

    comma_detection : for comma_bit in 0 to 7 generate
        N_comma_bit : process(all)
        begin
            case bit_mode is

                when set_12b_word =>

                    -- Analyze slices [18:7], [17:6] ... [11:0]
                    if dbl_word((11 + comma_bit) downto comma_bit) = comma_12b then
                        comma_detected(comma_bit) <= '1';
                    else
                        comma_detected(comma_bit) <= '0';
                    end if;

                when set_10b_word =>

                    -- Analyze slices [16:7], [15:6] ... [9:0]
                    if dbl_word((9 + comma_bit) downto comma_bit) = comma_10b then
                        comma_detected(comma_bit) <= '1';
                    else
                        comma_detected(comma_bit) <= '0';
                    end if;

                when others => -- set_8b_word

                    -- Analyze slices [14:7], [13:6] ... [7:0]
                    if dbl_word((7 + comma_bit) downto comma_bit) = comma_8b then
                        comma_detected(comma_bit) <= '1';
                    else
                        comma_detected(comma_bit) <= '0';
                    end if;

            end case;
        end process;
    end generate comma_detection;

    comma_detected_int <= to_integer(unsigned(comma_detected));

    set_word_end_pos_process : process (all)
    begin
        case comma_detected_int is
            when 255 downto 128 =>
                word_end_pos <= 7;
            when 127 downto 64 =>
                word_end_pos <= 6;
            when 63 downto 32 =>
                word_end_pos <= 5;
            when 31 downto 16 =>
                word_end_pos <= 4;
            when 15 downto 8 =>
                word_end_pos <= 3;
            when 7 downto 4 =>
                word_end_pos <= 2;
            when 3 downto 2 =>
                word_end_pos <= 1;
            when 1 =>
                word_end_pos <= 0;
            when others =>
                word_end_pos <= word_end_pos_next;
        end case;
    end process set_word_end_pos_process;

    -- Latching word start position to complete case statement
    calc_next_word_end_process : process(clk, rst)
    begin
        if rst = '1' then
            word_end_pos_next <= word_end_pos_init;
        elsif clk'event and clk = '1' then
            case bit_mode is
                when set_12b_word =>
                    if word_end_pos < 0 then
                        word_end_pos_next <= word_end_pos + 8;
                    else
                        word_end_pos_next <= word_end_pos - 4; -- +8-12
                    end if;
                when set_10b_word =>
                    if word_end_pos < 0 then
                        word_end_pos_next <= word_end_pos + 8;
                    else
                        word_end_pos_next <= word_end_pos - 2; -- +8-10
                    end if;
                when others => -- 8 bit
                               -- word end position stays the same
                    word_end_pos_next <= word_end_pos;
            end case;
        end if;
    end process calc_next_word_end_process;

    -- Outputs assignment
    comma_dtct_comb   <= OR_REDUCE(comma_detected);
    word_end_pos_comb <= to_signed(word_end_pos, 4);

end RTL;
