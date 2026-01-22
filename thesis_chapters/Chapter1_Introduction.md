# CHAPTER 1: INTRODUCTION

## 1.1 Introduction

Oral health is a fundamental component of overall well-being, yet it remains one of the most neglected aspects of children's health globally. According to the World Health Organization (2022), dental caries in primary teeth affects approximately 514 million children worldwide, making it the most prevalent chronic disease among the pediatric population. Early childhood caries (ECC) can lead to pain, infection, difficulty eating, and impaired growth and development, significantly impacting children's quality of life and school performance.

In Malaysia, the oral health status of children remains a concern despite various governmental initiatives. Research indicates that 63.4% of Malaysian preschoolers aged 3-6 years have at least one untreated caries (Mohd Nor et al., 2020). Among indigenous children aged 11-12 years, the prevalence of caries reaches 61.6% (Abdul Kadir et al., 2019). These statistics highlight the persistent challenges in promoting effective oral hygiene practices among Malaysian children.

Traditional oral health education methods, such as classroom-based instruction and pamphlet distribution, have shown limited effectiveness in engaging young audiences and fostering lasting behavioral change (Romalee et al., 2023). Children often find conventional educational approaches uninteresting, leading to poor retention of oral health knowledge and inadequate development of proper brushing habits. Furthermore, the abstract nature of dental concepts makes it challenging for children to understand the importance of oral hygiene and the consequences of poor dental care.

The rapid proliferation of mobile technology presents new opportunities for innovative approaches to children's oral health education. Gamification, the application of game design elements in non-game contexts, has emerged as a promising strategy for motivating children to adopt and maintain healthy behaviors (Schwarz et al., 2020). Additionally, advances in Augmented Reality (AR) and Artificial Intelligence (AI) offer interactive and personalized learning experiences that can capture children's attention and facilitate deeper understanding of oral health concepts.

The **ToothyMate** application was developed in collaboration with Klinik Pergigian Dr. Karthi to address these challenges by creating an engaging, gamified mobile platform specifically designed for children. The application integrates AR technology for interactive 3D tooth visualization, AI-powered dental condition classification using on-device machine learning, and comprehensive e-learning content. Through gamification elements including daily brushing missions, experience points (XP), hero rank progression, daily streaks, and achievement badges, ToothyMate transforms oral hygiene from a mundane routine into an exciting adventure, encouraging children to develop and maintain positive dental care habits.

---

## 1.2 Problem Statement

Despite widespread awareness of the importance of oral hygiene, dental caries remains the most prevalent chronic disease among children globally. The World Health Organization (2022) reports that nearly 50% of children worldwide are affected by dental caries across various age groups under 12 years. In Malaysia, studies have shown that a significant proportion of preschool children have untreated dental caries, with associated risk factors including sugar consumption, nutritional status, and inadequate oral hygiene practices (Mohd Nor et al., 2020).

### Problem 1: Limited Engagement with Traditional Oral Health Education for Children

Traditional oral health education methods fail to effectively engage children and produce lasting behavioral change. Conventional approaches such as lectures, pamphlets, and verbal instructions from parents or dentists often do not resonate with young audiences (Romalee et al., 2023). Children may find these methods boring or difficult to understand, resulting in poor adherence to recommended oral hygiene practices. Research indicates that passive educational approaches are insufficient in developing self-care skills and changing oral hygiene behaviors, even with regular professional reminders (Chang et al., 2021).

A systematic review by Tezcan et al. (2024) found that while gamified interventions show significant promise for improving children's oral health behaviors, existing oral health mobile applications have limited gamification components, averaging only 6.87 out of 31 possible gamification features (Schwarz et al., 2020). Many applications focus solely on brushing timers without providing comprehensive educational content, interactive features, or reward systems that appeal to children's motivational needs. There is a clear need for a mobile application that combines engaging gamification mechanics with educational content specifically designed for children's learning styles and developmental stages.

### Problem 2: Difficulty in Visualizing Abstract Dental Concepts

Children often struggle to understand abstract concepts related to tooth anatomy, plaque accumulation, and the progression of dental caries. Static images and verbal explanations fail to convey the three-dimensional nature of teeth and the invisible processes of decay formation (Romalee et al., 2023). This lack of visual understanding contributes to children's inability to appreciate the importance of thorough brushing and the consequences of neglecting oral hygiene.

