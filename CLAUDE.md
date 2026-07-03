# CLAUDE.md

## Project Overview

This repository contains the source code for **AI School Health Coach (AIMedic)**, an AI-powered health companion designed specifically for middle school students. The project was created for the **Samsung Solve for Tomorrow** competition under the theme of **using technology to create a more sustainable society**.

The application's mission is to help students develop healthier lifestyles by providing personalized guidance for physical and mental well-being using artificial intelligence. Rather than acting as a medical diagnosis system, the platform serves as a daily health coach that encourages students to build long-term healthy habits through education, reminders, motivation, and personalized recommendations.

The project addresses several major problems affecting students today:

- Increasing screen time and reduced physical activity.

- Rising rates of myopia, poor posture, obesity, and sleep deprivation.

- Growing levels of stress, anxiety, and emotional imbalance.

- Lack of personalized and continuous health guidance.

- Limited communication between students, parents, teachers, and school health staff regarding overall health trends.

The application aims to become a trusted digital companion that helps students understand their own health while respecting privacy and encouraging positive behavior instead of punishment.

---

# Core Vision

The project should always prioritize:

- Student health before technology.

- Simplicity over unnecessary complexity.

- Privacy before data collection.

- Motivation instead of pressure.

- Personalization instead of generic advice.

- Scientific evidence over assumptions.

Every feature should answer the question:

> "Does this genuinely help students build healthier habits?"

If the answer is no, the feature should be reconsidered.

---

# Target Users

Primary users:

- Middle school students

Secondary users:

- Parents

- Teachers

- School administrators

- School health staff

Students should always remain the primary focus when making design decisions.

---

# Technology Stack

## Frontend

- Flutter

- Material Design 3

- Responsive UI

- Mobile-first design

- Tablet compatible

## Backend

- Python

- FastAPI

- REST API architecture

## Database

- Firebase Firestore

- Firebase Authentication

- Firebase Storage

## AI

- Gemini API

- LLM-powered health assistant

- Prompt engineering

- Personalized recommendation engine

## Computer Vision

Used for:

- Posture detection

- Screen distance estimation

- Sitting position analysis

Computer vision should run efficiently and should not require expensive hardware.

---

# Core Features

## 1. AI Health Coach

An AI chatbot that communicates naturally with students.

Responsibilities:

- Answer health-related questions.

- Explain healthy habits.

- Encourage healthy routines.

- Provide age-appropriate guidance.

- Recommend healthier daily choices.

- Explain scientific concepts simply.

The AI must never:

- Diagnose diseases.

- Prescribe medication.

- Replace doctors.

- Create panic.

- Make unsupported medical claims.

Whenever appropriate, recommend consulting parents, teachers, or healthcare professionals.

---

## 2. Personalized Health Profile

Students provide:

- Age

- Gender

- Height

- Weight

- Activity level

- Sleep schedule

- Study schedule

The application calculates:

- BMI

- Water intake recommendations

- Daily calorie estimation

- Activity recommendations

- Sleep recommendations

Everything should be personalized rather than using one-size-fits-all advice.

---

## 3. Daily Health Tracking

Students can log:

- Sleep

- Water intake

- Meals

- Exercise

- Mood

- Stress level

- Screen time

The system should visualize progress over time rather than overwhelming students with numbers.

---

## 4. Nutrition Assistant

Students can:

- Enter meals manually.

- Take photos of meals.

- Receive nutritional estimates.

The AI should provide:

- Estimated calories

- Protein

- Carbohydrates

- Fat

- Healthy suggestions

Responses should be educational rather than judgmental.

---

## 5. Smart Reminders

Reminder examples:

- Drink water

- Stretch

- Rest eyes

- Walk

- Sleep

- Relax

- Practice breathing

Reminders should adapt to:

- School timetable

- User activity

- Time of day

- Previous habits

Avoid excessive notifications.

---

## 6. Computer Vision Posture Assistant

Using the camera, AI can estimate:

- Sitting posture

- Neck angle

- Screen distance

- Head position

The application should gently remind students to:

- Sit straighter.

- Increase screen distance.

