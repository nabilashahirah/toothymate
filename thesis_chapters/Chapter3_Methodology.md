# CHAPTER 3: METHODOLOGY

## 3.1 Introduction

This chapter describes the methodology adopted for the development of the ToothyMate mobile application. The development process follows the Agile methodology, which emphasizes iterative development, continuous feedback, and flexibility in responding to user needs. This chapter covers the development approach, user requirement gathering through pre-survey, system design including flowcharts and use case diagrams, and the tools and technologies employed in the project.

---

## 3.2 Development Methodology: Agile Approach

This project adopts the Agile methodology as its core development approach. Agile is a software development methodology that emphasizes iterative development, continuous feedback, collaboration, and flexibility in responding to changing requirements (Saigon Technology, 2025). The Agile approach is particularly suitable for this project due to:

1. **Iterative Development:** The ToothyMate application involves multiple complex modules (gamification, AR, AI classification, e-learning) that benefit from incremental development and testing.

2. **User-Centered Design:** Agile's emphasis on user feedback aligns with the project's goal of creating an engaging, child-friendly application.

3. **Flexibility:** The ability to adapt features based on testing results and user feedback is essential for developing an effective educational tool.

4. **Risk Management:** Early and continuous testing allows for identification and resolution of technical challenges before they become critical.

### 3.2.1 Project Phases Overview

The project follows a structured timeline across two semesters, with the Agile methodology applied during the development phase:

| Phase | Name | Semester | Weeks | Description |
|-------|------|----------|-------|-------------|
| 1 | Planning | A | 1-4 | Topic confirmation, problem statement, literature review, survey distribution |
| 2 | Requirement & Design | A | 3-6 | Survey analysis, system scope, wireframes, UI design, app flow |
| 3 | Proposal & Presentation | A | 6-10 | Draft proposal, slides preparation, proposal defense |
| 4 | Submission | A | 9-11 | Submit proposal presentation and report |
| 5 | Skill & Prototype Prep | B | 1-4 | Learn development tools, prototype basic UI, initial feedback |
| 6 | **Agile Development** | B | 3-9 | Iterative module development with continuous feedback |
| 7 | Testing & Finalization | B | 7-11 | User testing, bug fixes, refinements |
| 8 | Final Report & Presentation | B | 10-14 | Thesis finalization, demo preparation, final submission |

### 3.2.2 Agile Development Iterations (Phase 6)

Within the **Agile Development phase**, the development follows iterative cycles. Each iteration focuses on specific modules, with continuous integration and feedback:

**Iteration 1: Core Gamification System**
- Home screen UI development with gradient background and mascot character
- User profile card with editable name and avatar
- XP system implementation (20 XP per mission, 100 XP per level)
- Hero rank progression (7 ranks from Tooth Rookie to Legendary Smile Guardian)
- Daily missions with time-based visibility (morning 6AM-12PM, night 6PM-12AM)
- Streak tracking with calendar-based logic
- Achievement badge system (First Brush, Week Warrior, Tooth Genius, etc.)
- SharedPreferences integration for local data persistence

**Iteration 2: E-Learning Module**
- JSON-based lesson data structure with bilingual content (EN/MS)
- 13 lessons covering: tooth anatomy, brushing techniques, flossing, cavities, gum disease, diet, dentist visits, braces, mouthguard, baby teeth, bad breath, tooth injuries, sealants
- Lesson listing screen with category filtering and search functionality
- Lesson detail view with interactive flip cards
- Quiz component with multiple-choice questions and immediate feedback
- YouTube video player integration using `youtube_player_flutter`
- Lesson completion tracking with progress persistence
- XP rewards for completing lessons

**Iteration 3: AR Module**
- AR Flutter Plugin integration for augmented reality functionality
- 3D tooth model loading (GLB format) with texture support
- AR scene setup with horizontal plane detection
- Gesture controls: pinch-to-zoom, drag-to-rotate
- 5 discoverable dental cases on tooth model (cavity, plaque, healthy enamel, root, gum)
- Confetti animation on case discovery
- Text-to-speech feedback for discovered cases
- AR session management and resource cleanup

