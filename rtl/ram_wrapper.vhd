----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/26/2024 08:44:33 AM
-- Design Name: 
-- Module Name: ram_wrapper - Behavioral
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

entity ram_wrapper is
  Port ( 
      clk  : in std_logic;
      r_w  : in std_logic;    
      addr : in std_logic_vector(15 downto 0);  
      data : inout std_logic_vector(7 downto 0)          
        );
end ram_wrapper;

architecture Behavioral of ram_wrapper is

signal w_read_addr, w_write_addr    : std_logic_vector(15 downto 0);
signal w_write_value, w_read_value  : std_logic_vector(7 downto 0);
signal w_we                         : std_logic;


component RAM is
   port(
        clk         : in std_logic;
        read_addr   : in std_logic_vector(15 downto 0);
        write_addr  : in std_logic_vector(15 downto 0);
        we          : in std_logic;
        write_value : in std_logic_vector(7 downto 0);
        read_value  : out std_logic_vector(7 downto 0)
        );
end component;

begin

RAM_inst : RAM
port map(
      clk         => clk,
      read_addr   => w_read_addr,
      write_addr  => w_write_addr,
      we          => w_we,
      write_value => w_write_value,
      read_value  => w_read_value
        );

w_we <= not r_w;
w_write_addr  <= addr;
w_read_addr   <= addr;
w_write_value <= data;

--process (addr) begin
--    if r_w = '0' then
--        w_write_addr  <= addr;
--    else
--        w_read_addr   <= addr;
--    end if;
--end process;

process (clk) begin
    if falling_edge(clk) then
        if r_w = '1' then
            data  <= w_read_value;
        else
            data <= (others => 'Z');    
        end if;
    end if;
end process;



end Behavioral;
