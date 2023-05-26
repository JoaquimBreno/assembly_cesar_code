#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <assembly-file>"
    exit 1
fi

input_file=$1
base_name="${input_file%.*}"

nasm -f elf32 "$input_file" 
gcc -m32 -no-pie "${base_name}.o" -o "${base_name}" -lc

if [ -f "${base_name}" ]; then
    echo "Executando o programa..."
    ./"${base_name}"
else
    echo "Falha na montagem. Verifique o código fonte."
fi