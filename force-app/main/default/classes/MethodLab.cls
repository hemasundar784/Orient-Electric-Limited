public class MethodLab {
    // Validates that contacts have phone numbers. Logs warnings without blocking DML.
    public static void validateContactPhone(List<Contact> contacts){
        for(Contact con: contacts){
            if(String.isBlank(con.Phone)){
                System.debug('❌ ERROR: Phone missing for Contact → (' + con.FirstName + ' ' + con.LastName + ')');
            }
        }
    }



    // Bulk-copies Phone values to missing Fax fields for a list of Contacts.
    public static void copyPhoneToFax(List<Contact> contacts){
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact con: contacts){
            if(String.isNotBlank(con.Phone) && String.isBlank(con.Fax)){
                con.Fax = con.Phone;
                contactsToUpdate.add(con);
            }
        }
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
            System.debug('Contacts fax updated: ' + contactsToUpdate.size());
        }
    }


    // Creates a related RequestForm__c record for existing Accounts, due in 5 days.
    public static void createServiceRequestForms(List<Account> accounts){
        List<RequestForm__c> forms = new List<RequestForm__c>();
        for(Account acc: accounts){
            if(String.isNotBlank(acc.Id)){
                forms.add(new RequestForm__c(
                    accountId__c = acc.id, 
                    deliverydate__c = Date.today() + 5
                ));
            }
        }
        if(!forms.isEmpty()){
            insert forms;
            System.debug('Request forms created: ' + forms.size());
        }
    }



       // Bulk-posts Chatter alerts on new, high-priority breakdown Cases.
    public static void postHighPriorityCaseAlerts(List<Case> cases){
        if(cases == null || cases.isEmpty()) return;
        List<FeedItem> posts = new List<FeedItem>();
        for(Case cs: cases){
            if(cs.Priority == 'High' && cs.Status == 'New' && cs.Reason == 'Breakdown' && String.isNotBlank(cs.AccountId)){
                posts.add(new FeedItem(
                    ParentId = cs.Id,
                    Body = '🚨 High Priority Case. Resolve within 24 hours.'
                ));
            }
        }
        if(!posts.isEmpty()){
            insert posts;
        }
    }




      // Demo method evaluating basic Account ownership logic before mock deletion.
    public static void showAccountDeleteAccess(List<Account> accounts){
        Id currentUserId = UserInfo.getUserId();
        for(Account acc: accounts){
            String status = (acc.OwnerId == currentUserId) ? '✅ Can delete' : '❌ Cannot delete';
            System.debug(status + ' → (' + acc.Name + ' { Owner - ' + acc.Owner.Name + ' }).');
        }
    }
    /* Administrative cleanup: Closes open cases linked to expired accounts.
    Demonstrates multi-object data traversal: Account → Contact → Case. */
    public static void closeCasesForExpiredAccounts(List<Account> accounts){
        if(accounts.isEmpty()) return;

        Set<Id> expiredAccountIds = new Set<Id>();
        for(Account acc: accounts){
            if(acc.serviceStatus__c == 'Expired') {
                expiredAccountIds.add(acc.Id);
            }
        }
        if(expiredAccountIds.isEmpty()) return;

        Map<Id, Contact> contacts = new Map<Id, Contact>([
            SELECT Id FROM Contact WHERE AccountId IN :expiredAccountIds
        ]);
        
        if(!contacts.isEmpty()){
            List<Case> cases = [
                SELECT Id FROM Case WHERE isClosed = false AND ContactId IN :contacts.keySet()
            ];
            if(!cases.isEmpty()){
                for(Case cs: cases) {
                    cs.Status = 'Closed';
                }
                update cases;
                System.debug('Total Cases Closed → ' + cases.size());
            }
        }
    }


       // Prints contact counts per account.
    public static void printAccountNameAndContactCount(List<Contact> contacts) {
        Map<Id, Integer> countMap = new Map<Id, Integer>();
        for(Contact con: contacts){
            if(String.isNotBlank(con.AccountId)){
                Integer count = countMap.containsKey(con.AccountId) ? countMap.get(con.AccountId) + 1 : 1;
                countMap.put(con.AccountId, count);
            }
        }
        for(Id accId: countMap.keySet()){
            Account acc = [SELECT Name FROM Account WHERE Id = :accId];
            System.debug(acc.Name + ' → {' + countMap.get(accId) + '}');
        }
    }



    // Reassigns Account ownership from specified Users to their assigned Supervisors.
    public static void transferAccountsToSupervisor(List<User> usersList) {
        Map<Id, Id> ownerToSupervisor = new Map<Id, Id>();
        for(User u: usersList){
            ownerToSupervisor.put(u.Id, u.supervisorId__c);
        }
        List<Account> accs = [
            SELECT Id, OwnerId FROM Account WHERE OwnerId IN :ownerToSupervisor.keySet()
        ];
        if(!accs.isEmpty()){
            for(Account acc: accs){
                acc.OwnerId = ownerToSupervisor.get(acc.OwnerId);
            }
            update accs;
        }
    }



      // Inserts a Contact utilizing partial success options and returns status reporting.
    public static String createContactAndReturnMessage(
        String firstName, String lastName, String phone, String fax, String email, Id accountId
    ){
        if(String.isBlank(lastName)) return '❌ Failure: LastName required';

        Contact con = new Contact(
            FirstName = firstName, LastName = lastName, Phone = phone,
            Fax = fax, Email = email, AccountId = accountId
        );
        Database.SaveResult sr = Database.insert(con, false);
        return sr.isSuccess() 
            ? '✅ Success: ' + sr.getId() 
            : '❌ Failure: ' + sr.getErrors().get(0).getMessage();
    }
}