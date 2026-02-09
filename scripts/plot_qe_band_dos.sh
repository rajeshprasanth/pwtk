#!/bin/bash

# -------------------------------
# Check for config file argument
# -------------------------------

if [ $# -lt 1 ]; then
    echo "Usage: $0 <config_file>"
    echo
    echo "Example:"
    echo "  $0 plot.conf"
    exit 1
fi

CONFIG_FILE="$1"

# Check if file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file '$CONFIG_FILE' not found!"
    exit 1
fi

# Load variables from config
source "$CONFIG_FILE"


# ==========================================
# FILE CHECK
# ==========================================
for f in "$BANDS_DATA_FILE" "$DOS_DATA_FILE" "$BANDS_OUT" "$SCF_OUT"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: File not found -> $f"
        exit 1
    fi
done



# ==========================================
# EXTRACT FERMI ENERGY
# ==========================================
FERMI=$(grep "the Fermi energy is" "$SCF_OUT" | awk '{print $5}')

if [ -z "$FERMI" ]; then
    echo "ERROR: Could not detect Fermi energy!"
    exit 1
fi


# ==========================================
# EXTRACT HIGH-SYMMETRY K-POINT POSITIONS
# ==========================================
KPTS=($(grep "high-symmetry point" "$BANDS_OUT" | awk '{print $NF}'))

# Safety check
if [ ${#KPTS[@]} -ne ${#KLABELS[@]} ]; then
    echo "ERROR: Number of k-points and labels do not match!"
    echo "K-points found : ${#KPTS[@]}"
    echo "Labels defined : ${#KLABELS[@]}"
    exit 1
fi

echo " ============================================================"
echo "           QE Bands & Dos Plotting Program v1.0         "
echo " ============================================================"
echo
echo " PREFIX            : $PREFIX"
echo " TITLE             : $TITLE"
echo " BANDS TITLE       : $BANDS_TITLE"
echo " DOS TITLE         : $DOS_TITLE"
echo
echo " BANDS_DATA_FILE   : $BANDS_DATA_FILE"
echo " DOS_DATA_FILE     : $DOS_DATA_FILE"
echo " BANDS_OUT         : $BANDS_OUT"
echo " SCF_OUT           : $SCF_OUT"
echo
echo " Energy Range      : $EMIN  to  $EMAX  eV"
echo " DOS Range         : $DOSMIN  to  $DOSMAX"
echo
echo " Fermi Energy      : $FERMI eV"
echo
echo " High Symmetry points"
for ((i=0; i<${#KPTS[@]}; i++)); do
    echo "     kvec($i) ---> ${KLABELS[$i]} at ${KPTS[$i]}"
done
echo


# ==========================================
# GENERATE BANDS GNUPLOT SCRIPT
# ==========================================

cat > $PREFIX.bands.gp << EOF
# ---------------------------------
# Multipurpose terminal selection
# ---------------------------------

prefix = "$PREFIX.bands"
format = "$FORMAT"
title = "$BANDS_TITLE"

if ("$FORMAT" eq "png") {
    set terminal pngcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.png", prefix)
}

if ("$FORMAT" eq "pdf") {
    set terminal pdfcairo enhanced font "Arial,14" size 6,4
    set output sprintf("%s.pdf", prefix)
}

if ("$FORMAT" eq "jpeg") {
    set terminal jpegcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.jpg", prefix)
}



set label 100 title at screen 0.5,0.95 center font ",18"

fermi = $FERMI

# ==========================================
# LEFT PANEL : BAND STRUCTURE
# ==========================================

#set lmargin at screen 0.10
#set rmargin at screen 0.58
set bmargin at screen 0.12
set tmargin at screen 0.90


set ylabel "Energy (eV)"

set yrange [$EMIN:$EMAX]
unset grid
set key off

set xtics nomirror
set ytics nomirror
set tics out

EOF

# -------- Vertical symmetry lines ----------
for k in "${KPTS[@]}"; do
echo "set arrow from $k,$EMIN to $k,$EMAX nohead dt 2 lw 1 lc rgb 'black'" >> $PREFIX.bands.gp
done

# -------- X-tics from config labels ----------
echo -n "set xtics (" >> $PREFIX.bands.gp
for i in "${!KPTS[@]}"; do
    if [ $i -eq 0 ]; then
        echo -n "\"${KLABELS[$i]}\" ${KPTS[$i]}" >> $PREFIX.bands.gp
    else
        echo -n ", \"${KLABELS[$i]}\" ${KPTS[$i]}" >> $PREFIX.bands.gp
    fi
done
echo ")" >> $PREFIX.bands.gp

cat >> $PREFIX.bands.gp << EOF

# -------- Fermi level (Band panel) ----------
set arrow 100 from graph 0, first 0 to graph 1, first 0 \
    nohead dt 2 lw 1 lc rgb "black"

#plot '$BANDS_DATA_FILE' using 1:(\$2-fermi) w l lw 1.5 lc rgb "blue"
plot '$BANDS_DATA_FILE' using 1:(\$2-fermi) w l lw 1.5 lc rgb "black"

EOF

# ==============================================
# GENERATE DOS GNUPLOT SCRIPT
# ==============================================


cat > $PREFIX.dos.gp<< EOF
# ---------------------------------
# Multipurpose terminal selection
# ---------------------------------

prefix = "$PREFIX.dos"
format = "$FORMAT"
title = "$DOS_TITLE"

if ("$FORMAT" eq "png") {
    set terminal pngcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.png", prefix)
}

if ("$FORMAT" eq "pdf") {
    set terminal pdfcairo enhanced font "Arial,14" size 6,4
    set output sprintf("%s.pdf", prefix)
}

if ("$FORMAT" eq "jpeg") {
    set terminal jpegcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.jpg", prefix)
}

set label 100 title at screen 0.5,0.95 center font ",18"

fermi = $FERMI

unset arrow


set bmargin at screen 0.12
set tmargin at screen 0.90

set ylabel "DOS (states/eV)"
set xlabel "Energy (eV)"


set xrange [$EMIN:$EMAX]
set yrange [$DOSMIN:$DOSMAX]

set xtics nomirror
set ytics nomirror

set tics out

unset grid
set key off

# -------- Fermi level (DOS panel) ----------
set arrow 200 from graph 0, first 0 to graph 1, first 0 \
    nohead dt 2 lw 1 lc rgb "black"

#plot '$DOS_DATA_FILE' using 2:(\$1-fermi):2 w l lw 1.5 lc rgb "red"
plot '$DOS_DATA_FILE' using (\$1-fermi):2 w l lw 1.5 lc rgb "black"

unset multiplot
EOF
# ==============================================
# GENERATE COMBINED BANDS AND DOS GNUPLOT SCRIPT
# ==============================================
cat > $PREFIX.bands.dos.gp<< EOF
# ---------------------------------
# Multipurpose terminal selection
# ---------------------------------

prefix = "$PREFIX.bands.dos"
format = "$FORMAT"
title = "$TITLE"

if ("$FORMAT" eq "png") {
    set terminal pngcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.png", prefix)
}

if ("$FORMAT" eq "pdf") {
    set terminal pdfcairo enhanced font "Arial,14" size 6,4
    set output sprintf("%s.pdf", prefix)
}

if ("$FORMAT" eq "jpeg") {
    set terminal jpegcairo enhanced font "Arial,14" size 1800,1200
    set output sprintf("%s.jpg", prefix)
}


set multiplot

set label 100 title at screen 0.5,0.95 center font ",18"

fermi = $FERMI

# ==========================================
# LEFT PANEL : BAND STRUCTURE
# ==========================================

set lmargin at screen 0.10
set rmargin at screen 0.58
set bmargin at screen 0.12
set tmargin at screen 0.90


set ylabel "Energy (eV)"

set yrange [$EMIN:$EMAX]
unset grid
set key off

set xtics nomirror
set ytics nomirror
set tics out

EOF

# -------- Vertical symmetry lines ----------
for k in "${KPTS[@]}"; do
echo "set arrow from $k,$EMIN to $k,$EMAX nohead dt 2 lw 1 lc rgb 'black'" >> $PREFIX.bands.dos.gp
done

# -------- X-tics from config labels ----------
echo -n "set xtics (" >> $PREFIX.bands.dos.gp
for i in "${!KPTS[@]}"; do
    if [ $i -eq 0 ]; then
        echo -n "\"${KLABELS[$i]}\" ${KPTS[$i]}" >> $PREFIX.bands.dos.gp
    else
        echo -n ", \"${KLABELS[$i]}\" ${KPTS[$i]}" >> $PREFIX.bands.dos.gp
    fi
done
echo ")" >> $PREFIX.bands.dos.gp

cat >> $PREFIX.bands.dos.gp<< EOF

# -------- Fermi level (Band panel) ----------
set arrow 100 from graph 0, first 0 to graph 1, first 0 \
    nohead dt 2 lw 1 lc rgb "black"

#plot '$BANDS_DATA_FILE' using 1:(\$2-fermi) w l lw 1.5 lc rgb "blue"
plot '$BANDS_DATA_FILE' using 1:(\$2-fermi) w l lw 1.5 lc rgb "black"

# ==========================================
# RIGHT PANEL : DOS
# ==========================================

unset arrow
unset xtics

set lmargin at screen 0.62
set rmargin at screen 0.90
set bmargin at screen 0.12
set tmargin at screen 0.90

set xlabel "DOS (states/eV)"
unset ylabel
unset ytics

set yrange [$EMIN:$EMAX]
set xrange [$DOSMIN:$DOSMAX]

unset ytics
set xtics nomirror
set tics out

unset grid
set key off

# -------- Fermi level (DOS panel) ----------
set arrow 200 from graph 0, first 0 to graph 1, first 0 \
    nohead dt 2 lw 1 lc rgb "black"

#plot '$DOS_DATA_FILE' using 2:(\$1-fermi) w l lw 1.5 lc rgb "red"
plot '$DOS_DATA_FILE' using 2:(\$1-fermi) w l lw 1.5 lc rgb "black"

unset multiplot
EOF

# ==========================================
# RUN GNUPLOT
# ==========================================
echo

echo " Writing gnuplot instructions to file : $PREFIX.bands.gp"
echo " Writing gnuplot instructions to file : $PREFIX.dos.gp"
echo " Writing gnuplot instructions to file : $PREFIX.bands.dos.gp"

gnuplot $PREFIX.bands.gp
gnuplot $PREFIX.dos.gp
gnuplot $PREFIX.bands.dos.gp
echo
echo " Plot saved to file : ${PREFIX}.bands.${FORMAT}"
echo " Plot saved to file : ${PREFIX}.dos.${FORMAT}"
echo " Plot saved to file : ${PREFIX}.bands.dos.${FORMAT}"
echo
echo " =-------------------------------------------------------="
echo " JOB DONE"
echo " =-------------------------------------------------------="
