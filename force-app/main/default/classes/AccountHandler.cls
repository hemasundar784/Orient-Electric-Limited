public with sharing class AccountHandler {

    public static Account insertNewAccount(String accountName) {
        try {
            // Create a new Account record using the incoming string as the Name
            Account acct = new Account(Name = accountName);
            
            // Insert the account into the system
            insert acct;
            
            // Return the inserted account record
            return acct;
        } catch (DmlException e) {
            // Catch the failed DML exception (e.g., when passing an empty string) and return null
            System.debug('A DML exception has occurred: ' + e.getMessage());
            return null;
        }
    }
}