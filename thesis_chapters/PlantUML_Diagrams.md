# PlantUML Diagrams for ToothyMate Thesis

Use these PlantUML codes at:
- https://www.plantuml.com/plantuml/uml/
- Or VS Code with PlantUML extension

---

## 1. Gamification System Flowchart (Simplified)

```plantuml
@startuml Gamification System
skinparam backgroundColor #FEFEFE
skinparam activityBackgroundColor #E3F2FD
skinparam activityBorderColor #1976D2
skinparam activityDiamondBackgroundColor #FFF3E0
skinparam activityDiamondBorderColor #F57C00

start
:Load User Data;
:Display Home Screen;

if (Mission Available?) then (yes)
  :User Completes Mission;
  :Award 20 XP;

  if (Both Missions Done?) then (yes)
    :Increment Streak;
  else (no)
  endif

  if (XP >= 100?) then (yes)
    :Level Up;
    :Update Hero Rank;
  else (no)
  endif

  :Check Badge Unlocks;
  :Save to Local + Firebase;
else (no)
endif

:Return to Home;
stop

@enduml
```

---

## 2. AI Classification Flowchart

```plantuml
@startuml AI Classification
skinparam backgroundColor #FEFEFE
skinparam activityBackgroundColor #E8F5E9
skinparam activityBorderColor #388E3C

start
:User Captures/Selects Image;
:Resize to 224x224;
:Normalize & Convert to Float32;
:Run TensorFlow Lite Model;

:Get Classification Results|
note right
  - Calculus %
  - Caries %
  - Healthy %
  - Stain %
  - Not Teeth %
end note

:Generate Feedback Message;

fork
  :Display Visual Result;
fork again
  :Play TTS Audio;
fork again
  :Update Mascot Icon;
end fork

stop
@enduml
```

---

## 3. AR Module Flowchart

```plantuml
@startuml AR Module
skinparam backgroundColor #FEFEFE
skinparam activityBackgroundColor #F3E5F5
skinparam activityBorderColor #7B1FA2

start
:Initialize AR Session;
:Load 3D Tooth Model;

repeat
  :Scan for Plane Surface;
repeat while (Plane Detected?) is (no)
->yes;

:Place 3D Model;
:Enable Gesture Controls;

repeat
  switch (User Action?)
  case (Pinch)
    :Zoom In/Out;
  case (Rotate)
    :Rotate Model;
  case (Tap)
    if (Case Found?) then (yes)
      :Show Case Info;
      :Play Confetti;
      :TTS Feedback;
    endif
  case (Exit)
    stop
  endswitch
repeat while (Continue?) is (yes)

stop
@enduml
```

---

## 4. Application Main Flowchart

```plantuml
@startuml Main App Flow
skinparam backgroundColor #FEFEFE
skinparam activityBackgroundColor #E3F2FD
skinparam activityBorderColor #1976D2

start
:Launch App;
:Display Splash Screen;

if (First Time User?) then (yes)
  :Language Selection;
  :Welcome Screens;
endif

:Display Home Screen;

switch (Select Feature?)
case (Missions)
  :Complete Daily Mission;
  :Award XP + Streak;
case (E-Learning)
  :Browse & Complete Lessons;
case (AI Scan)
  :Capture Image;
  :Get AI Result;
case (Chat Buddy)
  :Ask Question;
  :Receive Response;
case (AR Tooth)
  :Explore 3D Model;
  :Discover Cases;
endswitch

:Return to Home;
stop

@enduml
```

---

## 5. Use Case Diagram

