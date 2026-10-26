// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket, LongPoll } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import confetti from "canvas-confetti"

let Hooks = {};

Hooks.LocalTime = {
  mounted() { this.render() },
  updated() { this.render() },
  render() {
    const dt = new Date(this.el.dataset.utc)
    this.el.textContent = dt.toLocaleTimeString([], {
      hour: "numeric",
      minute: "2-digit"
    })
  }
}


Hooks.DisplayConfetti = {
  mounted() {
    var duration = 15 * 1000;
    var animationEnd = Date.now() + duration;
    var defaults = { startVelocity: 30, spread: 360, ticks: 60, zIndex: 0 };

    function randomInRange(min, max) {
      return Math.random() * (max - min) + min;
    }

    var interval = setInterval(function() {
      var timeLeft = animationEnd - Date.now();

      if (timeLeft <= 0) {
        return clearInterval(interval);
      }

      var particleCount = 50 * (timeLeft / duration);
      // since particles fall down, start a bit higher than random
      confetti({ ...defaults, particleCount, origin: { x: randomInRange(0.1, 0.3), y: Math.random() - 0.2 } });
      confetti({ ...defaults, particleCount, origin: { x: randomInRange(0.7, 0.9), y: Math.random() - 0.2 } });
    }, 250);
    window.scrollTo(0, document.body.scrollHeight);
  }
}
Hooks.ModalCheckboxHandlers = {
  mounted() {
    var checkbox = this.el;
    this.handleEvent(
      "js:modal:#" + checkbox.id,
      function onModal(payload) {
        checkbox.checked = payload.open;
      },
    );
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

const useLongPoll = window.sessionStorage.getItem("phx_longpoll") === "true"

let liveSocket = new LiveSocket("/live", Socket, {
  transport: useLongPoll ? LongPoll : WebSocket,
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
})

if (!useLongPoll) {
  let wsConnected = false
  liveSocket.getSocket().onOpen(() => { wsConnected = true })

  setTimeout(() => {
    if (!wsConnected) {
      console.warn("WebSocket failed to connect in 2500ms, falling back to LongPoll...")
      window.sessionStorage.setItem("phx_longpoll", "true")
      liveSocket.disconnect()
      liveSocket.getSocket().transport = LongPoll
      liveSocket.connect()
    }
  }, 2500)
}

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

