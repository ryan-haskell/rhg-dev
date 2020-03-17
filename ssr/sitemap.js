const path = require('path')
const fs = require('fs')

const config = require('./config')

const sitemap = ({ baseUrl, routes }) =>
`<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  ${routes.map(path => `<url><loc>${baseUrl + path}</loc></url>`).join('\n  ')}
</urlset>`

const start = _ =>
  fs.writeFileSync(
    path.join(__dirname, '..', 'public', 'sitemap.xml'),
    sitemap(config),
    { encoding: 'utf8' }
  )

start()
