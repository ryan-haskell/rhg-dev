const frontMatter = require('front-matter')
const fs = require('fs')
const path = require('path')

const templates = {
  content: fs.readFileSync(path.join(__dirname, 'templates', 'Content.elm'), { encoding: 'utf8' }),
  posts: fs.readFileSync(path.join(__dirname, 'templates', 'Posts.elm'), { encoding: 'utf8' }),
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
  fs.mkdirSync(path.join(__dirname, '..', 'src', 'Generated', 'Content'), { recursive: true })

  // Generate src/Generated/Posts.elm
  const posts = {
    filepath: path.join(__dirname, '..', 'src', 'Generated', 'Posts.elm'),
    content: templates.posts
      .split('{{posts}}').join(contentPosts(files))
  }

  fs.writeFileSync(posts.filepath, posts.content, { encoding: 'utf8' })

  // Generate src/Generated/Content.elm
  const content = {
    filepath: path.join(__dirname, '..', 'src', 'Generated', 'Content.elm'),
    content: templates.content
      .split('{{imports}}').join(contentImports(filenames))
      .split('{{conditions}}').join(contentConditions(filenames))
  }

  fs.writeFileSync(content.filepath, content.content, { encoding: 'utf8' })

  // Generate src/Generated/Content/*.elm
  filenames.forEach(filename => {
    const moduleName = toModuleName(filename)
    const { meta, content } = files[filename]

    const result = {
      filepath: path.join(__dirname, '..', 'src', 'Generated', 'Content', moduleName + '.elm'),
      content: templates.post
        .split('{{moduleName}}').join(`Content.${moduleName}`)
        .split('{{slug}}').join(filename.split('.md').join(''))
        .split('{{meta.title}}').join(meta.title || `${filename} is missing title`)
        .split('{{meta.date}}').join(meta.date || `${filename} is missing date`)
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
  `import Generated.Content.${toModuleName(name)}`
  
const contentConditions = (names) =>
  names.map(condition).join('\n')

const condition = (filename) => 
`        "${filename.split('.md').join('')}" ->
            Just Generated.Content.${toModuleName(filename)}.view
`

const contentPosts = files =>
  files.length == 0
    ? '    []'
    : '    [ ' + Object.entries(files).map(contentPost).join('\n    , ') + '\n    ]'

const contentPost = ([ filename, { meta } ]) =>
  `{ slug = "${filename.split('.md').join('')}", title = "${meta.title}", date = ${meta.date} }`

start()