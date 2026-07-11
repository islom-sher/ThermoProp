# ThermoProp 

**High-performance thermodynamic property calculations, natively on iOS.**

ThermoProp is a robust engineering tool designed to bring the power of the industry-standard **CoolProp** C++ library to the iOS ecosystem. Engineered for mechanical and energy engineering professionals, this application provides rapid, accurate fluid property data, saturation tables, and process simulation directly on mobile devices.

## Key Features

* **HEOS Core Engine:** Powered by the CoolProp High-Efficiency Object-Oriented Solver (HEOS) for accurate, research-grade fluid property modeling.
* **C++ to Swift Bridge:** Custom Objective-C++ wrappers seamlessly integrate the massive CoolProp backend with modern Swift and UIKit frontends without performance degradation.
* **State-Point Analysis:** Calculate exact thermodynamic states by defining any two independent properties (e.g., T & P, P & h, s & Q).
* **Saturation Tables:** Generate dynamic phase-boundary data with customizable ranges and step intervals for iterative thermal design.
* **Iso-Process Simulation:** Model standard thermodynamic changes, including isobaric, isothermal, isochoric, isenthalpic, and isentropic processes.
* **Engineering-Ready:** Full support for dynamic unit systems (SI, Imperial, custom) and customizable decimal precision.
* **Export & Reporting:** Seamlessly export generated tables to PDF or CSV formats for inclusion in engineering documentation.

## 🛠 Tech Stack

* **Core Backend:** C++ / CoolProp Framework
* **Language:** Swift 6.0, Objective-C++
* **Interface:** UIKit with programmatic Auto-Layout components, optimized for adaptive multitasking on iPad and iPhone.
* **Architecture:** MVC pattern with dedicated Singleton managers (`SessionDataManager`, `SettingsManager`) to handle complex state and global preferences.

## ⚙️ Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/islom-sher/ThermoProp.git](https://github.com/islom-sher/ThermoProp.git)

