# Personnel Management Assembler Program

## Overview

This is a console-based personnel management system implemented in x86 assembly language for Linux. The program manages a dynamic list of personnel records, allowing the user to add, list, delete, and display statistics about the personnel.

## Features

- **Dynamic memory allocation** for the personnel table to optimize memory usage.
- Interactive menu with 6 options for managing personnel data.
- Personnel records consist of:
  - ID (2 ASCII characters, auto-incremented)
  - Name (up to 30 characters, padded with spaces)
  - Age (2 ASCII characters, supports 1 or 2 digits)
- Functions include:
  - Adding new personnel entries (up to 99)
  - Listing all personnel in a formatted way
  - Deleting a personnel entry by ID
  - Displaying minimum and maximum ages among personnel
  - Handling input validation and error messages

## Data Structure

- Each personnel entry occupies 34 bytes:
  - ID: 2 bytes (ASCII)
  - Name: 30 bytes (ASCII, space-padded)
  - Age: 2 bytes (ASCII)
- The program maintains counters for the number of personnel and auto-incremented IDs.

## How to Use

1. Launch the program in a Linux environment.
2. Use the menu to select operations:
   - Add personnel
   - List personnel
   - Delete personnel by ID
   - Display min/max ages
   - Exit
3. Follow the on-screen prompts to enter names and ages.
4. Error messages appear if invalid input is detected or operations fail (e.g., full list, invalid ID).

## Implementation Details

- Uses Linux system calls (`write`, `read`) for input/output.
- Careful register management with stack saving/restoring.
- Manual memory handling to avoid unnecessary static allocation.
- Data input handled character by character with ASCII conversions.
- Includes robust input validation.

## Requirements

- Linux operating system.
- x86 architecture.
- Assembler and linker tools (e.g., `nasm`, `ld`).

## Author

Houcine Hamnouche  
Date: March 30, 2025
