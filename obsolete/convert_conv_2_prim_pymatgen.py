#!/usr/bin/env python
############################################################################
# VERSION = '1.0.0'                                                        #
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'             #
# Written on Mon Apr  1 10:44:16 PM IST 2024                               #
############################################################################
# Purpose : This script converts a POSCAR file to its primitive or         #
#           conventional cell using pymatgen.                              #
############################################################################
import argparse
from pymatgen.io.vasp import Poscar
from pymatgen.symmetry.analyzer import SpacegroupAnalyzer

VERSION = '1.0.0'
AUTHOR = 'Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'

def reduce_to_primitive(poscar_file, output_file):
    # Read the POSCAR file
    poscar = Poscar.from_file(poscar_file)
    structure = poscar.structure

    # Convert to primitive cell
    primitive_structure = SpacegroupAnalyzer(structure).find_primitive()

    # Write the reduced structure to a file
    poscar_primitive = Poscar(primitive_structure)
    poscar_primitive.write_file(output_file)
    print("-----------------------------------------------------------")
    print("Primitive Cell is written to %s" % (output_file))
    print("-----------------------------------------------------------")

def convert_to_conventional(poscar_file, output_file):
    # Read the POSCAR file
    poscar = Poscar.from_file(poscar_file)
    structure = poscar.structure

    # Convert to conventional cell
    conventional_structure = SpacegroupAnalyzer(structure).get_conventional_standard_structure()

    # Write the conventional structure to a file
    poscar_conventional = Poscar(conventional_structure)
    poscar_conventional.write_file(output_file)
    print("-----------------------------------------------------------")
    print("Conventional Cell is written to %s" % (output_file))
    print("-----------------------------------------------------------")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert POSCAR to primitive or conventional cell')
    parser.add_argument('-p', '--poscar', help='Path to the POSCAR file', required=True)
    parser.add_argument('-o', '--output', help='Output file name for the structure', required=True)
    parser.add_argument('-t', '--type', choices=['primitive', 'conventional'], help='Type of conversion (primitive or conventional)', required=True)
    parser.add_argument("-v", "--version", action="version", version="%(prog)s {version}, Author: {author}".format(version=VERSION, author=AUTHOR), help="Show program's version number and author")
    args = parser.parse_args()

    if args.type == 'primitive':
        reduce_to_primitive(args.poscar, args.output)
    elif args.type == 'conventional':
        convert_to_conventional(args.poscar, args.output)
