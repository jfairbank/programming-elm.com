const express = require('express')
const cors = require('cors')
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

app.get('/badfeed', render(db.badfeed))
app.get('/feed', render(db.feed))

app.listen(PORT, () => {
  if (!isProduction) {
    console.log(`Server listening at http://localhost:${PORT}`)
  }
})
