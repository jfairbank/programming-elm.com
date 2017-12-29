import { Main } from './Main.elm'
import registerServiceWorker from './registerServiceWorker'

Main.embed(document.getElementById('root'), {
  width: window.innerWidth,
  height: window.innerHeight,
})

registerServiceWorker()
