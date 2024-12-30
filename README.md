# Bingebros 🎥🎮📚  

**Bingebros** is a centralized entertainment hub for movies, games, books, and anime enthusiasts. Currently, the app focuses on the **Movies** section, offering personalized recommendations and top picks powered by APIs. The app is backed by Firebase for secure authentication and data management.

---

## Table of Contents  

1. [Features](#features)  
2. [Modules and Working](#modules-and-working)  
   - [Movies Section](#movies-section)  
   - [Authentication](#authentication)  
3. [Installation](#installation)  
4. [Usage](#usage)  
5. [API Integrations](#api-integrations)  

---

## Features  

- **Personalized Recommendations**: Leverage **TheMovieDB.org** and **Gemini API** to get tailored movie suggestions.  
- **Firebase-Integrated Authentication**: Log in securely via **Google** or **Phone Number**.  
- **Modern Design**: Experience a sleek and intuitive UI optimized for all devices.  
- **Extensible Categories**: Ready to expand with **Games**, **Books**, and **Anime** sections.  

---

## Modules and Working  

### Movies Section  

1. **Home Page**:  
   - Displays recommended movies and top picks using **TheMovieDB.org API**.  
   - Dynamically updates content based on user preferences and trends.  

2. **Movie Swiper**:  
   - Offers movie recommendations powered by **Gemini API**.  
   - Swipe to explore and add movies to your favorites or watchlist.  

### Authentication  

- **Google Login**: Easily sign in with your Google account.  
- **Phone Authentication**: Use your phone number to create and access your account securely.  

---

## Installation  

1. **Clone the Repository**:  

    ```bash
    git clone https://github.com/YourUsername/Bingebros.git
    cd Bingebros
    ```

2. **Install Dependencies**:  

    ```bash
    flutter pub get
    ```

3. **Setup Firebase**:  
   - Add your Firebase configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) to the respective directories.  
   - Ensure authentication and Firestore are configured in your Firebase project.  

4. **Run the Application**:  

    ```bash
    flutter run
    ```

---

## Usage  

1. **Authentication**:  
   - Log in via Google or Phone Number.  

2. **Explore Movies**:  
   - Navigate the Home Page for top picks and recommendations.  
   - Visit the Movie Swiper page for tailored suggestions.
    
3. **Bookmarks**
    - Bookmark movies that you want to watch later from any section.
    - Transfer bookmarks to watched list to keep track of the movies you have watched.

3. **Future Sections**:  
   - Access other categories (**Games**, **Books**, **Anime**) in upcoming updates.  

---

## API Integrations  

1. **TheMovieDB.org API**:  
   - Powers the Home Page with trending movies and recommendations.  

2. **Gemini API**:  
   - Enables the Swiper feature for custom movie suggestions.  

3. **Firebase**:  
   - Manages backend operations, including authentication and database.  

---
