import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startBtn", "modeLabel", "sessionCount", "roundDot"]
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

  disconnect() { this._clearTick() }

  toggle()    { this.running ? this._pause() : this._start() }
  reset()     { this._clearTick(); this._reset() }
  skipMode()  { this._clearTick(); this._switchMode(); this._reset() }

  // ── private ──────────────────────────────────────────────

  _start() {
    this.running = true
    this.startBtnTarget.textContent = "일시정지"
    this.startBtnTarget.classList.replace("btn--primary", "btn--secondary")
    this._tick()
    this.timer = setInterval(() => this._tick(), 1000)
  }

  _pause() {
    this.running = false
    this.startBtnTarget.textContent = "계속하기"
    this.startBtnTarget.classList.replace("btn--secondary", "btn--primary")
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

  _notify(msg) {
    this._updateSessionCount()
    if ("Notification" in window && Notification.permission === "granted") {
      new Notification("포모도로", { body: msg })
    } else {
      alert(msg)
    }
  }
}
