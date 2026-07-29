# Bin Packing Solver (MIPS Assembly)

## Overview
This project implements the **Bin Packing Problem** in **MIPS Assembly Language** using two classic allocation algorithms:

- First Fit
- Best Fit

The program reads item sizes and bin capacity from an input file, validates the input, executes the selected allocation algorithm, and writes the results to an output file.

## Features

- Implements **First Fit** and **Best Fit** algorithms.
- Reads input data from a file.
- Validates input values before processing.
- Allocates items into bins based on the selected algorithm.
- Displays and saves the allocation results.
- Written entirely in **MIPS Assembly**.

## Algorithms

### First Fit
Places each item into the first bin that has enough remaining capacity. If no existing bin can accommodate the item, a new bin is created.

### Best Fit
Places each item into the bin that leaves the smallest remaining free space after placement. If no suitable bin exists, a new bin is created.

## Input Format

The input file should contain:

- Bin capacity
- Number of items
- Item sizes

Example:

```
10
5
2 5 4 7 1
```

*(Modify the example to match your project's actual input format if necessary.)*

## Output

The program outputs:

- Number of bins used
- Assignment of items to bins
- Remaining capacity of each bin

## Technologies

- MIPS Assembly
- MARS Simulator (or QtSPIM)

## How to Run

1. Open the project in **MARS** (or **QtSPIM** if compatible).
2. Load `main_code.asm`.
3. Make sure the input file is in the correct location.
4. Run the program.
5. View the generated output.

## Project Structure

```
.
├── main_code.asm
├── README.md
├── Input.txt
└── Output.txt
```
