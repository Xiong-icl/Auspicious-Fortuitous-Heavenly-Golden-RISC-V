#include "base_testbench.h"

#define OPCODE_ADD      0b0000
#define OPCODE_SUB      0b0001
#define OPCODE_AND      0b0010
#define OPCODE_OR       0b0011
#define OPCODE_XOR      0b0100
#define OPCODE_LSL      0b0101
#define OPCODE_LSR      0b0110
#define OPCODE_ASR      0b0111
#define OPCODE_SLT      0b1000
#define OPCODE_SLTU     0b1001
#define OPCODE_B        0b1010

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class AluTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->ALUctrl = 0;
        top->ALUop1 = 0;
        top->ALUop2 = 0;
    }
};

TEST_F(AluTestbench, AdditionTest)
{

    //Addition test to form 0xFFFFFFFF
    int add1 = 0x66666666;
    int add2 = 0x99999999;

    top->ALUctrl = OPCODE_ADD;
    top->ALUop1 = add1;
    top->ALUop2 = add2;

    top->eval();

    EXPECT_EQ(top->SUM, add1 + add2);
    EXPECT_EQ(top->EQ, (add1 + add2) == 0);
}
/*
TEST_F(AluTestbench, SubtractionTest)
{

    int sub1 = 0x99999999;
    int sub2 = 0x66666666;

    top->ALUctrl = OPCODE_SUB;
    top->ALUop1 = sub1;
    top->ALUop2 = sub2;

    top->eval();

    EXPECT_EQ(top->SUM, sub1 - sub2);
    EXPECT_EQ(top->EQ, (sub1 - sub2) == 0);
}

TEST_F(AluTestbench, AndTest)
{

    int and1 = 0x66666666;
    int and2 = 0x66666666;

    top->ALUctrl = OPCODE_AND;
    top->ALUop1 = and1;
    top->ALUop2 = and2;

    top->eval();

    EXPECT_EQ(top->SUM, and1 & and2);
    EXPECT_EQ(top->EQ, (and1 & and2) == 0);
}

TEST_F(AluTestbench, OrTest)
{

    int or1 = 0x10101010;
    int or2 = 0x01010101;

    top->ALUctrl = OPCODE_OR;
    top->ALUop1 = or1;
    top->ALUop2 = or2;

    top->eval();

    EXPECT_EQ(top->SUM, or1 | or2);
    EXPECT_EQ(top->EQ, (or1 | or2) == 0);
}

TEST_F(AluTestbench, XorTest)
{

    int xor1 = 0x10101010;
    int xor2 = 0x11111111;

    top->ALUctrl = OPCODE_XOR;
    top->ALUop1 = xor1;
    top->ALUop2 = xor2;

    top->eval();

    EXPECT_EQ(top->SUM, xor1 ^ xor2);
    EXPECT_EQ(top->EQ, (xor1 ^ xor2) == 0);
}

TEST_F(AluTestbench, LSLTest)
{

    int LSL1 = 0x10101010;
    int shift = 2;

    top->ALUctrl = OPCODE_LSL;
    top->ALUop1 = LSL1;
    top->ALUop2 = shift;

    top->eval();

    EXPECT_EQ(top->SUM, LSL1 << shift);
    EXPECT_EQ(top->EQ, (LSL1 << shift) == 0);
}

TEST_F(AluTestbench, LSRTest)
{

    int LSR1 = 0x10101010;
    int shift = 2;

    top->ALUctrl = OPCODE_LSR;
    top->ALUop1 = LSR1;
    top->ALUop2 = shift;

    top->eval();

    EXPECT_EQ(top->SUM, LSR1 >> shift);
    EXPECT_EQ(top->EQ, (LSR1 >> shift) == 0);
}

//Same operator, but ASR uses signed and LSR uses unsigned numbers
TEST_F(AluTestbench, ASRTest)
{

    int ASR1 = 0xF0101010;
    int shift = 2;

    top->ALUctrl = OPCODE_ASR;
    top->ALUop1 = ASR1;
    top->ALUop2 = shift;

    top->eval();

    EXPECT_EQ(top->SUM, ASR1 >> shift);
    EXPECT_EQ(top->EQ, (ASR1 >> shift) == 0);
}

//If Set is Less Than test
TEST_F(AluTestbench, SLTTest)
{

    int rs1 = 0x01010101;
    int rs2 = 0x10101010;

    top->ALUctrl = OPCODE_SLT;
    top->ALUop1 = rs1;
    top->ALUop2 = rs2;

    top->eval();

    EXPECT_EQ(top->SUM, (rs1 < rs2) ? 1:0);
    EXPECT_EQ(top->EQ, ((rs1 < rs2) ? 1:0) == 0);
}

TEST_F(AluTestbench, SLTUTest)
{

    int rs1 = 0xF1010101;
    int rs2 = 0xF0101010;

    top->ALUctrl = OPCODE_SLT;
    top->ALUop1 = rs1;
    top->ALUop2 = rs2;

    top->eval();

    EXPECT_EQ(top->SUM, (rs1 < rs2) ? 1:0);
    EXPECT_EQ(top->EQ, ((rs1 < rs2) ? 1:0) == 0);
}
*/

TEST_F(AluTestbench, EqualsTest)
{
    //Comparing 2 numbers by subtraction
    int sub1 = 0x66666666;
    int sub2 = 0x66666666;

    top->ALUctrl = OPCODE_SUB;
    top->ALUop1 = sub1;
    top->ALUop2 = sub2;

    top->eval();

    EXPECT_EQ(top->SUM, sub1 - sub2);
    EXPECT_EQ(top->EQ, (sub1 - sub2) == 0);
}

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
