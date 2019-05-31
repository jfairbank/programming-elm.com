const childProcess = require('child_process')
const crypto = require('crypto')
const fs = require('fs')
const path = require('path')
const util = require('util')
const cheerio = require('cheerio')
const replace = require('replace-in-file')
const linkBlogPosts = require('./linkBlogPosts')
const paths = require('./paths')

const glob = util.promisify(require('glob'))
const rimraf = util.promisify(require('rimraf'))
const exec = util.promisify(childProcess.exec)
const readFile = util.promisify(fs.readFile)
const writeFile = util.promisify(fs.writeFile)
const renameFile = util.promisify(fs.rename)

const build = () =>
  exec(`cd ${paths.site} && elmstatic && cp ../favicon.ico _site`)

async function fingerprintAssets() {
  const files = await glob(`${paths.build}/**/*.{css,js}`).then(files =>
    Promise.all(
      files.map(async file => {
        const contents = await readFile(file)
        const hash = crypto
          .createHash('md5')
          .update(contents)
          .digest('hex')

        const { base, dir, ext, name } = path.parse(file)

        return {
          dir,
          from: `${name}${ext}`,
          to: `${name}-${hash}${ext}`,
        }
      }),
    ),
  )

  await Promise.all(
    files.map(({ dir, from, to }) =>
      renameFile(path.join(dir, from), path.join(dir, to)),
    ),
  )

  for (const { from, to } of files) {
    await replace({
      files: `${paths.build}/**/*.html`,
      from: new RegExp(`(href|src)="(.*?)${from}"`, 'mg'),
      to: (_, attr, prefix) => `${attr}="${prefix}${to}"`,
    })
  }
}

async function removeBlogIndexFromFeed() {
  const file = path.join(paths.build, 'rss.xml')
  const contents = await readFile(file, 'utf8')

  const $ = cheerio.load(contents, {
    xmlMode: true,
  })

  $('item')
    .last()
    .remove()

  await writeFile(file, $.xml())
}

const removePostsDir = () => rimraf(path.join(paths.build, 'posts'))

async function main() {
  await build()
  await fingerprintAssets()
  await Promise.all([
    linkBlogPosts(),
    removeBlogIndexFromFeed(),
    removePostsDir(),
  ])
}

main()