**Iteration 4: AI Classification Module**
- TensorFlow Lite model integration (`tflite_flutter` package)
- Custom trained model for 5-class classification
- Camera service with live preview and capture functionality
- Gallery image picker integration
- Image preprocessing: resize to 224×224, normalize pixels, convert to Float32
- Classification result display with confidence percentages
- Mascot-based feedback icons (happy, concerned, neutral)
- Text-to-speech for classification results
- Educational disclaimers (non-diagnostic purpose)

**Iteration 5: AI Chatbot Module**
- Google Gemini API integration (`google_generative_ai` package)
- Chat interface with message bubbles and typing indicators
- System prompt engineering for child-friendly dental assistant persona
- Safety content filtering (dental topics only, age-appropriate language)
- Dynamic bot personality with emotion detection (happy, sad, neutral icons)
- Quick question buttons for common dental queries
- Chat history persistence with SharedPreferences
- Text-to-speech for bot responses
- Clear chat functionality

**Iteration 6: Cloud Database Integration**
- Firebase project setup and configuration
- Firebase Core initialization in `main.dart`
- Firebase Anonymous Authentication (no login required)
- Firestore database structure design (`users/{userId}/` collection)
- `FirebaseService` singleton implementation
- User data sync: XP, streak, missions, completed lessons
- Chat history cloud backup (`chatHistory` subcollection)
- Hybrid storage strategy (local cache + cloud backup)
- Offline support with SharedPreferences fallback
- Android Gradle configuration for Google Services

**Iteration 7: Integration, Localization, and Polish**
- Module integration and navigation flow
- EasyLocalization setup for bilingual support (English/Malay)
- Translation JSON files for all UI text
- Sound effects integration (button clicks, achievements, celebrations)
- Lottie animations for splash screen and loading states
- Tutorial overlay for first-time users
- UI/UX refinement based on testing feedback
- Bug fixes and performance optimization

### 3.2.3 Agile Methodology Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      AGILE DEVELOPMENT CYCLE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐ │
│    │  PLAN    │───>│  DESIGN  │───>│  DEVELOP │───>│   TEST   │ │
│    └──────────┘    └──────────┘    └──────────┘    └──────────┘ │
│         ^                                               │        │
│         │                                               │        │
│         │         ┌──────────┐    ┌──────────┐         │        │
│         └─────────│  REVIEW  │<───│  DEPLOY  │<────────┘        │
│                   └──────────┘    └──────────┘                   │
│                         │                                        │
│                         v                                        │
│                   ┌──────────┐                                   │
│                   │ FEEDBACK │                                   │
│                   └──────────┘                                   │
│                                                                  │
│    Applied during Phase 6: Agile Development (Sem B, Week 3-9)  │
│    Total Iterations: 7                                           │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2.4 Development Iterations Timeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│            AGILE DEVELOPMENT ITERATIONS (Phase 6, Semester B)                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Week 3-4        Week 4-5        Week 5-6        Week 6-7                   │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │Iteration │───>│Iteration │───>│Iteration │───>│Iteration │              │
│  │    1     │    │    2     │    │    3     │    │    4     │              │
│  │Gamifica- │    │E-Learning│    │    AR    │    │ AI Scan  │              │
│  │  tion    │    │  Module  │    │  Module  │    │  Module  │              │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘              │
│       │                                               │                     │
│       └─────────────── Feedback Loop ─────────────────┘                     │
│                                                                              │
│  Week 7-8        Week 8-9        Week 9                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                              │
│  │Iteration │───>│Iteration │───>│Iteration │                              │
│  │    5     │    │    6     │    │    7     │                              │
│  │    AI    │    │ Firebase │    │ Integra- │                              │
│  │ Chatbot  │    │  Cloud   │    │tion/i18n │                              │
│  └──────────┘    └──────────┘    └──────────┘                              │
│       │                               │                                     │
│       └────── Continuous Feedback ────┘                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

