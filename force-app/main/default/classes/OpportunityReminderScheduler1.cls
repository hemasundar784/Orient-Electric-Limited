global class OpportunityReminderScheduler1 implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Configuration kept inline (harder to maintain/change later)
        final String SALES_REP_PROFILE_NAME = 'Sales Representative';
        Date today = System.today();
        Date endDate = today.addDays(7);
        // 1) Query data
        List<Opportunity> opps = [
            SELECT Id, Name, StageName, Amount, CloseDate,
                   OwnerId, Owner.Name, Owner.Email
            FROM Opportunity
            WHERE IsClosed = false AND CloseDate >= :today AND CloseDate <= :endDate
              AND Owner.Profile.Name = :SALES_REP_PROFILE_NAME
            ORDER BY OwnerId, CloseDate
        ];
        if (opps.isEmpty()) return;
        // 2) Group Opportunities by OwnerId
        Map<Id, List<Opportunity>> oppsByOwner = new Map<Id, List<Opportunity>>();
        for (Opportunity o : opps) {
            if (!oppsByOwner.containsKey(o.OwnerId)) {
                oppsByOwner.put(o.OwnerId, new List<Opportunity>());
            }
            oppsByOwner.get(o.OwnerId).add(o);
        }
        // 3) Build emails (one per owner)
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Id ownerId : oppsByOwner.keySet()) {
            List<Opportunity> ownerOpps = oppsByOwner.get(ownerId);
            if (ownerOpps == null || ownerOpps.isEmpty()) continue;
            // Pick first record only to read owner details
            Opportunity sample = ownerOpps[0];
            // 4) Build email subject + body
            String subject = 'OPP-REMINDER – Opportunities Closing in Next 7 Days (' +
                System.today().format() + ')';
            String body =
                'Hello ' + sample.Owner.Name + ',\n\n' +
                'Below are your open Opportunities closing within the next 7 days:\n\n';
            // 5) Append Opportunity lines
            for (Opportunity o : ownerOpps) {
                body +=
                    '--------------------------------------------------\n' +
                    'Opportunity : ' + o.Name + '\n' + 'Close Date  : ' + o.CloseDate.format() + '\n' +
                    'Amount      : ' + o.Amount + '\n' + 'Stage       : ' + o.StageName + '\n\n';
            }
            body +=
                '\nPlease review and take the necessary action.\n\n Regards,\nSalesforce Scheduler';
            // 6) Create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ sample.Owner.Email });
            email.setSubject(subject); email.setPlainTextBody(body);
            emails.add(email);
        }
        // 7) Send all emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}