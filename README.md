<h1 style="text-align: center;">Thermokinetics Toolset</h1>
<div style="text-align: center;">

![Static Badge](https://img.shields.io/badge/Version-1.3-mediumseagreen)
![Static Badge](https://img.shields.io/badge/MATLAB-R2023a-blue)
![Static Badge](https://img.shields.io/badge/License-MIT-crimson)
![GitHub last commit (by committer)](https://img.shields.io/github/last-commit/xenozite/Thermokinetics-Toolset?color=orchid)
</div>

<div style="text-align: center;">

![logo](https://github-production-user-asset-6210df.s3.amazonaws.com/59807560/268472879-467c4a52-91c6-4423-a214-e932b161ef69.svg)
</div>

# About
<div style="text-align: justify;">

**Thermokinetics Toolset** is a set of half automated MATLAB scripts for performing analysis of thermal data (TGA, DSC) and obtaining a kinetic triplet for every reaction stage. Most programs with similar functionality are proprietary. Despite this, more and more free and open source variants have been appearing recently (ThermV, THINKS, takos, Kinetic Calculation, mixchar, pICNIK). Thermokinetics Toolset includes the implementation of the most common  model and model-free (isoconversional) kinetic methods for finding the activation energy of individual reaction stages, as well as the pre-exponential factor and model at the **nonisothermal** conditions.
</div>

# Features
<div style="text-align: justify;">

+ Model fitting methods:
  - [X] Direct differential (DD)
  - [X] Coats-Redfern (CR)
+ Model-free (isoconversional) methods:
  + Differential methods:
    - [X] Friedman (FR)
  + Integral methods:
    + Approximated:
      - [X] Ozawa-Flynn-Wall (OFW)
      - [X] Kissinger-Akahira-Sunose (KAS)
      - [X] Starink (STR)
      - [X] Nonlinear integral method by Vyazovkin (VYZ)
    + Numerical:
      - [X] Advanced Isoconvertional method by Vyazovkin (AIC)
      - [X] Average linear integral method (ALIM)
+ Kinetic Compensation Effect (KCE)
+ f(α), g(α), Z(α) Master Plots

Despite the abundance of methods, it is recommended to use FR, AIC, ALIM for analysis, since they can be used to obtain activation energy values with a low error in case of its variability with conversion.
</div>

# Usage
<div style="text-align: justify;">

1. The analysis begins with the preparation of data in CSV format and placing that file in main directory with some name, for example 'Data.csv':

| Temperature (°C) | Mass change (%) for every heat veloctiy | Heat change (mW/mg) for every heat veloctiy | Deconvoluted peak #1 for <span style="color:orange">first</span> velocity | ... |  Deconvoluted peak #N for <span style="color:orange">first</span> velocity | Deconvoluted peak #1 for <span style="color:orange">second</span> velocity |
|:-----------:|:---------------------------------------:| :-------------------------------------------:|:----:|:---:|:----:| :----: |
|     30.5    |                   99.3                  |                     -0.16                   | 0.05 | ... | 0.02 | ... |
|     31.2    |                   98.6                  |                     -0.21                   | 0.07 | ... | 0.03 | ... |
|     32.7    |                   97.1                  |                     -0.25                   | 0.08 | ... | 0.07 | ... |
|     ...     |                   ...                   |                      ...                    | ... | ... | ... | ... |

1. Open GlobalSettings.m and define initial masses of samples, heat velocities, steps and its temperature ranges, deconvoluted peaks count, target convertion range. This script will make precomputions for further usage in other ones. Deconvolution of peaks must be done using dm/dT vs T relation (% of lost mass/K). Here is an example:

```js
// We have 3 samples which were analysed on 3 velocities.
InitialMass = [21.8907 22.8865 23.8825];
InitialVelocities = [3 5 10];
// Number of steps which we will analyse without deconvolution in specified range.
// Set to 0 if you would like to analyze only separated peaks.
StepsCount = 1;
// Temperature ranges for every velocity.
Steps = [
    30.27800 328.21148;  // Velocity = 3.
    30.27800 348.26469;  // Velocity = 5.
    30.27800 375.95723]; // Velocity = 10.
// Number of deconvoluted peaks which we will analyse separately due to their intersection.
// Set to 0 if you would like to analyze only steps, basing on temperature ranges.
PeaksCount = 2;
// Total number of reaction stages.
StagesCount = StepsCount + PeaksCount;
// Target conversion range in which computions will be performed.
TargetConversions = 0.1:0.01:0.9;
```
There are several optimal experimentally revealed target conversions ranges scoped in table:

| Script | Target Conversion Range |
|:------:|:-----------------------:|
|  VYZ   |       0.1:0.01:0.9      |
|  AIC   |      0.1:0.00625:0.9    |
|  ALIM  |      0.1:0.00625:0.9    |
| OFW, KAS, STR | 0.1:0.01:0.9     |
| Friedman |      0.1:0.01:0.9     |
| CR | 0.01:0.01:0.99 |
| DD | 0.01:0.01:0.99 |
| KCE | 0.01:0.005:0.99 |
| f-MasterPlot | 0:0.025:1 |
| g-MasterPlot | 0.005:0.001:0.995 |
| Z-MasterPlot | 0:0.025:1 |

Despite this, they may be unique in your own case.

3. For viewing first results open Plotter.m and run. This script will plot TGA, DSC, DTG, Convertions dependencies.
<div style="text-align: center;">

![TG](https://private-user-images.githubusercontent.com/59807560/336993481-b592891b-c2ea-4ed2-a4c7-308dd2d3b20c.svg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MTc2MTgxNDQsIm5iZiI6MTcxNzYxNzg0NCwicGF0aCI6Ii81OTgwNzU2MC8zMzY5OTM0ODEtYjU5Mjg5MWItYzJlYS00ZWQyLWE0YzctMzA4ZGQyZDNiMjBjLnN2Zz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDA2MDUlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwNjA1VDIwMDQwNFomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPWJlY2ZkMDJlNDE4ZGI4ZGFjMDlhMDU4ZGViNWVjZDU5ZWE3Nzg2MDdmZDc4ZGFlMGY1ODQ3MDE0ZDhhYzYyZTkmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.y8qwMSA4ouXdtg8wgegeNwtmSSyI9zbyHwIEMqRyZCM)
</div>

4. Choose corresponding target convertion range and run any method for getting Ea dependencies for every reaction stage.

<div style="text-align: center;">

![Ea](https://github-production-user-asset-6210df.s3.amazonaws.com/59807560/268499813-8a199891-57c5-4d5d-bb91-4a4e4bb1416f.svg)
</div>

5. Basing on Ea variation set UseEaMeanValue flags in GlobalSettings.m for every reaction stage.

```js
// Reaction stages:    1     2     3
   UseEaMeanValue = [false false false];
```

6. Open KineticCompensationEffect.m and calculate values of pre-exponential factor A for every reaction stage basing on previous Ea values. In case of variable Ea, the pre-exponential factor A will also be variable and vice versa if Ea is constant with conversion then pre-exponential factor A will also be constant.

<div style="text-align: center;">

![A](https://github-production-user-asset-6210df.s3.amazonaws.com/59807560/268500444-81e4196f-f37e-47d8-84e0-4f780719354b.svg)
</div>

7. Choose corresponding target convertion range again and run any Master Plot method for getting the remaining component of the kinetic triplet - model. Script will plot reconstructed model of reaction stage on the background of ideal models. There are more then 30 models in database based on various common mechanisms (F1/3, F3/4, F3/2, F2, F3, A1, A3/2, A2, A3, A4, R1, R2, R3, P3/2, P1/2, P1/3, P1/4, E1, D1, D2, D3, D4, D5, D6, D7, D8, G1, G2, G3, G4, G5, G6, G7, G8).

<div style="text-align: center;">

![MP](https://github-production-user-asset-6210df.s3.amazonaws.com/59807560/268500563-b05ce73d-145e-440e-83f8-4ca4dc2ea58f.svg)
</div>
</div>
