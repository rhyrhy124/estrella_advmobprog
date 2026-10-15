# Rhyza Ann H. Estrella
## INF 233
### CTADMOBL Advance Mobile Programming

A Flutter Project that focuses on Advance topic covering the Web to Mobile transaction

## Lab Activity Instance


# Lab Activity 1

## Ephemeral State vs App State


This activity demonstrates the use of state management in Flutter.

The counter feature uses **Ephemeral State** with `setState()` 
because the data is only used inside one screen.

The theme feature uses **App State** with `Provider` because 
the data can affect the whole application.



## Discussion


### setState()

Used for simple data changes inside one screen.


### Provider

Used for managing shared data that can be accessed by different 
parts of the application.


# Lab Activity 2

## Web to Mobile Transaction

This activity demonstrates how a Flutter mobile application can get
data from a web API and display it inside the application.

The **Bulldogs Exchange** application gets product information from
an API and displays it in different screens such as the Shop,
Product Details, and Cart.

## What I Learned

### API and HTTP

I learned how to connect Flutter to a web API using the `http` package
and get product data.

### JSON and Model

I learned how to convert JSON data from the API into Dart objects
using a model class.

### FutureBuilder

I learned how to use `FutureBuilder` to handle loading, error, and
successful data from the API.

### Provider

I learned how to use Provider to manage shared data such as the cart
and application theme.

### .env

I learned how to use an `.env` file to store the API host instead of
putting it directly in the code.


# Lab Activity 5

This activity uses Firebase for sign-up, login, and managing
the user's account.


## Discussion

In DummyJSON, I use sample accounts to log in. The app sends the
username and password to the API and gets the user details.

In Firebase, users can create their own account using email and
password. Firebase Authentication saves the account, while
Firestore saves the other profile details.

I use UserService to keep the account functions in one file.
It handles login, sign-up, viewing user details, updating username,
changing password, deleting account, and logout.

Firebase helps the app save real accounts and keep users logged in.
The security rules also help protect each user's profile.


## What I Learned

I learned how to connect Firebase to Flutter, create an account,
and save user details in Firestore. I also learned how to update
the username, change the password, delete the account, and log out.


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
