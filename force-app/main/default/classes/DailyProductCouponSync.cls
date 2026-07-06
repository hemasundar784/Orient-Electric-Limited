/** Daily Product → Coupon Linking (Batch + Schedulable) */
//DailyProductCouponSync.apxc
global class DailyProductCouponSync implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private Integer totalProductsUpdated = 0; // Total updated products
    // Name of the scheduled job (used when scheduling or aborting)
    public static final String JOB_NAME = 'Daily Product Coupon Sync';
    // Cron Expression → 9:00 AM, Monday–Friday
    public static final String CRON_EXPRESSION = '0 28 16 ? * MON-FRI *'; 
    // Batch runs on Products coming from external upsert
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id, offerId__c, couponId__c FROM Product2 WHERE offerId__c != NULL
        ]);
    }
    global void execute(Database.BatchableContext bc, List<Product2> scope) {
        // Collect Offer Ids from Products
        Set<String> offerIds = new Set<String>();
        for (Product2 p : scope) offerIds.add(p.offerId__c);
        // Map offerId (code__c) → CouponCode__c.Id
        Map<String, Id> codeToCouponId = new Map<String, Id>();
        for (CouponCode__c c : [SELECT Id, code__c FROM CouponCode__c WHERE code__c IN :offerIds])
            codeToCouponId.put(c.code__c, c.Id);
        // Update Products
        for (Product2 p : scope) p.couponId__c = codeToCouponId.get(p.offerId__c);
        update scope;
        totalProductsUpdated += scope.size();
    }
    global void finish(Database.BatchableContext bc){
        String subject = 'Batch Summary - DailyProductCouponSync (' + System.now().format() + ')';
        String body = 'Dear '+UserInfo.getName()+'\n\n\tTotal Products Linked: ' + totalProductsUpdated+
        '\n\n----------\nRegards,\nBatch Apex,\nSalesforce.';
        List<String> toAddresses = new List<String>{UserInfo.getUserEmail()};
        EmailUtility.sendTo(toAddresses, subject, body);
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new DailyProductCouponSync(), 1);
    }
    public static String scheduleJob() {
        return System.schedule(JOB_NAME, CRON_EXPRESSION, new DailyProductCouponSync());
    }
}