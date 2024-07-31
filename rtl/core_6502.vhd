----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.07.2024 12:18:21
-- Design Name: 
-- Module Name: core_6502 - Behavioral
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

entity core_6502 is
    Port ( rdy : in STD_LOGIC;
           clk : in STD_LOGIC;
           res_n : in STD_LOGIC;
           sync : out STD_LOGIC;
           ab : out STD_LOGIC_VECTOR (15 downto 0);
           db : inout STD_LOGIC_VECTOR (7 downto 0);
           r_w : out STD_LOGIC;
           s_o : in STD_LOGIC); -- TODO: Set V-flag when this signal is set
end core_6502;

architecture Behavioral of core_6502 is

-- Registers
signal reg_a : std_logic_vector (7 downto 0);       -- accumulator register
signal reg_i : std_logic_vector (7 downto 0);       -- instruction register
signal reg_index_x : std_logic_vector (7 downto 0);
signal reg_index_y : std_logic_vector (7 downto 0);
signal reg_pc : unsigned (15 downto 0);  -- program counter register
-- -----------------------------------------------------------------
--  Register    :   Processor status
--              :
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
signal reg_ps : std_logic_vector (7 downto 0) := (others => '0');   

-- Helper signals
signal st : state;
signal op : alu_operation;
signal addr_mode : addressing_mode;
signal sig_r_w : std_logic;
-- TODO: better name
signal before_op : std_logic;
--signal db_internal : std_logic_vector (7 downto 0) := X"00";

component alu_6502 is
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
end component;

-- ALU signals
signal  alu_reg_a : unsigned (7 downto 0) := (others => '0');
-- TODO: Remove alu_reg_b and replace with db, if ot stays the same for new state machine
signal  alu_reg_b : unsigned (7 downto 0) := (others => '0');
signal  alu_reg_out : unsigned (7 downto 0);
signal alu_reg_ps : std_logic_vector (7 downto 0) := (others  => '0');
signal alu_op : alu_operation := OP_ERR;

component id_6502 is
    Port ( 
        instruction : in STD_LOGIC_VECTOR (7 downto 0);
        reg_idx : out std_logic;
        op : out alu_operation;    
        addr_mode: out addressing_mode;
        op_grp : out op_group
    );
end component;

signal id_reg_idx : std_logic;
signal grp : op_group;

begin

alu: component alu_6502 port map (
    reg_a => alu_reg_a,
    reg_b => alu_reg_b,
    c_in => reg_ps(0),
    z_in => reg_ps(1),
    v_in => reg_ps(6),
    n_in => reg_ps(7),
    op => alu_op,
    reg_out => alu_reg_out,
    c_out => alu_reg_ps(0),
    z_out => alu_reg_ps(1),
    v_out => alu_reg_ps(6),
    n_out => alu_reg_ps(7)
);

id : component id_6502 port map (
    instruction => reg_i,
    reg_idx => id_reg_idx,
    op => op,
    addr_mode => addr_mode,
    op_grp => grp
);

