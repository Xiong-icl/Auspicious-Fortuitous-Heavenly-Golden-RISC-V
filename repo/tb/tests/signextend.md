# Few notes on sign extension for future reference

### Sign extending load instructions
When a value is loaded from memory with fewer than 32 bits, the remaining bits must be assigned. Sign extension is used for signed loads of bytes (8 bits using the lb instruction) and halfwords (16 bits using the lh instruction). Sign extension replicates the most significant bit loaded into the remaining bits. -[Florida State University](https://www.cs.fsu.edu/~hawkes/cda3101lects/chap4/extension.htm#:~:text=When%20a%20value%20is%20loaded,loaded%20into%20the%20remaining%20bits.) 

### Sign extending branch instructions
Branch offsets are signed 12-bit immediates but in units of two bytes. RISC-V instructions are four bytes long, so why are offsets in units of two bytes? Compressed instructions (to be covered in a future post) are only two bytes long, so branch offsets need to be in units of two bytes.

Offsets are sign extended, so you can easily branch backwards in your code. With 12-bit offsets in units of two bytes, branch instructions have a range of ±4 KiB. -[Project F](https://projectf.io/posts/riscv-branch-set/)
