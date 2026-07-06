// EmailUtility.apxc
public class EmailUtility {
    
    /**
     * Sends a basic text/HTML email to a list of recipients
     */
    public static void sendTo(List<String> toAddresses, String subject, String body) {
        // 1. Guard against empty execution drops
        if (toAddresses == null || toAddresses.isEmpty()) {
            System.debug('EmailUtility: No recipient email addresses provided.');
            return;
        }
        
        // 2. Instantiate the core Salesforce outbound email contract handler
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // 3. Map parameters to the systemic payload fields
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body); // or mail.setHtmlBody(body);
        
        // 4. Dispatch the payload through the platform outbox system
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // 5. Audit the transaction dispatch status in the execution log trace
        if (results[0].isSuccess()) {
            System.debug('EmailUtility: Notification dispatched successfully.');
        } else {
            System.debug('EmailUtility failed to send: ' + results[0].getErrors()[0].getMessage());
        }
    }
}