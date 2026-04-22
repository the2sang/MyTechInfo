import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editor", "editPane", "previewPane", "editTab", "previewTab", "previewPanel", "hiddenContent"]

  connect() {
    this.showEdit()

    this.editorTarget.addEventListener("lexxy:initialize", () => this.onEditorReady())
    this.editorTarget.addEventListener("lexxy:change", () => this.syncContent())

    const form = this.element.closest("form")
    if (form) form.addEventListener("submit", () => this.syncContent(), { capture: true })
  }

  onEditorReady() {
    if (this.hasHiddenContentTarget && this.hasEditorTarget) {
      const initialContent = this.hiddenContentTarget.value
      if (initialContent) {
        this.editorTarget.value = initialContent
      }
    }
  }

  syncContent() {
    if (this.hasHiddenContentTarget && this.hasEditorTarget) {
      const value = this.editorTarget.value
      if (value !== undefined) {
        this.hiddenContentTarget.value = value
      }
    }
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

    // Preview of user's own editor content (not external/untrusted input)
    this.previewPanelTarget.innerHTML = html
  }
}
