trigger AccountTrigger on Account (after insert, after update, before delete) {
    System.debug('AccountTrigger(' + Trigger.operationType + ').');
    
    switch on Trigger.operationType {
        
        when AFTER_INSERT {
            // Create a list to hold new SRF records
            List<RequestForm__c> forms = new List<RequestForm__c>();
            
            // For each newly created Account, prepare a child SRF record
            for (Account insertedAccount : Trigger.new) {
                RequestForm__c form = new RequestForm__c(
                    accountId__c = insertedAccount.Id, 
                    deliverydate__c = Date.today() + 5
                );
                forms.add(form);
            }
            
            // Insert all SRF records at once safely (bulk-safe)
            if (!forms.isEmpty()) {
                insert forms;
            }
        }
        
        when BEFORE_DELETE {
            Id currentUserId = UserInfo.getUserId();
            
            // Loop through accounts being deleted.
            for (Account acc : Trigger.old) {
                // Restrict deletion if current user is not the owner.
                if (acc.OwnerId != currentUserId) {
                    acc.addError('ACC-401-VR-OWNER-DEL – You must be the Account owner to delete this record.');
                }
            }
        }
        
        when AFTER_UPDATE {
            // Collect IDs of accounts whose service was just changed to "Expired".
            Set<Id> expiredAccountIds = new Set<Id>();
            
            for (Account updatedAccount : Trigger.new) {
                if (
                    updatedAccount.serviceStatus__c == 'Expired' &&
                    updatedAccount.serviceStatus__c != Trigger.oldMap.get(updatedAccount.Id).serviceStatus__c
                ) {
                    expiredAccountIds.add(updatedAccount.Id);
                }
            }
            
            System.debug('Total Expired Accounts → ' + expiredAccountIds.size());
            
            // Proceed only if any accounts have newly expired.
            // Wrapped in an IF check instead of a hard "return;" to protect the multiplexed trigger thread.
            if (!expiredAccountIds.isEmpty()) {
                
                // Fetch all contacts related to expired accounts.
                Map<Id, Contact> contacts = new Map<Id, Contact>([
                    SELECT Id FROM Contact WHERE AccountId IN :expiredAccountIds
                ]);
                
                // Proceed only if any contacts are available
                if (!contacts.isEmpty()) {
                    
                    // Fetch all open cases of those contacts.
                    List<Case> casesToBeClosed = [
                        SELECT Id, Status FROM Case 
                        WHERE isClosed = false
                        AND ContactId IN :contacts.keySet()
                    ];
                    
                    // Close cases if found.
                    if (!casesToBeClosed.isEmpty()) {
                        for (Case cs : casesToBeClosed) {
                            cs.Status = 'Closed';
                        }
                        update casesToBeClosed;
                    }
                }
            }
        }
    }
}