----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.07.2024 09:32:41
-- Design Name: 
-- Module Name: id_6502 - Behavioral
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity id_6502 is
    Port ( 
        instruction : in STD_LOGIC_VECTOR (7 downto 0);
        -- 0 = Indexed register X
        -- 1 = Indexed register Y
        reg_idx : out std_logic;
        op : out alu_operation;    
        addr_mode : out addressing_mode;
        op_grp : out op_group
    );
end id_6502;

architecture Behavioral of id_6502 is

-- Group masks
constant group_mask : std_logic_vector (7 downto 0)         := "00000011";
constant g1_mask : std_logic_vector (7 downto 0)            := "00000001";
constant g2_mask : std_logic_vector (7 downto 0)            := "00000010";
constant g3_mask : std_logic_vector (7 downto 0)            := "00000000";

-- Operation masks
constant operation_mask : std_logic_vector (7 downto 0)     := "11100000";
-- Group I
constant op_mask_0 : std_logic_vector (7 downto 0)           := "00000000";
constant op_mask_1 : std_logic_vector (7 downto 0)           := "00100000";
constant op_mask_2 : std_logic_vector (7 downto 0)           := "01000000";
constant op_mask_3 : std_logic_vector (7 downto 0)           := "01100000";
constant op_mask_4 : std_logic_vector (7 downto 0)           := "10000000";
constant op_mask_5 : std_logic_vector (7 downto 0)           := "10100000";
constant op_mask_6 : std_logic_vector (7 downto 0)           := "11000000";
constant op_mask_7 : std_logic_vector (7 downto 0)           := "11100000";

-- Group III
-- TODO: if $4C then JMP, abs
--      if $50 then BVC, rel
--      if $58 then CLI, implied
--      if $48 then PHA, implied
--      if $40 then RTI, implied
constant jmp_mask : std_logic_vector (7 downto 0)           := "01000000";
-- TODO: if $90 then BCC, rel
--      if $88 then DEY, implied
--      if $84, $94, $8C then STY, 0pg, 0pg_idx, abs
--      if $98 then TYA, implied
constant bcc_mask : std_logic_vector (7 downto 0)           := "10000000";
-- TODO: if $B0 then BCS, rel
--      if $B8 then CLV, implied
--      if $A0, $A4, $B4, $AC, $BC then LDY, imm, 0pg, 0pg_idx, abs, abs_idx
--      if $A8 then TAY, implied
constant bcs_mask : std_logic_vector (7 downto 0)           := "10100000";
-- TODO: if $F0 then BEQ, rel
--      if $E0, $E4, $EC then CPX imm, 0pg, abs
--      if $E8 then INX, implied
--      if $F8 then SED, implied 
constant beq_mask : std_logic_vector (7 downto 0)           := "11100000";
-- TODO: if $24, $2C then BIT 0pg, abs
--      if $30 then BMI, rel
--      if $20 then JSR, abs
--      if $28 then PLP, implied
--      if $38 then SEC, implied
constant bit_mask : std_logic_vector (7 downto 0)           := "00100000";
-- TODO: if $D0 then BNE, rel
--      if $D8 then CLD, implied        
--      if $C0, $C4, $CC then CPY, imm, 0pg, abs
--      if $C8 then INY, implied
constant bne_mask : std_logic_vector (7 downto 0)           := "11000000";
-- TODO: if $10 then BPL, rel
--      if $00 then BRK, implied
--      if $18 then CLC, implied
--      if $08 then PHP, implied
constant bpl_mask : std_logic_vector (7 downto 0)           := "00000000";
-- TODO: if $10 then BVS, rel
--      if $6C then JMP, ind        
--      if $68 then PLA, implied
--      if $60 then RTS, implied
--      if $78 then SEI, implied
constant bvs_mask : std_logic_vector (7 downto 0)           := "01100000";

-- Addressing masks
-- Group I
constant addressing_mask : std_logic_vector (7 downto 0)    := "00011100";
constant addr_mask_0 : std_logic_vector (7 downto 0)        := "00000000";  -- indexed indirect
constant addr_mask_1 : std_logic_vector (7 downto 0)        := "00000100";
constant addr_mask_2 : std_logic_vector (7 downto 0)        := "00001000";
constant addr_mask_3 : std_logic_vector (7 downto 0)        := "00001100";
constant addr_mask_4 : std_logic_vector (7 downto 0)        := "00010000";  -- indirect indexed
constant addr_mask_5 : std_logic_vector (7 downto 0)        := "00010100";
constant addr_mask_6 : std_logic_vector (7 downto 0)        := "00011000";
constant addr_mask_7 : std_logic_vector (7 downto 0)    := "00011100";