```plantuml
@startuml Use Case
left to right direction
skinparam packageStyle rectangle
skinparam backgroundColor #FEFEFE

actor "Child User" as child #FFD54F

rectangle "ToothyMate System" {
  usecase "Complete Daily Missions" as UC1 #E3F2FD
  usecase "Access E-Learning" as UC2 #E8F5E9
  usecase "Use AI Scan" as UC3 #FFF3E0
  usecase "View AR Tooth Model" as UC4 #F3E5F5
  usecase "Chat with Dental Buddy" as UC5 #FFEBEE

  usecase "Earn XP" as UC1a #E3F2FD
  usecase "Update Streak" as UC1b #E3F2FD
  usecase "Level Up" as UC1c #E3F2FD

  usecase "View Lessons" as UC2a #E8F5E9
  usecase "Complete Quiz" as UC2b #E8F5E9

  usecase "Capture Image" as UC3a #FFF3E0
  usecase "Get AI Result" as UC3b #FFF3E0

  usecase "Place 3D Model" as UC4a #F3E5F5
  usecase "Discover Cases" as UC4b #F3E5F5

  usecase "Ask Question" as UC5a #FFEBEE
  usecase "Receive Answer" as UC5b #FFEBEE
}

child --> UC1
child --> UC2
child --> UC3
child --> UC4
child --> UC5

UC1 ..> UC1a : <<include>>
UC1 ..> UC1b : <<include>>
UC1 ..> UC1c : <<include>>

UC2 ..> UC2a : <<include>>
UC2 ..> UC2b : <<include>>

UC3 ..> UC3a : <<include>>
UC3 ..> UC3b : <<include>>

UC4 ..> UC4a : <<include>>
UC4 ..> UC4b : <<include>>

UC5 ..> UC5a : <<include>>
UC5 ..> UC5b : <<include>>

@enduml
```

---

## 6. System Architecture Diagram

```plantuml
@startuml System Architecture
skinparam backgroundColor #FEFEFE
skinparam componentStyle rectangle

package "Presentation Layer" #E3F2FD {
  [Home Screen]
  [E-Learning Screen]
  [AI Scan Screen]
  [Chat Screen]
  [AR Tooth Screen]
}

package "State Management" #E8F5E9 {
  [AppProvider]
  [AiScanProvider]
  [ChatProvider]
}

package "Service Layer" #FFF3E0 {
  [AI Service]
  [Camera Service]
  [Gemini Service]
  [TTS Service]
  [Feedback Service]
  [Firebase Service]
}

package "Data Layer" #F3E5F5 {
  database "SharedPreferences\n(Local Cache)" as SP
  database "JSON Assets" as JSON
}

package "External Services" #FFEBEE {
  [TensorFlow Lite]
  [Google Gemini API]
  cloud "Firebase" {
    [Firestore]
    [Anonymous Auth]
  }
}

[Presentation Layer] --> [State Management]
[State Management] --> [Service Layer]
[Service Layer] --> [Data Layer]
[Service Layer] --> [External Services]
[Firebase Service] --> [Firestore]
[Firebase Service] --> [Anonymous Auth]

@enduml
```

---

## 7. E-Learning Module Flowchart

```plantuml
@startuml E-Learning
skinparam backgroundColor #FEFEFE
skinparam activityBackgroundColor #F3E5F5
skinparam activityBorderColor #7B1FA2

start
:Load Lessons from JSON;
:Display Lesson List;

:User Selects Lesson;
:Open Lesson Detail;

repeat
  switch (Content Type?)
  case (Text)
    :Show Flip Cards;
  case (Quiz)
    :Display Questions;
    :Check Answers;
  case (Video)
    :Play YouTube Video;
  endswitch
repeat while (More Content?) is (yes)
->no;

:Mark Lesson Complete;
:Update Progress;

if (13 Lessons Done?) then (yes)
  :Unlock Tooth Genius Badge!;
endif

:Return to Lesson List;
stop

@enduml
```

---

## 8. AI Chatbot Flowchart

```plantuml
@startuml Chatbot
skinparam backgroundColor #FEFEFE
skinparam activityBackgroundColor #FFEBEE
skinparam activityBorderColor #D32F2F

start
:Load Chat History;
:Display Welcome;

repeat
  :User Sends Question;
  :Send to Gemini API;
  :Apply Safety Filters;
  :Process Response;

  :Detect Emotion Keywords;

  switch (Emotion?)
  case (Happy)
    :Set Happy Icon 😊;
  case (Sad/Pain)
    :Set Concerned Icon 😟;
  case (Neutral)
    :Set Default Icon 🦷;
  endswitch

  :Display Response;
  :Text-to-Speech;
  :Save to Local + Firebase;

repeat while (Continue Chat?) is (yes)

stop
@enduml
```

