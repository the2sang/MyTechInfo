import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "editPane", "previewPane", "editTab", "previewTab", "previewPanel"]

  connect() {
    this.showEdit()
  }

  showEdit() {
    this.editPaneTarget.hidden = false
    this.previewPaneTarget.hidden = true
    this.editTabTarget.classList.add("content-editor__tab--active")
    this.previewTabTarget.classList.remove("content-editor__tab--active")
  }

  showPreview() {
    this.renderPreview()
    this.editPaneTarget.hidden = true
    this.previewPaneTarget.hidden = false
    this.editTabTarget.classList.remove("content-editor__tab--active")
    this.previewTabTarget.classList.add("content-editor__tab--active")
  }

  renderPreview() {
    const html = this.editorTarget.value || ""

    if (html.trim() === "" || html.trim() === "<p></p>") {
      this.previewPanelTarget.innerHTML = '<span class="content-preview__empty">미리 보기할 내용을 입력하세요</span>'
      return
    }

    this.previewPanelTarget.innerHTML = html
  }
}
