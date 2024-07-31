----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.07.2024 15:14:47
-- Design Name: 
-- Module Name: 6502_alu - Behavioral
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
use IEEE.numeric_std.all;
library lib_6502;
use lib_6502.pkg_6502.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_6502 is
    Port ( 
        reg_a : in unsigned (7 downto 0);
        reg_b : in unsigned (7 downto 0);
        c_in : in std_logic; -- carry_in = borrow_in_n
        z_in : in std_logic;
        n_in : in std_logic;
        v_in : in std_logic;
        op : in alu_operation;
        reg_out : out unsigned (7 downto 0);
        c_out : out STD_LOGIC;
        z_out : out std_logic;
        n_out : out std_logic;
        v_out : out std_logic
   );
end alu_6502;

architecture Behavioral of alu_6502 is

signal reg_out_ext : unsigned (8 downto 0) := (others => '0');

-- -----------------------------------------------------------------
--  Format      :   NV-BDIZC
--              :
--  Explanation :   N = negativity flag
--              :   V = signed overflow flag
--              :   - = always set
--              :   B = break command
--              :   D = decimal mode
--              :   I = interrupt DISABLE
--              :   Z = zero flag
--              :   C = carry flag
-- -----------------------------------------------------------------
signal affected_flags: std_logic_vector (7 downto 0) := (others => '0');

begin

operation: process (reg_a, reg_b, c_in) begin
    reg_out_ext <= (others => '0');
    
    case op is
    -- TODO: the results of ADC and SBC depend on D (decimal) flag
    -- Group I
    when ADC =>
        reg_out_ext <= reg_a + reg_b + (X"00" & c_in);
        affected_flags <= X"E3";
    when ADD =>
        reg_out_ext <= resize(reg_a, 9) + resize(reg_b, 9);
        affected_flags <= X"21";
    when AND_OP =>
        reg_out_ext (7 downto 0) <= reg_a and reg_b;
        affected_flags <= X"A2";
    when CMP =>
        reg_out_ext <= resize(reg_a, 9) + resize(not(reg_b), 9) + X"01";
        affected_flags <= X"A3";
    when EOR =>
        reg_out_ext (7 downto 0) <= reg_a xor reg_b;
        affected_flags <= X"A2";  
    when LDA | LDX =>
        reg_out_ext (7 downto 0) <= reg_b;
        affected_flags <= X"A2";
    when ORA =>
        reg_out_ext (7 downto 0) <= reg_a or reg_b;
        affected_flags <= X"A2";
    when SBC =>
        reg_out_ext <= resize(reg_a, 9) + resize(not(reg_b), 9) + (X"00" & c_in);
        affected_flags <= X"E3";    
    -- Group IIa    
    when ASL =>
        reg_out_ext (8 downto 1) <= reg_a;       
        affected_flags <= X"A3";  
    when LSR =>
        reg_out_ext (6 downto 0) <= reg_a (7 downto 1);
        reg_out_ext(8) <= reg_a(0);       
        affected_flags <= X"A3";  
    when ROL_OP =>
        reg_out_ext (8 downto 1) <= reg_a;
        reg_out_ext(0) <= c_in;       
        affected_flags <= X"A3";  
    when ROR_OP =>
        reg_out_ext (6 downto 0) <= reg_a (7 downto 1);
        reg_out_ext(7) <= c_in;
        reg_out_ext(8) <= reg_a(0);       
        affected_flags <= X"A3";  
    -- Group IIb
    when DEC =>
        reg_out_ext <= resize(reg_a, 9) - (X"00" & '1');
        affected_flags <= X"A2";
    when INC =>
        reg_out_ext <= resize(reg_a, 9) + (X"00" & '1');
        affected_flags <= X"A2";
    -- Group III    
    when BIT_OP =>
        reg_out_ext (7 downto 0) <= reg_a and reg_b;
        affected_flags <= X"E2";    
              
    when others =>
        -- TODO: This is just a placeholder. A better error handling has to be implemented.
        affected_flags <= X"20";
    end case;
    
end process;

flag: process (reg_out_ext) begin
    
    if affected_flags(7) = '1' then
        n_out <= reg_out_ext(7);
    else
        n_out <= n_in;  
    end if;  
    
    if affected_flags(6) = '1' then
        if op = BIT_OP then
            v_out <= reg_out_ext(6);
        else
            v_out <= reg_out_ext(7) xor reg_out_ext(8);
        end if;
    else
        v_out <= v_in;
    end if;
    
    if affected_flags(1) = '1' then
        z_out <= not(or_bits(reg_out_ext (7 downto 0)));  
    else
        z_out <= z_in;
    end if;
    
    if affected_flags(0) = '1' then
        c_out <= reg_out_ext(8);    
    else
        c_out <= c_in;
    end if;  
    
--            when 4 =>
--                n_out <= reg_out_ext(7);
--            when 3 =>
--                n_out <= reg_out_ext(7);
--            when 2 =>
--                n_out <= reg_out_ext(7);    
end process;

reg_out <= reg_out_ext (7 downto 0);        
        
end Behavioral;
