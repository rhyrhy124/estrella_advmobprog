# Rhyza Ann H. Estrella
## INF 233
### CTADMOBL Advance Mobile Programming

A Flutter Project that focuses on Advance topics covering API and
Mobile Application Transactions


# Lab Activity Instance


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



# Lab Activity 3

## Add to Cart Transaction


This activity demonstrates how to add products to a cart using an API.

The **Bulldogs Exchange** application uses the **DummyJSON API**
to handle the Add to Cart feature.

The API used for adding products is:

https://dummyjson.com/carts/add


## Add to Cart


When the user clicks the **Add to Cart** button, the selected product
is added to the user's cart.

The product is also sent to the DummyJSON API.


## User Cart


Each user has their own cart.

For example:

User 1 has their own cart.

User 2 has a different cart.

The cart items of User 1 should not be shown to User 2.


## Cart Items


The existing items in the user's cart should stay when adding
a new product.

For example, User 1 already has:

- Product A
- Product B
- Product C


When User 1 adds Product D, the cart should contain:

- Product A
- Product B
- Product C
- Product D


The new product should be added without removing the existing
cart items.


## What I Learned


### POST Request

I learned how to use a POST request to send product information
to an API when adding a product to the cart.


### Add to Cart

I learned how to make the Add to Cart button work with an API.


### Cart

I learned how to display products inside the cart and add new
products without removing the existing items.


### User Data

I learned how to separate the cart of one user from another user.


### API Response

I learned how to get the response from the API and use the data
to update the cart.



# Lab Activity 4

## Persistent Authentication and User Profile


This activity demonstrates how to save user login information using
`SharedPreferences` and display it on the Profile Screen.

The application uses the **DummyJSON API** for user authentication.


## Persistent Authentication


The app saves the user's information after a successful login.

The Splash Screen checks if the user is already logged in.

If logged in, the user goes to the Home Screen. Otherwise, the user
goes to the Sign In Screen.


## User Service and User Model


The `UserService` handles the login, saving, and retrieving of user data.

The `User` model is used to handle the user information from the API.


## Profile Screen


The Profile Screen displays the saved information of the logged-in user,
such as the name, username, email, gender, and user ID.


## Cart Using User ID


The saved user ID can be used to get the cart of the logged-in user.

This helps show the correct cart for each user.


## Discussion


The **User Model** handles the user data, while the **UserService**
handles the API and saved data.

The **Screens** display the information and handle user actions.

Using these parts makes the code more organized and easier to manage.


## What I Learned


### SharedPreferences

I learned how to save and retrieve user data locally.


### Authentication

I learned how to keep the user logged in after closing the app.


### User Model

I learned how to use a model for user data from the API.


### Profile

I learned how to display saved user information.


### User ID

I learned how to use the user ID to show the correct cart.
