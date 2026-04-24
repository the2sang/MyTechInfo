import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iosGuide", "androidGuide", "desktopGuide", "installBtn", "banner", "footerBtn", "iosModal"]

  connect() {
    this.deferredPrompt = null
    this.isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream
    this.isStandalone = window.matchMedia("(display-mode: standalone)").matches || navigator.standalone === true

    if (this.isStandalone) {
      if (this.hasBannerTarget) this.bannerTarget.hidden = true
      if (this.hasFooterBtnTarget) this.footerBtnTarget.hidden = true
      return
    }

    this._showLoginBanner()
    this._listenInstallPrompt()
  }

  _showLoginBanner() {
    if (!this.hasBannerTarget) return
    const ua = navigator.userAgent
    const isAndroid = /Android/.test(ua)

    if (this.isIOS) {
      if (this.hasIosGuideTarget) this.iosGuideTarget.hidden = false
    } else if (isAndroid) {
      if (this.hasAndroidGuideTarget) this.androidGuideTarget.hidden = false
    } else {
      if (this.hasDesktopGuideTarget) this.desktopGuideTarget.hidden = false
    }
  }

  _listenInstallPrompt() {
    window.addEventListener("beforeinstallprompt", (e) => {
      e.preventDefault()
      this.deferredPrompt = e
      if (this.hasInstallBtnTarget) this.installBtnTarget.hidden = false
    })

    window.addEventListener("appinstalled", () => {
      if (this.hasBannerTarget) this.bannerTarget.hidden = true
      if (this.hasFooterBtnTarget) this.footerBtnTarget.hidden = true
      this.deferredPrompt = null
    })
  }

  // 로그인 페이지 배너 dismiss
  dismiss() {
    if (this.hasBannerTarget) this.bannerTarget.hidden = true
  }

  // footer 버튼 또는 배너 설치 버튼 클릭
  async install() {
    if (this.isIOS) {
      this.showIosModal()
      return
    }
    if (!this.deferredPrompt) return
    this.deferredPrompt.prompt()
    const { outcome } = await this.deferredPrompt.userChoice
    if (outcome === "accepted") {
      if (this.hasBannerTarget) this.bannerTarget.hidden = true
      if (this.hasFooterBtnTarget) this.footerBtnTarget.hidden = true
    }
    this.deferredPrompt = null
  }

  showIosModal() {
    if (this.hasIosModalTarget) this.iosModalTarget.hidden = false
  }

  hideIosModal() {
    if (this.hasIosModalTarget) this.iosModalTarget.hidden = true
  }
}
