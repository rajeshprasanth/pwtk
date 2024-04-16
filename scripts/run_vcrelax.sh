#!/bin/bash
#
# Script version and author information
VERSION="1.0.0"
AUTHOR="Rajesh Prashanth A <rajeshprasanth@rediffmail.com>"
#
#
# Function to parse command-line options
# Usage: parse_options "$@"
parse_options() {
    # Parse command-line options using getopt
    args=$(getopt -o f:o:hv --long poscar:,output-dir:,help,version -n "$0" -- "$@")

    # Check for parsing errors
    if [ $? -ne 0 ]; then
        echo "Error: Invalid command-line options"
        exit 1
    fi

    # Extract options and their arguments into variables
    eval set -- "$args"
    while true; do
        case "$1" in
            -f | --poscar)
                poscar_filename="$2"
                shift 2
                ;;
            -o | --output-dir)
                output_dir="$2"
                shift 2
                ;;
            -h | --help)
                display_usage
                exit 0
                ;;
            -v | --version)
                display_version
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Internal error!"
                exit 1
                ;;
        esac
    done

    # Display help message if any required options are missing
    if [ -z "$poscar_filename" ] || [ -z "$output_dir" ]; then
        echo "Error: Missing required options"
        exit 1
    fi
}

# Function to display usage instructions
display_usage() {
    echo "Usage: $0 -f <poscar_filename> -o <output_dir>"
    echo "Options:"
    echo "  -f, --poscar     Path to the POSCAR file"
    echo "  -o, --output-dir Path to the output directory"
    echo "  -h, --help       Display this help message"
    echo "  -v, --version    Display version information"
}

# Function to display version information
display_version() {
    echo "$0 version $VERSION, created by $AUTHOR"
}

# Main script starts here

# Parse command-line options
parse_options "$@"

# Now you can use $poscar_filename and $output_dir variables in your script
echo "------------------------------------------------------------"
echo "Quantum Espresso Automation script"
echo "------------------------------------------------------------"
echo ""
echo "Started on : $(date +"%Y-%m-%d %H:%M:%S")"
#
# Create Parent output directory, if doesn't exist
mkdir -p $output_dir
#
# Define subdirectories for each calculations
subdir_scf="$output_dir/scf"
subdir_vcrelax="$output_dir/vcrelax"
subdir_bands="$output_dir/bands"
subdir_dos="$output_dir/dos"
subdir_pdos="$output_dir/pdos"

# Create subdirectories
mkdir -p "$subdir_scf" "$subdir_vcrelax" "$subdir_bands" "$subdir_dos" "$subdir_pdos"

# Define common variables (!!!sort of hard coded.!!!)
scf_template="./templates/template.scf.dat"
vcrelax_template="./templates/template.vcrelax.dat"

# Tracking information
echo -e "\nTracking Information:"
echo ""
echo "- Input POSCAR........................: $poscar_filename"
echo "- Parent Output directory.............: $output_dir"
echo "-- Subdirectories"
echo "--- SCF...............................: $subdir_scf"
echo "--- Vcrelax...........................: $subdir_vcrelax"
echo "--- Bands.............................: $subdir_bands"
echo "--- DOS...............................: $subdir_dos"
echo "--- PDOS..............................: $subdir_pdos"
echo

# Loading necessary modules
module load qe-7.3 > /dev/null

# Enable python Virtual Environment
source ~/venv/bin/activate

# Record start time
start_time=$(date +%s)

vcrelax () {
    cp $poscar_filename $subdir_vcrelax/Si.vcrelax_1_in.poscar
    start_step1=$(date +%s)
    max_step=5
    step=1
    while [ $step -le $max_step ]; do
        # Prepare input files for QE vcrelax calculations
        python poscar2pwi.py --poscar  $subdir_vcrelax/Si.vcrelax_${step}_in.poscar --template $vcrelax_template --pwi $subdir_vcrelax/Si.vcrelax_${step}.in > /dev/null
        mpirun -np 4 pw.x < $subdir_vcrelax/Si.vcrelax_${step}.in > $subdir_vcrelax/Si.vcrelax_${step}.out &
        run_pid=$!
        echo -n "Step # 1: Running QE vcrelax (pid: $run_pid) sub step: ${step} ... "
        wait "$run_pid"
        end_step1=$(date +%s)
        time_spent_step=$((end_step1 - start_step1))
        echo "Done (time spent so far: $time_spent_step seconds)"
        python pwo2poscar.py --pwo $subdir_vcrelax/Si.vcrelax_${step}.out --poscar $subdir_vcrelax/Si.vcrelax_${step}_out.poscar > /dev/null
        prev=$step
        step=$((step + 1))
        cp $subdir_vcrelax/Si.vcrelax_${prev}_out.poscar $subdir_vcrelax/Si.vcrelax_${step}_in.poscar
    done
}

