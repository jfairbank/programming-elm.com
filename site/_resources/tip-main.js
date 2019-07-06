;(function() {
  var container = document.getElementById('post-tip-images')

  var images = [].map.call(container.querySelectorAll('img'), function(el) {
    return el.src
  })

  var app = Elm.Tip.init({
    node: container,
    flags: { images: images },
  })

  app.ports.showModal.subscribe(function() {
    document.body.classList.add('modal-open')
  })

  app.ports.hideModal.subscribe(function() {
    document.body.classList.remove('modal-open')
  })
})()
