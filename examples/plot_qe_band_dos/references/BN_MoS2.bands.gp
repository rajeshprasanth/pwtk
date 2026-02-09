# ---------------------------------
# Multipurpose terminal selection
# ---------------------------------

prefix = "BN_MoS2.bands"
format = "pdf"
title = "BN/MoS2 Bandstructure"

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

# ==========================================
# LEFT PANEL : BAND STRUCTURE
# ==========================================

#set lmargin at screen 0.10
#set rmargin at screen 0.58
set bmargin at screen 0.12
set tmargin at screen 0.90


set ylabel "Energy (eV)"

set yrange [-4:4]
unset grid
set key off

set xtics nomirror
set ytics nomirror
set tics out

set arrow from 0.0000,-4 to 0.0000,4 nohead dt 2 lw 1 lc rgb 'black'
set arrow from 0.5774,-4 to 0.5774,4 nohead dt 2 lw 1 lc rgb 'black'
set arrow from 0.9107,-4 to 0.9107,4 nohead dt 2 lw 1 lc rgb 'black'
set arrow from 1.5773,-4 to 1.5773,4 nohead dt 2 lw 1 lc rgb 'black'
set xtics ("Γ" 0.0000, "K" 0.5774, "M" 0.9107, "Γ" 1.5773)

# -------- Fermi level (Band panel) ----------
set arrow 100 from graph 0, first 0 to graph 1, first 0     nohead dt 2 lw 1 lc rgb "black"

#plot '/home/rajeshprashanth/gcp_output_02042026/es_soc_ncpp/BN_MoS2.soc/BN_MoS2.soc.bands.dat.gnu' using 1:($2-fermi) w l lw 1.5 lc rgb "blue"
plot '/home/rajeshprashanth/gcp_output_02042026/es_soc_ncpp/BN_MoS2.soc/BN_MoS2.soc.bands.dat.gnu' using 1:($2-fermi) w l lw 1.5 lc rgb "black"