-- State machine
-- TODO: introduce wait states
process (res_n, clk) begin
    if res_n = '0' then
        st <= RESET;
        before_op <= '0';
    elsif falling_edge(clk) then
        case st is
        when RESET =>
            st <= INIT1;
        when INIT1 =>
            st <= INIT2;
        when INIT2 =>
            st <= INIT3;
        when INIT3 =>
            st <= FETCH;
        when FETCH =>
            case addr_mode is
            when IMMEDIATE | A =>
                st <= MC_DONE;
            when ZERO_PG =>
                st <= MC_INC;
                before_op <= '1';
            when IND_IDX_Y =>
                st <= MC_INC;   
            when ABSOLUTE_X | ABSOLUTE_Y =>
                st <= MC_ADD_PC;
            when IDX_IND_X | ZERO_PG_INDEXED =>
                st <= MC_ADD_ALU;
            when ABSOLUTE =>
                st <= MC_LD_PC;
            when others =>
                st <= ST_ERR;
            end case;
        when MC_DONE =>
            st <= FETCH;
        when MC_INC =>
            case addr_mode is
            when ZERO_PG =>
                if grp = GROUP2 and op /= LDX and op /= STX then
                    st <= MC_OP_MEM;
                else
                    st <= MC_DONE;
                end if;                 
            when IND_IDX_Y =>
                st <= MC_ADD_ALU;
            when others =>
                st <= ST_ERR;    
            end case;        
        when MC_ADD_ALU =>
            case addr_mode is
            when IND_IDX_Y =>
                st <= MC_INC_ABS;
                if alu_reg_ps(0) = '0' then
                    before_op <= '1';
                end if;    
            when ZERO_PG_INDEXED =>
                st <= MC_INC_ALU;
                before_op <= '1';
            when IDX_IND_X =>
                st <= MC_INC_ALU;
            when others =>
                st <= ST_ERR;
            end case;
        when MC_INC_ALU =>
            case addr_mode is
            when IDX_IND_X =>
                st <= MC_LD_ALU;
            when ZERO_PG_INDEXED =>
                if grp = GROUP2 and op /= LDX and op /= STX then
                    st <= MC_OP_MEM;
                else
                    st <= MC_DONE;
                end if;
            when others =>
                st <= ST_ERR;
            end case;    
        when MC_LD_PC =>
            -- TODO: Implement in new state machine
            if op = JMP then
                if grp = GROUP2 and op /= LDX and op /= STX then
                    st <= MC_OP_MEM;
                else
                    st <= MC_DONE;
                end if;
            else
                st <= MC_INC_ABS;
                before_op <= '1';
            end if;
            
        when MC_LD_ALU =>
            st <= MC_INC_ABS; 
            before_op <= '1';   
        when MC_ADD_PC =>
            st <= MC_INC_ABS;
            if alu_reg_ps(0) = '0' then
                before_op <= '1';
            end if; 
        when MC_INC_ABS =>
            case addr_mode is
            when IND_IDX_Y | ABSOLUTE_X | ABSOLUTE_Y =>
                if before_op = '0' then
                    st <= MC_NOP_ABS;
                    before_op <= '1';
                else    
                    if grp = GROUP2 and op /= LDX and op /= STX then
                        st <= MC_OP_MEM;
                    else
                        st <= MC_DONE;
                    end if;
                end if;    
            when ABSOLUTE | IDX_IND_X =>
                if grp = GROUP2 and op /= LDX and op /= STX then
                    st <= MC_OP_MEM;
                else
                    st <= MC_DONE;
                end if;      
            when others =>
                st <= ST_ERR;
            end case;
        when MC_NOP_ABS =>
            if grp = GROUP2 and op /= LDX and op /= STX then
                    st <= MC_OP_MEM;
                else
                    st <= MC_DONE;
                end if;   
        when MC_OP_MEM =>
            st <= MC_NOP;
        when MC_NOP =>
            st <= MC_DONE;    
        when others =>
            -- TODO: 
            st <= RESET;
        end case;
        
        if before_op = '1' then
            before_op <= '0';
        end if;
    end if;
end process;

-- Read/Not Write signal
process (res_n, clk) begin
    if res_n = '0' then
        sig_r_w <= '1';
    elsif rising_edge(clk) then    
        if before_op = '1' and (op = STA or op = STX) then
            sig_r_w <= '0';
        else
            sig_r_w <= '1';
        end if;
    end if;
end process;

r_w <= sig_r_w;

-- Data bus
process (res_n, clk) begin
    if res_n = '0' then
        db <= (others => 'Z');
    elsif falling_edge(clk) then
        if sig_r_w = '0' then
            if op = STA then
                db <= reg_a;
            elsif op = STX then
                db <= reg_index_x;
            end if;    
        else
            db <= (others => 'Z');     
        end if;
    end if;    
end process;

-- Instruction register
process (res_n, clk)
begin
    if res_n = '0' then
        reg_i <= (others => '0');
    elsif rising_edge(clk) then
        if st = FETCH then
            reg_i <= db;
        end if;
    end if;
end process;

