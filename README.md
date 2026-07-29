# Bin Packing Solver (MIPS Assembly)

## Overview

This project implements the **Bin Packing Problem** in **MIPS Assembly Language** using two classic allocation algorithms:

- First Fit
- Best Fit

The program reads item sizes from an input file, validates the input, executes the selected bin allocation algorithm, and displays the allocation results.

## Features

- Implements **First Fit** and **Best Fit** algorithms.
- Reads item sizes from an input file.
- Validates input values before processing.
- Allocates items into bins according to the selected algorithm.
- Displays the allocation results.
- Written entirely in **MIPS Assembly**.

## Algorithms

### First Fit
Places each item into the first bin with enough remaining capacity. If no existing bin can accommodate the item, a new bin is created.

### Best Fit
Places each item into the bin that leaves the least remaining free space after placement. If no suitable bin exists, a new bin is created.

## Input Format

The input file contains the item sizes, with **one item per line**.

Example:

```text
0.5
0.9
0.1
0.4
0.9
0.4
0.8
0.5
1.3
0.7
0.2
0.1
```

## Technologies

- MIPS Assembly
- MARS Simulator

## How to Run

1. Open `main_code.asm` using the **MARS** simulator.
2. Place the input file in the appropriate directory.
3. Assemble and run the program.
4. Follow the program prompts to execute the desired allocation algorithm.

## Project Structure

```text
.
├── main_code.asm
├── Input.txt
└── README.md
```
