#!/usr/bin/env python
###########################################################################
# VERSION = '1.0.0'
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'
# Written on Mon Apr 08 01:43:30 PM IST 2024
############################################################################
# Purpose : This script converts a POSCAR file to primitive or conventional cell
###########################################################################
import argparse
from pymatgen.io.vasp import Poscar
from pymatgen.symmetry.analyzer import SpacegroupAnalyzer

def convert_cell_using_pymatgen(poscar_file, cell_type, output_file):
    if cell_type == 'p':
        cell_name = 'primitive'
        poscar = Poscar.from_file(poscar_file)
        structure = poscar.structure
        primitive_structure = SpacegroupAnalyzer(structure).find_primitive()
        poscar_primitive = Poscar(primitive_structure)
        poscar_primitive.write_file(output_file)
    elif cell_type == 'c':
        cell_name = 'conventional'
        poscar = Poscar.from_file(poscar_file)
        structure = poscar.structure
        conventional_structure = SpacegroupAnalyzer(structure).get_conventional_standard_structure()
        poscar_conventional = Poscar(conventional_structure)
        poscar_conventional.write_file(output_file)
    else:
        print("Invalid cell type. Please choose 'p' for primitive or 'c' for conventional.")
        return

    print(f"Successfully converted {cell_name} cell using pymatgen and saved to {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert POSCAR to primitive or conventional cell")
    parser.add_argument("-i", "--input_file", help="Input POSCAR file name", required=True)
    parser.add_argument("-t", "--cell_type", choices=['p', 'c'], help="Cell type to convert to ('p' for primitive, 'c' for conventional)", required=True)
    parser.add_argument("-o", "--output_file", help="Output file name", required=True)

    args = parser.parse_args()

    convert_cell_using_pymatgen(args.input_file, args.cell_type, args.output_file)
