public with sharing class CustomerWorkspaceController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accountId) {
        if (accountId == null) return new List<Contact>();
        return [
            SELECT Id, Name, Email, Phone
            FROM Contact
            WHERE AccountId = :accountId
            ORDER BY Name
        ];
    }
    @AuraEnabled(cacheable=true)
    public static List<Candidate__c> getCandidates() {
        return [
            SELECT Id, Name, skill__c, exp__c, status__c
            FROM Candidate__c
        ];
    }
}