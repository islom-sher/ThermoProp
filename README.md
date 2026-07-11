# ThermoProp 

**High-performance thermodynamic property calculations, natively on iOS.**

ThermoProp is a robust engineering tool designed to bring the power of the industry-standard **CoolProp** C++ library to the iOS ecosystem. Engineered for mechanical and energy engineering professionals, this application provides rapid, accurate fluid property data, saturation tables, and process simulation directly on mobile devices.
<p align="center">
   <img width="300" height="652" alt="Simulator Screenshot - iPhone 17 Pro - 2026-07-11 at 12 34 38" src="https://github.com/user-attachments/assets/1f25c026-5090-425b-8e7b-f3622af3b1e4" />
   <img width="300" height="652" alt="Simulator Screenshot - iPhone 17 Pro - 2026-07-11 at 12 34 44" src="https://github.com/user-attachments/assets/2567a83e-6700-4d07-b817-9c12afc8e5e5" />
   <img width="300" height="652" ![Uploading Simulator Screenshot - iPhone 17 Pro - 2026-07-11 at 12.34.49.png…]()
alt="Simulator Screenshot - iPhone 17 Pro - 2026-07-11 at 12 34 49" />
</p>

## Key Features

* **HEOS Core Engine:** Powered by the CoolProp High-Efficiency Object-Oriented Solver (HEOS) for accurate, research-grade fluid property modeling.
* **C++ to Swift Bridge:** Custom Objective-C++ wrappers seamlessly integrate the massive CoolProp backend with modern Swift and UIKit frontends without performance degradation.
* **State-Point Analysis:** Calculate exact thermodynamic states by defining any two independent properties (e.g., T & P, P & h, s & Q).
* **Saturation Tables:** Generate dynamic phase-boundary data with customizable ranges and step intervals for iterative thermal design.
* **Iso-Process Simulation:** Model standard thermodynamic changes, including isobaric, isothermal, isochoric, isenthalpic, and isentropic processes.
* **Engineering-Ready:** Full support for dynamic unit systems (SI, Imperial, custom) and customizable decimal precision.
* **Export & Reporting:** Seamlessly export generated tables to PDF or CSV formats for inclusion in engineering documentation.

<img width="590" height="1278" alt="IMG_1153" src="https://github.com/user-attachments/assets/43c58b10-e060-418f-9340-defb015dcc0e" />
<img width="590" height="1278" alt="IMG_1151" src="https://github.com/user-attachments/assets/a7e46855-d12a-4266-a1f4-1a93df86801e" />
<img width="590" height="1278" alt="IMG_1150" src="https://github.com/user-attachments/assets/f436f933-c7c9-4600-8746-06cbb6704334" />
<img width="590" height="1278" alt="IMG_1149" src="https://github.com/user-attachments/assets/58c64d11-45ab-4b64-adb7-a98083392f0c" />

## 🛠 Tech Stack

* **Core Backend:** C++ / CoolProp Framework
* **Language:** Swift 6.0, Objective-C++
* **Interface:** UIKit with programmatic Auto-Layout components, optimized for adaptive multitasking on iPad and iPhone.
* **Architecture:** MVC pattern with dedicated Singleton managers (`SessionDataManager`, `SettingsManager`) to handle complex state and global preferences.

## ⚙️ Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/islom-sher/ThermoProp.git](https://github.com/islom-sher/ThermoProp.git)

