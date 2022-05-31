import { LightningElement, wire, track } from 'lwc';


import getProductList from '@salesforce/apex/GetProducts.getProductList';


import createCustomer from '@salesforce/apex/HttpCallout.createStripeCustomer';
import createPaymentMethod from '@salesforce/apex/HttpCallout.createStripePaymentMethod';
import dispatchPlatformEvent from '@salesforce/apex/HttpCallout.dispatchPlatformEvent';
import userId from '@salesforce/user/Id';

const COLUMNS = [
    { label: '', fieldName: 'Id', type: 'enterQuantity', fixedWidth: 50,
        typeAttributes: {
            recordId: { fieldName: 'recordId' },
            quantityValue: { fieldName: 'quantityValue' },
            quantityInput: { fieldName: 'quantityInput' }
        }
    },
    { label: '', fieldName: 'Name',  fixedWidth: 150},
    { label: '', fieldName: 'Description',  fixedWidth: 350, wrapText: true},
    { label: '', fieldName: 'UnitPrice', type: 'currency', fixedWidth: 80, cellAttributes: { alignment: 'right', class: 'slds-text-color_success slds-text-title_caps'} },
    { label: '', fieldName: 'ProductCode', fixedWidth: 80 }
];

export default class showProducts extends LightningElement {
    @track error;

    @track columns = COLUMNS;
    @track data = [];
    @track enterCreditCardInfo = false;
    @track thankYou = false;
    @track selectProduct = true;
    @track total;

    name;//card holder name
    cardNumber;
    lastFour;
    expirationMonth;
    expirationYear;
    cvc;
    country;
    zip;
    cardType;
    //selected product info
    productName;
    description;
    productCode;
    productId;

    customerId;
    paymentMethodId;
    transactionType = 'New Business';
    productChange;

    productQuantity;
    unitPrice;

    @wire(getProductList) products ({ error, data }) {
        if (data) {
            //console.log('data-----j--', JSON.stringify(data));
            this.data = data;
        }
        else if(error) {
            window.console.log('error ===> '+JSON.stringify(error));
        }  
    }

    connectedCallback () {
        console.log('--------connectedCallback---------');
    }
    getSelectedRow(event) {
        const selectedRows = event.detail.selectedRows;
        /* console.log('selectedRows-----j--', JSON.stringify(selectedRows)); */

        let selections = this.template.querySelector('c-lightning-datatable-ext').getSelectedRows();
        console.log('selections.UnitPrice-------', selections[0].UnitPrice);
        this.unitPrice = selections[0].UnitPrice;
        console.log('this.unitPrice-------', this.unitPrice);
        if(this.productQuantity) {
            console.log('this.productQuantity-------', this.productQuantity);
            this.total = this.unitPrice*this.productQuantity; 
        }
    }
    handleQuantity(event) {
        /* console.log('-----------PARENT-----------event.detail.quantityInput', event.detail.quantityInput); */
        this.productQuantity = event.detail.quantityInput;

        if(this.unitPrice) {
            /* console.log('this.unitPrice-------', this.unitPrice); */
            this.total = this.unitPrice*this.productQuantity; 
        }
    }
    
    handleCheckOut() {
        console.log('----------handleCheckOut-------');
        this.enterCreditCardInfo = true;
        this.selectProduct = false;


        this.productChange = [{"Product" : this.productCode, "Quantity" : this.productQuantity}];
        this.total = this.unitPrice*this.productQuantity;

        let selections = this.template.querySelector('c-lightning-datatable-ext').getSelectedRows();
        this.productName = this.selections[0].Name;
        this.description = this.selections[0].Description;
        this.productId = this.selections[0].Id;
        this.productCode = this.selections[0].ProductCode;
        this.unitPrice = this.selections[0].UnitPrice;
        

    }
    
    handlePayNow(event) {
        this.name = this.template.querySelector("lightning-input[data-name]").value;
        let cardNumber = this.template.querySelector("lightning-input[data-cardnumber]").value;
        this.lastFour = cardNumber.substr(cardNumber.length - 4);
        let expiration = this.template.querySelector("lightning-input[data-expiration]").value.split("/");
        this.expirationMonth = expiration[0];
        this.expirationYear = expiration[1];
        this.cvc = this.template.querySelector("lightning-input[data-cvc]").value;
        this.country = this.template.querySelector("lightning-input[data-country]").value;
        this.zip = this.template.querySelector("lightning-input[data-zip]").value;
        
        createCustomer({name: 'Skip', email: 'skip@gmail.com'})
            .then(result => {
                const response = JSON.parse(result);
                this.customerId = response.id;
                

            })
            .catch(error => {
                console.log('this.createCustomerError' + console.log('error-----j--', JSON.stringify(error)));
                
            });
    



        createPaymentMethod({name: this.name, type: this.transactionType, exp_month: this.expirationMonth, exp_year: this.expirationYear, cvc: this.cvc})
            .then(result => {
                const response = JSON.parse(result);
                //console.log('result-------', result);
                
                this.paymentMethodId = response.id;

                dispatchPlatformEvent({name: this.name, customerId: this.customerId, paymentMethodId: this.paymentMethodId, productQuantity: this.productQuantity, productCode: this.productCode, type: this.transactionType, exp_month: this.expirationMonth, exp_year: this.expirationYear, last_four: this.lastFour})
                .then(result => {
                    /* console.log('customerId-------', this.customerId);
                    console.log('paymentMethodId-------', this.paymentMethodId); 
                    console.log('productQuantity-------', this.productQuantity);*/
                    console.log('productCode-------', this.productCode);
                    console.log('name-------', this.name);
                    console.log('type-------', this.type);
                    console.log('exp_month-------', this.expirationMonth);
                    console.log('exp_year-------', this.expirationYear);
                    console.log('last_four-------', this.lastFour);

                    this.thankYou = true;
                    this.enterCreditCardInfo = false;

                })
                .catch(error => {
                    console.log('this.createError' + console.log('error-----j--', JSON.stringify(error)));
                    
                });

            })
            .catch(error => {
                console.log('this.createError' + console.log('error-----j--', JSON.stringify(error)));
                
            });
    }
}