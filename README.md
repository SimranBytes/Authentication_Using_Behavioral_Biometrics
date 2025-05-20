
# Authentication Using Behavioral Biometrics

A seamless, non-intrusive second-factor authentication system for mobile devices, leveraging each user’s unique behavioral traits—how they hold, move, and interact with their phone—to provide continuous identity verification without passwords.

---

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Repository Structure](#repository-structure)  
3. [Source Code](#source-code)  
4. [Documentation](#documentation)  
5. [Installation & Setup](#installation--setup)  
6. [Usage](#usage)  
7. [Video Demonstration](#video-demonstration)  
8. [Dataset](#dataset)  
9. [Contributors](#contributors)  

---

## Project Overview

As traditional authentication (passwords, PINs, OTPs) faces ever-smarter attacks and adds friction for users, **behavioral biometrics** offers a continuous, in-the-background approach: analyzing how a user holds, moves, swipes, and taps their phone to confirm identity. This repository delivers:

- **Mobile data‐collection app** (Flutter)  
- **Preprocessing & deep-learning models** (Python notebooks)  
- **Prototype authentication app** (Flutter + TensorFlow Lite)  
- **Full documentation** (proposals, reports, slides)

---

## Repository Structure

```
├── 01_Sensor_Collection_App/        # Flutter app to record accelerometer, gyroscope, touch, etc.
│   ├── android/
│   ├── ios/
│   └── lib/
│       └── sensor_manager.dart     # sensor hooks & CSV export
├── 02_Data_Preprocessing_and_DL/   # Jupyter notebooks for combining, cleaning, modeling
│   ├── 01_Combining_CSVs.ipynb
│   ├── 02_Preprocessing_and_LSTM.ipynb
│   ├── 03_GRU_for_Behavioural_Biometrics.ipynb
│   └── 04_GRU_without_touch_data.ipynb
├── 03_Biometrics_Prototype/        # Flutter prototype + TensorFlow Lite model
│   ├── android/
│   ├── lib/
│   └── assets/
├── 04_Documentation/               # Project write-ups and slides
│   ├── 01_PPTs/
│   ├── 02_Reports/
│   └── Major Project Proposal.pdf
└── README.md                       # ← You are here
```

---

## Source Code

- **Sensor Collection App** (`01_Sensor_Collection_App/`):  
  - Flutter UI and sensor hooks (`sensor_manager.dart`)  
  - Records motion & touch data to CSV  

- **Preprocessing & DL** (`02_Data_Preprocessing_and_DL/`):  
  - Combines per-user CSVs, cleans & synchronizes timestamps  
  - Implements LSTM & GRU models for user classification  
  - Exports final GRU model as TensorFlow Lite (`.tflite`)  

- **Prototype** (`03_Biometrics_Prototype/`):  
  - Flutter app integrating the `.tflite` model  
  - Continuous authentication checks based on confidence threshold  

---

## Documentation

- **Proposal & Reports**: `04_Documentation/02_Reports/`  
- **Slides & Presentation**: `04_Documentation/01_PPTs/`  
- **Major Project Proposal**: `04_Documentation/Major Project Proposal.pdf`  

---

## Installation & Setup

1. **Prerequisites**  
   - Flutter SDK ≥ 3.0  
   - Android Studio / Xcode (for iOS)  
   - Python 3.8+ & Jupyter  

2. **Clone the repository**  
   ```bash
   git clone https://github.com/Authentication_Using_Behavioral_Biometrics.git
   cd Authentication_Using_Behavioral_Biometrics
   ```

### Sensor Collection App
```bash
cd 01_Sensor_Collection_App
flutter pub get
flutter run
```

### Preprocessing & Model Training
```bash
cd ../02_Data_Preprocessing_and_DL
jupyter lab
# Run notebooks: 
# 01_Combining_CSVs.ipynb → 02_Preprocessing_and_LSTM.ipynb → 03_GRU_for_Behavioural_Biometrics.ipynb
```

Export the final `.tflite` model

### Prototype App
```bash
cd ../03_Biometrics_Prototype
flutter pub get
flutter run
```

---

## Usage

**Collect Data**:
- Launch the sensor-collection app.
- Grant sensor & storage permissions.
- Start/stop recording sessions; CSVs saved locally.

**Train & Export Model**:
- Execute the preprocessing notebooks; train GRU; export `.tflite`.

**Authenticate**:
- Open prototype app → log in → model trains on your behavior → continuous checks.

---

## Video Demonstration

A concise 5-minute walkthrough of the system—from data capture to real-time authentication—is available here:  
**[5-Minute Demo Video](https://youtu.be/joPARCbaVeA)**

---

## Dataset

We collected a dataset (5.5 million+ rows from 25 participants) is too large for GitHub. Download it here:  
**[Behavioral Biometrics Dataset (CSV)](https://drive.google.com/drive/folders/1uCqLl4tcyYuNKrnHRNdaHvTjbt-T95jS?usp=sharing)**

---

## Contributors (G36)

- Akshit Sharma (211435)  
- Simran (211442)  

**Supervisor**: Dr. Kushal Kanwar, Assistant Professor (SG), CSE & IT, JUIT

---

