import Sortable from "stimulus-sortable"

export default class extends Sortable {
  connect() {
    super.connect()
    this.sortable
    this.options
    this.defaultOptions
  }

  onUpdate(event) {
    super.onUpdate(event)
    console.log(event)
  }

  onUpdate(event) {
    super.onUpdate(event).then(
      () => {
        let iframe = document.getElementById("iframe_preview");
        iframe.src = iframe.src;
      }
    )
  }
}
