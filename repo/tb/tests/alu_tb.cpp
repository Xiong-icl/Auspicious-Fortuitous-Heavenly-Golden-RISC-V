/*
 *  Verifies the results of the mux, exits with a 0 on success.
 */

#include "base_testbench.h"

#define OPCODE_ADD 0b0000
#define OPCODE_SUB 0b0001

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
    EXPECT_EQ(top->EQ, add1 + add2 == 0);
}

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
