#!/bin/bash
source ../environment

result_dir="gen_bands_results"

rm -rf $result_dir && mkdir -p $result_dir

module load qe-7.3 mpi > /dev/null

i=1
for poscar_name in $(ls $ASSETS_DIR/POSCARS/*.poscar);do
    system_name=$(basename -s .poscar $poscar_name)

    python $UTILS_DIR/gen_bands.py --poscar $poscar_name \
    --scf $result_dir/$system_name.scf.in \
    --nscf $result_dir/$system_name.nscf.in \
    --bands $result_dir/$system_name.bands.in \
    --template $TEMPLATES_DIR/template.scf.dat  \
    --bands-data $result_dir/$system_name.bands.dat \
    --system-name $system_name > $result_dir/conversion.log

    # Run first command with status update
    echo " ------------ Running Test # $i ------------ "
    echo -ne "Running scf for test # $i with pid: $pid_code .... "
    mpirun -np 4 pw.x < $result_dir/$system_name.scf.in > $result_dir/$system_name.scf.out
    pid_code=$!
    wait $pid_code
    echo "Done"

    # Run second command with status update
    echo -ne "Running nscf for test # $i with pid: $pid_code .... "
    mpirun -np 4 pw.x < $result_dir/$system_name.nscf.in > $result_dir/$system_name.nscf.out
    pid_code=$!
    wait $pid_code
    echo "Done"

    # Run third command with status update
    echo -ne "Running bands for test # $i with pid: $pid_code .... "
    mpirun -np 4 bands.x < $result_dir/$system_name.bands.in > $result_dir/$system_name.bands.out
    pid_code=$!
    wait $pid_code
    echo "Done"
    echo " ------------ End of Test # $i ------------"
    echo
    i=$((i + 1))



done
