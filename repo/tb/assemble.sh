#!/bin/bash

# Usage: ./assemble.sh <file.s>

# Default vars
SCRIPT_DIR=$(dirname "$(realpath "$0")")
output_file_rtl="$SCRIPT_DIR/../rtl/program.hex"

# Handle terminal arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: ./assemble.sh <file.s>"
    exit 1
fi

input_file=$1
basename=$(basename "$input_file" | sed 's/\.[^.]*$//')
parent=$(dirname "$input_file")
file_extension="${input_file##*.}"
LOG_DIR="$SCRIPT_DIR/test_out/$basename"

# Create output directory for disassembly, hex and waveforms
mkdir -p "$LOG_DIR"

riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 \
                        -o "a.out" "$input_file"

riscv64-unknown-elf-ld -melf32lriscv \
                        -e 0xBFC00000 \
                        -Ttext 0xBFC00000 \
                        -o "a.out.reloc" "a.out"

riscv64-unknown-elf-objcopy -O binary \
                            -j .text "a.out.reloc" "a.bin"

rm *dis 2>/dev/null

# This generates a disassembly file
riscv64-unknown-elf-objdump -f -d --source -m riscv \
                            a.out.reloc > "${LOG_DIR}/program.dis"

# Define the output hex in tes_out
output_file_test_out="$LOG_DIR/program.hex"

# Formats into a hex file
od -v -An -t x1 "a.bin" | tr -s '\n' | awk '{$1=$1};1' > "$output_file_test_out"

# Copy the hex file to the rtl directory
cp "$output_file_test_out" "$output_file_rtl"

rm "a.out.reloc"
rm "a.out"
rm "a.bin"
