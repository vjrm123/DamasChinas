import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")


let Hooks = {}

Hooks.JugadorSession = {
  mounted() {
    this.handleEvent("set_jugador", ({token, codigo}) => {
      sessionStorage.setItem(`damas_jugador_${codigo}`, token)
    })
    this.restaurarJugador()
  },
  reconnected() {
    this.restaurarJugador()
  },
  restaurarJugador() {
    const codigo = this.el.dataset.codigo
    const token = codigo && sessionStorage.getItem(`damas_jugador_${codigo}`)
    if (token) this.pushEvent("restore_jugador", {token})
  }
}


Hooks.EscalarLienzo = {
  mounted() {
    this.ajustar = () => {
      const w = this.el.offsetWidth
      const h = this.el.offsetHeight
      if (!w || !h) return
      const vw = window.innerWidth
      const vh = window.innerHeight
      const s = Math.min(vw / w, vh / h)
      document.documentElement.style.setProperty("--inicio-s", s.toFixed(4))
    }
    this.onResize = () => requestAnimationFrame(this.ajustar)
    window.addEventListener("resize", this.onResize)
    this.ajustar()
  },
  updated() { this.ajustar() },
  destroyed() {
    window.removeEventListener("resize", this.onResize)
    document.documentElement.style.removeProperty("--inicio-s")
  }
}

// Conexin con Phoenix LiveView
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})

// Al navegar a otra pagina reproducir la animacin de salida
window.addEventListener("phx:page-loading-start", info => {
  topbar.show(300)
  if (info.detail?.kind === "redirect") {
    document.querySelectorAll(".page-emerge").forEach(el => {
      el.style.animation = "page-retreat 0.35s cubic-bezier(0.64,0,0.78,0) forwards"
    })
  }
})
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// en el mismo momento del clic, antes de que LiveView responda con el nuevo contenido
document.addEventListener("click", e => {
  const btn = e.target.closest("#inicio-modo-crear, #inicio-modo-unirse, #inicio-volver")
  if (btn) {
    document.querySelectorAll(".page-emerge").forEach(el => {
      el.style.animation = "page-retreat 0.28s cubic-bezier(0.64,0,0.78,0) forwards"
    })
  }
})

liveSocket.connect()
window.liveSocket = liveSocket
