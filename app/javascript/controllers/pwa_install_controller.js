import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iosGuide", "androidGuide", "desktopGuide", "installBtn", "banner"]

  connect() {
    this.deferredPrompt = null
    this._detect()
    this._listenInstallPrompt()
  }

  _detect() {
    const ua = navigator.userAgent
    const isIOS = /iPad|iPhone|iPod/.test(ua) && !window.MSStream
    const isAndroid = /Android/.test(ua)
    const isStandalone = window.matchMedia("(display-mode: standalone)").matches
      || navigator.standalone === true

    if (isStandalone) {
      this.bannerTarget.hidden = true
      return
    }

    if (isIOS) {
      this.iosGuideTarget.hidden = false
    } else if (isAndroid) {
      this.androidGuideTarget.hidden = false
    } else {
      this.desktopGuideTarget.hidden = false
    }
  }

  _listenInstallPrompt() {
    window.addEventListener("beforeinstallprompt", (e) => {
      e.preventDefault()
      this.deferredPrompt = e
      if (this.hasInstallBtnTarget) {
        this.installBtnTarget.hidden = false
      }
    })

    window.addEventListener("appinstalled", () => {
      this.bannerTarget.hidden = true
      this.deferredPrompt = null
    })
  }

  async install() {
    if (!this.deferredPrompt) return
    this.deferredPrompt.prompt()
    const { outcome } = await this.deferredPrompt.userChoice
    if (outcome === "accepted") {
      this.bannerTarget.hidden = true
    }
    this.deferredPrompt = null
  }

  dismiss() {
    this.bannerTarget.hidden = true
  }
}
