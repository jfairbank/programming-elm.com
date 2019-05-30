;(function() {
  function forEach(arrayLike, fn) {
    Array.prototype.forEach.call(arrayLike, fn)
  }

  function socialLinkClick(name, constructURL) {
    var selector = '.share-' + name + '-js'

    forEach(document.querySelectorAll(selector), function(el) {
      el.addEventListener('click', function(e) {
        e.preventDefault()

        var windowName = 'programming-elm-' + name + '-share'
        var windowOptions =
          'width=600,height=400menubar=0,location=0,toolbar=0,status=0,scrollbars=1'

        var url = constructURL(
          encodeURI(window.location.href),
          encodeURIComponent(document.title),
        )

        window.open(url, windowName, windowOptions)
      })
    })
  }

  socialLinkClick('facebook', function(encodedURI) {
    return (
      'https://www.facebook.com/dialog/share?app_id=140586622674265&display=popup&href=' +
      encodedURI
    )
  })

  socialLinkClick('twitter', function(encodedURI, encodedTitle) {
    return (
      'https://twitter.com/intent/tweet?original_referer=' +
      encodedURI +
      '&ref_src=twsrc%5Etfw&text=' +
      encodedTitle +
      '&tw_p=tweetbutton&url=' +
      encodedURI +
      '&via=programming_elm'
    )
  })
})()
