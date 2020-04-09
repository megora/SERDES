--------------------------------------------------------------------------------
-- Title       : serdes_TB
-- Project     : GSoC-2012 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : serdes_TB.vhd
-- Author      : Maria Gorchichko
-- Company     : N/A
-- Platform    : Xilinx Artix-7
-- Standard    : <VHDL-2008 | VHDL-2002 | VHDL-1993 | VHDL-1987>
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serdes_TB is
--  Port ( );
end serdes_TB;

architecture Behavioral of serdes_TB is

    component serdes is
        Port (
            GCLK     : in STD_LOGIC;
            bit_mode : in STD_LOGIC_VECTOR(1 downto 0);
            RxD_p    : in STD_LOGIC;
            RxD_n    : in STD_LOGIC
        );
    end component;

    constant GCLK_T : time := 10 ns;
    signal GCLK     : STD_LOGIC;

    component ser_TX_imit is
        Port (
            dout_p   : out STD_LOGIC;
            dout_n   : out STD_LOGIC;
            bit_mode : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    signal dat_p, dat_n : STD_LOGIC;
    signal bit_mode : STD_LOGIC_VECTOR(1 downto 0);


begin

    GCLK_gen : process
    begin
        L1 : loop
            GCLK <= '1';
            wait for GCLK_T / 2;
            GCLK <= '0';
            wait for GCLK_T / 2;
        end loop L1;
    end process;

    ser_TX_imit_inst : ser_TX_imit
        port map(
            bit_mode => bit_mode,
            dout_p   => dat_p,
            dout_n   => dat_n
        );

    UUT : serdes
        port map (
            GCLK     => GCLK,
            bit_mode => bit_mode,
            RxD_p    => dat_p,
            RxD_n    => dat_n
        );

end Behavioral;
