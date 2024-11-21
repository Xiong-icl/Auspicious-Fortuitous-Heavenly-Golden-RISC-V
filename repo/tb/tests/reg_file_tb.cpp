#include "testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class RegfileTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->AD1 = 0;
        top->AD2 = 0;
        top->AD3 = 0;
        top->WE3 = 0;
        top->WD3 = 0;

        //clock is always on
        top->clk = 1;
    }
};

/*Do we need to check 0 register for lab?
//Checking the hardwired 0 register
TEST_F(RegfileTestbench, CheckZeroRegister)
{

    int number = 0x66666666;

    //Should AD3 be 1 or 0 to write to 0 address?
    top->WE3 = 1;
    top->WD3 = number;
    top->AD3 = 0;

    runSimulation(1);

    top->AD1 = 0;
    top->AD2 = 0;

    EXPECT_EQ(top->AD1, 0);
    EXPECT_EQ(top->AD2, 0);
}
*/

//Checking Registers
TEST_F(RegfileTestbench, CheckAllRegisters)
{
    int number = 0x66666666;
    top->WE3 = 1;
    top->WD3 = number;

    //Checking registers from 1 to 31, register 0 is hardwired 0
    for(int i = 1; i < 32; i++){

        //Assigning AD3 to i to change write address
        top->AD3 = i;
        runSimulation(1);

        //Assigning AD1/AD2 to i to change read address
        top->AD1 = i;
        top->AD2 = i;
        runSimulation(1);

        EXPECT_EQ(top->RD1, number);
        EXPECT_EQ(top->RD2, number);
    }
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
