const util = require('util')
const fs = require('fs')
const path = require('path')
const sh = require('shelljs')
const elmStaticHtml = require('elm-static-html-lib').default
const cheerio = require('cheerio')
const { minify } = require('html-minifier')
const manifest = require('../build/webpack-assets.json')

const writeFile = util.promisify(fs.writeFile)

const rootPath = path.resolve(__dirname, '../')

const model = {
  coverUrl: manifest['static/media/jfelm.jpg'],
  width: 1920,
  height: 960,
}
const decoder = 'Main.decodeModel'
const viewFunction = 'Main.view'
const options = { model, decoder }

const elmStaticHtmlDir = path.resolve(rootPath, '.elm-static-html')
const elmPackage = path.resolve(rootPath, 'elm-package.json')
const buildDir = path.resolve(rootPath, 'build')
const outFile = path.join(buildDir, 'index.html')

function addLinkAndScript($) {
  const $body = $('body')
  const $children = $body.children()
  const $root = $('<div id="root"></div>')
  const mainJs = manifest['main.js']

  $('head')
    .append(`
      <meta charset="utf-8">
      <meta http-equiv="x-ua-compatible" content="ie=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
      <title>Programming Elm</title>
      <link rel="stylesheet" href="https://use.fontawesome.com/102743fa7d.css">
      <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:400,700,700i" rel="stylesheet">
    `)

  $root.append($children)

  $body
    .html($root)
    .append(`<script src="${mainJs}"></script>`)

  return $
}

function writeOutFile(html) {
  return writeFile(outFile, html)
}

elmStaticHtml(rootPath, viewFunction, options)
  .then(cheerio.load)
  .then(addLinkAndScript)
  .then($ => $.html())
  .then(html => minify(html, { collapseWhitespace: true }))
  .then(writeOutFile)
