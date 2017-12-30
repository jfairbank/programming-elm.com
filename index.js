const express = require('express')
const cors = require('cors')
const jsonServer = require('json-server')
const db = require('./db.json')

// Constants
// =========

const PORT = process.env.PORT || 5000
const isProduction = process.env.NODE_ENV === 'production'

// Helpers
// =======

const render = data => (req, res) => res.send(data)

// API
// ===

const app = express()

app.use(cors())
app.use(express.static('build'))
app.use(jsonServer.router('db.json'))

app.listen(PORT, () => {
  if (!isProduction) {
    console.log(`Server listening at http://localhost:${PORT}`)
  }
})
