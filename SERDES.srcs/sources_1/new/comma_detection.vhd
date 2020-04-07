--------------------------------------------------------------------------------
-- Title       : comma_detection
-- Project     : GSoC-2012 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : comma_detection.vhd
-- Author      : Maria Gorchichko
-- Company     : N/A
-- Platform    : Xilinx Artix-7
-- Standard    : <VHDL-2008 | VHDL-2002 | VHDL-1993 | VHDL-1987>
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.parameters.all;

entity comma_detection is
    Port (
        clk              : in  STD_LOGIC;
        rst              : in  STD_LOGIC;
        bit_mode         : in  STD_LOGIC_VECTOR(1 downto 0);
        dbl_word         : in  STD_LOGIC_VECTOR(15 downto 0);
        dat_strb         : in  STD_LOGIC;
        comma_dtct_comb  : out STD_LOGIC;
        word_st_pos_comb : out STD_LOGIC_VECTOR(3 downto 0)
    );
end comma_detection;

architecture RTL of comma_detection is

    -- Word start position and the register to store the last value
    signal word_st_pos     : integer range 0 to 15;
    signal word_st_pos_reg : integer range 0 to 15;

    --signal word_len        : UNSIGNED(3 downto 0); -- word length (12/10/8 bits)

    --signal comma_flag : STD_LOGIC;

    signal comma_detected : STD_LOGIC;


begin

    -- Combinational comma sequences search
    comma_detect_comb : process(bit_mode, dbl_word, word_st_pos_reg, rst)
    begin
        if rst = '1' then
            comma_detected <= '0';
            word_st_pos <= 15;
        else
            case bit_mode is
                when set_12b_word =>
                    case dbl_word is

                        when comma_12b & "----" =>
                            comma_detected <= '1';
                            word_st_pos    <= 15;

                        when "-" & comma_12b & "---"  =>
                            comma_detected <= '1';
                            word_st_pos    <= 14;

                        when "--"   & comma_12b & "--"   =>
                            comma_detected <= '1';
                            word_st_pos    <= 13;

                        when "---"  & comma_12b & "-"    =>
                            comma_detected <= '1';
                            word_st_pos    <= 12;

                        when "----" & comma_12b          =>
                            comma_detected <= '1';
                            word_st_pos    <= 11;

                        when others =>
                            comma_detected <= '0';
                            word_st_pos    <= word_st_pos_reg - (12 - 8);

                    end case;
                when set_10b_word =>
                    case dbl_word is

                        when comma_10b & "------" =>
                            comma_detected <= '1';
                            word_st_pos    <= 15;

                        when "-" & comma_10b & "-----"  =>
                            comma_detected <= '1';
                            word_st_pos    <= 14;

                        when "--"     & comma_10b & "----"   =>
                            comma_detected <= '1';
                            word_st_pos    <= 13;

                        when "---"    & comma_10b & "---"    =>
                            comma_detected <= '1';
                            word_st_pos    <= 12;

                        when "----"   & comma_10b & "--"     =>
                            comma_detected <= '1';
                            word_st_pos    <= 11;

                        when "-----"  & comma_10b & "-"      =>
                            comma_detected <= '1';
                            word_st_pos    <= 10;

                        when "------" & comma_10b            =>
                            comma_detected <= '1';
                            word_st_pos    <=  9;

                        when others =>
                            comma_detected <= '0';
                            word_st_pos    <= word_st_pos_reg - (10 - 8);

                    end case;

                when others => -- 8 bits word is the default case
                               -- I expressly don NOT detect comma located in the last 8 bits.
                               -- It'll be detected during next cycle.
                    case dbl_word is

                        when comma_8b & "--------" =>
                            comma_detected <= '1';
                            word_st_pos    <= 15;

                        when "-" & comma_8b & "-------"    =>
                            comma_detected <= '1';
                            word_st_pos    <= 14;

                        when "--"       & comma_8b & "------"     =>
                            comma_detected <= '1';
                            word_st_pos    <= 13;

                        when "---"      & comma_8b & "-----"      =>
                            comma_detected <= '1';
                            word_st_pos    <= 12;

                        when "----"     & comma_8b & "----"       =>
                            comma_detected <= '1';
                            word_st_pos    <= 11;

                        when "-----"    & comma_8b & "---"        =>
                            comma_detected <= '1';
                            word_st_pos    <= 10;

                        when "------"   & comma_8b & "--"         =>
                            comma_detected <= '1';
                            word_st_pos    <=  9;

                        when "-------"  & comma_8b & "-"          =>
                            comma_detected <= '1';
                            word_st_pos    <=  8;

                        when others =>
                            comma_detected <= '0';
                            word_st_pos    <= word_st_pos_reg;

                    end case;
            end case;
        end if;
    end process;

    -- Latching word start position to complete case statement
    word_st_pos_latch : process(clk, rst)
    begin
        if rst = '1' then
            word_st_pos_reg <= 15;
        elsif clk'event and clk = '1' then
            if dat_strb = '1' then
                word_st_pos_reg <= word_st_pos;
            end if;
        end if;
    end process;

    -- Outputs assignment
    comma_dtct_comb  <= STD_LOGIC(comma_detected);
    word_st_pos_comb <= STD_LOGIC_VECTOR(to_unsigned(word_st_pos, 4));

end RTL;
