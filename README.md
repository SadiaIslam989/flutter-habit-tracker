# habit_tracker

 A flutter app to help users build routines , track habits and stay motivated.

## Features 

-**User Authentication**
  - Register/ login / Logout (Firebase Authrntication)
  - use email and password to login
  - user saved with Sharedprefernces
  
- **User Profile**
  - View and edit profile
  - updates sync instantly across devices
  - Emain shown as read-only

- **Habits**
  - shows default habits for new users
  - create , edit , delete habits
  - properties : tittle , category , frequency , start date , notes
  - stored in firestore under `users/{userId}/habits/{habitId}`

- **Habit Tracking**
  - daily/weekly completion marking
  - prevents invalid completion dates
  - track streaks

- **Categories**
  - Health,Study, Fitness, Productivity, Mental Health, Other
  - shows as tags with icons
  - filter habits by category

- **Motivational Quotes**
  - fetched from API - (Quoteable)
  - save to favorites in firestore
  - Randomized on refresh

-  **Favorites Screen**
  - View saved quotes
  - Option to unfavorite (syncs instantly)

- **Progress Visualization**
   - line chart for recent progress
   - last 7 days/ current week chart
   - updates when habits marked complete
   - tooltip list

- **Themes**
   -dark/light theme toggle
   -applied instantly without restart

  

  ## Author

**Sadia Islam**
   
