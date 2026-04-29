import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { pieceCount: { type: Number, default: 9 } }
  static targets = ["grid", "scatter", "timer", "preview", "startBtn", "countBtn", "overlay", "overlayTitle", "overlayMsg"]

  IMAGES  = ["/puzzles/sakura.svg", "/puzzles/mountain.svg", "/puzzles/ocean.svg", "/puzzles/forest.svg", "/puzzles/city.svg"]
  TIMERS  = { 9: 600, 25: 1200, 36: 1800 }
  GRIDS   = { 9: 3, 25: 5, 36: 6 }

  currentImage = null
  timeLeft     = 0
  placedCount  = 0
  interval     = null
  draggedId    = null
  playing      = false
  touchPiece   = null
  touchGhost   = null

  connect() { this._syncCountBtns() }
  disconnect() { this._stopTimer() }

  selectCount(e) {
    if (this.playing) return
    this.pieceCountValue = parseInt(e.currentTarget.dataset.count)
    this._syncCountBtns()
  }

  startGame() {
    if (this.playing) return
    this.playing = true
    this.placedCount = 0
    this.draggedId = null
    this._hideOverlay()

    this.currentImage = this.IMAGES[Math.floor(Math.random() * this.IMAGES.length)]
    this.previewTarget.style.backgroundImage = `url(${this.currentImage})`
    this.previewTarget.querySelector(".pz-preview__hint").textContent = "힌트"
    this.startBtnTarget.disabled = true

    const cols = this.GRIDS[this.pieceCountValue]
    this._renderGrid(cols)
    setTimeout(() => {
      this._renderPieces(cols)
      this.timeLeft = this.TIMERS[this.pieceCountValue]
      this._updateTimer()
      this._startTimer()
    }, 60)
  }

  resetGame() {
    this._stopTimer()
    this.playing = false
    this.placedCount = 0
    this.gridTarget.replaceChildren()
    this.scatterTarget.replaceChildren()
    this.timerTarget.textContent = "--:--"
    this.timerTarget.classList.remove("pz-timer--urgent")
    this.previewTarget.style.backgroundImage = ""
    this.previewTarget.querySelector(".pz-preview__hint").textContent = "원본 이미지"
    this._hideOverlay()
    this.startBtnTarget.disabled = false
    if (this.touchGhost) { this.touchGhost.remove(); this.touchGhost = null }
  }

  // ── Grid ────────────────────────────────────────────────
  _renderGrid(cols) {
    const grid = this.gridTarget
    grid.replaceChildren()
    grid.style.gridTemplateColumns = `repeat(${cols}, 1fr)`
    for (let r = 0; r < cols; r++) {
      for (let c = 0; c < cols; c++) {
        const slot = document.createElement("div")
        slot.className = "pz-slot"
        slot.dataset.slotId = `${r}_${c}`
        slot.addEventListener("dragover", e => e.preventDefault())
        slot.addEventListener("drop", this._onDrop.bind(this))
        grid.appendChild(slot)
      }
    }
  }

  // ── Pieces ───────────────────────────────────────────────
  _renderPieces(cols) {
    const scatter  = this.scatterTarget
    scatter.replaceChildren()
    const gridPx   = this.gridTarget.clientWidth || 360
    const pSize    = Math.floor(gridPx / cols)
    const gap      = 3
    const sw       = scatter.clientWidth || 340

    // How many pieces fit per row without overlap
    const perRow   = Math.max(1, Math.floor(sw / (pSize + gap)))
    const total    = cols * cols

    // Adjust scatter height to fit all rows
    const rowCount = Math.ceil(total / perRow)
    scatter.style.height = `${rowCount * (pSize + gap) + gap}px`

    const ids = []
    for (let r = 0; r < cols; r++)
      for (let c = 0; c < cols; c++)
        ids.push(`${r}_${c}`)
    ids.sort(() => Math.random() - 0.5)

    ids.forEach((id, i) => {
      const [r, c] = id.split("_").map(Number)
      const col = i % perRow
      const row = Math.floor(i / perRow)
      const el  = document.createElement("div")
      el.className = "pz-piece"
      el.dataset.pieceId = id
      el.draggable = true
      el.style.backgroundImage    = `url(${this.currentImage})`
      el.style.backgroundSize     = `${gridPx}px ${gridPx}px`
      el.style.backgroundPosition = `-${c * pSize}px -${r * pSize}px`
      el.style.width              = `${pSize}px`
      el.style.height             = `${pSize}px`
      el.style.left               = `${col * (pSize + gap) + gap}px`
      el.style.top                = `${row * (pSize + gap) + gap}px`
      el.addEventListener("dragstart", this._onDragStart.bind(this))
      el.addEventListener("dragend",   this._onDragEnd.bind(this))
      el.addEventListener("touchstart", this._onTouchStart.bind(this), { passive: false })
      el.addEventListener("touchmove",  this._onTouchMove.bind(this),  { passive: false })
      el.addEventListener("touchend",   this._onTouchEnd.bind(this))
      scatter.appendChild(el)
    })
  }

  // ── Drag (PC) ────────────────────────────────────────────
  _onDragStart(e) {
    this.draggedId = e.currentTarget.dataset.pieceId
    e.currentTarget.classList.add("pz-piece--dragging")
    e.dataTransfer.effectAllowed = "move"
    e.dataTransfer.setData("text/plain", this.draggedId)
  }

  _onDragEnd(e) { e.currentTarget.classList.remove("pz-piece--dragging") }

  _onDrop(e) {
    e.preventDefault()
    const pid = e.dataTransfer.getData("text/plain") || this.draggedId
    this._tryPlace(pid, e.currentTarget.dataset.slotId, e.currentTarget)
  }

  // ── Touch (Mobile) ───────────────────────────────────────
  _onTouchStart(e) {
    e.preventDefault()
    const piece = e.currentTarget
    this.touchPiece = piece
    const t = e.touches[0]
    const w = piece.offsetWidth, h = piece.offsetHeight
    const ghost = piece.cloneNode()
    ghost.style.position    = "fixed"
    ghost.style.opacity     = "0.85"
    ghost.style.zIndex      = "9999"
    ghost.style.pointerEvents = "none"
    ghost.style.left        = `${t.clientX - w / 2}px`
    ghost.style.top         = `${t.clientY - h / 2}px`
    document.body.appendChild(ghost)
    this.touchGhost = ghost
    piece.style.opacity = "0.25"
  }

  _onTouchMove(e) {
    e.preventDefault()
    if (!this.touchGhost) return
    const t = e.touches[0]
    this.touchGhost.style.left = `${t.clientX - this.touchGhost.offsetWidth  / 2}px`
    this.touchGhost.style.top  = `${t.clientY - this.touchGhost.offsetHeight / 2}px`
  }

  _onTouchEnd(e) {
    if (!this.touchGhost || !this.touchPiece) return
    const t   = e.changedTouches[0]
    const pid = this.touchPiece.dataset.pieceId
    this.touchGhost.hidden = true
    const el = document.elementFromPoint(t.clientX, t.clientY)
    this.touchGhost.hidden = false
    this.touchGhost.remove()
    this.touchGhost = null
    const slot = el?.closest(".pz-slot")
    if (slot) {
      this._tryPlace(pid, slot.dataset.slotId, slot)
    } else {
      this.touchPiece.style.opacity = "1"
    }
    this.touchPiece = null
  }

  // ── Placement ────────────────────────────────────────────
  _tryPlace(pieceId, slotId, slotEl) {
    if (slotEl.classList.contains("pz-slot--filled")) return
    if (pieceId !== slotId) {
      slotEl.classList.add("pz-slot--wrong")
      setTimeout(() => slotEl.classList.remove("pz-slot--wrong"), 400)
      if (this.touchPiece) this.touchPiece.style.opacity = "1"
      return
    }
    const piece = this.scatterTarget.querySelector(`[data-piece-id="${pieceId}"]`)
    if (!piece) return
    const cols     = this.GRIDS[this.pieceCountValue]
    const [r, c]   = pieceId.split("_").map(Number)
    const pct      = v => cols > 1 ? (v * 100 / (cols - 1)) : 0
    slotEl.classList.add("pz-slot--filled")
    slotEl.appendChild(piece)
    piece.style.position           = "static"
    piece.style.left               = ""
    piece.style.top                = ""
    piece.style.width              = "100%"
    piece.style.height             = "100%"
    piece.style.opacity            = "1"
    piece.style.cursor             = "default"
    piece.style.backgroundSize     = `${cols * 100}% ${cols * 100}%`
    piece.style.backgroundPosition = `${pct(c)}% ${pct(r)}%`
    piece.draggable                = false
    piece.classList.add("pz-piece--placed")
    this.placedCount++
    if (this.placedCount >= this.pieceCountValue) {
      this._stopTimer()
      this._showCelebration()
    }
  }

  // ── Timer ────────────────────────────────────────────────
  _startTimer() {
    this.interval = setInterval(() => {
      this.timeLeft--
      this._updateTimer()
      if (this.timeLeft <= 0) { this._stopTimer(); this._showGameOver() }
    }, 1000)
  }

  _stopTimer() {
    if (this.interval) { clearInterval(this.interval); this.interval = null }
  }

  _updateTimer() {
    const m = String(Math.floor(this.timeLeft / 60)).padStart(2, "0")
    const s = String(this.timeLeft % 60).padStart(2, "0")
    this.timerTarget.textContent = `${m}:${s}`
    this.timerTarget.classList.toggle("pz-timer--urgent", this.timeLeft <= 60)
  }

  // ── Overlay ──────────────────────────────────────────────
  _showCelebration() {
    this._showOverlay("🎉 완성!", "퍼즐을 완성했습니다! 축하해요!")
    this._launchConfetti()
  }

  _showGameOver() {
    this.playing = false
    this._showOverlay("⏰ 시간 초과", `${this.placedCount} / ${this.pieceCountValue} 조각 완성`)
  }

  _showOverlay(title, msg) {
    this.overlayTitleTarget.textContent = title
    this.overlayMsgTarget.textContent   = msg
    this.overlayTarget.hidden = false
  }

  _hideOverlay() { this.overlayTarget.hidden = true }

  // ── Confetti ─────────────────────────────────────────────
  _launchConfetti() {
    const colors = ["#7b42bc","#FFD700","#FF6B6B","#4ECDC4","#45B7D1","#f48fb1","#69f0ae"]
    const wrap = document.createElement("div")
    wrap.className = "pz-confetti-wrap"
    document.body.appendChild(wrap)
    for (let i = 0; i < 90; i++) {
      const p    = document.createElement("div")
      const size = 5 + Math.random() * 8
      p.className = "pz-confetti-piece"
      p.style.left             = `${Math.random() * 100}%`
      p.style.background       = colors[i % colors.length]
      p.style.animationDelay   = `${Math.random() * 1.5}s`
      p.style.animationDuration= `${2.5 + Math.random() * 1.5}s`
      p.style.width            = `${size}px`
      p.style.height           = `${size}px`
      p.style.borderRadius     = Math.random() > 0.5 ? "50%" : "3px"
      wrap.appendChild(p)
    }
    setTimeout(() => wrap.remove(), 5500)
  }

  _syncCountBtns() {
    this.countBtnTargets.forEach(btn => {
      btn.classList.toggle("pz-count-btn--active", parseInt(btn.dataset.count) === this.pieceCountValue)
    })
  }
}
