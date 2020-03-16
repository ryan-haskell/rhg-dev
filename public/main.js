window.addEventListener('load', () => {
  const app = Elm.Main.Client.init()
  window.hljs.initHighlighting()
  // Ports
  app.ports.afterNavigate.subscribe(_ =>
    setTimeout(meta => {
      // Set meta
      const { protocol, host, pathname } = window.location
      const updateMeta = (selectors, value) =>
        selectors.map(s => document.querySelector(s).setAttribute('content', value))

      updateMeta([
        'meta[property="og:url"]'
      ], `${protocol}//${host}${pathname}`)

      updateMeta([
        'meta[name="twitter:title"]',
        'meta[property="og:title"]'
      ], meta.title)

      updateMeta([
        'meta[name="description"]',
        'meta[name="twitter:description"]',
        'meta[property="og:description"]'
      ], meta.description)

      updateMeta([
        'meta[name="image"]',
        'meta[name="twitter:image"]',
        'meta[property="og:image"]'
      ], meta.image)

      // Highlight code blocks
      hljs.initHighlighting.called = false; window.hljs.initHighlighting()

      // Scroll to top
      window.scrollTo({ top: 0, left: 0, behavior: 'smooth' })
    }, 100)
  )
})
