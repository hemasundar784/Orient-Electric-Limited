// Test_OpportunityReminderScheduler.cls
@IsTest 
class Test_OpportunityReminderScheduler {
    
    @TestSetup 
    static void makeData() {
        Id salesRepProfileId = [SELECT Id FROM Profile WHERE Name='Sales Representative' LIMIT 1].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        
        User salesRep = new User(
            FirstName='Sales', LastName='Rep', Alias='srep',
            Email='s.rep@test.com', Username='s.rep@test.com',
            TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
            ProfileId=salesRepProfileId
        );
        User adminUser = new User(
            FirstName='Admin', LastName='User', Alias='admusr',
            Email='a.usr@test.com', Username='a.usr@test.com',
            TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
            ProfileId=adminProfileId
        );
        insert new List<User>{salesRep, adminUser};
        
        Account acc = new Account(Name='Reminder Test Acc', Phone='123', Fax='123', email__c='rem@test.com');
        insert acc;
        
        // Qualifying Opportunity (should be picked)
        Opportunity opp1 = new Opportunity(
            Name='Qualifying Opp', StageName='Prospecting', Amount=1000,
            CloseDate=Date.today().addDays(3), AccountId=acc.Id, OwnerId=salesRep.Id
        );
        // Non-qualifying (outside 7 days)
        Opportunity opp2 = new Opportunity(
            Name='Future Opp', StageName='Prospecting', Amount=2000,
            CloseDate=Date.today().addDays(15), AccountId=acc.Id, OwnerId=salesRep.Id
        );
        // Non-qualifying (wrong profile owner)
        Opportunity opp3 = new Opportunity(
            Name='Admin Opp', StageName='Prospecting', Amount=3000,
            CloseDate=Date.today().addDays(3), AccountId=acc.Id, OwnerId=adminUser.Id
        );
        insert new List<Opportunity>{opp1, opp2, opp3};
        
        opp1.CloseDate = Date.today().addDays(3);
        opp2.CloseDate = Date.today().addDays(15);
        opp3.CloseDate = Date.today().addDays(3);
        update new List<Opportunity> {opp1, opp2, opp3};
    }

    @IsTest 
    static void testExecuteSendsEmailForQualifiedOpportunities() {
        // FIXED: Using System.Test namespace to bypass the namespace conflict
        System.Test.startTest();
        new OpportunityReminderScheduler().execute(null);
        System.Test.stopTest();
    }
    
    @IsTest 
    static void testExecuteDoesNothingWhenNoQualifiedOpps() {
        delete [SELECT Id FROM Opportunity WHERE Name='Qualifying Opp' LIMIT 1];
        
        // FIXED: Using System.Test namespace to bypass the namespace conflict
        System.Test.startTest();
        new OpportunityReminderScheduler().execute(null);
        System.Test.stopTest();
        
        Assert.areEqual(0, Limits.getEmailInvocations(), 'No email should be sent when no qualifying opportunities exist.');
    }
    
    @IsTest 
    static void testScheduleJob() {
        // FIXED: Using System.Test namespace to bypass the namespace conflict
        System.Test.startTest();
        String jobId = OpportunityReminderScheduler.scheduleJob();
        System.Test.stopTest();

        Assert.isNotNull(jobId, 'Scheduler should return a valid Job Id.');

        CronTrigger ct = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id=:jobId LIMIT 1];
        Assert.areEqual(OpportunityReminderScheduler.CRON_EXPRESSION, ct.CronExpression, 'Cron expression mismatch.');
        Assert.areEqual('WAITING', ct.State, 'Scheduled job should be in WAITING state.');
    }
}