import coverUrl from './jfelm.jpg'
import { Main } from './Main.elm'
import registerServiceWorker from './registerServiceWorker'

Main.embed(document.getElementById('root'), {
  coverUrl,
  width: window.innerWidth,
  height: window.innerHeight,
})

registerServiceWorker()