Meta-analyses of AR in education have demonstrated that augmented reality technology benefits learning outcomes across all levels, with particularly strong effects on performance-based outcomes (Garzón et al., 2022). AR has been shown to create realistic and enjoyable learning environments for young children by merging play with learning and enabling interactive engagement (Safar et al., 2022). However, the application of AR specifically for children's oral health education remains limited. There is an opportunity to leverage AR technology to help children visualize and interact with 3D tooth models, making abstract dental concepts tangible and understandable.

### Problem 3: Limited Access to AI-Based Dental Condition Feedback for Children

Most children only receive dental feedback during periodic dental visits, which may occur infrequently or be avoided due to dental anxiety. Between visits, parents and children often cannot assess the current state of oral hygiene or identify emerging problems such as plaque buildup, stains, or early signs of cavities.

Recent advances in artificial intelligence have demonstrated the feasibility of using deep learning models for detecting dental conditions from photographs. Research by Kühnisch et al. (2022) achieved over 90% accuracy in caries detection using Convolutional Neural Networks on intraoral photographs. Studies have also shown the effectiveness of AI models in detecting dental caries across different dentition stages in children, including primary, mixed, and permanent teeth (Alharbi et al., 2024). However, consumer-friendly applications that provide educational, non-diagnostic feedback for children's self-monitoring remain scarce. There is a need for an accessible AI-powered tool that can provide children and parents with simple, educational insights about visible dental conditions to support oral hygiene awareness between dental visits.

---

## 1.3 Project Objectives

The primary objectives of this project are:

**I. To develop a gamified mobile application aimed at improving oral health awareness and encouraging consistent brushing habits among children** by providing an engaging, child-friendly platform that incorporates game mechanics including daily brushing missions, XP rewards, hero rank progression, daily streaks, achievement badges, and comprehensive e-learning content.

**II. To incorporate Augmented Reality (AR) technology** that enables children to explore an interactive 3D tooth model with discoverable dental cases, helping young users understand tooth anatomy and common oral health conditions through immersive visualization and interactive learning.

**III. To integrate Artificial Intelligence (AI) for dental condition classification** using an on-device TensorFlow Lite machine learning model that provides non-diagnostic, educational feedback based on tooth images, detecting visible signs of calculus (plaque/tartar), caries (cavities), and stains to support children's oral hygiene awareness.

---

## 1.4 Project Scope

### A. System Scope

The system scope of ToothyMate encompasses the development of an integrated mobile application with the following components:

#### Gamification System
- Daily brushing missions (morning and night) that award 20 XP upon completion
- Progressive hero rank system with six levels: Tooth Cadet (Level 1-4), Plaque Protector (Level 5-9), Cavity Fighter (Level 10-19), Smile Guardian (Level 20-29), Tooth Master (Level 30-49), and Legendary Hero (Level 50+)
- Daily streak counter that tracks consecutive days of completing both brushing missions
- Four achievement badges: Early Bird (morning brush), Night Owl (night brush), Plaque Protector (reach Level 5), and Tooth Genius (complete 13 lessons)
- Level progression system requiring 100 XP per level
- Personalized user profile with editable username

