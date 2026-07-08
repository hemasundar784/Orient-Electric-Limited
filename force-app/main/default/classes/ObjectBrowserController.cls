public with sharing class ObjectBrowserController {

    // Wrapper class used to expose Id + Label to LWC
    public class RecordSummary {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String label { get; set; }
    }

    // Supported objects for the object picker
    @AuraEnabled(cacheable=true)
    public static List<String> getSupportedObjects() {
        return new List<String>{
            'Account',
            'Contact',
            'Opportunity',
            'Student__c',
            'BankAccount__c',
            'DepositAccount__c',
            'Candidate__c'
        };
    }

    // Field used as display "label" in the list for each object
    private static Map<String, String> getListLabelFieldMap() {
        return new Map<String, String>{
            'Account'             => 'Name',
            'Contact'             => 'Name',
            'Opportunity'         => 'Name',
            'Student__c'          => 'Name',
            'BankAccount__c'     => 'Name',
            'DepositAccount__c'  => 'Name',
            'Candidate__c'        => 'Name'
        };
    }

    // Fields to show in the record viewer component for each object
    private static Map<String, List<String>> getRecordViewFieldMap() {
        return new Map<String, List<String>>{
            'Account' => new List<String>{
                'Name', 'AccountNumber', 'Phone', 'Fax', 'email__c', 'Website'
            },
            'Contact' => new List<String>{
                'Name', 'Email', 'Phone', 'MailingCity'
            },
            'Opportunity' => new List<String>{
                'Name', 'StageName', 'Amount', 'CloseDate'
            },
            'Student__c' => new List<String>{
                'Name', 'mobile__c', 'email__c', 'branch__c'
            },
            'BankAccount__c' => new List<String>{
                'Name', 'accnumber__c', 'amount__c', 'category__c', 'totalAmount__c', 'totalDeposits__c'
            },
            'DepositAccount__c' => new List<String>{
                'Name', 'accnumber__c', 'amount__c', 'bankId__c'
            },
            'Candidate__c' => new List<String>{
                'Name', 'mobile__c', 'email__c', 'exp__c', 'status__c', 'skill__c'
            }
        };
    }

    // Fields list for record viewer (used by LWC to loop fields)
    @AuraEnabled(cacheable=true)
    public static List<String> getRecordViewFields(String objectApiName) {
        Map<String, List<String>> config = getRecordViewFieldMap();
        if (!config.containsKey(objectApiName)) {
            return new List<String>();
        }
        return config.get(objectApiName);
    }

    // Records for list component (Id + label only)
    @AuraEnabled(cacheable=true)
    public static List<RecordSummary> getRecordSummaries(String objectApiName) {
        Map<String, String> fieldMap = getListLabelFieldMap();
        if (!fieldMap.containsKey(objectApiName)) {
            return new List<RecordSummary>();
        }

        String labelField = fieldMap.get(objectApiName);
        String soql =
            'SELECT Id, ' + labelField +
            ' FROM ' + objectApiName +
            ' ORDER BY CreatedDate DESC LIMIT 20';

        List<SObject> rows = Database.query(soql);
        List<RecordSummary> summaries = new List<RecordSummary>();

        for (SObject row : rows) {
            RecordSummary r = new RecordSummary();
            r.id = (String)row.get('Id');
            r.label = (String)row.get(labelField);
            summaries.add(r);
        }
        return summaries;
    }
}