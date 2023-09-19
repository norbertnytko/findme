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
  
    fetch(this.element.action, {
      method: this.element.method,
      body: new FormData(this.element)
    })
    .then(response => {
      if (response.ok) {
        let iframe = document.getElementById("iframe_preview");
        iframe.src = iframe.src;
      } else {
        console.error('Fetch request failed:', response.statusText);
      }
    })
    .catch(error => {
      console.error('Fetch error:', error);
    });
  }
}
