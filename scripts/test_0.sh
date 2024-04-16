#!/bin/bash
#
echo "------------------------------------------------------------"
echo "Quantum Espresso Automation script"
echo "------------------------------------------------------------"

# Cleanup residual files if exist

# Define parent directory
rm -rf Silicon Conversion.log
parent_dir="./Silicon"

# Create parent directory if it doesn't exist
mkdir -p "$parent_dir"

# Define subdirectories for each conversion
subdir_scf="$parent_dir/scf"
subdir_vcrelax="$parent_dir/vcrelax"
subdir_bands="$parent_dir/bands"
subdir_dos="$parent_dir/dos"
subdir_pdos="$parent_dir/pdos"

# Create subdirectories
mkdir -p "$subdir_scf" "$subdir_vcrelax" "$subdir_bands" "$subdir_dos" "$subdir_pdos"

# Define common variables
scf_template="./templates/template.scf.dat"
vcrelax_template="./templates/template.vcrelax.dat"

# Check if all required arguments are provided
if [ "$#" -ne 8 ]; then
    echo "Usage: $0 --strain/-s <strain_direction> --strain-percentage/-p <strain_percentage> --poscar/-f <poscar_filename> --output-dir/-o <output_dir>"
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -s|--strain)
            strain_direction="$2"
            shift
            shift
            ;;
        -p|--strain-percentage)
            strain_percentage="$2"
            shift
            shift
            ;;
        -f|--poscar)
            poscar_filename="$2"
            shift
            shift
            ;;
        -o|--output-dir)
            output_dir="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            exit 1
            ;;
    esac
done

# Tracking information
echo -e "\nTracking Information:"
echo "- Parent directory: $parent_dir"
echo "-- Subdirectories:"
echo "--- SCF: $subdir_scf"
echo "--- Vcrelax: $subdir_vcrelax"
echo "--- Bands: $subdir_bands"
echo "--- DOS: $subdir_dos"
echo "--- PDOS: $subdir_pdos"

# Loading necessary modules
echo -e "\nLoading Modules..."
module load qe-7.3

# Enable python Virtual Environment
source ~/venv/bin/activate

# Record start time
start_time=$(date +%s)

# Step #1: Converting POSCAR to QE vcrelax input file
echo -e "\nStep #1: Converting POSCAR to QE vcrelax input file..."
echo "Step #1 -- Log Begin --" >> Conversion.log
start_step1=$(date +%s)
python poscar2pwi.py --poscar "$poscar_filename" --template "$vcrelax_template" --pwi "$output_dir/Si.vcrelax_0.in" >> Conversion.log
end_step1=$(date +%s)
time_spent_step1=$((end_step1 - start_step1))
echo "Step #1 -- Log End --" >> Conversion.log
echo "Done (time spent: $time_spent_step1 seconds)"

# Step #2: Running QE vcrelax
echo -e "\nStep #2: Running QE vcrelax..."
start_step2=$(date +%s)
mpirun -np 4 pw.x < "$output_dir/Si.vcrelax_0.in" > "$output_dir/Si.vcrelax_0.out" &
run_pid=$!
echo -n "---> Step #2: Running QE vcrelax (pid: $run_pid) sub step: 1 ... "
wait "$run_pid"
end_step2=$(date +%s)
time_spent_step2=$((end_step2 - start_step2))
echo "Done (time spent: $time_spent_step2 seconds)"

# Record end time
end_time=$(date +%s)
echo -e "\nTotal time spent: $((end_time - start_time)) seconds"
