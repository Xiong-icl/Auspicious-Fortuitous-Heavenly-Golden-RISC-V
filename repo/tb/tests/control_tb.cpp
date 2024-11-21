#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ControlTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instruction = 32'b0;
    }
};

TEST_F(ControlTestbench, ALUControlTest)
{
    //Addition Test
    top->instruction = 0b000'0011;
    top->eval();

    EXPECT_EQ(top->ALUctrl, 0) << "Control Addition Test";

    //BEQ Test
    top->instruction = 0b110'0011;
    top->eval();

    EXPECT_EQ(top->ALUctrl, 1) << "Control BEQ Test";

    //More tests required in the future
}

TEST_F(ControlTestbench, RegWriteTest)
{
    //Addition Test
    top->instruction = 0b000'0011;
    top->eval();

    EXPECT_EQ(top->RegWrite, 1);
}

TEST_F(ControlTestbench, ImmSrcTest)
{
    //BEQ Test
    top->instruction = 0b110'0011;
    top->eval();

    EXPECT_EQ(top->IMMsrc, 2);
}

TEST_F(ControlTestbench, ALUsrcTest)
{
    //Addition Test
    top->instruction = 0b000'0011;
    top->eval();

    EXPECT_EQ(top->ALUSrc, 1);
}

TEST_F(ControlTestbench, MemWriteTest)
{
    //Addition Test
    top->instruction = 0b000'0011;
    top->eval();

    EXPECT_EQ(top->MemWrite, 0);
}

TEST_F(ControlTestbench, ResultsrcTest)
{
    //Addition Test
    top->instruction = 0b000'0011;
    top->eval();

    EXPECT_EQ(top->Resultsrc, 1);
}

TEST_F(ControlTestbench, BranchTest)
{
    //BEQ Test
    top->instruction = 0b110'0011;
    top->eval();

    EXPECT_EQ(top->Branch, 1);
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