signal grp : std_logic_vector (7 downto 0)        := (others => '0');
signal operation : std_logic_vector (7 downto 0)  := (others => '0');
signal addressing : std_logic_vector (7 downto 0) := (others => '0');

begin

grp <= instruction and group_mask;
addressing <= instruction and addressing_mask;
operation <= instruction and operation_mask;

process (grp) begin
    case grp is
    when g1_mask =>
        op_grp <= GROUP1;
    when g2_mask =>
        if addressing = addr_mask_2 or addressing = addr_mask_2 then
            op_grp <= GROUP3;
        else
            op_grp <= GROUP2;
        end if;
    when g3_mask =>
        op_grp <= GROUP3;
    when others =>
        op_grp <= GROUP_ERR;
    end case;
end process;

process (addressing, grp, operation)
begin
    case addressing is
    when addr_mask_0 => 
        if grp = g1_mask then
            addr_mode <= IDX_IND_X;
        elsif grp = g2_mask then    -- There are actually some exceptions with group 2 mask. These are part of group 3.
            addr_mode <= IMMEDIATE;
        else
            -- TODO:       
        end if;
        reg_idx <= '0';
    when addr_mask_1 => addr_mode <= ZERO_PG;
    when addr_mask_2 => 
        if grp = g1_mask then
            addr_mode <= IMMEDIATE;
        elsif grp = g2_mask then
            addr_mode <= IMPLIED;
        else
            addr_mode <= ADDR_ERR;       
        end if;    
    when addr_mask_3 => addr_mode <= ABSOLUTE;
    when addr_mask_4 => 
        addr_mode <= IND_IDX_Y;
        reg_idx <= '1';
    when addr_mask_5 => 
        addr_mode <= ZERO_PG_INDEXED;
        if operation = op_mask_4 or operation = op_mask_5 then
            reg_idx <= '1';
        else
            reg_idx <= '0';       
        end if;
    when addr_mask_6 => 
        if grp = g1_mask then
            addr_mode <= ABSOLUTE_Y;
        elsif grp = g2_mask then    -- There are actually some exceptions with group 2 mask. These are part of group 3.
            addr_mode <= IMPLIED;
        else
            addr_mode <= ADDR_ERR;       
        end if;    
        reg_idx <= '1';
    when addr_mask_7 =>
        if operation = op_mask_4 or operation = op_mask_5 then
            addr_mode <= ABSOLUTE_Y;
        else
            addr_mode <= ABSOLUTE_X;       
        end if;    
        reg_idx <= '0';
    when others => addr_mode <= ADDR_ERR;
    end case;
end process;

process (grp, addressing, operation)
begin
    case operation is
    when op_mask_0 => 
        if grp = g1_mask then
            op <= ORA;
        elsif grp = g2_mask then
            op <= ASL;
        else
            -- TODO:
        end if;     
    when op_mask_1 =>
        if grp = g1_mask then
            op <= AND_OP;
        elsif grp = g2_mask then
            op <= ROL_OP;
        else
            -- TODO:
        end if;   
    when op_mask_2 =>
        if grp = g1_mask then
            op <= EOR;
        elsif grp = g2_mask then
            op <= LSR;
        else
            if instruction = X"4C" then
                op <= JMP;
            end if;
        end if;   
    when op_mask_3 => 
        if grp = g1_mask then
            op <= ADC;
        elsif grp = g2_mask then
            op <= ROR_OP;
        else
            -- TODO:
        end if;   
    when op_mask_4 => 
        if grp = g1_mask then
            op <= STA;
        elsif grp = g2_mask then
            if addressing = addr_mask_2 then
                op <= TXA;
            elsif addressing = addr_mask_6 then
                op <= TXS; 
            else
                op <= STX;
            end if;
        else
            -- TODO:
        end if;   
    when op_mask_5 =>
        if grp = g1_mask then
            op <= LDA;
        elsif grp = g2_mask then
            if addressing = addr_mask_2 then
                op <= TAX;
            elsif addressing = addr_mask_6 then
                op <= TSX; 
            else
                op <= LDX;
            end if;
        else
            -- TODO:
        end if;   
    when op_mask_6 => 
        if grp = g1_mask then
            op <= CMP;
        elsif grp = g2_mask then
            if addressing = addr_mask_2 then
                op <= DEX;            
            else
                op <= DEC;
            end if;
        else
            -- TODO:
        end if;   
    when op_mask_7 => 
        if grp = g1_mask then
            op <= SBC;
        elsif grp = g2_mask then
            if addressing = addr_mask_2 then
                op <= NOP;            
            else
                op <= INC;
            end if;
        else
            -- TODO:
        end if;   
    when others => op <= OP_ERR;
    end case;
end process;

end Behavioral;
