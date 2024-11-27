#include "base_testbench.h"
#include <bitset>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

#define R_TYPE              0b0110011
#define I_TYPE              0b0010011
#define S_TYPE              0b0100011
#define B_TYPE              0b1100011
#define J_TYPE              0b1101111
#define IJ_TYPE             0b1100111
#define U_TYPE              0b0110111
#define LOAD_TYPE           0b0000011

#define PC_NEXT             0b000
#define PC_INV_COND_BRANCH  0b100
#define PC_COND_BRANCH      0b101

#define MEM_B               0b000
#define MEM_H               0b001
#define MEM_W               0b010
#define MEM_BU              0b011
#define MEM_HU              0b100

int opcodesReg1[] = {
    R_TYPE, 
    I_TYPE, 
    LOAD_TYPE, 
    J_TYPE, 
    IJ_TYPE, 
    U_TYPE
};

int opcodesReg0[] = {
    S_TYPE, 
    B_TYPE 
};

int opcodesAluSrc1[] = {
    S_TYPE, 
    I_TYPE, 
    LOAD_TYPE, 
    J_TYPE, 
    IJ_TYPE, 
    U_TYPE
};

int opcodesAluSrc0[] = {
    R_TYPE,
    B_TYPE 
};

int opcodesIMMSrc0[] = {
    I_TYPE,
    LOAD_TYPE,
    IJ_TYPE
};

int opcodesMemWr0[] = {
    R_TYPE, 
    I_TYPE, 
    LOAD_TYPE, 
    J_TYPE, 
    IJ_TYPE, 
    U_TYPE,
    B_TYPE
};

int opcodesResSrc0[] = {
    R_TYPE, 
    I_TYPE, 
    U_TYPE,
    S_TYPE, 
    B_TYPE
}

int opcodesPCSrcCond[] = {
    B_TYPE + (0b000 << 12),
    B_TYPE + (0b101 << 12),
    B_TYPE + (0b111 << 12)
}

int opcodesPCSrcInvCond[] = {
    B_TYPE + (0b001 << 12),
    B_TYPE + (0b100 << 12),
    B_TYPE + (0b110 << 12)
}

class ControlTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instruction = 32'b0;
    }
};

TEST_F(ControlTestbench, RegWriteTest)
{
    for(auto opcode : opcodesReg1){

        top->instruction = S_TYPE;  //Setting RegWrite = 0
        top->eval();

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->RegWrite, 1);
    }

    for(auto opcode : opcodesReg0){

        top->instruction = R_TYPE;  //Setting RegWrite = 1
        top->eval();

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->RegWrite, 0);
    }
}

TEST_F(ControlTestbench, ALUSrcTest)
{
    for(auto opcode : opcodesAluSrc1){

        top->instruction = R_TYPE;  //Setting ALUSrc = 0
        top->eval();

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->ALUSrc, 1);
    }

    for(auto opcode : opcodesAluSrc0){

        top->instruction = S_TYPE;  //Setting ALUSrc = 1
        top->eval();

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->ALUSrc, 0);
    }
}

//Yet to fix
TEST_F(ControlTestbench, ALUControlTest)
{
    //Addition Test
    top->instruction = 0b000'0011;
    top->eval();

    EXPECT_EQ(top->ALUCtrl, 0);

    //BEQ Test
    top->instruction = 0b110'0011;
    top->eval();

    EXPECT_EQ(top->ALUCtrl, 1);

    //More tests required in the future
}

TEST_F(ControlTestbench, ImmSrcTest)
{
    //U TYPE
    top->instruction = S_TYPE;  //Setting IMMSrc = 1
    top->eval();

    top->instruction = U_TYPE;
    top->eval();

    EXPECT_EQ(top->IMMSrc, 3);

    //J TYPE
    top->instruction = S_TYPE;  //Setting IMMSrc = 1
    top->eval();

    top->instruction = J_TYPE;
    top->eval();

    EXPECT_EQ(top->IMMSrc, 4);

    //B TYPE
    top->instruction = S_TYPE;  //Setting IMMSrc = 1
    top->eval();

    top->instruction = B_TYPE;
    top->eval();

    EXPECT_EQ(top->IMMSrc, 2);

    //S TYPE
    top->instruction = I_TYPE;  //Setting IMMSrc = 0
    top->eval();

    top->instruction = S_TYPE;
    top->eval();

    EXPECT_EQ(top->IMMSrc, 1);

    //I, IJ, LOAD TYPE
    for(auto opcode : opcodesIMMSrc0){

        top->instruction = S_TYPE;  //Setting IMMSrc = 1
        top->eval();

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->IMMSrc, 0);
    }
}

TEST_F(ControlTestbench, MemCtrlTest)
{
    //Load
    top->instruction = LOAD_TYPE + (0b000 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_B);

    top->instruction = LOAD_TYPE + (0b001 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_H);

    top->instruction = LOAD_TYPE + (0b010 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_W);

    top->instruction = LOAD_TYPE + (0b100 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_BU);

    top->instruction = LOAD_TYPE + (0b101 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_HU);

    //Store
    top->instruction = S_TYPE + (0b000 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_B);

    top->instruction = S_TYPE + (0b001 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_H);

    top->instruction = S_TYPE + (0b010 << 12);
    top->eval();

    EXPECT_EQ(top->MemCtrl, MEM_W);
}

TEST_F(ControlTestbench, PCSrcTest)
{
    for(auto opcode : opcodesPCSrcCond){

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->PCSrc, PC_COND_BRANCH);
    }

    for(auto opcode : opcodesPCSrcInvCond){

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->PCSrc, PC_INV_COND_BRANCH);
    }
}

TEST_F(ControlTestbench, MemWriteTest)
{
    //Only MemWrite for store
    top->instruction = S_TYPE;
    top->eval();

    EXPECT_EQ(top->MemWrite, 1);

    //All others are 0
    for(auto opcode : opcodesMemCtrlLoad){

        top->instruction = S_TYPE;  //Setting MemWrite = 1
        top->eval();

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->MemWrite, 0);
    }
}

TEST_F(ControlTestbench, ResultSrcTest)
{
    top->instruction = LOAD_TYPE;
    top->eval();

    EXPECT_EQ(top->ResultSrc, 1);

    top->instruction = J_TYPE;
    top->eval();

    EXPECT_EQ(top->ResultSrc, 2);

    top->instruction = IJ_TYPE;
    top->eval();

    EXPECT_EQ(top->ResultSrc, 2);

    for(auto opcode : opcodesResSrc0){

        top->instruction = LOAD_TYPE;  //Setting ResultSrc = 0
        top->eval();

        top->instruction = opcode;
        top->eval();

        EXPECT_EQ(top->ResultSrc, 0);
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
