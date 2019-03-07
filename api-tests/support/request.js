const superagent = require('superagent')
const WebSocket = require('ws')

const PORT = 8001
const HOST = 'localhost'
const BASE_URL = `http://${HOST}:${PORT}`
const BASE_WS_URL = `ws://${HOST}:${PORT}`

exports.get = url => superagent.get(`${BASE_URL}${url}`)
exports.post = url => superagent.post(`${BASE_URL}${url}`)
exports.put = url => superagent.put(`${BASE_URL}${url}`)

exports.webSocket = (url, { buffer: bufferAmount }) =>
  new Promise(resolve => {
    const ws = new WebSocket(`${BASE_WS_URL}${url}`)
    const buffer = []

    ws.on('message', data => {
      buffer.push(JSON.parse(data))

      if (buffer.length === bufferAmount) {
        ws.close()
        resolve(buffer)
      }
    })
  })
