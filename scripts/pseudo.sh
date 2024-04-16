#!/bin/bash
#
#
pseudo_dir=$1
export pseudo_dir

#echo "{" > pseudo.json
for file in $(ls $pseudo_dir/*.UPF);do
cat >> pseudo.json << EOF
    "$(grep "Element:" $file | gawk -F: '{print $2}'|xargs)" : {
        "element" : "$(grep "Element:" $file | gawk -F: '{print $2}'|xargs)",
        "filename" : "$(basename $file|xargs)",
        "pseudopotential" : "$(grep "Pseudopotential type:" $file | gawk -F: '{print $2}'|xargs)",
        "functional" : "$(grep "Functional" $file | gawk -F: '{print $2}'|xargs)",
        "cutoff_wfc" : $(grep "Suggested minimum cutoff for wavefunctions:" $file | gawk '{print $6}'|xargs),
        "cutoff_rho" : $(grep "Suggested minimum cutoff for charge density:" $file | gawk '{print $7}'|xargs),
        "md5" : "$(md5sum $file | gawk '{print $1}'|xargs)"
    },
EOF
done
#echo "}" >> pseudo.json

