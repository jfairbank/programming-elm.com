const assert = require('assert')
const WebSocket = require('ws')
const picshare = require('../picshare.json')
const request = require('./support/request')

module.exports = {
  beforeEach() {
    this.requestBody = { life: 42, hello: 'world' }
  },

  assets: {
    async 'GET /1.jpg serves an image'() {
      const result = await request.get('/1.jpg')

      assert.equal(result.status, 200)
      assert.equal(result.type, 'image/jpeg')
    },

    async 'GET /font-awesome-4.7.0/css/font-awesome.min.css serves css'() {
      const result = await request.get(
        '/font-awesome-4.7.0/css/font-awesome.min.css',
      )

      assert.equal(result.status, 200)
      assert.equal(result.type, 'text/css')
    },
  },

  salad: {
    async 'POST /salad/send successfully sends back body'() {
      const result = await request.post('/salad/send').send(this.requestBody)

      assert.equal(result.status, 201)
      assert.deepEqual(result.body, this.requestBody)
    },

    async 'POST /salad/send fails with fail query param'() {
      try {
        await request
          .post('/salad/send')
          .query('fail=true')
          .send({})
      } catch (result) {
        assert.equal(result.status, 500)
      }
    },
  },

  animals: {
    async 'GET /animals returns successful response'() {
      const result = await request.get('/animals')

      assert.equal(result.status, 200)
      assert.equal(result.body.length, 300)
      assert.ok(result.body.every(animal => animal.id))
    },

    async 'GET /animals/large returns successful response'() {
      const result = await request.get('/animals/large')

      assert.equal(result.status, 200)
      assert.equal(result.body.length, 4000)
      assert.ok(result.body.every(animal => animal.id))
    },
  },

  picshare: {
    async 'GET /account returns successful response'() {
      const result = await request.get('/account')

      assert.equal(result.status, 200)
      assert.deepEqual(result.body, picshare.account)
    },

    async 'PUT /account successfully sends back body'() {
      const result = await request.put('/account').send(this.requestBody)

      assert.equal(result.status, 200)
      assert.deepEqual(result.body, this.requestBody)
    },

    async 'GET /user/:username/feed returns correct photos for user'() {
      const username = 'elpapapollo'

      const result = await request.get(`/user/${username}/feed`)

      assert.equal(result.status, 200)
      assert.equal(result.body.length, 3)
      assert.deepEqual(
        result.body,
        [...picshare.feed, ...picshare.wsFeed].filter(
          photo => photo.username === username,
        ),
      )
    },

    async 'GET /feed returns successful response'() {
      const result = await request.get('/feed')

      assert.equal(result.status, 200)
      assert.equal(result.body.length, 3)
      assert.deepEqual(result.body, picshare.feed)
    },

    async 'GET /badfeed returns photo with incorrect key value pairs'() {
      const result = await request.get('/badfeed')

      assert.equal(result.status, 200)
      assert.equal(result.body.length, 1)
      assert.deepEqual(result.body, picshare.badfeed)
    },

    async 'receives 3 photos from WebSocket feed'() {
      const result = await request.webSocket('/', { buffer: 3 })

      assert.equal(result.length, 3)
      assert.ok(result.every(photo => photo.id))
    },
  },
}
