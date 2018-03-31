const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')
const jsonServer = require('json-server')
const proxy = require('express-http-proxy')
const WebSocket = require('ws')
const { Observable } = require('rxjs')
const animal = require('./animal')
const picshareDB = require('./picshare.json')

// Constants
// =========

const PORT = process.env.PORT || 5000
const isProduction = process.env.NODE_ENV === 'production'

// Helpers
// =======

const randomDelay = (min, max) =>
  Math.floor(Math.random() * (max - min)) + min

const randomIteration = array => Observable.create((subscriber) => {
  const copy = array.slice(0)

  while (copy.length > 0) {
    const index = Math.floor(Math.random() * copy.length)
    const [item] = copy.splice(index, 1)
    subscriber.next(item)
  }

  subscriber.complete()
})

// API
// ===

const app = express()

app.use(bodyParser.json())
app.use(cors())

// Homepage
app.use(express.static('build'))

// Salad Builder
app.post('/salad/send', (req, res) => {
  if ('fail' in req.query) {
    res.sendStatus(500)
  } else {
    res
      .status(201)
      .send(req.body)
  }
})

// Animals
const animals = animal.allUnique()
const largeAnimals = animal.randomList(4000)

app.get('/animals', (req, res) => {
  res.send(animals)
})

app.get('/animals/large', (req, res) => {
  res.send(largeAnimals)
})

// Picshare
app.get('/*.(jpg|png)', proxy('programming-elm.surge.sh'))
app.use(jsonServer.router('picshare.json'))

// Server
const server = app.listen(PORT, () => {
  if (!isProduction) {
    console.log(`Server listening at http://localhost:${PORT}`)
  }
})

// WebSockets
// ==========

const wss = new WebSocket.Server({ server })

const feed$ = randomIteration(picshareDB.wsFeed)
  .map(JSON.stringify)
  .concatMap(photo =>
    Observable
      .of(photo)
      .delay(randomDelay(1000, 5000))
  )

wss.on('connection', (ws) => {
  const subscription = feed$.subscribe(photo => ws.send(photo))

  ws.on('error', () => {})
  ws.on('close', () => subscription.unsubscribe())
})
