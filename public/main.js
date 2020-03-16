window.addEventListener('load', () => {
  const app = Elm.Main.Client.init()

  // Highlight blocks
  document.querySelectorAll('pre code').forEach(hljs.highlightBlock)

  // Ports
  app.ports.afterNavigate.subscribe(meta =>
    setTimeout(_ => {
      // Set meta
      const { protocol, host, pathname } = window.location
      const updateMeta = (selectors, value) =>
        selectors.forEach(s => {
          document.querySelector(`meta[${s}]`).content = value
        })

      updateMeta([
        'property="og:url"'
      ], `${protocol}//${host}${pathname}`)

      updateMeta([
        'name="twitter:title"',
        'property="og:title"'
      ], meta.title)

      updateMeta([
        'name="description"',
        'name="twitter:description"',
        'property="og:description"'
      ], meta.description)

      updateMeta([
        'name="twitter:image"',
        'property="og:image"'
      ], meta.image)

      // Highlight code blocks
      document.querySelectorAll('pre code').forEach(hljs.highlightBlock)

      // Scroll to top
      window.scrollTo({ top: 0, left: 0, behavior: 'smooth' })
    }, 100)
  )
})
