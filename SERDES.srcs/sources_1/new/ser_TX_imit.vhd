--------------------------------------------------------------------------------
-- Title       : set_TX_imit
-- Project     : GSoC-2012 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : ser_TX_imit.vhd
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

entity ser_TX_imit is
    Port (
        bit_mode : in  STD_LOGIC_VECTOR(1 downto 0);
        dout_p   : out STD_LOGIC;
        dout_n   : out STD_LOGIC
    );
end ser_TX_imit;

architecture Behavioral of ser_TX_imit is

    constant test_seq : STD_LOGIC_VECTOR(7 downto 0) := x"BA"; -- test sequence

    constant dat_T   : time := 1666 ps; -- data are transmitted with 600 MHz frequency
    constant dat_phi : time := 5800 ps; -- initial data transmission phase shift

    signal clk_aux : STD_LOGIC; -- auxiliary clock;

begin

    clk_aux_gen : process
    begin
        clk_aux <= '0';
        wait for dat_phi;
        L1 : loop
            clk_aux <= '1';
            wait for dat_T / 2;
            clk_aux <= '0';
            wait for dat_T / 2;
        end loop L1;
    end process;

    dat_transmission : process(clk_aux)
        variable bit_num : integer range 15 downto 0 := 15;
        variable dout    : STD_LOGIC;
    begin
        if clk_aux'event and clk_aux = '1' then
            if bit_num = 15 then
                bit_num := 0;
            else
                bit_num := bit_num + 1;
            end if;
            -- select bit to send and assign values to the output ports
            if bit_num < 8 then
                dout := test_seq(bit_num);
            else
                dout := '0';
            end if;
            dout_p <= dout;
            dout_n <= not dout;
        end if;
    end process;

end Behavioral;
