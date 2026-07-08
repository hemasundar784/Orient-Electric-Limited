public with sharing class LWCUtility {
    // Static block executes once when the class is first loaded into memory by the Apex runtime.
    static{
        System.debug('LWCUtility.static{}.');
    }
    // Constructor executes when an instance/object of the class is created.
    // LWC wire service and imperative calls typically do not create instances (they call static methods).
    public LWCUtility() {
        System.debug('LWCUtility.constructor().');
    }
    /** * @Description: Simple method to return a hardcoded message.
     * This method is designed to be called automatically by LWC using the @wire service (property 
         wire).
     * @AuraEnabled(cacheable=true) is REQUIRED for all methods used with the @wire service.
     * cacheable=true allows the results to be cached on the client side, improving performance.
     * All wired methods must be static.
     * @return: A String message.
     */
    @AuraEnabled(cacheable=true) public static String sendMessage(){
        System.debug('LWCUtility.sendMessage().');
        return 'Salesforce is world\'s No.1 CRM Platform.';
    }
    /**
     * @Description: Method to return a personalized greeting.
     * This method is also designed for the @wire service (function wire) and accepts an input 
        parameter.
     * The parameter allows the LWC to reactively pass values to Apex.
     * @param person: The name of the person to greet, passed from the LWC.
     * @return: A personalized greeting String.
     */
    @AuraEnabled(cacheable=true) public static String sendGreeting(String person){
        System.debug('LWCUtility.sendGreeting('+person+').');
        // Example of a line that could cause an error (e.g., if uncommented, a Division by Zero exception)
        // Integer result = 5/0;
        return 'Hello '+person+', Welcome to LWC.';
    }
    /**
     * @Description: Performs a calculation based on two numbers and an operator.
     * This method is called imperatively from the LWC using a promise structure (.then/.catch).
     * @AuraEnabled is sufficient for imperative calls (cacheable=true is not needed or recommended 
       for write/transactional operations).
     * @param x: The first integer.
     * @param y: The second integer.
     * @param op: The operation Integer (1-'sum', 2-'diff', 3-'prod', 4-'quot', 5-'rem').
     * @return: The calculated Integer result.
     */
    @AuraEnabled public static Integer calculate(Integer x, Integer y, Integer op){
        System.debug('LWCUtility.calculate('+x+','+y+','+op+').');
        Integer result;
        // Switch statement to handle different calculation operations
        switch on op {
            when 1  { result = x + y; }
            when 2 { result = x - y; }
            when 3 { result = x * y; }
            when 4 { result = x / y; } // Apex automatically throws a System.DMLException (Division by Zero) if y is 0.
            when 5  { result = Math.mod(x, y); }
            when else   { throw new StringException('Invalid Operator: ' + op); } // If the operator is not recognized, throw a custom exception
        }
        System.debug('Result → '+result);
        return result;
    }
    @AuraEnabled(cacheable=true) // Expose method to LWC and enable caching
    public static List<Contact> findContacts(String searchKey) {
        // Return empty list if input is blank
        if (String.isBlank(searchKey)) return new List<Contact>();
        searchKey = searchKey + '%'; // Add wildcard for partial match
        return [
            SELECT Id, Name FROM Contact
            WHERE Name LIKE :searchKey ORDER BY Name LIMIT 5
        ];
    }

    /**
     * Returns account details for the given accountId.
     * @param accountId Id of the account record
     * @return AccountWrapper containing account fields
     */
    @AuraEnabled(cacheable=true)
    public static Prospect fetchAccountOverview(Id accountId) {
        Account acc = [
            SELECT Id, Name, AccountNumber, Phone, Fax, email__c, Rating, Industry
            FROM Account
            WHERE Id = :accountId
        ];
        Prospect wrapper = new Prospect();
        wrapper.recordId      = acc.Id;            wrapper.name     = acc.Name;
        wrapper.accountNumber = acc.AccountNumber; wrapper.phone    = acc.Phone; 
        wrapper.fax           = acc.Fax;           wrapper.email    = acc.email__c;
        wrapper.rating        = acc.Rating;        wrapper.industry = acc.Industry;
        return wrapper;
        }
    

    public class Prospect {
        @AuraEnabled public String recordId, name, accountNumber, phone, 
            fax, email, rating, industry;
    }
    /* Returns all Accounts as Prospect wrapper objects for LWC */
    @AuraEnabled(cacheable=true)
    public static List<Prospect> getProspects() {
        // Fetch Accounts from Salesforce
        List<Account> accounts = [
            SELECT Id, Name, AccountNumber, Phone, Fax,
                   email__c, Rating, Industry
            FROM Account ORDER BY Name ASC
        ];
        // Convert Accounts → Prospect wrappers
        List<Prospect> propsects = new List<Prospect>();
        for (Account acc : accounts) {
            Prospect p = new Prospect();
            p.recordId      = acc.Id;            p.name     = acc.Name;
            p.accountNumber = acc.AccountNumber; p.phone    = acc.Phone;
            p.fax           = acc.Fax;           p.email    = acc.email__c;
            p.rating        = acc.Rating;        p.industry = acc.Industry;
            propsects.add(p);
        }
        return propsects;
    }
     /**
     * Fetches key (primary) contacts for a given Account
     * @param accountId Account Id
     * @return List of Contact records
     */
    @AuraEnabled(cacheable=true)
    public static List<Contact> fetchAccountKeyContacts(Id accountId) {
        if (accountId == null) return new List<Contact>();
        return [ SELECT Id, Name, Phone, Fax, Email FROM Contact
            WHERE AccountId = :accountId AND Level__c = 'Primary' ORDER BY Name];
    }



    /**
 * @Description: Apex controller class designed to provide data and services
 * for the 'ApexdataBindingLwc' Lightning Web Component.
 * It demonstrates both wired (@AuraEnabled(cacheable=true)) and imperative
 * (@AuraEnabled) method calls.
 */

    /*Wrapper for incoming Contact data from LWC.
        Field names match the LWC JavaScript object.*/
    public class ContactWrapper {
        @AuraEnabled public String firstname { get; set; }
        @AuraEnabled public String lastname  { get; set; }
        @AuraEnabled public String phone     { get; set; }
        @AuraEnabled public String fax       { get; set; }
        @AuraEnabled public String email     { get; set; }
    }
    /*Generic response wrapper used for both success and error.
        Keeps the LWC parsing logic simple and predictable.*/
    public class CCResponse {
        @AuraEnabled public Id      recordId;
        @AuraEnabled public String  message;
        @AuraEnabled public Boolean isSuccess;
    }
    /*Helper: Convert wrapper → Contact SObject.
        Keeps the main method focused on DML and error handling.*/
    private static Contact toContact(ContactWrapper c, Id accountId) {
        return new Contact(
            FirstName = c.firstname, Phone     = c.phone,
            LastName  = c.lastname,  Fax       = c.fax,
            Email     = c.email,     AccountId = accountId
        );
    }
    /*Creates a Contact under the given Account.
        Called imperatively from LWC.*/
    @AuraEnabled(cacheable=false)
    public static CCResponse doCreateContact(ContactWrapper ctContact, Id accountId) {
        System.debug('LWCUtility.doCreateContact:'
            + '\nPayload: ' + JSON.serializePretty(ctContact)
            + '\nAccountId: ' + accountId);
        CCResponse response = new CCResponse();
        try {
            // Basic defensive checks (lets us fail fast with a clear message)
            if (ctContact == null) {
                response.isSuccess = false;
                response.message   = 'CON-REQ-400: No contact data received.';
                return response;
            }
            // Transform wrapper → Contact and insert
            Contact con = toContact(ctContact, accountId);
            insert con;
            // Success response
            response.isSuccess = true;
            response.recordId  = con.Id;
            response.message   = 'Contact ' + con.FirstName + ' ' + con.LastName + ' created successfully';
            System.debug('LWCUtility.doCreateContact Message: ' + response.message);
        }
        catch (DmlException e) {
            // Standardized error mapping → user-friendly messages
            System.debug('LWCUtility.doCreateContact DML Error: ' + e.getMessage());
            response.isSuccess = false;
            String msg = e.getMessage();
            if (msg.contains('REQUIRED_FIELD_MISSING')) {
                response.message = 'CON-400-REQ-FIELD-MISSING: Required Keys Missing (LastName)).';
            } else if (msg.contains('INVALID_EMAIL_ADDRESS')) {
                response.message = 'CON-EMAIL-422: Email is not in email format.';
            } else if (msg.contains('CON-400-VR-PHONE-REQ')) {
                response.message = 'CON-400-VR-PHONE-REQ: Contact\'s phone cannot be empty.';
            } else if (msg.contains('DUPLICATES_DETECTED')) {
                response.message = 'CON-400-DU-EXTS: Duplicate contact exists.';
            } else {
                response.message = 'CON-UNKW-500: An unexpected server error occurred.';
            }
        }
        return response;
    }
}           
    