---

## 9. Agile Development Cycle

```plantuml
@startuml Agile Cycle
skinparam backgroundColor #FEFEFE

|Sprint Cycle|
start
:Plan;
:Design;
:Develop;
:Test;
:Deploy;
:Review;
:Gather Feedback;

if (More Sprints?) then (yes)
  :Start Next Sprint;
  detach
else (no)
  :Project Complete;
  stop
endif

@enduml
```

---

## 10. Project Phases Timeline (Matching Gantt Chart)

```plantuml
@startuml Project Phases
skinparam backgroundColor #FEFEFE
skinparam packageStyle rectangle

package "SEMESTER A (SKM4950A)" #FAFAFA {
  rectangle "Phase 1\nPlanning\nWeek 1-4" as P1 #FFCDD2
  rectangle "Phase 2\nRequirement\n& Design\nWeek 3-6" as P2 #C8E6C9
  rectangle "Phase 3\nProposal &\nPresentation\nWeek 6-10" as P3 #BBDEFB
  rectangle "Phase 4\nSubmission\nWeek 9-11" as P4 #D1C4E9
}

package "SEMESTER B (SKM4950B)" #FAFAFA {
  rectangle "Phase 5\nSkill &\nPrototype Prep\nWeek 1-4" as P5 #B3E5FC
  rectangle "Phase 6\nAgile\nDevelopment\nWeek 3-9" as P6 #FFE0B2
  rectangle "Phase 7\nTesting &\nFinalization\nWeek 7-11" as P7 #C5CAE9
  rectangle "Phase 8\nFinal Report\n& Presentation\nWeek 10-14" as P8 #DCEDC8
}

P1 -right-> P2
P2 -right-> P3
P3 -right-> P4
P4 -down-> P5
P5 -right-> P6
P6 -right-> P7
P7 -right-> P8

@enduml
```

---

## 11. Agile Development Iterations (Phase 6)

```plantuml
@startuml Agile Iterations
skinparam backgroundColor #FEFEFE

|Phase 6: Agile Development (Week 3-9)|
start
:Iteration 1: Gamification;
note right: XP system, streaks, badges,\nhero ranks, daily missions
:Iteration 2: E-Learning;
note right: 13 lessons, flip cards, quizzes,\nYouTube videos, bilingual JSON
:Iteration 3: AR Module;
note right: 3D tooth model, gesture controls,\n5 discoverable cases, confetti
:Iteration 4: AI Scan;
note right: TensorFlow Lite, camera,\nimage preprocessing, 5-class model
:Iteration 5: AI Chatbot;
note right: Google Gemini API, safety filters,\nemotion detection, TTS
:Iteration 6: Firebase;
note right: Anonymous Auth, Firestore,\nhybrid storage, cloud sync
:Iteration 7: Integration & i18n;
note right: Localization (EN/MS), sounds,\nLottie animations, bug fixes

:User Feedback & Refinement;

stop
@enduml
```

---

## How to Use PlantUML

### Option 1: Online Editor
1. Go to **https://www.plantuml.com/plantuml/uml/**
2. Paste the code (without the ```plantuml wrapper)
3. Click "Submit" to generate
4. Right-click image to save as PNG

### Option 2: VS Code
1. Install "PlantUML" extension
2. Create `.puml` file
3. Press `Alt+D` to preview
4. Export as PNG/SVG

### Option 3: Draw.io
1. Go to draw.io
2. Arrange → Insert → Advanced → PlantUML
3. Paste code and insert

---

## Simplified Mermaid Alternative for Gamification

If you still prefer Mermaid but simpler:

```mermaid
flowchart TD
    A[Load User Data] --> B[Display Home]
    B --> C{Mission Available?}
    C -->|Yes| D[Complete Mission]
    D --> E[Award 20 XP]
    E --> F{Both Done?}
    F -->|Yes| G[Increment Streak]
    F -->|No| H{XP >= 100?}
    G --> H
    H -->|Yes| I[Level Up + Update Rank]
    H -->|No| J[Check Badges]
    I --> J
    J --> K[Save & Return Home]
    C -->|No| B
```

This simplified version has only 11 nodes instead of 20+.
