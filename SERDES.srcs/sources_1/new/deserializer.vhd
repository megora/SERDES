--------------------------------------------------------------------------------
-- Title       : deserializer
-- Project     : GSoC-2020 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : deserializer.vhd
-- Author      : Maria Gorchichko
-- Company     : N/A
-- Platform    : Xilinx Artix-7
-- Standard    : <VHDL-2008 | VHDL-2002 | VHDL-1993 | VHDL-1987>
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.VComponents.all;

entity deserializer is
    port (
        clk          : in  STD_LOGIC;
        clk_300_ph0  : in  STD_LOGIC;
        clk_300_ph90 : in  STD_LOGIC;
        gl_rst       : in  STD_LOGIC;
        RxD_p        : in  STD_LOGIC;
        RxD_n        : in  STD_LOGIC;
        dat          : out STD_LOGIC_VECTOR(7 downto 0);
        dat_strb     : out STD_LOGIC
    );
end entity deserializer;

architecture RTL of deserializer is

    signal iserdes_ce : STD_LOGIC;
    signal gl_rst_inv : STD_LOGIC;

    signal Q : STD_LOGIC_VECTOR(7 downto 0);

    signal clk_300_ph0_inv  : STD_LOGIC;
    signal clk_300_ph90_inv : STD_LOGIC;

begin

    gl_rst_inv <= not gl_rst;

    iserdes_ce_gen : UNISIM.Vcomponents.FDSE
        generic map (INIT => '0')
        port map (
            D  => '0',
            CE => '1',
            C  => clk,
            S  => gl_rst_inv,
            Q  => iserdes_ce
        );

    clk_300_ph0_inv  <= not clk_300_ph0;
    clk_300_ph90_inv <= not clk_300_ph90;

    ISERDESE2_inst : UNISIM.Vcomponents.ISERDESE2
        generic map (
            INTERFACE_TYPE    => "MEMORY",
            DATA_RATE         => "DDR",
            DATA_WIDTH        => 8,
            OFB_USED          => "FALSE",
            NUM_CE            => 1,
            SERDES_MODE       => "MASTER",
            IOBDELAY          => "NONE",
            DYN_CLKDIV_INV_EN => "FALSE",
            DYN_CLK_INV_EN    => "FALSE",
            INIT_Q1           => '0',
            INIT_Q2           => '0',
            INIT_Q3           => '0',
            INIT_Q4           => '0',
            SRVAL_Q1          => '0',
            SRVAL_Q2          => '0',
            SRVAL_Q3          => '0',
            SRVAL_Q4          => '0'
        )
        port map (
            CLK          => clk_300_ph0,
            CLKB         => clk_300_ph0_inv,
            OCLK         => clk_300_ph90,
            OCLKB        => clk_300_ph90_inv,
            D            => RxD_p,
            BITSLIP      => '0',
            CE1          => iserdes_ce,
            CE2          => '1',
            CLKDIV       => clk,
            CLKDIVP      => '0',
            DDLY         => '0',
            DYNCLKDIVSEL => '0',
            DYNCLKSEL    => '0',
            OFB          => '0',
            RST          => gl_rst,
            SHIFTIN1     => '0',
            SHIFTIN2     => '0',
            O            => open,
            Q1           => Q(0),
            Q2           => Q(1),
            Q3           => Q(2),
            Q4           => Q(3),
            Q5           => Q(4),
            Q6           => Q(5),
            Q7           => Q(6),
            Q8           => Q(7),
            SHIFTOUT1    => open,
            SHIFTOUT2    => open
        );

    dat      <= Q;
    dat_strb <= '1';

end architecture RTL;