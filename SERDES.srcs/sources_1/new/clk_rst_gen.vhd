--------------------------------------------------------------------------------
-- Title       : clk_rst_gen
-- Project     : GSoC-2020 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : clk_rst_gen.vhd
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

entity clk_rst_gen is
    port (
        GCLK         : in  STD_LOGIC;
        clk_300_ph0  : out STD_LOGIC;
        clk_300_ph90 : out STD_LOGIC;
        clk_75       : out STD_LOGIC;
        gl_rst       : out STD_LOGIC
    );
end entity clk_rst_gen;

architecture RTL of clk_rst_gen is

    component MMCM_300Mhz is
        port (
            -- Clock in ports
            clk_in : in STD_LOGIC;
            -- Status and control signals
            reset  : in  STD_LOGIC;
            locked : out STD_LOGIC;
            -- Clock out ports
            clk_300_ph0  : out STD_LOGIC;
            clk_300_ph90 : out STD_LOGIC;
            clk_75       : out STD_LOGIC
        );
    end component MMCM_300Mhz;

    signal clk_75_i   : STD_LOGIC; -- internal signal
    signal clk_locked : STD_LOGIC;
    signal gl_rst_inv : STD_LOGIC; -- global reset

begin

    clock_gen : MMCM_300Mhz
        port map(
            clk_300_ph0  => clk_300_ph0,
            clk_300_ph90 => clk_300_ph90,
            clk_75       => clk_75_i,
            reset        => '0',
            locked       => clk_locked,
            clk_in       => GCLK
        );

    locked_driven_rst : FDSE
        generic map (INIT => '0')
        port map (
            D  => '0',
            CE => '1',
            C  => clk_75_i,
            S  => clk_locked,
            Q  => gl_rst_inv
        );

    gl_rst <= not gl_rst_inv;
    clk_75 <= clk_75_i;

end architecture RTL;