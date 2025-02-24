# Auspicious-Fortuitous-Heavenly-Golden-RISC-V

## Team 10 Statement

### Contributors:
- Xiong Yi Loh (Team Lead)
- Antoni Steglinski
- Antoni Tokarski
- Soong En Wong

## Tags
Release | Tag                                                            
------------- | --------------------------------------------------------------
Single-Cycle CPU | [v0.1.0](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/tree/v.1.0)        
Pipelined CPU | [v0.2.0](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/tree/v.2.0)
2-way Associative Cache | [v0.3.0](https://github.com/Xiong-icl/Auspicious-Fortuitous-Heavenly-Golden-RISC-V/tree/v.3.0)  

## Personal Statements

- [Xiong Yi Loh](/docs/personal%20statements/XiongYi_Statement.md)
- [Antoni Steglinski](/docs/personal%20statements/Antoni_Steglinski_statement.md)
- [Antoni Tokarski](/docs/personal%20statements/Antoni_Tokarski_Statement.md)
- [Soong En Wong](/docs/personal%20statements/Soong_En_Wong_statement.md)

## Quick Start
Before running any scripts execute this 2 commands
```
cd repo/tb
```
### Using testbenches
To run any of the tests use the commands below:

|              Command               |             Test               |
|------------------------------------|--------------------------------|
|    ./doit.sh tests/verify.cpp      |       runs verify.cpp test     |
|./doit.sh tests/pdf_tb_gaussian.cpp | runs pdf gaussian test (Vbuddy)|
|  ./doit.sh tests/pdf_tb_noisy.cpp  |  runs pdf noisy test (Vbuddy)  |
|./doit.sh tests/pdf_tb_triangle.cpp | runs pdf triangle test (Vbuddy)|
|  ./doit.sh tests/f1_lights_tb.cpp  |  runs f1 lights test (Vbuddy)  |


## Testing Evidence
Below are videos showing that our design works. The evidence was collected using cache_cpu version of our design
### Videos
F1 lights

https://github.com/user-attachments/assets/8e465bfb-acce-416a-9a26-3a5d7274e0e5

Gaussian

https://github.com/user-attachments/assets/bb660c1a-810c-415c-aaaa-705ce549b9dd

Noisy

https://github.com/user-attachments/assets/35122815-d5df-4ccb-88c0-43587351abbc

Triangle

https://github.com/user-attachments/assets/ffe2538a-ec86-4bed-8f2e-0bf7bd26db68

## Individual Contributions

|              |                               | Xiong Yi           | Antoni Steglinski|     Antoni Tokarski      |  Soong En Wong   |
| ------------ | ----------------------------- | ------------------ | ---------------- | ------------------------ | ---------------- |
| Single Cycle | Program Counter               |                    |                  | Major                    |                  |
|              | ALU                           |                    | Major            |                          |                  |
|              | Register File                 |                    | Major            |                          |                  |
|              | Instruction Memory            |                    |                  |                          | Major            |
|              | Control Unit                  | Major              |                  |                          | Minor            |
|              | Sign Extend                   |                    |                  |                          | Major            |
|              | Testbench                     | Major              | Minor            |                          |                  |
|              | Data Memory                   |                    |                  | Major                    |                  |
|              | Top                           | Major              | Minor            | Minor                    | Minor            |
| Pipeline     | Pipeline           Stages     | Minor              | Major            | Minor                    | Minor            |
|              | Hazard Unit                   | Major              | Minor            |                          |                  |
|              | Top     (Revised)             | Major              |                  | Minor                    |                  |
| Cache        | Data Memory (Revised)         | Minor              |                  | Minor                    |                  |
|              | Finite State Machine          | Major              |                  | Minor                    |                  |
|              | Two-way Set Associative Cache | Major              |                  | Major                    | Minor            |
| PDF          | PDF                           |                    |  Major           | Minor                    |                  |
| F1 Lights    | F1 Lights                     |                    |  Major           | Minor                    |                  |

## Designs

### Single Cycle CPU Design

![Single Cycle](/images/single_cycle.png)

### Pipelined CPU Design

![Pipeline](/images/pipelinepc.png)

### Cache Control Finite State Machine Design

![Cache Control](/images/fsm.jpg)

### Cache Design

![Cache](/images/2waycache.png)


