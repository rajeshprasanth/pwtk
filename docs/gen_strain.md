# **POSCAR Strain Application Script**

**Version:** 1.0.0
**Author:** Rajesh Prashanth A `<rajeshprasanth@rediffmail.com>`
**Date:** Thu Apr 4, 2024
**Purpose:** Apply uniaxial, biaxial, shear, or hydrostatic strain to a VASP POSCAR file.

---

## **1. Overview**

This script applies controlled strain to a crystal lattice in a POSCAR file. It supports **uniaxial, biaxial, shear, and hydrostatic strains**, allowing first-principles simulations of strained materials.

**Key Uses:**

* Study effects of mechanical strain on electronic, optical, and transport properties.
* Generate strained structures for DFT calculations.
* High-throughput material screening under various deformations.

---

## **2. Installation Requirements**

* Python 3.8+
* ASE (`pip install ase`)
* NumPy (`pip install numpy`)

---

## **3. Strain Types Supported**

| Type        | Direction(s)                             | Description                                   |
| ----------- | ---------------------------------------- | --------------------------------------------- |
| Uniaxial    | `x`, `y`, `z`                            | Stretch/compress along one axis               |
| Shear       | `xy`, `yz`, `xz`                         | Distort lattice shape without uniform scaling |
| Biaxial     | `xy-biaxial`, `yz-biaxial`, `xz-biaxial` | Expand/compress two axes simultaneously       |
| Hydrostatic | `xyz`                                    | Uniform expansion/compression along all axes  |

---

## **4. Mathematical Formalism**

### **4.1 Strain Tensor**

Strain is represented by a **second-order tensor** $\boldsymbol{\epsilon}$:

$$
\boldsymbol{\epsilon} =
\begin{pmatrix}
\epsilon_{xx} & \epsilon_{xy} & \epsilon_{xz} \\
\epsilon_{yx} & \epsilon_{yy} & \epsilon_{yz} \\
\epsilon_{zx} & \epsilon_{zy} & \epsilon_{zz}
\end{pmatrix}
$$

* **Uniaxial strain:** Only diagonal element along the axis is non-zero.
  Example, x-direction: $\epsilon_{xx} = \text{strain\_value}, \ \epsilon_{yy} = \epsilon_{zz} = 0$

* **Biaxial strain:** Two diagonal elements non-zero.
  Example, xy-plane: $\epsilon_{xx} = \epsilon_{yy} = \text{strain\_value}, \ \epsilon_{zz} = 0$

* **Shear strain:** Off-diagonal elements non-zero.
  Example, xy-plane: $\epsilon_{xy} = \epsilon_{yx} = \text{strain\_value}$

* **Hydrostatic strain:** All diagonal elements equal.
  $\epsilon_{xx} = \epsilon_{yy} = \epsilon_{zz} = \text{strain\_value}$

---

### **4.2 Deformation Matrix**

The **deformation gradient matrix** $\mathbf{F}$ is used to apply the strain:

$$
\mathbf{F} = \mathbf{I} + \boldsymbol{\epsilon}
$$

Where:

* $\mathbf{I}$ is the $3 \times 3$ identity matrix
* $\boldsymbol{\epsilon}$ is the strain tensor

---

### **4.3 Applying Strain to the Lattice**

The new lattice vectors $\mathbf{a}'_i$ are computed as:

$$
\mathbf{a}'_i = \mathbf{F} \cdot \mathbf{a}_i
$$

Where $\mathbf{a}_i$ are the original lattice vectors.

Atomic positions are scaled automatically in the ASE framework using `scale_atoms=True`:

$$
\mathbf{r}'_j = \mathbf{F} \cdot \mathbf{r}_j
$$

* $\mathbf{r}_j$ – original atomic positions
* $\mathbf{r}'_j$ – strained atomic positions

---

## **5. Script Functions**

### **5.1 apply\_strain(atoms, strain\_direction, strain\_percentage)**

**Purpose:** Apply the strain tensor to an ASE `Atoms` object.
**Returns:** ASE `Atoms` with updated lattice and positions.

### **5.2 read\_poscar(poscar\_file)**

Read a POSCAR file into an ASE `Atoms` object.

### **5.3 write\_poscar(atoms, output\_file)**

Write ASE `Atoms` to a POSCAR file, preserving lattice vectors and positions.

### **5.4 main()**

Command-line interface for batch usage.

---

## **6. Usage Examples**

```bash
# Uniaxial strain along x-axis by 2%
python apply_strain.py -i POSCAR -d x -s 2.0 -o POSCAR_strained

# Biaxial strain in xy-plane by -1.5%
python apply_strain.py -i POSCAR -d xy-biaxial -s -1.5 -o POSCAR_biaxial

# Hydrostatic strain (uniform expansion) by 0.5%
python apply_strain.py -i POSCAR -d xyz -s 0.5 -o POSCAR_hydro
```

---

## **7. Notes and Best Practices**

1. **Precision:** ASE uses double precision for coordinates.
2. **Relaxation:** For fixed cell relaxation, set `ISIF=2` in VASP.
3. **Strain Conventions:** Positive → expansion, Negative → compression.
4. **Error Handling:** Invalid strain directions raise `ValueError`.

---

## **8. Optional Improvements**

* Support for **strain series** and automated sweeps.
* Logging and automated file naming.
* Integration with high-throughput DFT pipelines.

---

## **9. References**

* ASE Documentation: [https://wiki.fysik.dtu.dk/ase/](https://wiki.fysik.dtu.dk/ase/)
* VASP POSCAR Format: [https://www.vasp.at/](https://www.vasp.at/)

---
