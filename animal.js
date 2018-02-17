const dogNames = require('dog-names')
const catNames = require('cat-names')
const uniqueRandomArray = require('unique-random-array')
const cuid = require('cuid')
const { flatMap } = require('lodash')
const dogBreeds = require('./dog-breeds.json')
const catBreeds = require('./cat-breeds.json')

const randomDogBreed = uniqueRandomArray(dogBreeds)
const randomCatBreed = uniqueRandomArray(catBreeds)
const randomSex = uniqueRandomArray(['Male', 'Female'])

const randomAnimal = (type, generateName, generateBreed) => () => ({
  type,
  id: cuid(),
  name: generateName(),
  breed: generateBreed(),
  sex: randomSex(),
})

const randomAnimalGenerator = uniqueRandomArray([
  randomAnimal('dog', dogNames.allRandom, randomDogBreed),
  randomAnimal('cat', catNames.random, randomCatBreed),
])

const random = () =>
  randomAnimalGenerator()()

const randomList = length =>
  Array.from({ length }, random)

const allUnique = () =>
  flatMap([
    ['dog', dogNames.all, randomDogBreed],
    ['cat', catNames.all, randomCatBreed],
  ], ([type, names, randomBreed]) =>
    names.map(name => randomAnimal(type, () => name, randomBreed)()))

exports.random = random
exports.randomList = randomList
exports.allUnique = allUnique
