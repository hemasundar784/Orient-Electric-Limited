// As an OEL Salesforce System Administrator,
//   I want Salesforce to automatically retrieve contact data from an external GitHub JSON source on weekdays at 10:30 PM,
//   so that our contact master stays continuously updated without manual intervention, 
//   improving data accuracy across SAP and Salesforce systems.

//OELContactDailyContactSync.apxc
global with sharing class OELContactDailyContactSync implements Schedulable, Database.AllowsCallouts {
    // JOB Variables
    public static final String JOB_NAME = 'OEL_Weekday_ContactSync_Job';
    public static final String CRON_EXPRESSION = '0 30 22 ? * MON-FRI';
    // JOB Running Method
    public static Id scheduleJob() {
      return System.schedule(JOB_NAME, CRON_EXPRESSION, new OELContactDailyContactSync());
    }
    // Root payload wrapper: { "contacts": [ ... ] }
    private class ContactsPayload {
        public List<ContactWrapper> contacts;
    }
    // Single contact wrapper (matches JSON structure)
    private class ContactWrapper {
        public String id, firstname, lastname, title, email, department, source;
        public ContactPhones phones;
    }
    // Phone wrapper for nested "phones" node
    private class ContactPhones {
        public String phone, mobile, home, fax;
    }

    // Entry point for Scheduled Apex
    global void execute(SchedulableContext sc) {
        syncContactsFromEndpoint();
    }

    // Core sync logic: callout + deserialize + upsert
    @future(callout=true)
    private static void syncContactsFromEndpoint() {
        String endpoint = 'https://raw.githubusercontent.com/swhizzsfdc/oelIntegrationData/refs/heads/main/contacts.json';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');

        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            System.debug('Contact sync callout failed: ' + e.getMessage());
            return;
        }

        if (res.getStatusCode() != 200) {
            System.debug('Contact sync failed. HTTP ' + res.getStatusCode() + ' - ' + res.getStatus());
            System.debug('Body: ' + res.getBody());
            return;
        }

        ContactsPayload payload;
        try {
            payload = (ContactsPayload) JSON.deserialize(res.getBody(), ContactsPayload.class);
        } catch (Exception e) {
            System.debug('Contact sync JSON parse failed: ' + e.getMessage());
            System.debug('Raw body: ' + res.getBody());
            return;
        }

        if (payload == null || payload.contacts == null || payload.contacts.isEmpty()) {
            System.debug('Contact sync: no contacts found in payload.');
            return;
        }

        List<Contact> toUpsert = new List<Contact>();
        for (ContactWrapper cw : payload.contacts) {
            if (cw == null || String.isBlank(cw.id)) {
                continue; // skip invalid rows
            }
            Contact c = new Contact(
                uniqueId__c = cw.id,
                FirstName     = cw.firstname,
                LastName      = cw.lastname,
                Title         = cw.title,
                Email         = cw.email,
                Department    = cw.department,
                LeadSource    = cw.source
            );
            if (cw.phones != null) {
                c.Phone       = cw.phones.phone;
                c.MobilePhone = cw.phones.mobile;
                c.HomePhone   = cw.phones.home;
                c.Fax         = cw.phones.fax;
            }
            toUpsert.add(c);
        }

        if (toUpsert.isEmpty()) {
            System.debug('Contact sync: no valid contacts to upsert.');
            return;
        }

        Database.UpsertResult[] results = Database.upsert(toUpsert, Contact.uniqueId__c, false);
        for (Integer i = 0; i < results.size(); i++) {
            Database.UpsertResult r = results[i];
            if (!r.isSuccess()) {
                for (Database.Error err : r.getErrors()) {
                    System.debug(
                        'Contact sync DML error for extId ' + toUpsert[i].uniqueId__c +
                        ': ' + err.getStatusCode() + ' - ' + err.getMessage()
                    );
                }
            } else {
                System.debug(
                    'Contact sync: extId ' + toUpsert[i].uniqueId__c +
                    (r.isCreated() ? ' created.' : ' updated.')
                );
            }
        }
    }
}
