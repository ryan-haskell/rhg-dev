const frontMatter = require('front-matter')
const fs = require('fs')
const path = require('path')

const template = fs.readFileSync(path.join(__dirname, 'templates', 'Post.elm'), { encoding: 'utf8' })
const filenames = fs.readdirSync(path.join(__dirname, '..', 'content', 'posts'))

const start = _ => {
  fs.mkdirSync(path.join(__dirname, '..', 'src', 'Content'), { recursive: true })

  filenames.forEach(filename => {
    const file = fs.readFileSync(path.join(__dirname, '..', 'content', 'posts', filename), { encoding: 'utf8' })
    const moduleName = toModuleName(filename.split('.md').join(''))
    const { attributes: meta, body: content } =
      frontMatter(file)

    const result = {
      filepath: path.join(__dirname, '..', 'src', 'Content', moduleName + '.elm'),
      content: template
        .split('{{moduleName}}').join(`Content.${moduleName}`)
        .split('{{meta.title}}').join(meta.title || `${filename} is missing title`)
        .split('{{meta.description}}').join(meta.description || `${filename} is missing description`)
        .split('{{meta.image}}').join(meta.image || `${filename} is missing image`)
        .split('{{content}}').join(JSON.stringify(content))
    }

    fs.writeFileSync(result.filepath, result.content, { encoding: 'utf8' })
  })
}

const capitalize = word =>
  word && word[0].toUpperCase() + word.slice(1)

const toModuleName = filename =>
  filename.split('-').map(capitalize).join('')

start()