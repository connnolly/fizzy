import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "boostEvent" ]

  connect() {
    this.#summarizeBoosts()
  }

  #summarizeBoosts() {
    if (this.#isBoosted) {
      const el = document.createElement("span")
      el.dataset.turboTemporary = ""
      el.textContent = this.#boostSumaries.toSentence()
      this.element.appendChild(el)
    }
  }

  get #isBoosted() {
    return this.hasBoostEventTarget
  }

  get #boostSumaries() {
    return Object.entries(this.#boostsByCreator).map(([_creatorId, boostEvents]) => {
      return `${boostEvents[0].dataset.creatorName} +${boostEvents.length}`
    })
  }

  get #boostsByCreator() {
    return this.boostEventTargets.reduce((acc, target) => {
      const creatorId = target.dataset.creatorId

      if (!acc[creatorId]) acc[creatorId] = []

      acc[creatorId].push(target)

      return acc
    }, {})
  }
}
