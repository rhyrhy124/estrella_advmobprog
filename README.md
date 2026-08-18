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