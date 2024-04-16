#!/usr/bin/env python
############################################################################
# VERSION = '1.0.0'
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'
# Written on Thu Apr  4 07:20:42 PM IST 2024
############################################################################
# Purpose : This script compares two poscar files.
############################################################################
import argparse

def read_poscar(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
        print("Contents of the POSCAR file:")
        for line in lines:
            print(line.strip())

    # Extract lattice parameters
    lattice_parameters = [float(x) for x in lines[1].split()]

    # Extract lattice vectors
    lattice_vectors = [[float(x) for x in line.split()] for line in lines[2:5]]

    # Extract atom types and numbers
    atom_types = lines[5].split()
    atom_numbers = [int(x) for x in lines[6].split()]

    # Skip header lines and then extract atomic positions
    start_index = 7
    for line in lines[7:]:
        if line.strip().lower() in ['direct', 'cartesian']:
            start_index += 1
        else:
            break

    atomic_positions = []
    for line in lines[start_index:]:
        atomic_positions.append([float(x) for x in line.split()[:3]])

    return lattice_parameters, lattice_vectors, atom_types, atom_numbers, atomic_positions


def compare_poscars(poscar1, poscar2):
    poscar1_data = read_poscar(poscar1)
    poscar2_data = read_poscar(poscar2)

    # Compare lattice parameters
    if poscar1_data[0] != poscar2_data[0]:
        print("Lattice parameters are different:")
        print("POSCAR 1:", poscar1_data[0])
        print("POSCAR 2:", poscar2_data[0])

    # Compare lattice vectors
    for i in range(3):
        if poscar1_data[1][i] != poscar2_data[1][i]:
            print("Lattice vectors are different:")
            print("POSCAR 1:", poscar1_data[1][i])
            print("POSCAR 2:", poscar2_data[1][i])

    # Compare atom types and numbers
    if poscar1_data[2] != poscar2_data[2]:
        print("Atom types are different:")
        print("POSCAR 1:", poscar1_data[2])
        print("POSCAR 2:", poscar2_data[2])
    if poscar1_data[3] != poscar2_data[3]:
        print("Atom numbers are different:")
        print("POSCAR 1:", poscar1_data[3])
        print("POSCAR 2:", poscar2_data[3])

    # Compare atomic positions
    if poscar1_data[4] != poscar2_data[4]:
        print("Atomic positions are different:")
        print("POSCAR 1:", poscar1_data[4])
        print("POSCAR 2:", poscar2_data[4])
    else:
        print("The two POSCAR files are identical.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Compare two POSCAR files.')
    parser.add_argument('--poscar1', help='Path to the first POSCAR file',required=True)
    parser.add_argument('--poscar2', help='Path to the second POSCAR file', required=True)
    parser.add_argument('--version', action='version', version='%(prog)s 1.0')
    args = parser.parse_args()

    compare_poscars(args.poscar1, args.poscar2)
