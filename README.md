# Tutor Finder

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
A tool to help students find tutors and tutors to connect with students.

### App Evaluation
- **Category:** Education
- **Mobile:** This app would be primarily developed for mobile but would perhaps be just as viable on a computer, such as tinder or other similar apps. Functionality wouldn’t be limited to mobile devices, however mobile version could potentially have more features.
- **Story:** Connects tutors and students to each other based on preferences and filters. 
- **Market:** Upper-level education students and their respective tutors.
- **Habit:** The app would be used based on need and how often the user wants to be tutored/tutor. 
- **Scope:** First the app would present the search filters and the user can choose depending on which subject or area they want to work with. The user can then view different information about the person they choose in their details/about page and decide whether or not to contact them.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Sign in
* Register
* List of tutors
* More information
* Profiles
* ...

**Optional Nice-to-have Stories**

* Rating System
* Filtering
* Chats
* Map
* ...

### 2. Screen Archetypes

* Login
   * Login
* Register
   * Register
* Stream
    * List of tutors
* Detail
    * More Information
* Profiles
    * Profile
* Maps
    * Map
* Creation
    * Rating System
    * Chat

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Stream
* Profile
* Maps

**Flow Navigation** (Screen to Screen)

* Login/Register
   * Stream
* Stream
   * Detail
   * Profiles
* Detail
    * Stream
    * Creation
* 


## Wireframes
<img src="https://imgur.com/X1Hd5X7.jpg" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
### Models
#### Profile

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the user profile |
   | name          | String   | user's name 
   | subjects      | String   | stores user's subjects |
   | image         | File     | user's profile image|
   | description   | String   | user's description for profile |
   | rating        | Number   | average rating given by their students/tutors |
   | isTutor       | Boolean  | defines whether user is tutor or student |
   | contact       | String   | user's contact information |
   
#### Chat
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | person | Pointer| the person that the user is talking to |
   | name | String | name of the person talking to |
   | image | File | profile image of that person
   | text | String | the messages sent back and forth 
   | time | Time | the time a message is sent
   
### Networking
  - Tutor Feed Screen
      - (Read/GET) Query all profiles where user is tutor
      - (Update/PUT) Query tutors matching search filters
  - User Profile Screen
      - (Read/GET) Query logged in user object
      - (Update/PUT) Update user profile image
      - (Update/PUT) Update user information/description
  - Tutor Detail Screen
      - (Read/GET) Query selected tutor object
  - Chat Feed Screen
      - (Read/GET) Query all chats the user is having
      - (Create/POST) Start sending message to a user for the first time
  - Chat Detail Screen
      - (Read/GET) Query all the messages between the user and another one
      - (Create/POST) Send a new message 
