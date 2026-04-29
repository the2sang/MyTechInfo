import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startBtn", "modeLabel", "sessionCount", "roundDot", "turtle", "turtleFill", "clockProgress"]
  static values  = {
    focusMinutes:     Number,
    breakMinutes:     Number,
    longBreakMinutes: Number,
    rounds:           Number,
    autoStart:        Boolean
  }

  connect() {
    this.mode      = "focus"
    this.sessions  = 0
    this._reset()
  }

  disconnect() { this._clearTick(); this._setNavVisible(true) }

  toggle()    { this.running ? this._pause() : this._start() }
  reset()     { this._clearTick(); this._reset() }
  skipMode()  { this._clearTick(); this._switchMode(); this._reset() }

  // ── private ──────────────────────────────────────────────

  _start() {
    this.running = true
    this.startBtnTarget.textContent = "일시정지"
    this.startBtnTarget.classList.replace("btn--primary", "btn--secondary")
    if (this.hasTurtleTarget) this.turtleTarget.classList.add("turtle-track__turtle--running")
    this._setNavVisible(false)
    this._tick()
    this.timer = setInterval(() => this._tick(), 1000)
  }

  _pause() {
    this.running = false
    this.startBtnTarget.textContent = "계속하기"
    this.startBtnTarget.classList.replace("btn--secondary", "btn--primary")
    if (this.hasTurtleTarget) this.turtleTarget.classList.remove("turtle-track__turtle--running")
    this._setNavVisible(true)
    this._clearTick()
  }

  _tick() {
    if (this.remaining <= 0) { this._finish(); return }
    this.remaining -= 1
    this._render()
  }

  _finish() {
    this._clearTick()
    this.running = false
    if (this.mode === "focus") {
      this.sessions += 1
      this._updateDots()
      this._notify("집중 완료! 🎉 " + (this._isLongBreak() ? "긴 휴식" : "짧은 휴식") + " 시간입니다.")
    } else {
      this._notify("휴식 완료! 💪 다시 집중할 시간입니다.")
    }
    this._switchMode()
    this._reset()
    if (this.autoStartValue) this._start()
  }

  _switchMode() {
    if (this.mode === "focus") {
      this.mode = this._isLongBreak() ? "long_break" : "break"
    } else {
      this.mode = "focus"
    }
  }

  _isLongBreak() {
    return this.rounds > 0 && this.sessions % this.roundsValue === 0
  }

  _reset() {
    this.running   = false
    this.remaining = this._totalSeconds()
    if (this.hasTurtleTarget) {
      this.turtleTarget.classList.remove("turtle-track__turtle--running")
      this.turtleTarget.style.left = "0%"
    }
    if (this.hasTurtleFillTarget) this.turtleFillTarget.style.width = "0%"
    if (this.hasClockProgressTarget) {
      const c = 2 * Math.PI * 40
      this.clockProgressTarget.style.strokeDasharray = c
      this.clockProgressTarget.style.strokeDashoffset = c
      this._randomProgressColor()
    }
    this._setNavVisible(true)
    this._render()
    this._renderMode()
    if (this.hasStartBtnTarget) {
      this.startBtnTarget.textContent = "시작"
      this.startBtnTarget.classList.remove("btn--secondary")
      this.startBtnTarget.classList.add("btn--primary")
    }
  }

  _totalSeconds() {
    if (this.mode === "focus")      return this.focusMinutesValue * 60
    if (this.mode === "long_break") return this.longBreakMinutesValue * 60
    return this.breakMinutesValue * 60
  }

  _render() {
    const fmt = this._formatted()
    if (this.hasDisplayTarget) this.displayTarget.textContent = fmt
    const label = this.mode === "focus" ? "집중 중" : "휴식 중"
    document.title = `${fmt} — ${label}`
    this._updateTurtle()
    this._updateClockProgress()
  }

  _updateTurtle() {
    if (!this.hasTurtleTarget) return
    const total = this._totalSeconds()
    const pct = Math.min(((total - this.remaining) / total) * 100, 96)
    this.turtleTarget.style.left = `${pct}%`
    if (this.hasTurtleFillTarget) this.turtleFillTarget.style.width = `${pct}%`
  }

  _renderMode() {
    if (!this.hasModeLabelTarget) return
    const labels = { focus: "집중", break: "휴식", long_break: "긴 휴식" }
    this.modeLabelTarget.textContent = labels[this.mode] || "집중"
    this.modeLabelTarget.dataset.mode = this.mode === "focus" ? "focus" : "break"
  }

  _updateDots() {
    if (!this.hasRoundDotTarget) return
    this.roundDotTargets.forEach((dot, i) => {
      dot.classList.toggle("pomodoro-rounds__dot--done", i < (this.sessions % this.roundsValue || this.roundsValue))
    })
  }

  _updateSessionCount() {
    if (this.hasSessionCountTarget) {
      this.sessionCountTarget.textContent = `완료 ${this.sessions}세션`
    }
  }

  _formatted() {
    const m = Math.floor(this.remaining / 60).toString().padStart(2, "0")
    const s = (this.remaining % 60).toString().padStart(2, "0")
    return `${m}:${s}`
  }

  _clearTick() {
    if (this.timer) { clearInterval(this.timer); this.timer = null }
  }

  _updateClockProgress() {
    if (!this.hasClockProgressTarget) return
    const r = 40
    const c = 2 * Math.PI * r
    const el = this.clockProgressTarget
    el.style.strokeDasharray = c
    if (this.running) {
      el.style.strokeDashoffset = c * (1 - this.remaining / this._totalSeconds())
    } else {
      el.style.strokeDashoffset = c
    }
  }

  _setNavVisible(visible) {
    const nav = document.querySelector(".nav")
    if (nav) nav.classList.toggle("nav--hidden", !visible)
    const footer = document.querySelector(".footer")
    if (footer) footer.classList.toggle("footer--hidden", !visible)
  }

  _randomProgressColor() {
    const colors = ["#86efac", "#f97316", "#fbbf24", "#7dd3fc", "#d1d5db"]
    const color  = colors[Math.floor(Math.random() * colors.length)]
    this.clockProgressTarget.style.stroke = color
  }

  _notify(msg) {
    this._updateSessionCount()
    if ("Notification" in window && Notification.permission === "granted") {
      new Notification("포모도로", { body: msg })
    } else {
      alert(msg)
    }
  }
}
