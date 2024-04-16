#!/usr/bin/env python
###########################################################################
# VERSION = '1.0.0'
# Author : Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'
# Written on Thu Apr  4 10:06:05 AM IST 2024
###########################################################################
# Purpose : This script converts a POSCAR file to Quantum Espresso input files for DOS calculations.
###########################################################################

import argparse
import json
from ase.io import read, write
import f90nml

VERSION = '1.0.0'
AUTHOR = 'Rajesh Prashanth A <rajeshprasanth@rediffmail.com>'

def write_namelist(file_path, namelist_name, namelist_content):
    """
    Write a Fortran namelist to a file.

    Parameters:
        file_path (str): Path to the output file.
        namelist_name (str): Name of the namelist.
        namelist_content (dict): Content of the namelist.

    Returns:
        None
    """
    namelist = {namelist_name: namelist_content}
    f90nml.write(namelist, file_path, force=True)


def generate_input(template_path, poscar_path, scf_path, nscf_path, dos_path, dos_data_path, system_name):
    """
    Generate Quantum Espresso input files for DOS calculations.

    Parameters:
        template_path (str): Path to the template file.
        poscar_path (str): Path to the POSCAR file.
        scf_path (str): Path to save the Quantum Espresso SCF input file.
        nscf_path (str): Path to save the Quantum Espresso NSCF input file.
        dos_path (str): Path to save the Quantum Espresso DOS input file.
        dos_data_path (str): Path to save the DOS data file.

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
    #
    template['control']['prefix'] = system_name
    template['control']['title'] = system_name
    template['control']['outdir'] = "./" + str(system_name)
    #
    template['system']['nat'] = num_atoms
    template['system']['ntyp'] = num_species

    # Write Quantum ESPRESSO SCF input file
    write(scf_path, atoms, format='espresso-in', input_data=template, pseudopotentials=template['pseudopotentials'], kspacing=template['kspacing'], crystal_coordinates=template['crystal_coordinates'], pw=False)

    # Update template for NSCF calculations
    template['control']['calculation'] = 'nscf'
    template['system']['occupations'] = 'tetrahedra'

    # Write Quantum ESPRESSO NSCF input file
    write(nscf_path, atoms, format='espresso-in', input_data=template, pseudopotentials=template['pseudopotentials'], kspacing=template['kspacing'], crystal_coordinates=template['crystal_coordinates'], pw=False)

    # Write Quantum ESPRESSO DOS input file
    namelist_name = 'DOS'
    namelist_content = {
        'prefix': template['control']['prefix'],
        'outdir': template['control']['outdir'],
        'Emin': -20,
        'Emax': 20,
        'DeltaE': 0.1,
        'fildos': dos_data_path
    }
    write_namelist(dos_path, namelist_name, namelist_content)

    # Displaying file paths and information about generated Quantum Espresso input files and DOS data collection.
    print("-----------------------------------------------------------")
    print("Quantum Espresso SCF input file     : {:s}".format(scf_path))
    print("Quantum Espresso NSCF input file    : {:s}".format(nscf_path))
    print("Quantum Espresso DOS input file     : {:s}".format(dos_path))
    print("DOS data collection file            : {:s}".format(dos_data_path))
    print("-----------------------------------------------------------")


def main():
    """
    Main function to parse command line arguments and execute conversion.
    """
    parser = argparse.ArgumentParser(description="Convert VASP POSCAR file to Quantum ESPRESSO input files for DOS Calculations.")
    parser.add_argument("-p", "--poscar", help="Path to the POSCAR file", metavar="POSCAR", required=True)
    parser.add_argument("-t", "--template", help="Path to the template file", metavar="Template_filename", required=True)
    parser.add_argument("-sn", "--system-name", help="Path to the Quantum ESPRESSO PDOS data file", metavar="PDOS_Data_filename", required=True)
    parser.add_argument("-s", "--scf", help="Path to the Quantum ESPRESSO SCF input file", metavar="SCF_Input_filename", required=True)
    parser.add_argument("-n", "--nscf", help="Path to the Quantum ESPRESSO NSCF input file", metavar="NSCF_Input_filename", required=True)
    parser.add_argument("-d", "--dos", help="Path to the Quantum ESPRESSO DOS input file", metavar="DOS_Input_filename", required=True)
    parser.add_argument("-f", "--dos-data", help="Path to the Quantum ESPRESSO DOS data file", metavar="DOS_Data_filename", required=True)
    parser.add_argument("-v", "--version", action="version", version="%(prog)s {version}, Author: {author}".format(version=VERSION, author=AUTHOR), help="Show program's version number and author")
    args = parser.parse_args()

    template_filename = args.template
    poscar_filename = args.poscar
    scf_filename = args.scf
    nscf_filename = args.nscf
    dos_filename = args.dos
    dos_data_filename = args.dos_data
    system_name = args.system_name

    generate_input(template_filename, poscar_filename, scf_filename, nscf_filename, dos_filename, dos_data_filename,system_name)

if __name__ == "__main__":
    main()
