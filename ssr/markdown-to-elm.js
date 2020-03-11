const frontMatter = require('front-matter')
const fs = require('fs')
const path = require('path')

const templates = {
  content: fs.readFileSync(path.join(__dirname, 'templates', 'Content.elm'), { encoding: 'utf8' }),
  post: fs.readFileSync(path.join(__dirname, 'templates', 'Post.elm'), { encoding: 'utf8' })
}
const filenames = fs.readdirSync(path.join(__dirname, '..', 'content', 'posts'))

const files = {}
filenames.forEach(filename => {
  const rawMarkdown = fs.readFileSync(path.join(__dirname, '..', 'content', 'posts', filename), { encoding: 'utf8' })
  const { attributes: meta, body: content } = frontMatter(rawMarkdown)
  files[filename] = { meta, content }
})

const start = _ => {
  fs.mkdirSync(path.join(__dirname, '..', 'src', 'Content'), { recursive: true })

  // Generate Content.elm
  const content = {
    filepath: path.join(__dirname, '..', 'src', 'Content.elm'),
    content: templates.content
      .split('{{imports}}').join(contentImports(filenames))
      .split('{{conditions}}').join(contentConditions(filenames))
      .split('{{posts}}').join(contentPosts(files))
  }

  fs.writeFileSync(content.filepath, content.content, { encoding: 'utf8' })

  // Generate src/Content/*.elm
  filenames.forEach(filename => {
    const moduleName = toModuleName(filename)
    const { meta, content } = files[filename]

    const result = {
      filepath: path.join(__dirname, '..', 'src', 'Content', moduleName + '.elm'),
      content: templates.post
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
  filename
    .split('.md').join('')
    .split('-').map(capitalize).join('')

const contentImports = (names) =>
  names.map(contentImport).join('\n')

const contentImport = (name) =>
  `import Content.${toModuleName(name)}`
  
const contentConditions = (names) =>
  names.map(condition).join('\n')

const condition = (filename) => 
`        "${filename.split('.md').join('')}" ->
            Just Content.${toModuleName(filename)}.view
`

const contentPosts = files =>
  files.length == 0
    ? '    []'
    : '    [ ' + Object.entries(files).map(contentPost).join('\n    , ') + '\n    ]'

const contentPost = ([ filename, { meta } ]) =>
  `{ slug = "${filename}", title = "${meta.title}" }`

start()