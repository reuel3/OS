public without sharing class HttpCallout {

    public class Customer {
        public customer(String name, String email) {
            this.name = name;
            this.email = email;
        }
		public String name;
		public String email;
	}
    public class PaymentMethod {
        public PaymentMethod(String name, String type, String exp_month, String exp_year, String cvc) {
            this.name = name;
            this.type = type;
            this.exp_month = exp_month;
            this.exp_year = exp_year;
            this.cvc = cvc;
        }
		public String name;
		public String type;
		public String exp_month;
		public String exp_year;
		public String cvc;
	}


    
    @AuraEnabled
    public static String createStripeCustomer(String name, String email) {
        System.debug('name-------'+ name);
        System.debug('email-------'+ email);
        System.debug('----apex controller---');
        String key = 'sk_test_5XCnBxBC8oO4rGomHKNLCERe00IoCMzjCY';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.stripe.com/v1/customers');
        request.setHeader('Authorization', 'Bearer ' + key);

        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Id userId = UserInfo.getUserId();
        User user = [SELECT Name, Id, Email, Account.Price_Book__c, AccountId  FROM User WHERE Id = :userId];
        //Id accId = '0018a00001pgB5mAAE';
        Id accId = user.AccountId;
        Account acc = [SELECT Id, Name, Price_Book__c, BillingAddress FROM Account WHERE Id = :accId];

        Customer c = new Customer(user.Name, user.email);
        String cJson = JSON.serialize(c);
        cJson = cJson.remove('"').replace(',', '&').replace(':', '=').replace(' ', '+').replace('@', '%40').remove('{').remove('}');
        
        System.debug('cJson-------'+ cJson);
        //String cEncode = EncodingUtil.urlEncode(cJson, 'UTF-8');
        
        request.setBody(cJson);

        HttpResponse response = http.send(request);


        // Parse the JSON response
        if(response.getStatusCode() != 201) {
            System.debug('response.getStatusCode()-------'+ response.getStatusCode());
            System.debug('response.getBody()-------'+ response.getBody());
            System.debug('response.getStatus()-------'+ response.getStatus());
        } else {

            System.debug('ELSE-----------'+response.getBody());
        }
        return response.getBody();
    }

    @AuraEnabled
    public static String createStripePaymentMethod(String name, String type, String exp_month, String exp_year, String cvc ) {

        System.debug('----!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!apex controller!!!!!!!!!!!!!!!!!!!!!!!!!!!---');
        String key = 'sk_test_5XCnBxBC8oO4rGomHKNLCERe00IoCMzjCY';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.stripe.com/v1/payment_methods');
        request.setHeader('Authorization', 'Bearer ' + key);

        request.setMethod('POST');
        //request.setHeader('Content-Type', 'application/json;charset=UTF-8');


        //request.setBody('name=John+Steinbeck&email=JS%40gmail.com');
        PaymentMethod pm = new PaymentMethod(name, type, exp_month, exp_year, cvc);
        String pmJson = JSON.serialize(pm);
        pmJson = pmJson.remove('"').replace(',', '&').replace(':', '=').replace(' ', '+').replace('@', '%40').remove('{').remove('}').replace('[','%5B').replace(']', '%5D');
        
        System.debug('pmJson-------'+ pmJson);

        request.setBody(pmJson);
        request.setBody('type=card&card%5Bexp_month%5D=5&card%5Bexp_year%5D=2025&card%5Bnumber%5D=4242424242424242&card%5Bcvc%5D=314');

        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 201) {
            System.debug('response.getBody()-------'+ response.getBody());
        } else {

            System.debug('ELSE-----------'+response.getBody());
        }
        return response.getBody();
    }
    
    @AuraEnabled
    public static String dispatchPlatformEvent (String customerId,
                                                String paymentMethodId, 
                                                String productQuantity, 
                                                String productCode, 
                                                String name, 
                                                String type, 
                                                String exp_month, 
                                                String exp_year, 
                                                String last_four ) {

        

        Id userId = UserInfo.getUserId();
        User user = [SELECT Name, Id, Email, Account.Price_Book__c, AccountId  FROM User WHERE Id = :userId];
        //Id accId = '0018a00001pgB5mAAE';
        Id accId = user.AccountId;
        Account acc = [SELECT Id, Name, Price_Book__c, BillingAddress FROM Account WHERE Id = :accId];

        Self_Service__e event = new Self_Service__e();
        event.Transaction_Type__c = 'New Business'; //Static value must be New Business
        event.Account__c = accId; //The Id of the account to create oppty/quote
        event.User__c = userId;
        event.Customer_Token__c = customerId;
        event.Gateway_Token__c = paymentMethodId;
        event.Transaction_Type__c = type;
        event.Card_Expiration_Month__c = exp_month;
        event.Card_Expiration_Year__c = exp_year;
        event.Card_Last_4__c = last_four;
        event.Name_on_Card__c = acc.Name;

        List<QuoteLineAdder.ProductChange> changes = new List<QuoteLineAdder.ProductChange>();
        QuoteLineAdder.ProductChange change = new QuoteLineAdder.ProductChange();
        change.ProductCode = 'SLK - PLUS'; // Product code of the product being sold
        change.Quantity = Integer.valueOf(productQuantity); //Quantity of the above product being sold
        changes.add(change);

        
        System.debug('event.Transaction_Type__c-------'+ event.Transaction_Type__c); //Static value must be New Business
        System.debug('event.Account__c-------'+ event.Account__c);//The Id of the account to create oppty/quote
        System.debug('event.User__c-------'+ event.User__c);
        System.debug('event.Customer_Token__c-------'+ event.Customer_Token__c);
        System.debug('event.Gateway_Token__c-------'+ event.Gateway_Token__c);
        System.debug('event.Transaction_Type__c-------'+ event.Transaction_Type__c);
        System.debug('event.Card_Expiration_Month__c-------'+ event.Card_Expiration_Month__c);
        System.debug('event.Card_Expiration_Year__c-------'+ event.Card_Expiration_Year__c);
        System.debug('event.Card_Last_4__c-------'+ event.Card_Last_4__c);
        System.debug('event.Name_on_Card__c-------'+ event.Name_on_Card__c);


        event.Product_Change__c = JSON.serialize(changes);

        System.debug('event-------'+ event);

        try {
            Database.SaveResult sr = EventBus.publish(event);
        } catch(Exception e) {
            return e.getMessage();
        }
        return 'Success';


    }
}