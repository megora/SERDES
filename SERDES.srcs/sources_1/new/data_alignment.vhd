--------------------------------------------------------------------------------
-- Title       : data_alignment
-- Project     : GSoC-2012 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : data_alignment.vhd
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

entity data_alignment is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        bit_mode  : in  STD_LOGIC_VECTOR(1 downto 0);
        dat_in    : in  STD_LOGIC_VECTOR(7 downto 0);
        dat_strb  : in  STD_LOGIC;
        word      : out STD_LOGIC_VECTOR(11 downto 0);
        word_strb : out STD_LOGIC
    );
end data_alignment;

architecture RTL of data_alignment is

    component comma_detection is
        Port (
            clk              : in  STD_LOGIC;
            rst              : in  STD_LOGIC;
            bit_mode         : in  STD_LOGIC_VECTOR(1 downto 0);
            dbl_word         : in  STD_LOGIC_VECTOR(15 downto 0);
            dat_strb         : in  STD_LOGIC;
            comma_dtct_comb  : out STD_LOGIC;
            word_st_pos_comb : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal dbl_word    : STD_LOGIC_VECTOR(15 downto 0);
    signal word_i      : STD_LOGIC_VECTOR(11 downto 0); -- internal word
    signal word_strb_i : STD_LOGIC;

    signal comma_dtct_comb       : STD_LOGIC;
    signal comma_first_dtct_flag : STD_LOGIC;
    signal word_st_pos_comb      : STD_LOGIC_VECTOR(3 downto 0);
    signal word_st_pos_int       : integer range 0 to 15 := 15;

    signal dat_strb_reg : STD_LOGIC;

begin

    -- Making 2 words sequence to seek the comma
    words_unite : process(rst, clk)
    begin
        if rst = '1' then
            dbl_word <= x"0000";
        elsif clk'event and clk = '1' then
            if dat_strb = '1' then
                dbl_word <= dat_in & dbl_word(15 downto 8);
            end if;
        end if;
    end process;

    -- Asynchtonous comma detection. 
    comma_detection_comb : comma_detection
        port map(
            clk              => clk,
            rst              => rst,
            bit_mode         => bit_mode,
            dbl_word         => dbl_word,
            dat_strb         => dat_strb,
            comma_dtct_comb  => comma_dtct_comb,
            word_st_pos_comb => word_st_pos_comb
        );

    -- Managing first comma detection flag
    first_comma_detection : process(clk, rst)
    begin
        if rst = '1' then
            comma_first_dtct_flag <= '0';
        elsif rising_edge(clk) then
            if comma_dtct_comb = '1' then
                comma_first_dtct_flag <= '1';
            end if;
        end if;
    end process;

    data_strobe_latch : process (clk, rst)
    begin
        if (rst = '1') then
            dat_strb_reg <= '0';
        elsif rising_edge(clk) then
            dat_strb_reg <= dat_strb;
        end if;
    end process data_strobe_latch;


    -- Slicing dbl_word and assigning outputs
    word_st_pos_int <= to_integer(unsigned(word_st_pos_comb));

    dbl_word_slicing : process (bit_mode, dbl_word, word_st_pos_int)
    begin
        case (bit_mode) is
            when set_12b_word =>

                case (word_st_pos_int) is
                    when 15 downto 11 =>
                        word_i <= dbl_word(word_st_pos_int downto
                                           word_st_pos_int - 11);
                        word_strb_i <= '1';
                    when others =>
                        word_i <= x"000";
                        word_strb_i <= '0';
                end case;

            when set_10b_word =>

                case (word_st_pos_int) is
                    when 15 downto 11 =>
                        word_i <= "00" & dbl_word(word_st_pos_int downto
                                                  word_st_pos_int - 9);
                        word_strb_i <= '1';
                    when others =>
                        word_i <= x"000";
                        word_strb_i <= '0';
                end case;

            when set_8b_word | "00" => -- 8b word is the default

                case (word_st_pos_int) is
                    when 15 downto 8 =>
                        word_i <= x"0" & dbl_word(word_st_pos_int downto
                                                  word_st_pos_int - 7);
                        word_strb_i <= '1';
                    when others =>
                        word_i <= x"000";
                        word_strb_i <= '0';
                end case;

            when others =>
                word_i <= x"000";
                word_strb_i <= '0';

        end case;
    end process dbl_word_slicing;

    output_assignment : process (clk, rst)
    begin
        if (rst = '1') then
            word      <= x"000";
            word_strb <= '0';
        elsif rising_edge(clk) then
            if (dat_strb_reg = '1') then
                if comma_dtct_comb = '1' then
                    word      <= x"000";
                    word_strb <= '0';
                else
                    word      <= word_i;
                    word_strb <= word_strb_i;
                end if;
            else
                word      <= x"000";
                word_strb <= '0';
            end if;
        end if;
    end process output_assignment;

end RTL;
