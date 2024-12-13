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
I made the register file module for lab 4, and it did not change for the implementation of a single-cycle CPU. This is probably one of the simpler modules. It only needs to assign correct values to output registers RD1, RD2, and a0 based on addresses in the input. It has a synchronous write port for the register with address AD3, where the result from the previous calculation is stored if WE3 is enabled. WE3 is a control signal from the control unit.

![reg_file_synchronous write](/images/image-6.png)
There is also an asynchronous write port for registers RD1 and RD2 that contain data on which calculations will be made. Later, I changed it so it writes data on the falling edge of a clock cycle and added a mechanism to ensure that register zero is unwritable.

![register file](/images/image.png)
***
## ALU
The ALU is the Arithmetic Logic Unit. It is responsible for performing all the arithmetic calculations on the provided data. In this module, I implemented all arithmetic instructions as well as branch instructions. To do this, I used a case statement that selects the correct operation based on the control input from the control unit.
In the ALU, I only needed to decide whether a branch condition is met or not and then set EQ to true or false, respectively. To implement signed instructions, I simply declared new signed logic variables, which makes SystemVerilog treat binary numbers as two's complement numbers.
***
## Modules for simple pipelined processor
To create a simple pipelined processor, I inserted pipeline registers between each of the five stages. The function of these registers is to transfer the values of the previous stage to the next stage after each clock cycle. This ensures that all the modules do something during each clock cycle.
***
## F1 Program
I created an F1 lights program that iterates over each of the states in a loop. The first version looked like this:

![f1_lights_old](/images/image-2.png)

As I discovered later, when I created a testbench for that code and ran it after our CPU design was finished, this code was extremely slow to execute. The time between state transitions was around 4 seconds. I think this was because each state transition took 5 instructions to execute.
I decided to improve this by changing the code:

![f1_lights_final](/images/image-3.png)

In this code, each state transition takes only 1 cycle to execute. This significantly improved the time between transitions.
***
## 5_pdf.s program
I created a testbench for the 5_pdf.s program that plots the correct graphs on vbuddy. Before I did this, I had to debug our CPU model because test 5 in verify.cpp was not passing. I found that the problem was that the data memory for the PDF program should start reading data from address 0x10000. After fixing that, our design passed all 5 tests in verify.cpp.
![data_memory_fix](/images/image-4.png)

Then I created a testbench to view the waveforms on vbuddy. The program takes many clock cycles to execute, so it could not be fully run on vbuddy. To overcome this, I saved all the output values of a0 in a vector. Once the program finished executing, the values were read and displayed on vbuddy. This was challenging because I had to add conditions for when to start and stop saving data.

![pdf_tb.cpp](/images/image-5.png)
***
## Results
Gaussian:
![gaussian](</images/WhatsApp Image 2024-12-10 at 21.07.13 (1)-1.jpeg>)
noisy:
![noisy](</images/WhatsApp Image 2024-12-10 at 21.07.13-1.jpeg>)
triangle:
![triangle](</images/WhatsApp Image 2024-12-10 at 21.07.12-1.jpeg>)


## Additional comments
To run my testbenches, I had to modify assemble.sh because it was not correctly copying program.hex into the rtl folder, meaning that no tests would work. I added a statement to copy program.hex into the rtl folder.

![assembly.sh correction](/images/image-8.png)

I also modified doit.sh to run testbenches for the F1 lights and PDF programs.
![doit.sh](/images/image-7.png)
These simple changes allowed me to avoid writing a new makefile to run my testbenches.

Additionally, I wrote some testbenches for early versions of the pipelining modules and the hazard unit. I also tested the pipelining with the hazard unit and flushes implemented, and later tested the final design with the cache, debugging it so that it passed all the tests.

We encountered a problem with the cache that caused test 5 of verify.cpp to fail because it was accessing the wrong memory addresses. Although debugging revealed it to be a simple coding mistake, it took a long time to identify the issue.

Overall, I enjoyed the time I spent on this project and working with my team. I felt that I learned a lot about RISC-V and SystemVerilog, and that I improved my teamwork skills. If I had the chance to work on this project again, I would like to work on developing the cache. If there were more time, I would also like to see what programs we could run on our design and display their outputs on vbuddy. One thing I would do differently is spend more time discussing our design as a team to create modules that are easier to integrate into the final design.
