--------------------------------------------------------------------------------
-- Title       : data_alignment
-- Project     : GSoC-2020 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : data_alignment.vhd
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
            clk               : in  STD_LOGIC;
            rst               : in  STD_LOGIC;
            bit_mode          : in  STD_LOGIC_VECTOR(1 downto 0);
            word_sreg         : in  STD_LOGIC_VECTOR(18 downto 0);
            dat_strb          : in  STD_LOGIC;
            comma_dtct_comb   : out STD_LOGIC;
            word_end_pos_comb : out signed(3 downto 0)
        );
    end component;

    signal word_sreg : STD_LOGIC_VECTOR(18 downto 0);
    signal word_i    : STD_LOGIC_VECTOR(11 downto 0); -- internal word

    signal comma_detected       : STD_LOGIC;
    signal first_comma_detected : STD_LOGIC;
    signal full_word_in_sreg    : STD_LOGIC;

    signal word_end_pos_comb : signed(3 downto 0);
    signal word_end_pos_int  : integer range 0 to 7;

begin

    -- Making shift register to store 2+ input data values.
    words_unite : process(rst, clk)
    begin
        if rst = '1' then
            word_sreg <= (others => '0');
        elsif clk'event and clk = '1' then
            if dat_strb = '1' then
                word_sreg <= word_sreg(10 downto 0) & dat_in;
            end if;
        end if;
    end process;

    -- Combinational comma detection. 
    comma_detection_inst : comma_detection
        port map(
            clk               => clk,
            rst               => rst,
            bit_mode          => bit_mode,
            word_sreg         => word_sreg,
            dat_strb          => dat_strb,
            comma_dtct_comb   => comma_detected,
            word_end_pos_comb => word_end_pos_comb
        );

    -- Managing first comma detection flag
    first_comma_detection : process(clk, rst)
    begin
        if rst = '1' then
            first_comma_detected <= '0';
        elsif rising_edge(clk) then
            if comma_detected = '1' then
                first_comma_detected <= '1';
            end if;
        end if;
    end process;

    word_end_pos_int <=
        to_integer(unsigned(word_end_pos_comb(2 downto 0)));

    full_word_in_sreg <= not word_end_pos_comb(word_end_pos_comb'high); -- not negative


    -- Slicing word_sreg and assigning outputs

    word_sreg_slicing : process (all)
    begin
        if full_word_in_sreg = '1' then
            case (bit_mode) is
                when set_12b_word =>

                    word_i <= word_sreg(word_end_pos_int + 11 downto
                            word_end_pos_int);

                when set_10b_word =>

                    word_i <= "00" & word_sreg(word_end_pos_int + 9 downto
                            word_end_pos_int);

                when set_8b_word | "00" => -- 8b word is the default

                    word_i <= x"0" & word_sreg(word_end_pos_int + 7 downto
                            word_end_pos_int);

                when others =>
                    word_i <= x"000";

            end case;
        else
            word_i <= x"000";
        end if;
    end process word_sreg_slicing;

    output_assignment : process (clk, rst)
    begin
        if (rst = '1') then
            word      <= x"000";
            word_strb <= '0';
        elsif rising_edge(clk) then
            if (comma_detected = '0') and 
                (first_comma_detected = '1') and
                (full_word_in_sreg = '1') then
                word      <= word_i;
                word_strb <= '1';
            else
                word      <= x"000";
                word_strb <= '0';
            end if;
        end if;
    end process output_assignment;

end RTL;
