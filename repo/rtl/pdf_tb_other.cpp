#include <cstdlib>
#include <utility>
#include <vector>
#include <iostream>

#include "cpu_testbench.h"
#include "../vbuddy.cpp"


TEST_F(CpuTestbench, Testpdf)
{
    setupTest("5_pdf");
    setData("reference/gaussian.mem");
    initSimulation();
    std::vector<int> data; // array storing the waveform to be later displayed on vbuddy
    bool distribution_complete = false;
    for (int i = 0; i < 1000000; i++) {
        runSimulation(1);
        if (distribution_complete == false && top_->a0!= 0 ) {
                distribution_complete = true;
        } 
        else if (distribution_complete == true && 
                (data.empty() || top_->a0 != data.back())) {
            // Collect a0 values for plotting
            data.push_back(top_->a0);
        }
        // Stop simulation if data is collected
        if (data.size() >= 1024) {
            std::cout<<data.size()<<std::endl;
            break;
        }
    }
    for (int i = 0; i<data.size(); i++) {
        vbdPlot(data[i], 0, 255); // Plot on Vbuddy
        std::cout << data[i] << std::endl;
    }
}

int main(int argc, char** argv, char** env)
{
    // Initialize Vbuddy
    if (vbdOpen() != 1) {
        return(-1);
    }
    vbdHeader("pdf_plots");
    
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
    
    vbdClose();
    exit(0);
}
