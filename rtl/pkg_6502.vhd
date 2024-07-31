library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

package pkg_6502 is

type alu_operation is (
    OP_ERR,
    -- Group I
    ADC,
    ADD,
    AND_OP,
    CMP,
    EOR,
    LDA,
    ORA,
    SBC,
    STA,
    -- Group IIa
    ASL,
    LSR,
    ROL_OP,
    ROR_OP,
    -- Group IIb
    DEC,
    INC,
    LDX,
    STX,
    -- Group III
    BIT_OP,
    TXA,
    TXS,
    TSX,
    TAX,
    DEX,
    JMP,
    NOP
);

type addressing_mode is (
    ADDR_ERR,
    A,
    REL,
    IMMEDIATE,
    ABSOLUTE,
    IMPLIED,
    ZERO_PG,
    INDIRECT,
    ABSOLUTE_X,
    ABSOLUTE_Y,
    ZERO_PG_INDEXED,
    IDX_IND_X,
    IND_IDX_Y
);

type op_group is (
    GROUP_ERR,
    GROUP1,
    GROUP2,
    GROUP3
);

type state is (
    ST_ERR,
    RESET,
    INIT1,
    INIT2,
    INIT3,
    FETCH,
    MC_DONE,
    MC_INC,
    MC_INC_ALU,
    MC_INC_ABS,
    MC_NOP_ABS,
    MC_ADD_ALU,
    MC_ADD_PC,
    MC_LD_ALU,
    MC_LD_PC,
    MC_OP_MEM,
    MC_NOP
);

--type mc_state is (
--    MC_ERR,
--    MC_START,
--    MC_OP,
--    MC_NOP,
--    MC_INC,
--    MC_LD,
--    MC_ADD
--);

type alu_operation_array is array (natural range <>) of alu_operation;

-- -----------------------------------------------------------------

--  Note    :   UNRESOLVED_SIGNED type and or_bits function is taken
--          :   from numeric_std package. I reproduced it, because
--          :   there was a compatibility issue with Vivado 2008 with
--          :   the original function from the package.

-- ------------------------------------------------------------------

function or_bits (L : UNSIGNED) return STD_ULOGIC;

end pkg_6502;

package body pkg_6502 is

function or_bits (L : UNSIGNED) return STD_ULOGIC is
        variable result : std_logic := '0';
    begin
        for i in L'range loop
            result := result or L(i);
        end loop;
        return result;
    end function;

end pkg_6502;