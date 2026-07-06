public class UserService {
    // Validation: For first-time deactivation, SupervisorId__c must be populated.
     public static void validateSupervisorRequiredForFirstDeactivation(
        List<User> newUsers,Map<Id, User> oldUsersMap ) {
        if (newUsers == null || newUsers.isEmpty() || oldUsersMap == null) return;
        for(User u: newUsers){
            User oldU = oldUsersMap.get(u.Id);
            Boolean isFirstDeactivation = (oldU.IsActive == true && u.IsActive == false);
            if (isFirstDeactivation && u.SupervisorId__c == null)
                u.supervisorId__c.addError(
                    'USR-401-VR-SUPV-REQ – Assign a Supervisor before deactivating this User for the first time.');
        }
    }
    // After Update: For first-time deactivation, transfer record ownership where needed.
    public static void handleFirstTimeDeactivations(
        List<User> newUsers, Map<Id, User> oldUsersMap) {
        if (newUsers == null || newUsers.isEmpty() || oldUsersMap == null) return;
        Map<Id, Id> deactivatedUserToSupervisor = new Map<Id, Id>();
        for (User u : newUsers) {
            User oldU = oldUsersMap.get(u.Id);
            Boolean firstTimeDeactivation = (oldU.IsActive == true && u.IsActive == false);
            if (firstTimeDeactivation && u.SupervisorId__c != null)
                deactivatedUserToSupervisor.put(u.Id, u.SupervisorId__c);
        }
        if (!deactivatedUserToSupervisor.isEmpty()) transferAccountOwnershipAsync(deactivatedUserToSupervisor);
    }
    // Async transfer using Future method.
    @future
    private static void transferAccountOwnershipAsync(Map<Id, Id> fromUserToSupervisor) {
        if (fromUserToSupervisor == null || fromUserToSupervisor.isEmpty()) return;
        // Fetch accounts owned by deactivated users
        List<Account> accountsToTransfer = [
            SELECT Id, OwnerId FROM Account
            WHERE OwnerId IN :fromUserToSupervisor.keySet()
        ];
        if (accountsToTransfer.isEmpty()) return;
        // Reassign ownership to supervisor
        for (Account a : accountsToTransfer)
            a.OwnerId = fromUserToSupervisor.get(a.OwnerId);
        // Perform partial update
        List<Database.SaveResult> results = Database.update(accountsToTransfer, false);
        // Collect failures
        List<String> errorMessages = new List<String>();
        for (Integer i = 0; i < results.size(); i++) {
            if (!results.get(i).isSuccess()) {
                for (Database.Error err : results.get(i).getErrors()) {
                    errorMessages.add(
                        'Account Id: ' + accountsToTransfer.get(i).Id +' | Error: ' + err.getMessage()
                    );
                }
            }
        }
        // Notify only if there were failures
        if (!errorMessages.isEmpty())
            notifyOwnershipTransferFailure(String.join(errorMessages, '\n'));
    }
    private static void notifyOwnershipTransferFailure(String errorDetails) {
        List<String> toAddresses = new List<String>{ UserInfo.getUserEmail() };
        String subject = 'FUTURE: Account ownership transfer encountered errors';
        String body =
            'Dear Admin,\n\n' +
            'Some Account ownership transfers failed during User deactivation.\n\n' +
            'Details:\n--------\n' + errorDetails +
            '\n\n--\nSalesforce Automation';
        // Reuse Email Utility to send an email.
        EmailUtility.sendTo(toAddresses, subject, body);
    }
}