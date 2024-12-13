# Conventions

To standardise our work moving forward and reducing confusion, I am setting some conventions on how files will be handled within branches and how new files should be created.

## New Files
All new SystemVerilog files should be named in lowercase, with **_** being used for multiple words. (e.g. sign_extend.sv, reg_file.sv). This prevents any ambiguity on how files should be named and allows smoother work for testing to avoid naming errors.

## top.sv
top.sv is a file I hope everyone can collaborate in. The top.sv file is required to initiate the modules and allow testing, so I hope everyone can work to instantiate their **own respective modules only** so we reduce the time trying to instantiate everything and reduce naming confusion.