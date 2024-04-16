#!/usr/bin/env python
############################################################################
# VERSION = '1.0.0'
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'
# Written on Tue Apr  2 12:03:15 PM IST 2024
############################################################################
# Purpose : This script converts a Quantum Espresso output to POSCAR file.
############################################################################

import argparse
from ase.io import read, write

VERSION = '1.0.0'
AUTHOR = 'Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'

def convert_pwo_to_poscar(qe_output_file, poscar_output_file):
    """
    Convert Quantum Espresso output file to POSCAR file.

    Parameters:
        qe_output_file (str): Path to the Quantum Espresso output file.
        poscar_output_file (str): Path to save the POSCAR file.

    Returns:
        None
    """
    atoms = read(qe_output_file, format='espresso-out')
    write(poscar_output_file, atoms, format='vasp', direct=True)
    # Displaying information about the generated POSCAR file.

    print("-----------------------------------------------------------")
    print("Generated POSCAR file: {:s}".format(poscar_output_file))
    print("-----------------------------------------------------------")


def main():
    """
    Main function to parse command line arguments and execute conversion.
    """
    parser = argparse.ArgumentParser(description="Convert Quantum ESPRESSO output file to POSCAR file")
    parser.add_argument("-p", "--poscar", help="Path to the POSCAR file", metavar="POSCAR", required=True)
    parser.add_argument("-o", "--pwo", help="Path to the Quantum ESPRESSO output file", metavar="QE_Output_filename", required=True)
    parser.add_argument("-v", "--version", action="version", version="%(prog)s {version}, Author: {author}".format(version=VERSION, author=AUTHOR), help="Show program's version number and author")

    args = parser.parse_args()

    poscar_filename = args.poscar
    pwo_filename = args.pwo

    convert_pwo_to_poscar(pwo_filename, poscar_filename)

if __name__ == "__main__":
    main()
