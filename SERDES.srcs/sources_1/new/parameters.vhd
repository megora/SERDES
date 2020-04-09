--------------------------------------------------------------------------------
-- Title       : parameters
-- Project     : GSoC-2020 SERDES qualification task
--------------------------------------------------------------------------------
-- File        : parameters.vhd
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

package parameters is

    constant comma_12b : STD_LOGIC_VECTOR(11 downto 0) := x"BAF";
    --alias    comma_10b : STD_LOGIC_VECTOR(9 downto 0) is comma_12b(11 downto 2);
    --alias    comma_8b  : STD_LOGIC_VECTOR(7 downto 0) is comma_12b(11 downto 4);


    constant comma_10b : STD_LOGIC_VECTOR(9 downto 0) := comma_12b(11 downto 2);
    constant comma_8b  : STD_LOGIC_VECTOR(7 downto 0) := comma_12b(11 downto 4);


    constant set_8b_word  : STD_LOGIC_VECTOR(1 downto 0) := "11"; -- default
    constant set_10b_word : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant set_12b_word : STD_LOGIC_VECTOR(1 downto 0) := "01";

end parameters;


package body parameters is


end parameters;
