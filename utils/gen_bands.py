#!/usr/bin/env python
###########################################################################
# VERSION = '1.0.0'
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'
# Written on Tue Apr  2 04:34:11 PM IST 2024
###########################################################################
# Purpose : This script converts a POSCAR file to Quantum Espresso input files for BANDS calculations.
###########################################################################
import argparse
import json
from ase.io import read, write
from ase.dft.kpoints import parse_path_string
import re
import f90nml
import os

VERSION = '1.0.0'
AUTHOR = 'Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'


def write_namelist(file_path, namelist_name, namelist_content):
    namelist = {namelist_name: namelist_content}
    f90nml.write(namelist, file_path, force=True)


def generate_input(template_path, poscar_path, scf_path, nscf_path, bands_path, bands_data_path,system_name):
    # Load template from JSON
    with open(template_path, 'r') as f:
        template = json.load(f)

    # Load POSCAR file
    atoms = read(poscar_path)

    # Update template with information from the POSCAR file
    num_atoms = len(atoms)
    num_species = len(set(atoms.get_chemical_symbols()))
    #
    template['control']['prefix'] = system_name
    template['control']['title'] = system_name
    template['control']['outdir'] = "./" + str(system_name)
    #
    template['system']['nat'] = num_atoms
    template['system']['ntyp'] = num_species

    #
    lattice = atoms.cell.get_bravais_lattice()
    path = lattice.bandpath()
    special_points = path.special_points
    kpath = parse_path_string(path.path)

    high_symmetry_points = []

    for path_index, path in enumerate(kpath):
        for point_index, point in enumerate(path):
            if point_index == len(path) - 1:
                density = 1
            else:
                density = 10
            coordinates = ' '.join(format(coord, '.7f') for coord in special_points[point])
            high_symmetry_points.append(f"{coordinates} {density} ! {point}")

    # Write Quantum ESPRESSO scf input file
    write(scf_path, atoms, format='espresso-in', input_data=template, pseudopotentials=template['pseudopotentials'], kspacing=template['kspacing'],crystal_coordinates=template['crystal_coordinates'], pw=False)

    # Update template for nscf calculations
    template['control']['calculation'] = 'bands'

    # Write Quantum ESPRESSO nscf input file
    write('tmp_file_0', atoms, format='espresso-in', input_data=template, pseudopotentials=template['pseudopotentials'], crystal_coordinates=template['crystal_coordinates'], pw=False)

    # Compile the regular expression pattern
    pattern_regex = re.compile("K_POINTS gamma")

    # Read the file, omit lines matching the pattern
    with open('tmp_file_0', 'r') as file:
        lines = file.readlines()

    # Keep track of lines to keep
    lines_to_keep = [line for line in lines if not pattern_regex.search(line)]

    # Write the modified content back to the nscf file
    with open(nscf_path, 'w') as file:
        file.writelines(lines_to_keep)
        file.write("K_POINTS {crystal_b}\n")
        file.write("{}\n".format(str(len(high_symmetry_points))))
        for idx in high_symmetry_points:
            file.write("{}\n".format(idx))
    os.remove('tmp_file_0')
    # Generate bands file
    namelist_name = 'BANDS'
    namelist_content= {}
    namelist_content['prefix'] = template['control']['prefix']
    namelist_content['outdir'] = template['control']['outdir']
    namelist_content['filband'] = bands_data_path
    write_namelist(bands_path, namelist_name, namelist_content)

    # Displaying information about the generated Quantum Espresso input files and BANDS data collection.

    print("-----------------------------------------------------------")
    print("Generated Quantum Espresso SCF input file    : {:s}".format(scf_path))
    print("Generated Quantum Espresso NSCF input file   : {:s}".format(nscf_path))
    print("Generated Quantum Espresso BANDS input file  : {:s}".format(bands_path))
    print("BANDS data will be collected in file         : {:s}".format(bands_data_path))
    print("-----------------------------------------------------------")


def main():
    parser = argparse.ArgumentParser(description="Convert VASP POSCAR file to Quantum ESPRESSO input file")
    parser.add_argument("-p", "--poscar", help="Path to the POSCAR file", metavar="POSCAR", required=True)
    parser.add_argument("-t", "--template", help="Path to the template file", metavar="Template_filename", required=True)
    parser.add_argument("-sn", "--system-name", help="Path to the Quantum ESPRESSO PDOS data file", metavar="PDOS_Data_filename", required=True)
    parser.add_argument("-s", "--scf", help="Path to the Quantum ESPRESSO scf input file", metavar="SCF_Input_filename", required=True)
    parser.add_argument("-n", "--nscf", help="Path to the Quantum ESPRESSO nscf input file", metavar="NSCF_Input_filename", required=True)
    parser.add_argument("-b", "--bands", help="Path to the Quantum ESPRESSO bands input file", metavar="BANDS_Input_filename", required=True)
    parser.add_argument("-f", "--bands-data", help="Path to the Quantum ESPRESSO bands data file", metavar="BANDS_Data_filename", required=True)
    parser.add_argument("-v", "--version", action="version", version="%(prog)s {version}, Author: {author}".format(version=VERSION, author=AUTHOR), help="Show program's version number and author")
    args = parser.parse_args()

    template_filename = args.template
    poscar_filename = args.poscar
    scf_filename = args.scf
    nscf_filename = args.nscf
    bands_filename = args.bands
    bands_data_filename = args.bands_data
    system_name = args.system_name

    generate_input(template_filename, poscar_filename, scf_filename,nscf_filename,bands_filename,bands_data_filename,system_name)

if __name__ == "__main__":
    main()
