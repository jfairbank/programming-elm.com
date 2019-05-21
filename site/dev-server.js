const childExec = require('child_process')
const http = require('http')
const path = require('path')
const util = require('util')
const chokidar = require('chokidar')
const LiveReload = require('livereload')
const nodemon = require('nodemon')
const serve = require('serve-handler')

const log = (tag, thing) => console.log(tag, thing) || thing

const exec = util.promisify(childExec.exec)

const sitePath = __dirname
const buildPath = path.join(sitePath, '_site')

function debounce(fn, time) {
  let t = null

  return (...args) => {
    if (t) {
      clearTimeout(t)
    }

    t = setTimeout(fn, time, ...args)
  }
}

const build = () =>
  exec(`cd ${sitePath} && elmstatic draft && cp ../favicon.ico _site`).then(
    ({ stdout }) => console.log(stdout),
  )

function runDevServer() {
  const port = 5000
  const server = http.createServer((req, res) =>
    serve(req, res, { public: buildPath }),
  )

  server.listen(port, () => {
    console.log(`Dev server running at http://localhost:${port}`)
  })
}

function watch() {
  // nodemon({
  //   exec: 'cd site && npx elmstatic',
  //   ext: 'css elm jpg json png',
  //   runOnChangeOnly: true,
  //   watch: ['site/_layouts', 'site/_resources', 'site/config.json'],
  // })
  //   .on('stdout', stdout => console.log(stdout))
  //   .on('restart', debounce(() => livereload, 250))

  chokidar
    .watch(
      [
        path.join(sitePath, '_layouts/**/*.elm'),
        path.join(sitePath, '_pages/**/*.md'),
        path.join(sitePath, '_posts/**/*.md'),
        path.join(sitePath, '_resources/**/*.{css,png,jpg,js}'),
        path.join(sitePath, 'config.json'),
      ],
      {
        ignoreInitial: true,
      },
    )
    .on('change', debounce(() => build(), 250))
}

function liveReload() {
  const liveReloadServer = LiveReload.createServer()

  chokidar
    .watch(path.join(buildPath, '**/*.{css,html}'), { ignoreInitial: true })
    .on('add', filepath => liveReloadServer.refresh(filepath))
}

async function main() {
  await build()

  runDevServer()
  watch()
  liveReload()
}

main()
