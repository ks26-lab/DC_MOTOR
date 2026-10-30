# Working Model of a Permanent-Magnet DC Motor

A low-cost working model of a **permanent-magnet DC motor**, supported
by a MATLAB 3D/dynamic simulation and a FEMM magnetic-field simulation.

## Project Overview

The motor uses an enamelled copper-wire coil mounted on two safety-pin
supports and placed between two N35 neodymium magnets. When current
flows through the coil, the magnetic field produces Lorentz forces on
its opposite sides. These forces create torque and rotate the coil. The
partially stripped axle ends provide simple mechanical commutation.

## Main Components

-   26 SWG enamelled copper wire (approximately 3 m)
-   Two steel safety pins (supports and electrical contacts)
-   Two N35 neodymium magnets (20 × 12 × 6 mm)
-   Cardboard base
-   12 V, 2 A DC adapter and DC jack-to-screw-terminal connector

## Simulations

-   **MATLAB:** 3D motor layout and coil-motion model. The dynamics are
    integrated using `ode45`.
-   **FEMM:** 2D magnetic-field and torque analysis. The Lua script
    `coil_magnet_femm.lua` evaluates the field and torque for different
    coil angles and exports results to `femm_results.csv`.

## Running the Simulations

1.  Open the MATLAB project files in MATLAB and run the main simulation
    script.
2.  Open FEMM and run `coil_magnet_femm.lua` using FEMM's Lua scripting
    environment.
3.  Check the generated plots and `femm_results.csv` for simulation
    outputs.

*The report does not specify the MATLAB entry-point filename; run the
main script supplied with the project.*

## Important Model Values

  Parameter                                          Value
  --------------------------------- ----------------------
  Coil turns                              Approximately 12
  Coil resistance                     Approximately 0.31 Ω
  Mean coil area                                  46.6 cm²
  Estimated field at coil centre                    3.7 mT
  Estimated maximum torque at 2 A                0.41 mN·m
  Supply                                      12 V DC, 2 A

## Safety

**Do not connect the coil directly to the 12 V adapter for prolonged
operation.** The estimated coil resistance is very low, and the supply
may current-limit or shut down. The report estimates about 1.3 W of
copper loss and rapid heating at 2 A. Use a properly current-limited
supply or suitable series resistance, operate only in short supervised
bursts, and disconnect power if the coil becomes warm. Handle neodymium
magnets carefully and prevent exposed connections from shorting.

## Author

**Kartikay Singhal**\
Vellore Institute of Technology, Vellore\
Course: Electrical Machines (BAEEE206)\
Semester: Fall 2026--27
