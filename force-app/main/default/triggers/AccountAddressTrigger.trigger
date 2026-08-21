trigger AccountAddressTrigger on Account (before insert, before update) {
    for (Account acc : Trigger.new) {
        // Check if Match Billing Address is true and Billing Postal Code is not null
        if (acc.Match_Billing_Address__c == true && acc.BillingPostalCode != null) {
            acc.ShippingPostalCode = acc.BillingPostalCode;
        }
    }
}