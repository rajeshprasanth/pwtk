#!/usr/bin/env python
############################################################################
# VERSION = '1.0.0'                                                        #
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'             #
# Written on Mon Apr  1 10:44:16 PM IST 2024                               #
############################################################################
# Purpose : This script converts a POSCAR file to primitive or conventional#
#           cell.                                                          #
############################################################################
import argparse
import subprocess

def convert_cell(poscar_file, cell_type, output_file):
    if cell_type == 'p':
        command = ['aflow', '--prim']
    elif cell_type == 'c':
        command = ['aflow', '--std_conv']
    else:
        print("Invalid cell type. Please choose 'p' for primitive or 'c' for conventional.")
        return

    try:
        with open(poscar_file, 'rb') as f:
            input_content = f.read().decode('utf-8')
        output = subprocess.run(command, input=input_content, capture_output=True, text=True, check=True)
        with open(output_file, 'w') as f:
            f.write(output.stdout)
        print(f"Successfully converted {'primitive' if cell_type == 'p' else 'conventional'} cell and saved to {output_file}")
    except subprocess.CalledProcessError:
        print("An error occurred while converting the cell.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert POSCAR to primitive or conventional cell")
    parser.add_argument("-i", "--input_file", help="Input POSCAR file name", required=True)
    parser.add_argument("-t", "--cell_type", choices=['p', 'c'], help="Cell type to convert to ('p' for primitive, 'c' for conventional)", required=True)
    parser.add_argument("-o", "--output_file", help="Output file name", required=True)

    args = parser.parse_args()

    convert_cell(args.input_file, args.cell_type, args.output_file)
