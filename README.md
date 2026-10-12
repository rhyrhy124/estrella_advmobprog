
# Lab Activity 6

## Firebase Chat Application

This activity adds a chat feature to the Bulldogs Exchange application using Flutter and Firebase.

The application allows registered users to view other users, select someone to chat with, and send and receive messages. Firebase Authentication identifies the currently signed-in user, while Cloud Firestore stores user profiles, chat rooms, and messages.


## Discussion

### Firebase Authentication

I used Firebase Authentication to identify the currently signed-in user. The user's unique ID helps the application determine who is sending a message and who will receive it.

### Cloud Firestore

I used Cloud Firestore to retrieve registered users and store conversations and messages. It also allows the chat screen to update when new messages are sent.

### Chat Service

I used `ChatService` to handle chat-related functions, such as retrieving users, creating chat rooms, sending messages, and updating message statuses.

### Chat Screen

The chat screen displays the list of users and existing conversations. Users can select another registered user to open a conversation and exchange messages.

### Message Status

The application supports message statuses such as Sent, Delivered, and Seen. These statuses help users know the progress of their messages.

### User Profile and Display Name

I worked on displaying the correct recipient's name and profile icon in the conversation. The application uses the selected user's ID to retrieve the correct profile from Firestore.


## What I Learned

I learned how to create a chat feature in Flutter using Firebase Authentication and Cloud Firestore. I also learned how to retrieve registered users, identify the sender and recipient using their user IDs, store messages, and display conversations.

I also learned the importance of checking user IDs to make sure that the correct person's name and profile appear in the chat. This activity helped me understand how Firebase and Flutter work together to support communication.
