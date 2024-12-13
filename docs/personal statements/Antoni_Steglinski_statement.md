# RISC-V RV32I Processor Coursework
## Personal Stetement of Contributions
### Antoni Steglinski
Github commits under:AStegi05
## Overview 

- [Reg File](#reg-file)
- [ALU](#alu)
- [Modules for simple pipelined processor](#modules-for-simple-pipelined-processor)
- [F1 Program](#f1-program)
- [5_pdf.s program](#5_pdfs-program)
- [Additional Comments](#additional-comments)
***
## Reg File
I made register file module for lab 4 and it did not change for implementation of a single cycle CPU. This is propably one of the simpler modules. It only needs to assign correct values to output registers RD1, RD2 and a0 based on addreses in the input. It has a synchronoys write port for register with address AD3 where the result from previous calculation is stored if WE3 is enabled. WE3 is a control signal from control unit.
![reg_file_synchronous write](/images/image-6.png)
 There is also an asynchronous write port for register RD1 and RD2 that contain data, on which calculation will be made. Later I changed it so it writes data on a falling edge of a clock cycle and I added so that register zero is unwritable.

![register file](/images/image.png)
***
## ALU
The ALU is the arithmetic logic unit. It is responsible for doing all the arithmetic calculations on data provided. In this module I implemented all arithmetic instructions as well as Branch instructions. To do this I used a case statement that would choose to do the correct operation based on the control input from control unit. In Alu I only need to decide whether a branch condition is met or not and then respectively set EQ to true or falls.To implement signed instructions I simply declared new logic signed variables this makes system verillo treat binary numbers as two's complement numbers.
***
## Modules for simple pipelined processor
To create a simple pipelined processor I had to insert pipeline registers between each of the five stages. The function of those register is to transfer the values of the previous stage to the next stage after each clock cycle. Meaning that all the modules do something each colck cycle.
***
## F1 Program
I created a f1 lights program that would iterate over each of the state in a loop. The first version look like this:

![f1_lights_old](/images/image-2.png)

As I found out later, when I created a testbench for that code and run it after our cpu design was finished, this code was extremly slow to execute. The time between state transitions was around 4 seconds. I think this was because each state transition took 5 instructions to execute.
I decided to improve this by changing the code:

![f1_lights_final](/images/image-3.png)

In this code each state transition takes only 1 cycle to execute. This improved the in between transtion time to be much quicker.
***
## 5_pdf.s program
I created a testbench for 5_pdf.s program that would plot the correct graphs on vbuddy. Before I did this I had to debug our cpu model because the test 5 in verify.cpp was not passing. As I found out the problem was that for pdf program data memory should read data starting from address 0x10000. After that fix our design passed all 5 tests in verify.cpp.
![data_memory_fix](/images/image-4.png)

Then I created a testbench so that I can see the waveforms on vbuddy. Because the program takes many clock cycles to execute, because of this the program could not all be run on Vbuddy To overcome this I decided to save all the output values a0 that this program executes in a vector. And then once the program finishes executing the values are read and displayed on vbuddy. This was not easy to achieve, because I had to add the conditions on when to start saving data and when to stop saving data.

![pdf_tb.cpp](/images/image-5.png)
***
## Results
Gaussian:
![gaussian](/images/<WhatsApp Image 2024-12-10 at 21.07.13 (1)-1.jpeg>)
noisy:
![noisy](/images/<WhatsApp Image 2024-12-10 at 21.07.13-1.jpeg>)
triangle:
![triangle](/images/<WhatsApp Image 2024-12-10 at 21.07.12-1.jpeg>)


## Additional comments
To run my testbenches I had to change assemble.sh because for some reasons it correctly assembles testbenches into test_out folder but it does not copy program.hex into rtl folder meaning that no test would work. To change this I added this statement that created a copy of program.hex in rtl folder.

![assembly.sh correction](/images/image-8.png)

I also modified doit.sh so that I can run testbenches for f1 lights and pdf program.
![doit.sh](/images/image-7.png)
This simple changed allowed me to not write a new makefile to run my testbenches.

Additionaly I written some testbenches for early versions of pipelining modules and hazard unit. I also tested pipelining with hazard unit and flushes implemented and later also the final design with cache, and debuged it so it passess all the test. We had a problem with cache that cause test5 of verify.cpp to fail because it was accessing wrong memory addresses.

Overall, I enjoyed the time I spent on this project and I enjoyed working with my team. I fell that I learned a lot about RISC-V and SystemVerilog and that I improved my team working skills. If I had a chance to work on this project again I would like to have worked on developing cache, and if there was more time I would like to try and see what programs we could run on our design and see their outputs on vbuddy. One thing that I would do differently is that I would spend more time on discussing our design with team so that we can create modules that are than easier to connect with each other to create a final design.
