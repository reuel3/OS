import LightningDatatable from 'lightning/datatable';
import enterQuantity from './enterQuantity';

export default class LightningDatatableExt extends LightningDatatable {
    static customTypes = {
        enterQuantity: {
            template: enterQuantity,
            typeAttributes: ['recordId', 'quantityValue', 'quantityInput']
        }
    }
}