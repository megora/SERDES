--------------------------------------------------------------------------------
-- Title       : SERDES wrap
-- Project     : GSoC-2020 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : serdes_wrap.vhd
-- Author      : Maria Gorchichko
-- Company     : N/A
-- Platform    : Xilinx Artix-7
-- Standard    : <VHDL-2008 | VHDL-2002 | VHDL-1993 | VHDL-1987>
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use std.textio.all;
--use ieee.std_logic_textio.all;

library UNISIM;
use UNISIM.VComponents.all;

entity serdes_wrap is
    port (
        GCLK      : in  STD_LOGIC;
        RxD_p     : in  STD_LOGIC;
        RxD_n     : in  STD_LOGIC;
        bit_mode  : in  STD_LOGIC_VECTOR(1 downto 0);
        word      : out STD_LOGIC_VECTOR(11 downto 0);
        word_strb : out STD_LOGIC
    );
end entity serdes_wrap;

architecture RTL of serdes_wrap is

    component serdes is
        port (
            GCLK      : in  STD_LOGIC;
            bit_mode  : in  STD_LOGIC_VECTOR(1 downto 0);
            RxD       : in  STD_LOGIC;
            word      : out STD_LOGIC_VECTOR(11 downto 0);
            word_strb : out STD_LOGIC
        );
    end component serdes;

    signal RxD : STD_LOGIC;
    signal bit_mode_i : STD_LOGIC_VECTOR(1 downto 0);

begin

    IBUFDS_RxD_inst : UNISIM.VComponents.IBUFDS
    generic map (
        DIFF_TERM    => FALSE, -- Differential Termination 
        IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
        IOSTANDARD   => "DEFAULT")
    port map (
        O  => RxD,   -- Buffer output
        I  => RxD_p, -- Diff_p buffer input (connect directly to top-level port)
        IB => RxD_n  -- Diff_n buffer input (connect directly to top-level port)
    );

    IBUF_bit_mode_generate : for i in bit_mode'high downto bit_mode'low generate
        IBUF_inst : UNISIM.VComponents.IBUF
            generic map (
                IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
                IOSTANDARD   => "DEFAULT")
            port map (
                O => bit_mode_i(i), -- Buffer output
                I => bit_mode(i)  -- Buffer input (connect directly to top-level port)
            );
    end generate IBUF_bit_mode_generate;

    serdes_inst : entity work.serdes
        port map (
            GCLK      => GCLK,
            bit_mode  => bit_mode_i,
            RxD       => RxD,
            word      => word,
            word_strb => word_strb
        );        

end architecture RTL;