#### E-Learning Module
- 13 structured lessons organized by categories (Core Dental Knowledge, Myth vs Fact, Mom's Special Section, Video Tutorials)
- Interactive flip cards, inline quizzes, and educational images
- YouTube video integration for brushing technique demonstrations
- Lesson completion tracking with progress indicators
- Search and category filtering functionality
- Bilingual content (English and Malay)

#### Augmented Reality (AR) Module
- Interactive 3D tooth model using GLB format rendered through AR Flutter plugin
- Ten discoverable dental cases with educational information about different dental conditions
- Gesture controls including pinch-to-zoom and rotation for model manipulation
- Celebratory confetti animations and text-to-speech feedback upon case discovery
- Real-world plane detection for placing the 3D model in the user's environment

#### Artificial Intelligence (AI) Classification Module
- On-device TensorFlow Lite classifier with 224×224 pixel input size
- Classification of five categories: Calculus, Caries, Healthy Teeth, Stain, and Not Teeth
- Camera integration supporting both front and rear cameras for live capture
- Gallery image upload functionality for analyzing existing photos
- Confidence score display (0-100%) for each detected condition
- Animated mascot feedback with text-to-speech responses
- No-teeth detection threshold to filter invalid images

#### AI Chatbot Companion (Dental Buddy)
- Google Gemini Flash API integration for conversational AI
- Child-safe content filtering with safety settings for harassment, hate speech, and explicit content
- Bilingual support (English and Malay) with context-aware responses
- Dynamic bot personality with emotional responses (happy, sad, concern) based on conversation keywords
- Quick question buttons for common dental queries (braces, brushing, cavities, tooth pain, candy, jokes)
- Text-to-speech functionality for reading responses aloud
- Chat history persistence using local storage

#### Technical Infrastructure
- Flutter framework with Dart programming language (SDK 3.3.0+)
- Local data storage using SharedPreferences enabling offline functionality
- Bilingual localization (English and Malay) using easy_localization package
- Text-to-speech functionality using flutter_tts package
- Sound effects and audio feedback using audioplayers package
- Material 3 design compliance with child-friendly UI/UX

### B. User Scope

The primary users of ToothyMate are **children aged 5-12 years** who are developing their oral hygiene habits and require engaging, age-appropriate tools for dental health education. Secondary users include **parents** who may use the application alongside their children to monitor progress, access the "Mom's Special Section" content for pregnancy and baby teeth care, and utilize the AI chatbot for dental queries.

Users are expected to engage with the application by:
- Completing daily morning and night brushing missions to earn XP and maintain streaks
- Exploring the 3D tooth model through the AR feature to discover dental cases and learn about tooth anatomy
- Using the AI scan feature to capture tooth images for educational feedback on dental conditions
- Interacting with the AI Dental Buddy chatbot to ask dental questions in a conversational manner
- Accessing e-learning lessons to build dental knowledge through interactive content
- Tracking progress through the hero rank system and unlocking achievement badges

The application is designed to be intuitive for young users, featuring:
- Colorful, child-friendly user interface with animated elements and Lottie animations
- Simple navigation with clearly labeled icons and visual cues
- Text-to-speech support for pre-literate or early-reading children
- Offline functionality for use without internet connectivity (except AI chatbot)
- No user registration required, ensuring simplicity and privacy protection
- Tutorial overlay for first-time users to understand app features

---

## 1.5 Contributions of This Study

This project makes several contributions to the fields of mobile health (mHealth), children's oral health education, and educational technology:

1. **For Children:** ToothyMate provides an engaging platform that transforms dental hygiene from a chore into an enjoyable activity through gamification, potentially improving brushing compliance and oral health awareness among young users.

2. **For Parents:** The application offers a tool to support their children's oral health education while providing access to credible dental information through the AI chatbot and e-learning content developed in collaboration with Klinik Pergigian Dr. Karthi.

3. **For Dental Professionals:** ToothyMate serves as a complementary patient education tool that can be recommended to young patients and their families, extending oral health education beyond the dental clinic.

4. **For Researchers and Developers:** This project demonstrates the feasibility of integrating multiple technologies (AR, on-device AI classification, conversational AI, gamification) within a single mobile health application targeted at children, providing insights for future mHealth development.

5. **For the Malaysian Community:** With bilingual support (English and Malay), ToothyMate addresses the local context and contributes to national oral health improvement efforts aligned with the Ministry of Health Malaysia's preventive care initiatives.

---

## 1.6 Project Timeline

*[Insert Gantt Chart here]*

The project follows the Agile methodology with iterative development cycles (sprints). Key phases include:
- Planning and literature review
- Requirement gathering and design
- Prototype development and iteration
- Core module development (Gamification, AR, AI, E-Learning)
- Integration and testing
- User evaluation and refinement
- Final documentation and presentation

---

## 1.7 Thesis Organization

This thesis consists of six chapters organized to reflect the systematic approach toward achieving the project objectives:

**Chapter 1: Introduction** presents the project background, problem statement, objectives, scope, and contributions of this study. It establishes the rationale for developing a gamified oral health application for children integrating AR and AI technologies.

**Chapter 2: Literature Review** provides a comprehensive review of existing research on children's oral health status, gamification in health applications, augmented reality in education, and artificial intelligence for dental image classification. It also examines existing oral health mobile applications and identifies gaps that ToothyMate addresses.

**Chapter 3: Methodology** describes the development approach adopted for this project, including the Agile methodology, user requirement gathering through pre-survey, system design with flowcharts and use case diagrams, and the tools and technologies employed.

**Chapter 4: Implementation** details the development process of each module including the gamification system, AR visualization, AI classification, AI chatbot, and e-learning features.

**Chapter 5: Testing and Evaluation** presents the testing procedures, user evaluation results, and analysis of the application's effectiveness in engaging children and supporting oral health education.

**Chapter 6: Conclusion** summarizes the project achievements, discusses limitations, and provides recommendations for future enhancements.
