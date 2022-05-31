import { LightningElement, api, track } from 'lwc';

export default class EnterQuantity extends LightningElement {

    @api recordId;
    @api quantityValue;
    @api quantityInput;

    quantityChanged() {
        /* console.log('----------1---'+this.template.querySelector("lightning-input").value); */
        this.quantityInput = this.template.querySelector("lightning-input").value
        let newQuantityValue = this.quantityValue + 1;
        /* console.log('---CHILD---event.detail.quantityInput-----'+this.quantityInput); */

        const evt = new CustomEvent('quantity', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordId: this.recordId,
                newQuantityValue: newQuantityValue,
                quantityInput: this.quantityInput
            },
        });
        this.dispatchEvent(evt);
    }
}