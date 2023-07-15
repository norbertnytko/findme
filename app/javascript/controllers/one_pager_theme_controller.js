import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"];

  async change(event) {
    event.preventDefault();
  
    this.labelTargets.forEach((label) => {
      label.classList.remove("outline");
    });

    const selectedLabel = event.currentTarget.parentElement;
    selectedLabel.classList.add("outline");
  
    await fetch(this.element.action, {
      method: this.element.method,
      body: new FormData(this.element)
    });

  }
}
