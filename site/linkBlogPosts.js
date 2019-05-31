const fs = require('fs')
const util = require('util')
const cheerio = require('cheerio')
const R = require('ramda')
const paths = require('./paths')

const glob = util.promisify(require('glob'))
const readFile = util.promisify(fs.readFile)
const writeFile = util.promisify(fs.writeFile)

const BLOG_PAGE_REGEX = /\/(blog\/.*?)\/index\.html$/
const DATE_REGEX = /\d{4}-\d{2}-\d{2}/

const postLinkToHtml = (type, link) =>
  link
    ? `<a class="post-nav__${type}-post" href="${link.url}">${link.text}</a>`
    : ''

const parsePostLink = file => `/${file.match(BLOG_PAGE_REGEX)[1]}`

const isBlogPost = file => file.match(DATE_REGEX)
const blogPostDate = file => Date.parse(file.match(DATE_REGEX)[0])

const fileToPost = file => ({
  file,
  link: parsePostLink(file),
  previousLink: null,
  nextLink: null,
})

function createBlogPostLinks(
  [olderPost, newerPost, ...otherPosts],
  accum = [],
) {
  if (!olderPost && !newerPost) {
    return accum
  }

  if (!newerPost) {
    return [olderPost, ...accum]
  }

  const updatedNewerPost = {
    ...newerPost,
    previousLink: {
      url: olderPost.link,
      text: 'Previous Post',
    },
  }

  const updatedOlderPost = {
    ...olderPost,
    nextLink: {
      url: newerPost.link,
      text: 'Next Post',
    },
  }

  return createBlogPostLinks(
    [updatedNewerPost, ...otherPosts],
    [updatedOlderPost, ...accum],
  )
}

const saveBlogPostLinks = posts =>
  Promise.all(
    posts.map(post =>
      readFile(post.file, 'utf8').then(contents => {
        const $ = cheerio.load(contents)

        const postNav = `
          <div class="post-nav">
            ${postLinkToHtml('previous', post.previousLink)}
            ${postLinkToHtml('next', post.nextLink)}
          </div>
        `.trim()

        const newContents = $('.markdown + .share')
          .after(postNav)
          .prevObject.html()

        return writeFile(post.file, newContents)
      }),
    ),
  )

module.exports = async function linkBlogPosts() {
  return glob(`${paths.build}/blog/**/*.html`).then(
    R.pipe(
      R.filter(isBlogPost),
      R.sortBy(blogPostDate),
      R.map(fileToPost),
      createBlogPostLinks,
      saveBlogPostLinks,
    ),
  )
}
