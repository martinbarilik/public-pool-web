import { Controller } from '@hotwired/stimulus';
import qrcode from 'qrcode-generator';

export default class extends Controller {
  static values = { data: String };

  connect() {
    if (!this.dataValue) return;

    const qr = qrcode(0, 'M');
    qr.addData(this.dataValue);
    qr.make();

    this.element.innerHTML = qr.createSvgTag({
      cellSize: 0,
      margin: 4,
      scalable: true
    });
  }
}
