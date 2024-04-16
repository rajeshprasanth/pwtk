#!/usr/bin/env python
############################################################################
# VERSION = '1.0.0'
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'
# Written on Thu Apr  4 10:33:01 AM IST 2024
############################################################################
# Purpose : This script applies uniaxial strain to a POSCAR file
############################################################################

import argparse
from ase.io import read, write
import numpy as np

def apply_strain(atoms, strain_direction, strain_percentage):
    """
    Apply uniaxial strain to the atomic structure along the specified direction.

    Parameters:
        atoms (ASE Atoms): The atomic structure.
        strain_direction (str): Direction of the strain ('x', 'y', or 'z').
        strain_percentage (float): Strain percentage to apply.

    Returns:
        ASE Atoms: Atomic structure with applied strain.
    """
    strain_value = strain_percentage / 100.0
    if strain_direction == 'x':
        strain_matrix = np.array([[1 + strain_value, 0, 0],
                                  [0, 1, 0],
                                  [0, 0, 1]])
    elif strain_direction == 'y':
        strain_matrix = np.array([[1, 0, 0],
                                  [0, 1 + strain_value, 0],
                                  [0, 0, 1]])
    elif strain_direction == 'z':
        strain_matrix = np.array([[1, 0, 0],
                                  [0, 1, 0],
                                  [0, 0, 1 + strain_value]])
    else:
        raise ValueError("Invalid strain direction. Choose 'x', 'y', or 'z'.")

    atoms.set_cell(np.dot(atoms.get_cell(), strain_matrix), scale_atoms=True)
    return atoms

def read_poscar(poscar_file):
    """
    Read the atomic structure from a POSCAR file.

    Parameters:
        poscar_file (str): Path to the POSCAR file.

    Returns:
        ASE Atoms: Atomic structure read from the POSCAR file.
    """
    return read(poscar_file)

def write_poscar(atoms, output_file):
    """
    Write the atomic structure to a POSCAR file.

    Parameters:
        atoms (ASE Atoms): The atomic structure.
        output_file (str): Path to write the output POSCAR file.
    """
    write(output_file, atoms, format='vasp',direct=True)
    print("---------------------------------------------------")
    print("Strained atomic structure written to {:s}".format(output_file))
    print("---------------------------------------------------")

def main():
    parser = argparse.ArgumentParser(description='Apply uniaxial strain to a POSCAR file')
    parser.add_argument('-i', '--input-poscar', type=str, required=True, help='Path to the input POSCAR file')
    parser.add_argument('-d', '--strain-direction', type=str, choices=['x', 'y', 'z'], required=True, help='Direction of the strain (x, y, or z)')
    parser.add_argument('-s', '--strain-percentage', type=float, required=True, help='Strain percentage to apply')
    parser.add_argument('-o', '--output-poscar', type=str, required=True, help='Path to write the strained POSCAR file')

    args = parser.parse_args()

    # Read the initial structure from the input POSCAR file
    initial_structure = read_poscar(args.input_poscar)

    # Apply uniaxial strain
    strained_atoms = apply_strain(initial_structure.copy(), args.strain_direction, args.strain_percentage)

    # Write the strained atomic structure to the output POSCAR file
    write_poscar(strained_atoms, args.output_poscar)

if __name__ == '__main__':
    main()
