import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const panel = document.getElementById("memo-new-panel")
    if (panel) panel.hidden = !panel.hidden
  }
}
