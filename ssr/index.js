const path = require('path')
const fs = require('fs')
const { Elm } = require('../dist/elm.ssr.js')
const config = require('./config.js')

const start = () =>
  config.routes.forEach(route => {
    const app = Elm.Main.Ssr.init({
      flags: { config, path: route }
    })
    
    app.ports.render.subscribe(data => {
      const template = fs.readFileSync(
        path.join(__dirname, 'templates', 'index.html'),
        { encoding: 'utf8' }
      )
    
      const html =
        template
          .split(`{{config.baseUrl}}`).join(config.baseUrl)
          .split(`{{meta.title}}`).join(data.meta.title)
          .split(`{{meta.description}}`).join(data.meta.description)
          .split(`{{meta.image}}`).join(data.meta.image)
          .split(`{{path}}`).join(data.path)
          .split(`{{content}}`).join(data.content)

      fs.mkdirSync(path.join(__dirname, '..', 'dist', route), { recursive: true })
    
      return fs.writeFileSync(
        path.join(__dirname, '..', 'dist', route, 'index.html'),
        html,
        { encoding: 'utf8' }
      )
    })
  })

start()