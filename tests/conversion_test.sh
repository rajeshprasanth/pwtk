#!/bin/bash
source ../environment
POSCAR="$ASSETS_DIR/Si.prim.poscar"

rm -rf conversion_test_results && mkdir -p conversion_test_results

i=1
for file in $(ls $ASSETS_DIR/POSCARS/*.poscar);do
        for cell_type in "p" "c"; do
            poscar_name=$(basename $file)
            echo " ------------ Running Test # $i ------------ "
            echo " --Input file  : $poscar_name"
            echo " --Output file : ${cell_type}_$poscar_name"
            echo " --Cell type   : $cell_type"
            python $UTILS_DIR/convert_crystal.py --input_file $file \
            --cell_type $cell_type
            --output_file conversion_test_results/${cell_type}_${poscar_name} \
            > /dev/null
            if [ $? -eq 0 ]; then
                echo " --Status      : Passed"
            else
                echo " --Status      : Failed"
            fi
            echo " ------------ End of Test # $i ------------"
            echo
            i=$((i + 1))
        done
done
