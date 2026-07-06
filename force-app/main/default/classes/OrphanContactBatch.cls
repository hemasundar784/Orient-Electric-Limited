global class OrphanContactBatch implements Database.Batchable<SObject>, Database.Stateful{
    private Integer totalSuccessCount = 0; // Total successfully updated contacts count
    private List<String> failureDetailList = new List<String>();// Stores failure details (Id + Name + Error)
    private String defaultAccountId;
    // Default constructor (uses Custom Label)
    global OrphanContactBatch() { this.defaultAccountId = Label.defaultCustomerId;}
    // Parameterised constructor (inject Account Id)
    global OrphanContactBatch(String accountId) { this.defaultAccountId = accountId; }
    // START(): Returns orphan Contacts (no AccountId)
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO,'OrphanContactBatch.start() initiated.');
        // Default: empty result set => execute() will not run
        String soql = 'SELECT Id, Name FROM Contact WHERE Id = NULL';
        try{
            Id customerId = defaultAccountId; // throws StringException if invalid
            if([SELECT COUNT() FROM Account WHERE Id = :customerId]>0){
                soql = 'SELECT Id, Name FROM Contact WHERE AccountID = NULL';
            }else{
                System.debug(LoggingLevel.ERROR, 
                    'Configuration issue: No Account found for Id defined in label defaultCustomerId (' 
                    + customerId + '). Batch execution skipped.');
            }
        }catch(Exception se){
            System.debug(LoggingLevel.ERROR, 
                'Configuration issue: Invalid Account Id format provided ("' 
                + defaultAccountId + '"). Batch execution skipped.');
        }
        return Database.getQueryLocator(soql);
    }
    // EXECUTE(): Runs for each batch chunk. Assigns Default Account and performs partial update.
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        System.debug(LoggingLevel.INFO,
            'OrphanContactBatch.execute() processing scopeSize=' + scope.size()
        );
        // Assign default AccountId to each Contact
        for (Contact con : scope) {
            con.AccountId = defaultAccountId;
        }
        // Partial update
        List<Database.SaveResult> results = Database.update(scope, false);
        // Track outcomes
        for (Integer i = 0; i < results.size(); i++) {
            Contact currentContact = scope.get(i);
            if (results.get(i).isSuccess()) {
                totalSuccessCount++;
            } else {
                String errorMessage = results.get(i).getErrors().get(0).getMessage();
                failureDetailList.add('Id: ' + currentContact.Id +
                    ', Name: "' + currentContact.Name +'", Error: "' + errorMessage+'"');
            }
        }
    }
    // FINISH: Sends completion email with summary + failure details.
    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'OrphanContactBatch.finish() initiated.');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CompletedDate
            FROM AsyncApexJob WHERE Id = :bc.getJobId() LIMIT 1];
        String subject = 'Batch Summary - OrphanContactBatch (' + System.now().format() + ')';
        // Build email summary
        String body = 'Hello ' + UserInfo.getName() + ',\n\n' +
            'Batch Job Summary - OrphanContactBatch\n\n' +
            'Job Id: ' + job.Id + '\n Status: ' + job.Status + '\n' +
            'Batches Processed: ' + job.JobItemsProcessed + '/' + job.TotalJobItems + '\n' +
            'Total Records Updated: ' + totalSuccessCount + '\n' +
            'Total Records Failed: ' + failureDetailList.size() + '\n';
        if (job.CompletedDate != null)
            body += 'Completed On: ' + String.valueOf(job.CompletedDate) + '\n';
        if (!failureDetailList.isEmpty())
            body += '\n--- FAILURE DETAILS ---\n'+String.join(failureDetailList, '\n');
        body += '\n\nRegards,\nApex Batch\n';
        // Send email
        EmailUtility.sendTo(new List<String> {UserInfo.getUserEmail()}, subject, body);
    }
}