- Rest their eyes.

- Stretch.

Camera processing should prioritize privacy and local processing whenever possible.

---

## 7. Mental Wellness

Students can:

- Log mood

- Track stress

- Journal thoughts

AI should:

- Encourage healthy coping strategies.

- Suggest breathing exercises.

- Suggest breaks.

- Recommend talking to trusted adults if needed.

The AI must never pretend to be a therapist.

---

## 8. Habit Detection

Instead of only analyzing one day, the AI should detect long-term trends.

Examples:

- Consistently sleeping too little.

- Rarely drinking enough water.

- Excessive screen time.

- Lack of exercise.

- Increasing stress.

The AI should generate actionable recommendations based on patterns rather than isolated events.

---

## 9. Gamification

Students earn:

- XP

- Coins

- Badges

- Achievement levels

- Daily streaks

Healthy habits should feel rewarding.

Competition should remain friendly rather than stressful.

---

## 10. Parent & Teacher Dashboard

Dashboard shows only aggregated and authorized information.

Examples:

- Overall class wellness

- Average sleep

- Average activity

- Stress trends

- Water intake trends

Individual student privacy should always be protected.

---

# AI Principles

Every AI response should be:

- Friendly

- Encouraging

- Easy to understand

- Age appropriate

- Evidence based

- Non-judgmental

- Personalized

Avoid:

- Fear tactics

- Medical diagnosis

- Complex terminology

- Generic responses

---

# Privacy

Student privacy is one of the highest priorities.

Requirements:

- Secure authentication

- Encrypted communication

- Minimal data collection

- No unnecessary personal information

- Parent consent where applicable

- Anonymous analytics whenever possible

Teachers should never access unnecessary personal health information.

---

# Security

Follow best practices:

- Authentication

- Authorization

- Secure API endpoints

- Environment variables

- Rate limiting

- Input validation

- Secure Firebase rules

Never expose:

- API keys

- Secrets

- Tokens

- Private credentials

---

# UI Philosophy

The application should feel:

- Bright

- Friendly

- Calm

- Minimal

- Modern

- Accessible

Avoid clutter.

Students should understand the interface immediately.

Use:

- Large touch targets

- Clear icons

- Consistent spacing

- Smooth animations

---

# Code Standards

Write code that is:

- Modular

- Reusable

- Well documented

- Strongly typed where possible

- Easy to maintain

- Easy to extend

Prefer:

- Small functions

- Separation of concerns

- Feature-based architecture

- Clean naming conventions

Avoid:

- God classes

- Massive widgets

- Duplicate logic

- Hardcoded values

---

# Performance

Prioritize:

- Fast startup

- Responsive UI

- Low battery usage

- Efficient API usage

- Image optimization

- Lazy loading

The application should run smoothly on average Android devices used by students.

---

# Accessibility

Support:

- Color contrast

- Readable typography

- Screen readers where possible

- Simple language

- Large buttons

- Clear navigation

---

# Future Expansion

The architecture should be designed so future features can be added easily, including:

- Smartwatch integration

- School-wide analytics

- Health challenges

- AI voice assistant

- Wearable health synchronization

- Additional languages

- Personalized learning recommendations

- Emergency health alerts

- Community wellness events

---

# Development Philosophy

Every implementation should prioritize:

1\. Student well-being.

2\. User privacy.

3\. Scientific credibility.

4\. Simplicity.

5\. Maintainability.

6\. Scalability.

7\. Security.

8\. Accessibility.

When multiple implementation options exist, choose the solution that is easiest to maintain, safest for student data, and provides the best long-term user experience.

---

# Medical Disclaimer

AI School Health Coach is an educational wellness platform designed to encourage healthy habits and provide personalized lifestyle guidance.

The application **does not diagnose medical conditions, prescribe treatments, replace healthcare professionals, or provide emergency medical services.**

All recommendations should be presented as educational guidance based on established health practices. Users experiencing serious symptoms or medical emergencies should seek assistance from qualified healthcare professionals immediately.

The AI should always acknowledge its limitations and avoid presenting uncertain information as fact.

