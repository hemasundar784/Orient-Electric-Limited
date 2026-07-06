/* Schedules daily reminder emails for Opportunities
closing within the next 7 days for Sales Representatives. */
global class OpportunityReminderScheduler implements Schedulable{
    // Configuration Section
    // Name of the scheduled job (used when scheduling or aborting)
    public static final String JOB_NAME = 'Daily Opportunity Reminder';
    // Cron Expression → 9:00 AM, Monday–Friday
    public static final String CRON_EXPRESSION = '0 0 9 ? * MON-FRI *'; 
    private static final String SALES_REP_PROFILE_NAME = 'Sales Representative';
    /* Fetches open Opportunities closing within the next 7 days
    that belong to users with the Sales Representative profile. */
    private static List<Opportunity> fetchUpcomingOpenOpps() {
        Date today = System.today();
        Date endDate = today.addDays(7);
        return [
            SELECT Id, Name, StageName, Amount, CloseDate,
                   OwnerId, Owner.Name, Owner.Email FROM Opportunity
            WHERE IsClosed = false AND CloseDate >= :today AND CloseDate <= :endDate
            AND Owner.Profile.Name = :SALES_REP_PROFILE_NAME
            ORDER BY OwnerId, CloseDate
        ];
    }
    /* Groups Opportunities by OwnerId.
    This ensures one consolidated email per owner
    instead of sending multiple individual emails. */
    private static Map<Id, List<Opportunity>> groupByOwner(List<Opportunity> opps) {
        Map<Id, List<Opportunity>> byOwner = new Map<Id, List<Opportunity>>();
        for (Opportunity o : opps) {
            if (!byOwner.containsKey(o.OwnerId)) byOwner.put(o.OwnerId, new List<Opportunity>());
            byOwner.get(o.OwnerId).add(o);
        }
        return byOwner;
    }
    /* Formats Opportunity details into a structured
    plain-text block for email readability. */
    private static String formatOpportunityLines(List<Opportunity> opps) {
        String lines = '';
        for (Opportunity o : opps) {
            lines +='--------------------------------------------------\n' +
                'Opportunity : ' + o.Name + '\nClose Date  : ' + o.CloseDate.format() + '\n' +
                'Amount      : ' + o.Amount + '\nStage       : ' + o.StageName + '\n\n';
        }
        return lines;
    }
    /* Builds a single email message for an Opportunity owner.
    The email contains all Opportunities grouped for that owner. */
    private static Messaging.SingleEmailMessage buildOwnerEmail(
        String ownerName, String ownerEmail, List<Opportunity> ownerOpps) {
        String subject = 'OPP-REMINDER – Opportunities Closing in Next 7 Days (' +
            System.today().format() + ')';
        String body = 'Hello ' + ownerName + ',\n\n' +
            'Below are your open Opportunities closing within the next 7 days:\n\n' +
            formatOpportunityLines(ownerOpps) +
            '\nPlease review and take the necessary action.\n\n Regards,\nSalesforce Scheduler';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ ownerEmail });
        email.setSubject(subject); email.setPlainTextBody(body);
        return email;
    }
    /* Sends one consolidated reminder email per owner.
    All emails are sent in a single Messaging.sendEmail() call
    to stay bulk-safe and within governor limits. */
    private static void sendOwnerDigests(Map<Id, List<Opportunity>> oppsByOwner) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Id ownerId : oppsByOwner.keySet()) {
            List<Opportunity> ownerOpps = oppsByOwner.get(ownerId);
            if (ownerOpps == null || ownerOpps.isEmpty()) continue;
            Opportunity sample = ownerOpps.get(0);
            emails.add( buildOwnerEmail(sample.Owner.Name, sample.Owner.Email, ownerOpps));
        }
        if (!emails.isEmpty()) Messaging.sendEmail(emails);
    }
    // Scheduled Entry Point
    /* Entry point executed by the Salesforce Scheduler
    according to the defined CRON expression. */
    global void execute(SchedulableContext sc) {
        List<Opportunity> opps = fetchUpcomingOpenOpps();
        if (opps.isEmpty()) return;
        Map<Id, List<Opportunity>> oppsByOwner = groupByOwner(opps);
        sendOwnerDigests(oppsByOwner);
    }
    // Public Scheduler Helper
    /* Schedules the job using predefined job name and CRON expression.
    Returns the CronTrigger Id of the scheduled job. */
    public static String scheduleJob() {
        return System.schedule(JOB_NAME, CRON_EXPRESSION, new OpportunityReminderScheduler());
    }
}