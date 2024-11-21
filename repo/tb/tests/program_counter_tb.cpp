#include "testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class PCTestBench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->ImmOp = 0;
        top->PC = 0;
        //Unsure if I have to do this? PC is an output
        top->clk = 1;
        top->rst = 0;
        top->PCsrc = 0;
    }
};

//Tests need to be: when PC is initially 0, when PCsrc = 0, when PCsrc = 1, when reset = 1

//When there is no input
TEST_F(PCTestBench, InitialState)
{
    EXPECT_EQ(top->PC, 0x0000);
}

//Testing this is a bit difficult, will come back to this later
/*//When PCsrc is Off
TEST_F(PCTestBench, PCsrcOff)
{

    //Addition test to form 0xFFFFFFFF
    int add1 = 0x66666666;

    top->PCsrc = 0;
    top->ImmOp = add1;
    
    runSimulation(1);
    

    //PCsrc is off, expect inc_PC = PC + 4
    EXPECT_EQ(top->PC, PC + 4);
}

//When PCsrc is On
TEST_F(PCTestBench, PCsrcOn)
{

    //Addition test to form 0xFFFFFFFF
    int add1 = 0x66666666;

    top->PCsrc = 1;
    top->ImmOp = add1;

    runSimulation(1);

    //PCsrc is on, expect branch_PC = PC + ImmOp
    EXPECT_EQ(top->PC, PC + ImmOp);
}
*/

//Resetting
TEST_F(PCTestBench, ResetPC)
{

    int add1 = 0x66666666;

    top->PCsrc = 1;
    top->ImmOp = add1;

    runSimulation(5);

    top->rst = 1;

    runSimulation(1);

    EXPECT_EQ(top->PC, 0);
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
