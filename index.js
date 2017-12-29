const express = require('express')

const PORT = process.env.PORT || 5000

const app = express()

app.use(express.static('build'))

app.listen(PORT, () => {
  console.log(`Server ready on port ${PORT}`)
})