Throughout the Agile process, user stories are defined to reflect real-world needs. Examples include:
- "As a child, I want to earn points for brushing my teeth so that I feel motivated to brush every day."
- "As a child, I want to see a 3D tooth model so that I can understand what my teeth look like inside."
- "As a child, I want to ask questions about teeth and get friendly answers so that I can learn more."
- "As a child, I want to scan my teeth and see if they are healthy so that I can take better care of them."
- "As a parent, I want my child to learn about dental health through fun lessons so that they develop good habits."
- "As a user, I want my progress to be saved automatically so that I don't lose my achievements."

Regular reviews and testing during each sprint allow for quick identification of issues, feature adjustments, and usability improvements.

---

## 3.3 User Requirement Gathering via Pre-Survey

Prior to the development phase, a pre-survey was conducted to gather insights into users' current oral health behaviors, interests, and expectations regarding digital solutions for oral health awareness. The survey collected responses from 43 individuals, including both general public users and dental professionals, ensuring a diverse range of perspectives.

*[Include Figure 3.1.1: Distribution of Survey Respondents by User Type]*

### 3.3.1 Demographic Distribution

The age distribution of respondents revealed that the majority (51.2%) were within the 36-50 years age group, followed by 27.9% aged above 50 years. Smaller proportions of participants were aged 18-25 years (16.3%) and 26-35 years (4.7%). This distribution indicates strong representation from parents and caregivers who would be primary decision-makers for children's app usage.

*[Include Figure 3.1.2: Age Distribution of Survey Respondents]*

### 3.3.2 Dental Visit Habits

Regarding dental visit frequency, more than half of respondents (53.5%) indicated that they only seek dental care when experiencing pain. Meanwhile, 20.9% reported visiting the dentist rarely, 16.3% visited once a year, and only 9.3% maintained a routine schedule of visits every 3 to 6 months. These findings suggest a prevalent reactive approach to dental care, highlighting the need for interventions that encourage preventive behavior and regular self-monitoring—particularly important to instill in children from an early age.

*[Include Figure 3.1.3: Frequency of Dental Visits Among Survey Respondents]*

### 3.3.3 Experience with Dental Apps

A significant majority (95.3%) of respondents reported never having used any dental-related mobile applications prior to this study. Among the few who had, 4.7% mentioned using the Colgate app. This low adoption rate of existing dental apps suggests an untapped opportunity for an engaging and accessible platform, particularly one designed specifically for children that parents would be motivated to download for their families.

*[Include Figure 3.1.4: Proportion of Respondents Who Have Used Dental Mobile Applications]*

### 3.3.4 User Suggestions for App Functions

The survey included open-ended questions about features respondents would like to see in a dental app. Key suggestions included:
- Dental care guidance tailored by life stages (including children)
- More engaging and interesting information about teeth to increase user interest
- Dental appointment management and reminders
- Early detection of at-risk dental conditions
- Fun, interactive learning for children

*[Include Figure 3.1.5: Commonly Suggested Features for Dental Mobile Applications]*

### 3.3.5 Common Dental Concerns

Participants were asked about their primary dental worries:
- 44.2% cited pain as their main concern
- 34.9% were worried about late detection of dental issues
- 20.9% expressed concerns over the cost of dental care

The high concern for late detection (34.9%) supports the inclusion of AI-based scanning features that can provide early awareness of potential dental conditions.

*[Include Figure 3.1.6: Primary Dental Concerns Reported by Survey Respondents]*

### 3.3.6 Perception of AI-Based Detection Features

When asked if they would recommend a mobile app capable of automatically detecting dental issues like plaque or cavities and providing users with detailed information about their dental condition, **100% of respondents answered yes**, affirming its usefulness for society. This strongly supports integrating AI-driven educational and detection tools in the application.

