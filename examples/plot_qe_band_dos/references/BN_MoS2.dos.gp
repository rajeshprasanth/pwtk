# ---------------------------------
# Multipurpose terminal selection
# ---------------------------------

prefix = "BN_MoS2.dos"
format = "pdf"
title = "BN/MoS2 DOS"

if ("pdf" eq "png") {
    set terminal pngcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.png", prefix)
}

if ("pdf" eq "pdf") {
    set terminal pdfcairo enhanced font "Arial,14" size 6,4
    set output sprintf("%s.pdf", prefix)
}

if ("pdf" eq "jpeg") {
    set terminal jpegcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.jpg", prefix)
}

set label 100 title at screen 0.5,0.95 center font ",18"

fermi = -5.5476

unset arrow


set bmargin at screen 0.12
set tmargin at screen 0.90

set ylabel "DOS (states/eV)"
set xlabel "Energy (eV)"


set xrange [-4:4]
set yrange [0:40]

set xtics nomirror
set ytics nomirror

set tics out

unset grid
set key off

# -------- Fermi level (DOS panel) ----------


set arrow 200 from 0,0 to 0,40     nohead dt 2 lw 1 lc rgb "black"

#plot '/home/rajeshprashanth/gcp_output_02042026/es_soc_ncpp/BN_MoS2.soc/BN_MoS2.soc.dos.dat' using 2:($1-fermi):2 w l lw 1.5 lc rgb "red"
plot '/home/rajeshprashanth/gcp_output_02042026/es_soc_ncpp/BN_MoS2.soc/BN_MoS2.soc.dos.dat' using ($1-fermi):2 w l lw 1.5 lc rgb "black"

unset multiplot
