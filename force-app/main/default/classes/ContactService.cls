public class ContactService {

    public static void validateMandatoryPhone(List<Contact> contacts) {
        for (Contact insertingContact : contacts) {
            if (String.isBlank(insertingContact.Phone)) { 
                insertingContact.Phone.addError(
                    'CON-400-VR-PHONE-REQ – Enter a Phone number before saving this Contact.'
                );
            }
        }
    }

    public static void copyPhoneToFaxIfBlank(List<Contact> contacts) {
        for (Contact insertingContact : contacts) {
            if (String.isBlank(insertingContact.Fax) && String.isNotBlank(insertingContact.Phone)) {
                insertingContact.Fax = insertingContact.Phone;
            }
        }
    }

    public static void rollupContactCount(Set<Id> accountIds) {
        System.debug('ContactService.rollupContactCount('+accountIds+')');
        if (accountIds == null || accountIds.isEmpty()) return;
        
        Map<Id, Integer> countsByAccount = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) cnt FROM Contact
            WHERE AccountId IN :accountIds GROUP BY AccountId
        ]) {
            countsByAccount.put((Id)ar.get('accId'), (Integer)ar.get('cnt'));
        }
        
        List<Account> updates = new List<Account>();
        for (Id accId : accountIds) {
            updates.add(new Account(
                Id = accId,
                totalContacts__c = countsByAccount.containsKey(accId) ? countsByAccount.get(accId) : 0
            ));
        }
        System.debug('updates → '+updates);
        update updates;
    }
}