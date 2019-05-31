const childExec = require('child_process')
const http = require('http')
const path = require('path')
const util = require('util')
const LiveReload = require('livereload')
const { debounce } = require('lodash')
const chokidar = require('chokidar')
const serve = require('serve-handler')
const linkBlogPosts = require('./linkBlogPosts')
const paths = require('./paths')

const exec = util.promisify(childExec.exec)

const elmstatic = () =>
  exec(`cd ${paths.site} && elmstatic draft && cp ../favicon.ico _site`).then(
    ({ stdout }) => console.log(stdout),
  )

async function build() {
  await elmstatic()
  await linkBlogPosts()
}

function runDevServer() {
  const port = 5000
  const server = http.createServer((req, res) =>
    serve(req, res, { public: paths.build }),
  )

  server.listen(port, () => {
    console.log(`Dev server running at http://localhost:${port}`)
  })
}

function watch() {
  chokidar
    .watch(
      [
        path.join(paths.site, '_layouts/**/*.elm'),
        path.join(paths.site, '_pages/**/*.md'),
        path.join(paths.site, '_posts/**/*.md'),
        path.join(paths.site, '_resources/**/*.{css,png,jpg,js}'),
        path.join(paths.site, 'config.json'),
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
    .watch(path.join(paths.build, '**/*.{css,html}'), { ignoreInitial: true })
    .on('add', async filepath => liveReloadServer.refresh(filepath))
}

async function main() {
  await build()

  runDevServer()
  watch()
  liveReload()
}

main()
