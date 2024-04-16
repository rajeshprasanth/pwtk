#!/usr/bin/env python
############################################################################
# VERSION = '1.0.0'
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'
# Written on Mon Apr  1 10:44:16 PM IST 2024
############################################################################
# Purpose : This script converts a POSCAR file to Quantum Espresso input file.
############################################################################

import argparse
import json
from ase.io import read, write

VERSION = '1.0.0'
AUTHOR = 'Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'

def convert_poscar_to_pwi(template_path, poscar_path, output_path):
    """
    Convert a POSCAR file to Quantum Espresso input file.

    Parameters:
        template_path (str): Path to the template file.
        poscar_path (str): Path to the POSCAR file.
        output_path (str): Path to save the Quantum Espresso input file.

    Returns:
        None
    """
    # Load template from JSON
    with open(template_path, 'r') as f:
        template = json.load(f)

    # Load POSCAR file
    atoms = read(poscar_path)

    # Update template with information from the POSCAR file
    num_atoms = len(atoms)
    num_species = len(set(atoms.get_chemical_symbols()))
    template['system']['nat'] = num_atoms
    template['system']['ntyp'] = num_species

    # Write Quantum ESPRESSO input file
    write(output_path, atoms, format='espresso-in', input_data=template, pseudopotentials=template['pseudopotentials'], kspacing=template['kspacing'],crystal_coordinates=template['crystal_coordinates'], pw=False)

    # Displaying information about the generated Quantum Espresso SCF input file.

    print("-----------------------------------------------------------")
    print("Generated Quantum Espresso SCF input file: {:s}".format(output_path))
    print("-----------------------------------------------------------")


def main():
    """
    Main function to parse command line arguments and execute conversion.
    """
    parser = argparse.ArgumentParser(description="Convert VASP POSCAR file to Quantum ESPRESSO input file")
    parser.add_argument("-p", "--poscar", help="Path to the POSCAR file", metavar="POSCAR", required=True)
    parser.add_argument("-t", "--template", help="Path to the template file", metavar="Template_filename", required=True)
    parser.add_argument("-i", "--pwi", help="Path to the Quantum ESPRESSO input file", metavar="QE_Input_filename", required=True)
    parser.add_argument("-v", "--version", action="version", version="%(prog)s {version}, Author: {author}".format(version=VERSION, author=AUTHOR), help="Show program's version number and author")
    args = parser.parse_args()

    template_filename = args.template
    poscar_filename = args.poscar
    pwi_filename = args.pwi
    convert_poscar_to_pwi(template_filename, poscar_filename, pwi_filename)

if __name__ == "__main__":
    main()
