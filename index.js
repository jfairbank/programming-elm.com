const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')
const jsonServer = require('json-server')
const proxy = require('express-http-proxy')
const WebSocket = require('ws')
const { Observable } = require('rxjs')
const picshareDB = require('./picshare.json')

// Constants
// =========

const PORT = process.env.PORT || 5000
const isProduction = process.env.NODE_ENV === 'production'

// Helpers
// =======

const randomDelay = (min, max) => Math.floor(Math.random() * (max - min)) + min

const randomIteration = array =>
  Observable.create(subscriber => {
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
app.use(express.static('site/_site'))

// Salad Builder
app.post('/salad/send', (req, res) => {
  if ('fail' in req.query) {
    res.sendStatus(500)
  } else {
    res.status(201).send(req.body)
  }
})

// Animals
const animals = require('./animals.json')
const largeAnimals = require('./animals-large.json')

app.get('/animals', (req, res) => {
  res.send(animals)
})

app.get('/animals/large', (req, res) => {
  res.send(largeAnimals)
})

// Picshare
const staticAssetsSource = isProduction
  ? proxy('programming-elm.surge.sh')
  : express.static('static-assets')

app.get('/*.(jpg|png)', staticAssetsSource)
app.get('/font-awesome*.(css|otf|eot|svg|ttf|woff2|woff)', staticAssetsSource)
app.put('/account', (req, res) => {
  res.status(200).send(req.body)
})
app.get('/user/:username/feed', (req, res, next) => {
  const { username } = req.params
  const feed = [...picshareDB.feed, ...picshareDB.wsFeed]
  const userFeed = feed.filter(photo => photo.username === username)

  res.send(userFeed)
})
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
  .concatMap(photo => Observable.of(photo).delay(randomDelay(1000, 5000)))

wss.on('connection', ws => {
  const subscription = feed$.subscribe(photo => ws.send(photo))

  ws.on('error', () => {})
  ws.on('close', () => subscription.unsubscribe())
})