-- ALU input
process (res_n, clk)
begin
    if res_n = '0' then
        alu_op <= OP_ERR;
        alu_reg_a <= (others => '0');
        alu_reg_b <= (others => '0');
    elsif rising_edge(clk) then
        case st is
        when MC_ADD_ALU | MC_ADD_PC =>
            alu_op <= ADD;
            if id_reg_idx = '0' then
                alu_reg_a <= unsigned(reg_index_x);
            else
                alu_reg_a <= unsigned(reg_index_y);
            end if;
            alu_reg_b <= unsigned(db);
        when MC_INC | MC_INC_ABS =>
            alu_op <= INC;
            alu_reg_a <= unsigned(db);
        when MC_INC_ALU =>
            alu_op <= INC;
            alu_reg_a <= alu_reg_out;
        when INIT1 | INIT2 | MC_LD_PC | MC_LD_ALU =>
            alu_op <= LDA;
            alu_reg_b <= unsigned(db);
        when MC_DONE =>
            alu_op <= op;
            alu_reg_a <= unsigned(reg_a);
            alu_reg_b <= unsigned(db);
        when MC_OP_MEM =>
            alu_op <= op;
            alu_reg_a <= unsigned(db);    
        when others =>
            alu_op <= NOP;    
        end case;
    end if;
end process;

-- Registers: a - accumulator; x,y - index registers; ps - processor status 
process (clk, res_n) begin

    if res_n = '0' then
        -- TODO: mask interrupt flag is set; load program counter from FFFC (low-order address byte) and FFFD (high-order address byte)
        reg_index_x <= X"F3";
        reg_index_y <= (others => '0');
        reg_a <= X"23";
        reg_ps <= (others => '0');
    elsif falling_edge(clk) then
        if st = MC_DONE then
            -- TODO: attribute alu_reg_out to reg_x or reg_y depending on reg_i
            case op is
            when OP_ERR | JMP | NOP | STA | STX | ASL | LSR => -- Do nothing
            when LDX => reg_index_x <= std_logic_vector(alu_reg_out);
            when others => reg_a <= std_logic_vector(alu_reg_out);
            end case;
            reg_ps <= alu_reg_ps;
        elsif st = MC_OP_MEM then
            reg_ps <= alu_reg_ps;
        end if;
            
    end if;

end process;

-- program counter
process (res_n, clk) begin
    if res_n = '0' then
        reg_pc <= (others => '0');
    else
        if falling_edge(clk) then
            case st is
            when INIT1 =>
                 reg_pc (7 downto 0) <= unsigned(alu_reg_out);
            when INIT2 =>
                 reg_pc (15 downto 8) <= unsigned(alu_reg_out);
            when INIT3 | FETCH | MC_LD_PC | MC_ADD_PC =>
                reg_pc <= reg_pc + X"0001";
            when MC_DONE =>
                 if addr_mode /= A then
                    reg_pc <= reg_pc + X"0001";
                end if;   
            when others =>  -- do nothing    
            end case;
            
            -- TODO: make a new state machine to integrate instructions from every group
            if op = JMP then
                if st = MC_LD_PC then
                    reg_pc (7 downto 0) <= unsigned(alu_reg_out);
                elsif st = MC_DONE then
                    reg_pc (15 downto 8) <= unsigned(db);
                end if;    
            end if;
            
        end if;
    end if;
end process;

-- address bus
process (res_n, clk) begin
    if res_n = '0' then
        ab <= (others => '0');
    elsif rising_edge(clk) then
        case st is
        when RESET =>
            ab <= X"FFFC";
        when INIT1 =>
            ab <= X"FFFD";
        when INIT3 | FETCH | MC_LD_PC | MC_ADD_PC =>
            ab <= std_logic_vector(reg_pc);
        when MC_DONE =>
            if op = JMP then
                ab <= db & std_logic_vector(reg_pc (7 downto 0));
            else
                ab <= std_logic_vector(reg_pc);
            end if;        
        when MC_INC =>
            ab <= (X"00" & db);
        when MC_ADD_ALU | MC_INC_ALU | MC_LD_ALU =>
            ab <= (X"00" & std_logic_vector(alu_reg_out));
        when MC_INC_ABS =>
            ab <= (db & std_logic_vector(alu_reg_out));
        when MC_NOP_ABS =>
            ab (15 downto 8) <= std_logic_vector(alu_reg_out);
        when others =>
            -- TODO: Do nothing?
        end case;
    end if;

end process;

-- sync signal
process (res_n, clk) begin
    if res_n = '0' then
        sync <= '0';
    elsif rising_edge(clk) then
        if st = INIT3 or st = MC_DONE then
            sync <= '1';
        else
            sync <= '0'; 
        end if;
    end if;
end process;

end Behavioral;