*[Include Figure 3.1.7: Respondents' Willingness to Recommend an AI-Powered Dental App]*

### 3.3.7 Trust and Credibility Factors

When asked what would make users trust a dental app, the majority (97.7%) highlighted that **approval or endorsement by dental professionals** is crucial. Reflecting this, the development of ToothyMate involved collaboration with **Klinik Pergigian Dr. Karthi**, ensuring that the app's content and features are credible and professionally validated. This partnership enhances user confidence and supports the app's goal of providing reliable oral health guidance.

*[Include Figure 3.1.10: Trust and Credibility Factors Influencing User Confidence in Dental Apps]*

### 3.3.8 Topics of Interest in Oral Health

Participants identified dental topics they were most interested in learning about:
- Dental treatment explanations: 67.4%
- Early cavity and tooth damage detection: 51.5%
- Gum disease prevention: 41.9%
- Proper brushing techniques: 25.6%
- Dental prosthetics (dentures, crowns): 2.3%

These preferences informed the content focus of the app's E-Learning Library, ensuring lessons address the topics users find most valuable.

*[Include Figure 3.1.11: Survey Respondents' Topics of Interest in Oral Health Education]*

### 3.3.9 Attitudes Toward AR and Gamification Features

Participants gave an average rating of **4.40 out of 5** for the perceived usefulness of Augmented Reality (AR) integration in the app, indicating strong interest in interactive and visual learning tools for dental education.

Furthermore, **81.4% of respondents agreed** that a "streak system"—a gamified feature rewarding users for consistent dental care activities—would motivate them to maintain better oral hygiene habits. This strongly supports the inclusion of gamification elements including daily missions, streaks, and achievement badges in ToothyMate.

*[Include Figure 3.1.12: Respondents' Attitudes Toward AR and Gamification Features]*

### 3.3.10 Perceived Usefulness of App Functions

Respondents were introduced to the proposed core features of the ToothyMate app and asked for feedback on their perceived usefulness:

| Feature | Perceived Useful (%) |
|---------|---------------------|
| AR Tooth Model | 95.3% |
| AI Scan (Educational Purpose) | 97.7% |
| E-Learning Library | 93.0% |
| Gamification (Streaks, Rewards) | 88.4% |

The majority of participants expressed high interest and confidence in the usefulness of these features, indicating strong alignment between user expectations and the app's objectives. This pre-survey not only validated the app's core components but also provided essential guidance for tailoring content and features to user preferences.

*[Include Figure 3.1.13: Respondents' Perceived Usefulness of Proposed Core Features]*

### 3.3.11 Summary of Pre-Survey Findings

The pre-survey results informed the development of ToothyMate in several key ways:

| Finding | Implication for ToothyMate |
|---------|---------------------------|
| 95.3% never used dental apps | Opportunity for innovative, engaging solution |
| 53.5% only visit dentist when in pain | Need for preventive education and self-monitoring |
| 100% support AI-based detection | Strong validation for AI classification module |
| 97.7% trust professional-endorsed content | Collaboration with Klinik Pergigian Dr. Karthi |
| 4.40/5 rating for AR usefulness | Validation for AR 3D tooth model feature |
| 81.4% motivated by streak systems | Support for gamification with streaks and rewards |

---

## 3.4 System Design

The design phase of the ToothyMate application focused on translating the system requirements and objectives into an organized, user-oriented mobile application structure. The primary design goals were to ensure simplicity, ease of navigation, child-friendliness, and alignment with the core components: gamification, Augmented Reality (AR), Artificial Intelligence (AI) classification, and e-learning content.

### 3.4.1 System Architecture

ToothyMate follows a modular architecture based on the Model-View-Provider pattern, which separates concerns and enables maintainable, testable code:

```
┌─────────────────────────────────────────────────────────────────┐
│                    TOOTHYMATE ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    PRESENTATION LAYER                    │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │    │
│  │  │  Home    │ │ E-Learn  │ │ AI Scan  │ │   Chat   │   │    │
│  │  │  Screen  │ │  Screen  │ │  Screen  │ │  Screen  │   │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐                │    │
│  │  │ AR Tooth │ │  Splash  │ │ Welcome  │                │    │
│  │  │  Screen  │ │  Screen  │ │ Screens  │                │    │
│  │  └──────────┘ └──────────┘ └──────────┘                │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    STATE MANAGEMENT                      │    │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │    │
│  │  │ AppProvider  │ │AiScanProvider│ │ ChatProvider │    │    │
│  │  └──────────────┘ └──────────────┘ └──────────────┘    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                     SERVICE LAYER                        │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │    │
│  │  │    AI    │ │  Camera  │ │  Gemini  │ │   TTS    │   │    │
│  │  │ Service  │ │ Service  │ │ Service  │ │ Service  │   │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐                │    │
│  │  │  Image   │ │ Feedback │ │  Sound   │                │    │
│  │  │ Service  │ │ Service  │ │ Manager  │                │    │
│  │  └──────────┘ └──────────┘ └──────────┘                │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                      DATA LAYER                          │    │
│  │  ┌──────────────────┐  ┌──────────────────┐             │    │
│  │  │ SharedPreferences │  │    JSON Assets   │             │    │
│  │  │  (Local Cache)    │  │ (Lessons, i18n)  │             │    │
│  │  └──────────────────┘  └──────────────────┘             │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   EXTERNAL SERVICES                      │    │
│  │  ┌──────────────────┐  ┌──────────────────┐             │    │
│  │  │  TensorFlow Lite │  │   Google Gemini  │             │    │
│  │  │   (On-Device)    │  │      (API)       │             │    │
│  │  └──────────────────┘  └──────────────────┘             │    │
│  │  ┌──────────────────────────────────────────┐           │    │
│  │  │        Firebase (Cloud Database)         │           │    │
│  │  │  ┌─────────────┐  ┌─────────────────┐   │           │    │
│  │  │  │  Firestore  │  │ Anonymous Auth  │   │           │    │
│  │  │  └─────────────┘  └─────────────────┘   │           │    │
│  │  └──────────────────────────────────────────┘           │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.4.2 Application Flowchart

The flowchart illustrates the sequential interaction between the user and the ToothyMate application:

```
                                ┌─────────┐
                                │  START  │
                                └────┬────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │ Launch ToothyMate   │
                          │       App           │
                          └──────────┬──────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │   Display Splash    │
                          │      Screen         │
                          └──────────┬──────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │  First Time User?   │
                          └──────────┬──────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │ Yes            │                │ No
                    ▼                │                ▼
          ┌─────────────────┐       │      ┌─────────────────┐
          │ Language Select │       │      │  Display Home   │
          └────────┬────────┘       │      │     Screen      │
                   │                │      └────────┬────────┘
                   ▼                │               │
          ┌─────────────────┐       │               │
          │ Welcome Screens │       │               │
          └────────┬────────┘       │               │
                   │                │               │
                   └────────────────┴───────────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │   Select Feature    │
                          └──────────┬──────────┘
                                     │
          ┌──────────┬───────────────┼───────────────┬──────────┐
          │          │               │               │          │
          ▼          ▼               ▼               ▼          ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │  Daily   │ │ E-Learn  │ │ AI Scan  │ │   Chat   │ │ AR Tooth │
    │ Missions │ │  Library │ │  Teeth   │ │  Buddy   │ │  Model   │
    └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
         │            │            │            │            │
         ▼            ▼            ▼            ▼            ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │ Complete │ │  Browse  │ │  Camera/ │ │   Ask    │ │  Explore │
    │ Mission  │ │ Lessons  │ │  Gallery │ │ Question │ │ 3D Model │
    └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
         │            │            │            │            │
         ▼            ▼            ▼            ▼            ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │ Award XP │ │ Complete │ │   Get    │ │ Receive  │ │ Discover │
    │ + Streak │ │  Lesson  │ │ AI Result│ │ Response │ │  Cases   │
    └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
         │            │            │            │            │
         └────────────┴────────────┴────────────┴────────────┘
                                     │
                                     ▼
                          ┌─────────────────────┐
                          │  Return to Home?    │
                          └──────────┬──────────┘
                                     │
                         ┌───────────┴───────────┐
                         │ Yes                   │ No
                         ▼                       ▼
              ┌─────────────────┐      ┌─────────────────┐
              │  Display Home   │      │  Continue in    │
              │     Screen      │      │    Feature      │
              └─────────────────┘      └─────────────────┘
```

### 3.4.3 Use Case Diagram

The use case diagram represents the key functional interactions between the user (child) and the ToothyMate application:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    TOOTHYMATE USE CASE DIAGRAM                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│    ┌─────────┐                                                         │
│    │         │                                                         │
│    │  Child  │                                                         │
│    │  User   │                                                         │
│    │         │                                                         │
│    └────┬────┘                                                         │
│         │                                                               │
│         │         ┌───────────────────────────────────────────┐        │
│         │         │           ToothyMate System               │        │
│         │         │                                           │        │
│         ├────────>│  ┌─────────────────────────────────────┐ │        │
│         │         │  │     Complete Daily Missions         │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Earn XP         │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Update Streak   │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Level Up        │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  └─────────────────────────────────────┘ │        │
│         │         │                                           │        │
│         ├────────>│  ┌─────────────────────────────────────┐ │        │
│         │         │  │      Access E-Learning Library      │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> View Lessons    │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Complete Quiz   │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Watch Videos    │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  └─────────────────────────────────────┘ │        │
│         │         │                                           │        │
│         ├────────>│  ┌─────────────────────────────────────┐ │        │
│         │         │  │         Use AI Scan Feature         │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Capture Image   │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Get AI Result   │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Hear Feedback   │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  └─────────────────────────────────────┘ │        │
│         │         │                                           │        │
│         ├────────>│  ┌─────────────────────────────────────┐ │        │
│         │         │  │       View AR Tooth Model           │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Place 3D Model  │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Discover Cases  │    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  │  ┌─────────────────────────────┐    │ │        │
│         │         │  │  │ <<include>> Manipulate Model│    │ │        │
│         │         │  │  └─────────────────────────────┘    │ │        │
│         │         │  └─────────────────────────────────────┘ │        │
│         │         │                                           │        │
│         └────────>│  ┌─────────────────────────────────────┐ │        │
│                   │  │      Chat with Dental Buddy         │ │        │
│                   │  │  ┌─────────────────────────────┐    │ │        │
│                   │  │  │ <<include>> Ask Question    │    │ │        │
│                   │  │  └─────────────────────────────┘    │ │        │
│                   │  │  ┌─────────────────────────────┐    │ │        │
│                   │  │  │ <<include>> Receive Answer  │    │ │        │
│                   │  │  └─────────────────────────────┘    │ │        │
│                   │  │  ┌─────────────────────────────┐    │ │        │
│                   │  │  │ <<include>> Listen to TTS   │    │ │        │
│                   │  │  └─────────────────────────────┘    │ │        │
│                   │  └─────────────────────────────────────┘ │        │
│                   │                                           │        │
│                   └───────────────────────────────────────────┘        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.4.4 Data Flow for AI Classification Module

```
┌─────────────────────────────────────────────────────────────────┐
│              AI CLASSIFICATION DATA FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────┐       │
│  │  User    │───>│   Camera/    │───>│  Raw Image       │       │
│  │  Input   │    │   Gallery    │    │  (Variable size) │       │
│  └──────────┘    └──────────────┘    └────────┬─────────┘       │
│                                               │                  │
│                                               ▼                  │
│                                    ┌──────────────────┐          │
│                                    │  Image Service   │          │
│                                    │  - Resize 224x224│          │
│                                    │  - Normalize     │          │
│                                    │  - Float32       │          │
│                                    └────────┬─────────┘          │
│                                               │                  │
│                                               ▼                  │
│                                    ┌──────────────────┐          │
│                                    │  TensorFlow Lite │          │
│                                    │     Model        │          │
│                                    │  (On-Device)     │          │
│                                    └────────┬─────────┘          │
│                                               │                  │
│                                               ▼                  │
│                                    ┌──────────────────┐          │
│                                    │  Classification  │          │
│                                    │    Results       │          │
│                                    │  - Calculus  %   │          │
│                                    │  - Caries    %   │          │
│                                    │  - Healthy   %   │          │
│                                    │  - Stain     %   │          │
│                                    │  - Not Teeth %   │          │
│                                    └────────┬─────────┘          │
│                                               │                  │
│                                               ▼                  │
│                                    ┌──────────────────┐          │
│                                    │ Feedback Service │          │
│                                    │  - Generate Msg  │          │
│                                    │  - Select Icon   │          │
│                                    └────────┬─────────┘          │
│                                               │                  │
│                         ┌────────────────────┼────────────────┐  │
│                         │                    │                │  │
│                         ▼                    ▼                ▼  │
│                  ┌──────────┐        ┌──────────┐      ┌──────────┐
│                  │  Visual  │        │   TTS    │      │  Mascot  │
│                  │  Display │        │  Audio   │      │   Icon   │
│                  └──────────┘        └──────────┘      └──────────┘
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3.5 Tools and Technologies

Several tools, frameworks, and programming platforms were employed in the development of this project:

### 3.5.1 Development Framework and Language

| Tool/Technology | Purpose | Version |
|-----------------|---------|---------|
| **Flutter** | Cross-platform mobile development framework | 3.x |
| **Dart** | Programming language for Flutter | SDK 3.3.0+ |
| **Android Studio** | IDE for development and testing | Latest |
| **VS Code** | Code editor | Latest |

### 3.5.2 Core Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| **provider** | State management | ^6.1.1 |
| **tflite_flutter** | TensorFlow Lite for on-device ML | ^0.12.1 |
| **camera** | Camera access for AI scan | ^0.10.0+4 |
| **image_picker** | Gallery image selection | ^1.0.7 |
| **image** | Image processing and manipulation | ^4.3.0 |
| **google_generative_ai** | Google Gemini API for chatbot | ^0.4.5 |
| **ar_flutter_plugin** | Augmented Reality functionality | Any |
| **shared_preferences** | Local data persistence (cache) | ^2.1.1 |
| **firebase_core** | Firebase initialization | ^3.8.1 |
| **cloud_firestore** | Cloud database for user data | ^5.6.0 |
| **firebase_auth** | Anonymous authentication | ^5.3.4 |
| **easy_localization** | Bilingual support (EN/MS) | ^3.0.7 |
| **flutter_tts** | Text-to-speech functionality | ^4.2.2 |
| **audioplayers** | Sound effects playback | Any |
| **youtube_player_flutter** | YouTube video integration | ^9.1.1 |
| **confetti** | Celebration animations | Any |
| **lottie** | Animated illustrations | Any |
| **flip_card** | Interactive flip card UI | Any |

### 3.5.3 AI and Machine Learning

| Component | Description |
|-----------|-------------|
| **TensorFlow Lite Model** | Custom trained classifier for dental condition detection |
| **Input Size** | 224 × 224 pixels |
| **Output Classes** | Calculus, Caries, Healthy_Teeth, Stain, Not_Teeth |
| **Processing** | On-device inference (no cloud required) |
| **Google Gemini Flash** | Large language model for conversational AI chatbot |

### 3.5.4 Data Storage Strategy

ToothyMate employs a hybrid data storage approach combining local storage with cloud database:

| Storage Type | Technology | Purpose |
|--------------|------------|---------|
| **Local Cache** | SharedPreferences | Fast access to user data, offline support |
| **Cloud Database** | Firebase Firestore | Persistent user data backup, cross-device sync |
| **Authentication** | Firebase Anonymous Auth | Unique user identification without login |
| **Static Content** | JSON Assets | Lesson content with bilingual support (EN/MS) |

**Firebase Integration Benefits:**
- **No Login Required:** Users are automatically assigned a unique anonymous ID
- **Data Persistence:** User progress (XP, streaks, completed lessons) is backed up to cloud
- **Chat History:** Conversation history with the AI chatbot is preserved
- **Offline Support:** SharedPreferences serves as local cache when offline

### 3.5.5 Design and Documentation

| Tool | Purpose |
|------|---------|
| **Figma** | User interface design and prototyping |
| **Google Forms** | Survey data collection |
| **Draw.io** | Flowcharts and diagrams |

### 3.5.6 Asset Creation

| Asset Type | Tools/Sources |
|------------|---------------|
| **3D Tooth Model** | GLB format for AR visualization |
| **Lottie Animations** | JSON-based animations for splash screen |
| **Educational Images** | Custom graphics for e-learning content |
| **Sound Effects** | Audio files for UI feedback and celebrations |
| **Lesson Content** | JSON files with bilingual content |

---

## 3.6 Gantt Chart

*[Insert your existing Gantt Chart here]*

The project timeline follows the Agile sprints outlined in Section 3.2.1, spanning both semesters (SKM4950A and SKM4950B) with the following major phases:

1. **Planning Phase** (Weeks 1-4, Semester A)
   - Topic confirmation and supervisor consultation
   - Problem statement, objectives, and scope definition
   - Literature review and survey distribution

2. **Requirement and Design Phase** (Weeks 5-8, Semester A)
   - Survey analysis and user needs assessment
   - System scope and user scope definition
   - Wireframes and UI design
   - App flow and architecture design

3. **Proposal and Submission Phase** (Weeks 9-15, Semester A)
   - Draft proposal report
   - Proposal slides and presentation
   - Proposal defense and finalization

4. **Prototype and Development Phase** (Weeks 1-8, Semester B)
   - Learn required development tools
   - Prototype basic UI
   - Develop gamification, AR, AI, and e-learning modules
   - User feedback and module refinement

5. **Testing and Finalization Phase** (Weeks 9-14, Semester B)
   - User testing and evaluation
   - Bug fixes and improvements
   - Final thesis documentation
   - Final presentation preparation and submission

---

## 3.7 Expected Output

The expected outcome of this project is a fully functional mobile application that leverages gamification, AR, and AI technologies to raise awareness of oral health and encourage consistent oral hygiene practices among children. The application delivers:

1. **Engaging Gamified Experience:** A comprehensive gamification system with daily missions, XP rewards, hero rank progression, streaks, and achievement badges that motivates children to maintain consistent brushing habits.

2. **Interactive AR Visualization:** An augmented reality module featuring an interactive 3D tooth model with discoverable dental cases, helping children understand tooth anatomy and dental conditions through immersive visualization.

3. **AI-Powered Dental Classification:** An on-device machine learning model that provides educational, non-diagnostic feedback on tooth images, detecting visible signs of calculus, caries, stains, and healthy teeth.

4. **Comprehensive E-Learning Content:** A library of 13 structured lessons covering dental topics through interactive flip cards, quizzes, and video tutorials, delivered in both English and Malay.

5. **AI Chatbot Companion:** A conversational dental buddy powered by Google Gemini that provides child-friendly responses to dental questions with text-to-speech support.

It is anticipated that the app will positively influence children's oral health awareness and behaviors, serving as a model for the integration of digital technologies in preventive dental care education for young users.

---

## 3.8 Chapter Summary

This chapter has described the methodology adopted for developing the ToothyMate mobile application. The project follows 8 structured phases across two semesters, with the Agile methodology applied during Phase 6 (Agile Development) through 7 iterative development cycles. This approach enables continuous feedback, flexibility, and incremental delivery of features.

User requirement gathering through pre-survey provided valuable insights that shaped the application's features, validating the inclusion of gamification (81.4% support for streaks), AR visualization (4.40/5 usefulness rating), and AI classification (100% support for detection features).

The system design section presented the application architecture, flowcharts, and use case diagrams that guide the implementation. The tools and technologies section detailed the Flutter framework, TensorFlow Lite for on-device AI, Google Gemini for chatbot functionality, Firebase Firestore for cloud data persistence, and various supporting packages that enable the application's features. The hybrid data storage strategy combining local SharedPreferences with Firebase Firestore ensures both fast offline access and reliable cloud backup of user progress.

The next chapter will detail the implementation of each module, including the gamification system, AR visualization, AI classification, e-learning library, and AI chatbot companion.
