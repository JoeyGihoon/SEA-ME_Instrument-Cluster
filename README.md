# [DES] Instrument Cluster - Team 5
|[![GitHub](https://img.shields.io/badge/GitHub-JoeyGihoon-167842?logo=github&logoColor=white)](https://github.com/JoeyGihoon)|[![GitHub](https://img.shields.io/badge/GitHub-oyg0323-248635?logo=github&logoColor=white)](https://github.com/oyg0323)|[![GitHub](https://img.shields.io/badge/GitHub-XZIBIT93-182457?logo=github&logoColor=white)](https://github.com/XZIBIT93)|
|:--:|:--:|:--:|

## Introduction
This project implements a Qt-based instrument cluster for the PiRacer, displaying live speed readings on a Raspberry Pi. By tapping into the vehicle’s CAN bus, the application retrieves data directly from the speed sensor and renders it in real time. Throughout development, we focused on designing a modular software architecture suitable for embedded environments, integrating Qt’s GUI components to create an intuitive display. Leveraging CAN communication protocols and Raspberry Pi hardware, this work showcases a complete end-to-end solution—from low-level data acquisition to polished user interface. The finished application demonstrates our ability to architect and build an automotive-grade display system and to document and present the results clearly.  

## HW Components
|  HW    | Image    |
|:--------:|:--------:|
| PiRacer     | <img src="images/PiRacer.png" width="100"/>    |
| Arduino UNO  | <img src="images/arduino.jpg" width="100"/>  |
| CAN-BUS Shield V2.0  | <img src="images/CAN shield.jpg" width="100"/>     |
| CAN-BUS (FD) HAT for Raspberry Pi    | <img src="images/CAN HAT.jpg" width="100"/>     |
| Raspberri Pi 4    |   <img src="images/raspberry pi 4.jpg" width="100"/>   |
| Speed Sensor     | <img src="images/SEN-Speed-02.png" width="100"/>    |
| 7.9 inch Display     | <img src="images/display.jpg" width="100"/>    |
| Joystick(controller)     | <img src="images/joystick.jpg" width="100"/>    |


- Speed Sensor Data Collection: Gathers vehicle speed data using an Arduino CAN shield.
- Data Transmission and Communication: Transmits data to Raspberry Pi through the CAN bus and CAN HAT.
- Qt Application: Receives and visualizes the collected data in real-time on a dashboard.
- I2C Communication (Bonus Feature): Gathers vehicle battery data via I2C and displays it on the Qt app.

## Installation and Usage
### Installation

### Usage

