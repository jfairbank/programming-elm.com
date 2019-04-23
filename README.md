# programming-elm.com

This repo contains the source for [programming-elm.com](https://programming-elm.com), the accompanying website and API to my book [_Programming Elm_](https://pragprog.com/book/jfelm/programming-elm) from the Pragmatic Programmers.

## Run API Locally

As you work through the book, I encourage you to use the API endpoints provided from the server at [programming-elm.com](https://programming-elm.com) for simplicity's sake. However, if you would prefer to run the server locally, you may do so by following these instructions:

```
npm install
npm start
```

The server should start on port 5000:

```
Server listening at http://localhost:5000
```

Then, as you follow along with the book, replace the protocol and domain for the HTTP and WebSocket URLs from the code samples like so:

```
https://programming-elm.com  ==>  http://localhost:5000

wss://programming-elm.com    ==>  ws://localhost:5000
```
