# programming-elm.com

This repo contains the source for [programming-elm.com](https://programming-elm.com), the accompanying website to my book [_Programming Elm_](https://pragprog.com/book/jfelm/programming-elm) from the Pragmatic Programmers.

## About

* The server is built with [Express](https://expressjs.com/).
* The homepage is a PWA built with Elm.
  * It was bootstrapped with [create-elm-app](https://github.com/halfzebra/create-elm-app).
  * Content is pre-rendered with [elm-static-html-lib](https://github.com/eeue56/elm-static-html-lib) for SEO.
  * Layout and styling is managed with [style-elements](https://github.com/mdgriffith/style-elements).
* The API routes such as `/feed` are used throughout the tutorials in [_Programming Elm_](https://pragprog.com/book/jfelm/programming-elm).
