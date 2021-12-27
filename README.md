<p>
<h1 align="center">Reversible image authentication scheme with blind content reconstruction based on compressed sensing</h1>
</p>  

<p align='center'>
  <b><a href="https://github.com/MelendezGab/">G. Melendez-Melendez</a><sup>1</sup>, R. Cumplido<sup>1</sup>
</p>

 <p align='center'>
<sup>1</sup> <a href="https://www.inaoep.mx/"> Instituto Nacional de Astrofísica, Óptica y Electrónica - INAOE </a>, Luis Enrique Erro #1, CP 72840, Puebla, México. 
</p> 

<p align='left'>
For further detail, please refer to:
</p>

<p align='center'>
  <b> <a href="https://doi.org/10.1016/j.jestch.2021.101080">https://doi.org/10.1016/j.jestch.2021.101080</a></b>
</p>


## Introduction
<b>This repository contains the updated version of the proposed reversible image authentication (RIA) scheme.</b> RIA schemes employ fragile watermarks to protect images against tampering attacks. If a marked image is not attacked, the watermarks can be completely eliminated, and original cover image is obtained. In our scheme, watermarks are complemented using reference values obtained with compressed sensing theory for reconstruction purposes. Sparse signal levels of image blocks can be modified by omitting some DCT coefficients according to threshold T<sub>d</sub>, improving reconstruction results.

<p align="center">
<img src='https://github.com/MelendezGab/ria-scheme/blob/main/scheme.png' width=750>
</p>


## Instructions

MATLAB software is required with next toolboxes:
- Wavelet toolbox
- Image processing toolbox 

For simulation, clone/download this repository and run Demo_RIA.m file.

## Tested platform
This software has been tested on: 
- MATLAB R2021a / Windows 10

Feedback, questions and bug reports are welcome and encouraged.