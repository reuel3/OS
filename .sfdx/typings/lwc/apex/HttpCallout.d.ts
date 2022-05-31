declare module "@salesforce/apex/HttpCallout.createStripeCustomer" {
  export default function createStripeCustomer(param: {name: any, email: any}): Promise<any>;
}
declare module "@salesforce/apex/HttpCallout.createStripePaymentMethod" {
  export default function createStripePaymentMethod(param: {name: any, type: any, exp_month: any, exp_year: any, cvc: any}): Promise<any>;
}
declare module "@salesforce/apex/HttpCallout.dispatchPlatformEvent" {
  export default function dispatchPlatformEvent(param: {customerId: any, paymentMethodId: any, productQuantity: any, productCode: any, name: any, type: any, exp_month: any, exp_year: any, last_four: any}): Promise<any>;
}
