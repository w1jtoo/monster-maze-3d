#!/bin/bash

if [ ! -d bin ]; then
  mkdir -p bin;
fi

cd src
nasm main.asm -o ../bin/main.com
cd ..
dosemu bin/main.com
