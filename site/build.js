const childProcess = require('child_process')
const crypto = require('crypto')
const fs = require('fs')
const path = require('path')
const util = require('util')
const _ = require('lodash')
const replace = require('replace-in-file')

const glob = util.promisify(require('glob'))
const exec = util.promisify(childProcess.exec)
const readFile = util.promisify(fs.readFile)
const renameFile = util.promisify(fs.rename)

const sitePath = __dirname
const buildPath = path.join(sitePath, '_site')

const build = () =>
  exec(`cd ${sitePath} && elmstatic && cp ../favicon.ico _site`)

async function fingerprintAssets() {
  const files = await glob(`${buildPath}/**/*.{css,js}`).then(files =>
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
      files: `${buildPath}/**/*.html`,
      from: new RegExp(`(href|src)="(.*?)${from}"`, 'mg'),
      to: (_, attr, prefix) => `${attr}="${prefix}${to}"`,
    })
  }
}

async function main() {
  await build()
  await fingerprintAssets()
}

main()
