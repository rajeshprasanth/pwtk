# QE Band Structure + DOS Plotting Tool

A configurable shell-based plotting utility for generating **Band Structure**, **Density of States (DOS)**, and **Combined Band + DOS** plots from Quantum ESPRESSO outputs using **gnuplot**.

This tool is fully driven by a configuration file — no need to modify the main script for different systems.

---

# Features

* ✔ Automatic Fermi energy extraction
* ✔ Automatic high-symmetry k-point detection
* ✔ Energy aligned to Fermi level (E − Ef)
* ✔ Band-only plot
* ✔ DOS-only plot
* ✔ Combined Band + DOS plot
* ✔ Supports `pdf`, `png`, and `jpeg` output formats
* ✔ Configurable energy and DOS ranges
* ✔ High-symmetry labels support (including Γ)

---

# Requirements

* Quantum ESPRESSO
* gnuplot (with cairo support recommended)
* Bash shell (Linux environment)

Check gnuplot installation:

```bash
gnuplot --version
```

---

# Directory Structure Expected

Your QE calculation directory must contain:

```
system.bands.dat.gnu     (from bands.x)
system.dos.dat           (from dos.x)
system.bands.out         (bands.x output)
system.nscf.dos.out      (for Fermi energy)
```

---

# How to Use

## Step 1 — Prepare Configuration File

Create a config file (e.g., `plot.conf`) and define system-specific parameters.

Example:

```bash
./plot.sh plot.conf
```

The script will:

* Read file paths
* Extract Fermi energy
* Extract high-symmetry points
* Generate gnuplot scripts
* Produce output plots

---

# Configuration File Guide

The configuration file controls everything. No modification of the main script is required.

---

## 1️. System & File Paths

```bash
LAYER_1="BN"
LAYER_2="MoS2"
```

Used for labeling and file path construction.

---

### Base Data Directory

```bash
DATAFILE_PATH="/path/to/qe/output/${LAYER_1}_${LAYER_2}.soc"
```

Must contain QE output files.

---

### Required QE Files

```bash
BANDS_DATA_FILE="...bands.dat.gnu"
DOS_DATA_FILE="...dos.dat"
BANDS_OUT="...bands.out"
SCF_OUT="...nscf.dos.out"
```

---

## 2️. Output Settings

```bash
PREFIX=${LAYER_1}_${LAYER_2}
FORMAT="pdf"
```

Supported formats:

* `pdf` → Recommended for journal publication
* `png` → Good for thesis/PPT
* `jpeg` → Not recommended for publication

Output files generated:

```
PREFIX.bands.pdf
PREFIX.dos.pdf
PREFIX.bands.dos.pdf
```

---

## 3️. Titles

```bash
TITLE="BN/MoS2 Bandstructure and DOS"
BANDS_TITLE="BN/MoS2 Bandstructure"
DOS_TITLE="BN/MoS2 DOS"
```

Used in figure headers.

---

## 4️. Energy Window (Relative to Fermi Level)

```bash
EMIN=-4
EMAX=4
```

Energy is plotted as:

```
E - Ef
```

So Fermi level is always at **0 eV**.

---

## 5️. DOS Range

```bash
DOSMIN=0
DOSMAX=40
```

Controls vertical extent of DOS-only plot
(or horizontal extent in combined plot).

---

## 6️. High-Symmetry Labels

```bash
KLABELS=("Γ" "K" "M" "Γ")
```

Must match number of high-symmetry points extracted from `bands.out`.

If mismatch occurs, script will stop with an error.

### Greek Symbols

For better gnuplot compatibility:

```bash
KLABELS=("{/Symbol G}" "K" "M" "{/Symbol G}")
```

---

# Plot Behavior

## Band Plot

* X-axis → k-path
* Y-axis → Energy (E − Ef)
* Horizontal dashed line → Fermi level

---

## DOS Plot

* X-axis → Energy (E − Ef)
* Y-axis → DOS
* Vertical dashed line → Fermi level (E = 0)

---

## Combined Plot

Left panel:

* Band structure

Right panel:

* DOS (aligned in energy)

---

# Error Handling

The script automatically checks:

* Config file existence
* Required QE files
* Fermi energy detection
* Matching high-symmetry labels

If any issue occurs, execution stops with a clear error message.

---

# Recommended Workflow

1. Run SCF
2. Run NSCF
3. Run bands.x
4. Run dos.x
5. Prepare `plot.conf`
6. Run plotting script

---

# Best Format for Different Use Cases

| Use Case       | Recommended Format |
| -------------- | ------------------ |
| Journal Paper  | pdf                |
| Conference PPT | png                |
| PhD Thesis     | pdf                |
| Quick Check    | png                |

---

# Version

QE Bands & DOS Plotting Program v1.0

---

# Author Notes

This script is designed for:

* 2D materials
* Heterostructures
* SOC calculations
* High-throughput plotting workflows

It is modular and easily extendable for:

* Spin-polarized calculations
* Projected DOS
* Fat band plots
* Publication-quality styling

