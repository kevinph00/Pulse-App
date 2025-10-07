# 🎵 Pulse – Find Your Friends Offline

**Pulse** is a Flutter app designed for festivals and concerts where the internet is unreliable but GPS still works.  
You can share just your coordinates with a friend, and Pulse will show you a **live compass** pointing toward them — making it easy to find each other in huge crowds.

---

## ✨ Features

- 🧭 **Live Compass Rotation** – Smoothly rotates as you turn your phone.  
- 📍 **Current Pulse** – Shows your current coordinates, altitude, and timestamp.  
- 📤 **Quick Share** – Tap your coordinates to **copy to clipboard** 📋 for easy sharing.  
- 🎯 **Track a Friend’s Pulse** – Paste your friend’s coordinates to:  
  - See a **green arc** outside the compass showing which direction to head.  
  - View the **distance in meters** above the compass to know how far they are.  
- 🔄 **Pulse Button** – Refresh your location or hold for continuous tracking.  
- 🔒 **Portrait Lock** – Always stays vertical for easier use in crowds.  
- ⚡ **Offline-First** – Works with only GPS — no internet required after sharing coordinates.  

---

## Festival & Concert Use Case

Imagine you’re at a huge festival:  
- The crowd is dense.  
- Mobile internet is slow or not working.  
- You need to find your friends quickly.  

With **Pulse**:  
1. Tap your **coordinates** to copy them.  
2. Send them over SMS or any low-data channel.  
3. Your friend **pastes the coordinates** into their Pulse app.  
4. The app’s compass and distance display guide them to you.  

No extra accounts. No map tiles. No heavy internet. Just **Pulse** and GPS.

---
 
## 📂 Project Structure

lib/  
├─ main.dart                        # App entry point  
├─ screens/
│  └─ compass_screen.dart           # Main UI & app logic  
├─ painters/
│  ├─ compass_painter.dart          # CustomPainter for compass 
│  └─ tracking_arc_painter.dart     # CustomPainter for green arc  
├─ widgets/  
│  ├─ compass_info.dart             # Info-panel showing heading, distance, coordinates and altitude 
│  ├─ pulse_button.dart             # Center button for refreshing location  
│  ├─ top_toast.dart                # Lightweight top toast for copy feedback
│  └─ track_button.dart             # Bottom button for tracking on input coordinates


---

## 🚀 Getting Started

1. Clone the repository:
   git clone https://github.com/your-username/pulse-app.git
   cd pulse-app

2. Install dependencies:
   flutter pub get

3. Run the app:
   flutter run

---

## 📦 Dependencies

Add these to your pubspec.yaml:

dependencies:  
  flutter:  
    sdk: flutter  
  flutter_compass: ^0.7.0  
  location: ^6.0.0  

---

## 📱 Usage

1. Launch Pulse – it fetches your location automatically.
2. Tap your Pulse coordinates to copy them.
3. Send the coordinates to your friend via SMS or any channel.
4. Your friend pastes the coordinates into Track to see:
    - A green directional arc pointing to your location.
    - The distance in meters displayed above the compass.
5. Use the pulse button to refresh your own location when needed.

---

## 📝 Permissions

The app requests:
- Location – to get GPS coordinates.
- Sensor – to read compass heading.

---

## Vision

Pulse keeps it simple and reliable:
- Lightweight and offline-friendly
- Only GPS coordinates are shared
- Made for real-world festival & concert navigation

