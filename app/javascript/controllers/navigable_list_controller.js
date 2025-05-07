import { Controller } from "@hotwired/stimulus"
import { nextFrame } from "helpers/timing_helpers"

export default class extends Controller {
  static targets = [ "item" ]
  static values = { selectionAttribute: { type: String, default: "aria-current" } }

  // Actions

  navigate(event) {
    if (this.itemTargets.includes(event.target)) {
      this.#keyHandlers[event.key]?.call(this, event)
    }
  }

  selectLast(event) {
    this.#setCurrentFrom(this.itemTargets[this.itemTargets.length - 1])
  }

  #handleArrowKey(event, fn) {
    if (event.shiftKey || event.metaKey || event.ctrlKey) { return }
    fn.call()
    event.preventDefault()
  }

  #selectPrevious() {
    if (this.currentItem.previousElementSibling) {
      this.#setCurrentFrom(this.currentItem.previousElementSibling)
    }
  }

  #selectNext() {
    if (this.currentItem.nextElementSibling) {
      this.#setCurrentFrom(this.currentItem.nextElementSibling)
    }
  }

  async #setCurrentFrom(element) {
    const selectedItem = this.itemTargets.find(item => item.contains(element))

    if (selectedItem) {
      this.#clearSelection()
      selectedItem.setAttribute(this.selectionAttributeValue, "true")
      this.currentItem = selectedItem
      await nextFrame()
      this.currentItem.focus()
    }
  }

  #clearSelection() {
    for (const item of this.itemTargets) {
      item.removeAttribute(this.selectionAttributeValue)
    }
  }

  #keyHandlers = {
    ArrowDown(event) {
      this.#handleArrowKey(event, this.#selectNext.bind(this))
    },
    ArrowUp(event) {
      this.#handleArrowKey(event, this.#selectPrevious.bind(this))
    },
    ArrowRight(event) {
      this.#handleArrowKey(event, this.#selectNext.bind(this))
    },
    ArrowLeft(event) {
      this.#handleArrowKey(event, this.#selectPrevious.bind(this))
    },
    Enter(event) {
      // this.#currentFirstFocusableControl?.focus()
      // event.preventDefault()
    }
  }
}
