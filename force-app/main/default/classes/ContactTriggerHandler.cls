public class ContactTriggerHandler extends TriggerHandler {
    
    protected override void beforeInsert() {
        List<Contact> newContacts = (List<Contact>) Trigger.new;
        ContactService.validateMandatoryPhone(newContacts);
        ContactService.copyPhoneToFaxIfBlank(newContacts);
    }

    protected override void afterInsert() {
        ContactService.rollupContactCount(
            getImpactedAccountIds((List<Contact>)Trigger.new, null)
        );
    }

    protected override void afterUpdate() {
        ContactService.rollupContactCount(
            getImpactedAccountIds(
                (List<Contact>)Trigger.new,
                (Map<Id, Contact>)Trigger.oldMap
            )
        );
    }

    protected override void afterDelete() {
        ContactService.rollupContactCount(
            getImpactedAccountIds(null, (Map<Id, Contact>)Trigger.oldMap)
        );
    }

    protected override void afterUndelete() {
        ContactService.rollupContactCount(
            getImpactedAccountIds((List<Contact>)Trigger.new, null)
        );
    }

    private static Set<Id> getImpactedAccountIds(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        if (newList != null) {
            for (Contact c : newList) {
                if (c.AccountId != null) {
                    accIds.add(c.AccountId);
                }
            }
        }
        if (oldMap != null) {
            for (Contact oldC : oldMap.values()) {
                if (oldC.AccountId != null) {
                    accIds.add(oldC.AccountId);
                }
            }
        }
        return accIds;
    }
}