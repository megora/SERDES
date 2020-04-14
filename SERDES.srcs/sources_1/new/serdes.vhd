--------------------------------------------------------------------------------
-- Title       : serdes
-- Project     : GSoC-2020 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : serdes.vhd
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

library UNISIM;
use UNISIM.VComponents.all;

entity serdes is
    Port (
        GCLK      : in  STD_LOGIC;
        bit_mode  : in  STD_LOGIC_VECTOR(1 downto 0);
        RxD       : in  STD_LOGIC;
        word      : out STD_LOGIC_VECTOR(11 downto 0);
        word_strb : out STD_LOGIC
    );
end serdes;

architecture RTL of serdes is

    component clk_rst_gen is
        port (
            GCLK         : in  STD_LOGIC;
            clk_300_ph0  : out STD_LOGIC;
            clk_300_ph90 : out STD_LOGIC;
            clk_75       : out STD_LOGIC;
            gl_rst       : out STD_LOGIC
        );
    end component clk_rst_gen;

    -- clocking signals
    signal clk          : STD_LOGIC;
    signal clk_300_ph0  : STD_LOGIC;
    signal clk_300_ph90 : STD_LOGIC;
    signal gl_rst       : STD_LOGIC;

    component deserializer is
        port (
            clk          : in  STD_LOGIC;
            clk_300_ph0  : in  STD_LOGIC;
            clk_300_ph90 : in  STD_LOGIC;
            gl_rst       : in  STD_LOGIC;
            RxD          : in  STD_LOGIC;
            dat          : out STD_LOGIC_VECTOR(7 downto 0);
            dat_strb     : out STD_LOGIC
        );
    end component deserializer;

    signal dat      : STD_LOGIC_VECTOR(7 downto 0);
    signal dat_strb : STD_LOGIC;

    component data_alignment is
        port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            bit_mode  : in  STD_LOGIC_VECTOR(1 downto 0);
            dat_in    : in  STD_LOGIC_VECTOR(7 downto 0);
            dat_strb  : in  STD_LOGIC;
            word      : out STD_LOGIC_VECTOR(11 downto 0);
            word_strb : out STD_LOGIC
        );
    end component data_alignment;

    --signal word      : STD_LOGIC_VECTOR(11 downto 0);
    --signal word_strb : STD_LOGIC;


begin

    clk_rst_gen_inst : entity work.clk_rst_gen
        port map (
            GCLK         => GCLK,
            clk_300_ph0  => clk_300_ph0,
            clk_300_ph90 => clk_300_ph90,
            clk_75       => clk,
            gl_rst       => gl_rst
        );

    deserializer_inst : entity work.deserializer
        port map (
            clk          => clk,
            clk_300_ph0  => clk_300_ph0,
            clk_300_ph90 => clk_300_ph90,
            gl_rst       => gl_rst,
            RxD          => RxD,
            dat          => dat,
            dat_strb     => dat_strb
        );

    data_alignment_inst : entity work.data_alignment
        port map (
            clk       => clk,
            rst       => gl_rst,
            bit_mode  => bit_mode,
            dat_in    => dat,
            dat_strb  => dat_strb,
            word      => word,
            word_strb => word_strb
        );

end architecture RTL;