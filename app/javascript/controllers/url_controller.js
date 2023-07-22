import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["input", "submit", "error", "inputWrapper"];

  connect() {
    this.check();
  }

  check() {
    const url = this.inputTarget.value;
    const urlPattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
      '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
      '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
      '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
      '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
      '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
    if(urlPattern.test(url)) {
      this.submitTarget.disabled = false;
      this.errorTarget.classList.add('hidden');
      this.inputWrapperTarget.classList.remove('border-red-600');
    } else {
      this.submitTarget.disabled = true;
      this.errorTarget.classList.remove('hidden');
      this.inputWrapperTarget.classList.add('border-red-600');
    }
  }
}
