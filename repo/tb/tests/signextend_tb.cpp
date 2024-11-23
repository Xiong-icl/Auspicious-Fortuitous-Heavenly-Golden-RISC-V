#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class SignExtendTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instr = 0;
        top->IMMsrc = 0;
    }
};

//I-type Instructions
TEST_F(SignExtendTestbench, PositiveITypeTestbenchImmSrcZero)
{
    int load_imm = 0x212; //12 bit number that we expect to load 
    int numbers = 0xFFFFF; //20 bit number part of the rest of the instruction

    int instruction = (load_imm << 20) + numbers;

    top->instr = instruction;
    top->IMMsrc = 0;

    top->eval();

    EXPECT_EQ(top->ImmOp, load_imm);
}

TEST_F(SignExtendTestbench, NegativeITypeTestbenchImmSrcZero)
{
    int load_imm = 0xFFFE; //12 bit number that we expect to load
    int numbers = 0xFFFFF; 

    int instruction = (load_imm << 20) + numbers;

    top->instr = instruction;
    top->IMMsrc = 0;

    top->eval();

    int check = (load_imm & 0x800) ? (load_imm | 0xFFFFF000) : load_imm; 
    //If load_imm is negative (checking the highest bit), load_imm is sign extended by 1 (0xFFFFF000), else return load_imm

    EXPECT_EQ(top->ImmOp, check);
}

//Do we need this??
/*
TEST_F(SignExtendTestbench, PositiveSTypeTestbenchImmSrcZero)
{
    int store_imm_7 = 7'b0101010; //Imm[11:5]
    int numbers = 13'b1; //rs2, rs1, funct
    int store_imm_5 = 5'b10101
    int opcode = 7'b1;

    int instruction = (store_imm_7 << 25) + (numbers << 12) + (store_imm_5 << 7) + opcode;

    top->instr = instruction;
    top->IMMsrc = 1;

    top->eval();

    EXPECT_EQ(top->ImmOp, (store_imm_7 << 5) + store_imm_5);
}
*/

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
