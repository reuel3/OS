public with sharing class GetProducts {

    public class ProductWrapper {
        @AuraEnabled
        public String Id { get; set;}
        @AuraEnabled
        public String Name { get; set;}
        @AuraEnabled
        public String Description { get; set;}
        @AuraEnabled
        public Decimal UnitPrice { get; set;} 
        @AuraEnabled
        public String ProductCode { get; set;} 
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getProductList() {
        Id userId = UserInfo.getUserId();
        System.debug('userId-------'+ userId);
        User user = [SELECT Id, Email, Account.Price_Book__c, AccountId  FROM User WHERE Id = :userId];
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

        //Id accId = '0018a00001pgB5mAAE';
        Id accId = user.AccountId;

        System.debug('accId-------'+ accId);

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Account acc = [SELECT Id, Name, Price_Book__c, BillingAddress FROM Account WHERE Id = :accId];
        //Id pbId = user.Account.Price_Book__c;
        Id pbId = acc.Price_Book__c;
        System.debug('acc-------'+ acc);
        System.debug('user-------'+ user);
        List<PricebookEntry> pbEntryList = [SELECT Id, Product2.Name, Product2.Description, UnitPrice, ProductCode FROM PricebookEntry WHERE Pricebook2Id = :pbId];
        System.debug('pbEntryList-------'+ pbEntryList);
        List<ProductWrapper> pwList = new List<ProductWrapper>();
        
        
        for (PricebookEntry pbe : pbEntryList) {
            ProductWrapper pw = new ProductWrapper();
            pw.Id = pbe.Product2Id;
            pw.Name = pbe.Product2.Name;
            pw.Description = pbe.Product2.Description;
            pw.UnitPrice = pbe.UnitPrice;
            pw.ProductCode = pbe.ProductCode;

            pwList.add(pw);
        }

        return pwList;
    }

/*     @AuraEnabled(cacheable=true)
    public static List<Contact> findContacts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [
            SELECT Id, Name, Title, Phone, Email
            FROM Contact
            
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Contact getSingleContact() {
        return [
            SELECT Id, Name, Title, Phone, Email
            FROM Contact
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }
 */}