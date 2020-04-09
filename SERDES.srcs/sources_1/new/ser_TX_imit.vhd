--------------------------------------------------------------------------------
-- Title       : set_TX_imit
-- Project     : GSoC-2020 SERDES qualification task
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

use work.parameters.all;

entity ser_TX_imit is
    Port (
        dout_p   : out STD_LOGIC;
        dout_n   : out STD_LOGIC;
        bit_mode : out STD_LOGIC_VECTOR(1 downto 0)
    );
end ser_TX_imit;

architecture Behavioral of ser_TX_imit is

    -- Define test words array
    constant tword_arr_size : integer := 10;
    --constant tword_arr_size : integer := 3;
    type tword_arr_type is array(tword_arr_size - 1 downto 0) of STD_LOGIC_VECTOR(11 downto 0);

    constant tword_arr : tword_arr_type := 
        (
            x"BAF", -- 1011.1010.1111
            x"925", -- 1001.0010.0101
            x"AE8", -- 1010.1110.1000
            x"296", -- 0010.1001.0110
            x"000", -- 0000.0000.0000
            x"E86", -- 1110.1000.0110
            x"845", -- 1000.0100.0101
            x"47D", -- 0100.0111.1101
            x"1A9", -- 0001.1010.1001
            x"FFF"  -- 1111.1111.1111
        ); 

    --constant tword_arr : tword_arr_type := 
    --    (
    --        x"BAF", -- 1011.1010.1111
    --        x"000", -- 0000.0000.0000
    --        x"FFF"  -- 1111.1111.1111
    --        --x"CBF"  -- 1100.1011.1111
    --    );

    -- Define transmissions sequence ------------------------------------------
    -- 8b -> 10b -> 12b -> 10b ->8b -> 12b -> 8b
    type tx_type is (tx8b, tx10b, tx12b);
    constant tx_arr_size : integer := 7;
    type tx_arr_type is array(tx_arr_size - 1 downto 0) of tx_type;

    constant tx_arr : tx_arr_type := (tx8b, tx10b, tx12b, tx10b, tx8b, tx12b, tx8b);

    --constant tword_seq : STD_LOGIC_VECTOR(11 downto 0) := x"BA"; -- test sequence

    constant dat_T   : time := 1666 ps; -- data are transmitted with 600 MHz frequency
    constant dat_phi : time := 5800 ps; -- initial data transmission phase shift

    constant init_delay : time := 451 ns; -- clock manager is locked in about 430 ns

    signal dout : STD_LOGIC;


    --signal clk_aux : STD_LOGIC; -- auxiliary clock;

begin

    dat_transmission : process
        --variable tx_cnt : integer range (tx_arr_size - 1 downto 0);

        variable tx : tx_type;
        variable tword_end : integer;
        variable tword : STD_LOGIC_VECTOR(11 downto 0);

    begin
        dout <= '0';
        bit_mode  <= "00";
        wait for init_delay;

        -- Looping transmissions
        tx_loop : for tx_num in tx_arr'high downto tx_arr'low loop

            tx := tx_arr(tx_num);

            -- Define test word length
            case tx is
                when tx8b  =>
                    bit_mode <= set_8b_word;
                    tword_end := 4; -- 11 downto 4
                when tx10b =>
                    bit_mode <= set_10b_word;
                    tword_end := 2; -- 11 downto 2
                when tx12b =>
                    bit_mode <= set_12b_word;
                    tword_end := 0; -- 11 downto 0
            end case;

            -- Choosing one test word in 'tword_arr' after another.
            tword_loop : for tword_num in tword_arr'high downto tword_arr'low loop

                tword := tword_arr(tword_num);

                -- Changing bit number in the loop
                --bit_loop : for bit_num in tword_end to 11 loop
                bit_loop : for bit_num in 11 downto tword_end loop
                    dout <= tword(bit_num);
                    wait for dat_T;   
                end loop bit_loop;

            end loop tword_loop;
        
            -- imitate transmitting device switching off;
            dout <= '0';
            wait for init_delay / 2;
            bit_mode  <= "00";
            wait for init_delay / 2;

        end loop tx_loop;

    end process;    

    -- Outputs assign
    dout_p <= dout;
    dout_n <= not dout;

end Behavioral;
