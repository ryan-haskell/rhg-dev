const fs = require('fs')
const path = require('path')

const filenames = fs.readdirSync(path.join(__dirname, '..', 'content', 'posts'))

module.exports = {
  baseUrl: 'https://rhg.dev',
  routes: [
    '/',
    '/posts',
    ...filenames.map(n => `/posts/${n.split('.md').join('')}`),
    '/not-found'
  ]
}