bands () {
    cp $subdir_vcrelax/Si.vcrelax_${max_step}_out.poscar $subdir_bands/Si.scf.poscar

    python gen_bands.py --poscar $subdir_bands/Si.scf.poscar \
    --template $scf_template \
    --scf $subdir_bands/Si.scf.in \
    --nscf $subdir_bands/Si.nscf.in \
    --bands $subdir_bands/Si.bands.in \
    --bands-data $subdir_bands/Si.bands.dat > /dev/null

    mpirun -np 4 pw.x < $subdir_bands/Si.scf.in > $subdir_bands/Si.scf.out &
    run_pid=$!
    echo -n "Step # 2: Running QE SCF (pid: $run_pid) sub step 1 ... "
    wait "$run_pid"
    end_step2=$(date +%s)
    time_spent_step=$((end_step2 - start_step1))
    echo "Done (time spent so far: $time_spent_step seconds)"

    mpirun -np 4 pw.x < $subdir_bands/Si.nscf.in > $subdir_bands/Si.nscf.out &
    run_pid=$!
    echo -n "Step # 2: Running QE NSCF (pid: $run_pid) sub step 2 ... "
    wait "$run_pid"
    end_step2=$(date +%s)
    time_spent_step=$((end_step2 - start_step1))
    echo "Done (time spent so far: $time_spent_step seconds)"

    mpirun -np 4 bands.x < $subdir_bands/Si.bands.in > $subdir_bands/Si.bands.out &
    run_pid=$!
    echo -n "Step # 2: Running QE BANDS (pid: $run_pid) sub step 3 ... "
    wait "$run_pid"
    end_step2=$(date +%s)
    time_spent_step=$((end_step2 - start_step1))
    echo "Done (time spent so far: $time_spent_step seconds)"
}

dos () {
    cp $subdir_vcrelax/Si.vcrelax_${max_step}_out.poscar $subdir_dos/Si.scf.poscar

    python gen_dos.py --poscar $subdir_dos/Si.scf.poscar \
    --template $scf_template \
    --scf $subdir_dos/Si.scf.in \
    --nscf $subdir_dos/Si.nscf.in \
    --dos $subdir_dos/Si.dos.in \
    --dos-data $subdir_dos/Si.dos.dat > /dev/null

    mpirun -np 4 pw.x < $subdir_dos/Si.scf.in > $subdir_dos/Si.scf.out &
    run_pid=$!
    echo -n "Step # 2: Running QE SCF (pid: $run_pid) sub step 1 ... "
    wait "$run_pid"
    end_step2=$(date +%s)
    time_spent_step=$((end_step2 - start_step1))
    echo "Done (time spent so far: $time_spent_step seconds)"

    mpirun -np 4 pw.x < $subdir_dos/Si.nscf.in > $subdir_dos/Si.nscf.out &
    run_pid=$!
    echo -n "Step # 2: Running QE NSCF (pid: $run_pid) sub step 2 ... "
    wait "$run_pid"
    end_step2=$(date +%s)
    time_spent_step=$((end_step2 - start_step1))
    echo "Done (time spent so far: $time_spent_step seconds)"

    mpirun -np 4 dos.x < $subdir_dos/Si.dos.in > $subdir_dos/Si.dos.out &
    run_pid=$!
    echo -n "Step # 2: Running QE DOS (pid: $run_pid) sub step 3 ... "
    wait "$run_pid"
    end_step2=$(date +%s)
    time_spent_step=$((end_step2 - start_step1))
    echo "Done (time spent so far: $time_spent_step seconds)"
}
# step:1
vcrelax
bands
dos
