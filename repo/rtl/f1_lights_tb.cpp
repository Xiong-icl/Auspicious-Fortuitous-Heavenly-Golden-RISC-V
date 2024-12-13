#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"
#include "../vbuddy.cpp"

#define CYCLES 1000

TEST_F(CpuTestbench, TestF1lights)
{
    setupTest("f1_lights");
    initSimulation();
    for (int i = 0; i < CYCLES; ++i)
    {
        // Mask to get 8 bits
        vbdBar(top_->a0 & 0xFF);
        std::cout<<top_->a0<<std::endl;
        runSimulation(1);
        sleep(1);
    }
}

int main(int argc, char **argv, char **env)
{
    // init Vbuddy
    if (vbdOpen() != 1)
        return (-1);
    vbdHeader("F1 Lights");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    return res;
    vbdClose();
    exit(0);
}
