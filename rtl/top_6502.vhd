----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.07.2024 09:55:49
-- Design Name: 
-- Module Name: top_6502 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_6502 is
    Port (  clk : in std_logic;
            res_n : in std_logic);
end top_6502;

architecture Behavioral of top_6502 is

component core_6502 is
    Port ( rdy : in STD_LOGIC;
           clk : in STD_LOGIC;
           res_n : in STD_LOGIC;
           sync : out STD_LOGIC;
           ab : out STD_LOGIC_VECTOR (15 downto 0);
           db : inout STD_LOGIC_VECTOR (7 downto 0);
           r_w : out STD_LOGIC;
           s_o : in STD_LOGIC); -- TODO: Set V-flag when this signal is set
end component;

component ram_wrapper is
  Port ( 
      clk  : in std_logic;
      r_w  : in std_logic;    
      addr : in std_logic_vector(15 downto 0);  
      data : inout std_logic_vector(7 downto 0)          
        );
end component;

signal r_w : std_logic;
signal db : std_logic_vector (7 downto 0);
signal ab : STD_LOGIC_VECTOR (15 downto 0);
signal sync : STD_LOGIC;

begin

core: core_6502 port map (
    rdy => '1',
    clk => clk,
    res_n => res_n,
    sync => sync,
    ab  => ab ,
    db  => db ,
    r_w => r_w,
    s_o => '1'
);

ram: ram_wrapper port map (
    clk => clk,
    r_w => r_w,
    addr => ab,
    data => db
);

end Behavioral;
