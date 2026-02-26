## AuthFlow - Authentication System

- A simple and modern authentication application built with Flutter and Supabase.

----

## Overview

AuthFlow is a clean authentication app that provides multiple login methods using Supabase. It
includes email/password authentication, social logins (Google/Facebook), and phone number
verification with OTP.

----





|  التسجيل |  الشاشه الرئيسيه | إدارة الوصفات | المفضله | اعدادات المستخدم |تفاصيل الوصفه
|----------------|-----------------|--------------|-----------------|-----------------|-----------------|
| <img width="130" height="250" alt="registration_page" src="https://github.com/user-attachments/assets/d0f27f57-6199-4ddf-9238-36bb69f62926" /> | <img width="130" height="250" alt="home_screen" src="https://github.com/user-attachments/assets/fffc5fd6-184d-4e85-9c27-3e279dde732f" /> | <img width="130" height="250" alt="user_recipes" src="https://github.com/user-attachments/assets/858a1f10-0f2a-4c3a-8f88-dd3f0cd1d22b" /> |<img width="130" height="250" alt="user_favorites" src="https://github.com/user-attachments/assets/36f1b64e-e914-43ba-9d06-f2bad00f8a54" /> | <img width="130" height="250" alt="user_settings" src="https://github.com/user-attachments/assets/d56549cd-1342-4800-9134-33d0374bed70" /> | <img width="130" height="250" alt="recipe_details" src="https://github.com/user-attachments/assets/b6e46649-6783-4100-acb3-d7d7ba504266" />


## Features

- **Login with Email & Password**
- **Sign up with Email**
- **Social Login** (Google, Facebook)
- **Phone Authentication** with OTP
- **Password Reset**
- **Clean and Modern UI**

----

## Screenshots

<!--  -->

----

## Project Structure

<!-- 

   AppConstants.dart
│   auth_lisener.dart
│   auth_validators.dart
│   main.dart
│   validators.dart
│   
├───screens
│       forgot_password_screen.dart
│       otp_screen.dart
│       phone_input_screen.dart
│       reset_password_screen.dart
│       signin_screen.dart
│       signup_screen.dart
│       
├───service
│       auth_service.dart
│       
└───widgets
    │   auth_footerlink.dart
    │   auth_header_widget.dart
    │   basic_text_field.dart
    │   divider_widget.dart
    │   forgot_password_link.dart
    │   glowing_background.dart
    │   gradient_button.dart
    │   password_text_field.dart
    │   social_auth_button.dart
    │   
    └───phone_input_widget
            otp_input_widget.dart

-->

----

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
