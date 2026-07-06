// Test_ContactTrigger.apxc
@IsTest class Test_ContactTrigger {
    @TestSetup static void makeData() {
        Account a1 = new Account(Name='TestA1', Phone='6321', Fax='6321', email__c='a1@ts.cm', totalContacts__c=0);
        Account a2 = new Account(Name='TestA2', Phone='6322', Fax='6322', email__c='a2@ts.cm', totalContacts__c=0);
        insert new List<Account>{a1,a2};
        List<Contact> cons = new List<Contact>();
        for(Integer i=0;i<=3;i++) cons.add(new Contact(LastName='Test_Con_'+i, AccountId=a1.Id, Phone='672'+i, Fax='672'+i));
        insert cons;
        delete [SELECT Id FROM Contact WHERE LastName='Test_Con_3' LIMIT 1];
    }

    @IsTest static void testBeforeInsertValidation() {
        Contact c = new Contact(LastName='Invalid Contact');
        try { 
            insert c; 
            Assert.fail('Insert should fail due to missing phone.'); 
        }
        catch(DmlException de) 
        { 
            Assert.isTrue(de.getMessage().contains('CON-400-VR-PHONE-REQ'), 'Validation error not as expected.'); 
        }
    }

    @IsTest static void testBeforeInsertFaxCopy() {
        Contact c1 = new Contact(LastName='NoFax', Phone='87691');
        Contact c2 = new Contact(LastName='WithFax', Phone='87691', Fax='45634');
        insert new List<Contact>{c1,c2};
        Contact afterC1 = [SELECT Fax FROM Contact WHERE Id=:c1.Id];
        Contact afterC2 = [SELECT Fax FROM Contact WHERE Id=:c2.Id];
        Assert.areEqual('87691', afterC1.Fax, 'Fax should be copied from Phone when blank.');
        Assert.areEqual('45634', afterC2.Fax, 'Fax should remain unchanged if already populated.');
    }

    @IsTest static void testAfterInsertAccountContactsCount() {
        Account a = [SELECT Id, totalContacts__c FROM Account WHERE email__c='a1@ts.cm' LIMIT 1];
        Integer beforeCnt = (Integer)a.totalContacts__c;
        insert new Contact(LastName='Rollup Insert', Phone='53345', AccountId=a.Id);
        Integer afterCnt = (Integer)[SELECT totalContacts__c FROM Account WHERE Id=:a.Id].totalContacts__c;
        Assert.areEqual(beforeCnt+1, afterCnt, 'Contact count should increment by 1 after insert.');
    }

    @IsTest static void testAfterUpdateAccountContactsCount() {
        Account a1 = [SELECT Id, totalContacts__c FROM Account WHERE email__c='a1@ts.cm' LIMIT 1];
        Account a2 = [SELECT Id, totalContacts__c FROM Account WHERE email__c='a2@ts.cm' LIMIT 1];
        Integer beforeA1 = (Integer)a1.totalContacts__c, beforeA2 = (Integer)a2.totalContacts__c;
        Contact c = [SELECT Id, AccountId FROM Contact WHERE AccountId=:a1.Id LIMIT 1];
        c.AccountId = a2.Id; update c;
        Integer afterA1 = (Integer)[SELECT totalContacts__c FROM Account WHERE Id=:a1.Id].totalContacts__c;
        Integer afterA2 = (Integer)[SELECT totalContacts__c FROM Account WHERE Id=:a2.Id].totalContacts__c;
        Assert.areEqual(beforeA1-1, afterA1, 'Contact count should decrement from old account.');
        Assert.areEqual(beforeA2+1, afterA2, 'Contact count should increment in new account.');
    }

    @IsTest static void testAfterDeleteAccountContactsCount() {
        Account a = [SELECT Id, totalContacts__c FROM Account WHERE email__c='a1@ts.cm' LIMIT 1];
        Integer beforeCnt = (Integer)a.totalContacts__c;
        Contact c = [SELECT Id FROM Contact WHERE AccountId=:a.Id LIMIT 1];
        delete c;
        Integer afterCnt = (Integer)[SELECT totalContacts__c FROM Account WHERE Id=:a.Id].totalContacts__c;
        Assert.areEqual(beforeCnt-1, afterCnt, 'Contact count should decrement by 1 after delete.');
    }

    @IsTest static void testAfterUndeleteAccountContactsCount() {
        Account a = [SELECT Id, totalContacts__c FROM Account WHERE email__c='a1@ts.cm' LIMIT 1];
        Integer beforeCnt = (Integer)a.totalContacts__c;
        Contact c = [SELECT Id FROM Contact WHERE AccountId=:a.Id AND IsDeleted=true LIMIT 1 ALL ROWS];
        undelete c;
        Integer afterCnt = (Integer)[SELECT totalContacts__c FROM Account WHERE Id=:a.Id].totalContacts__c;
        Assert.areEqual(beforeCnt+1, afterCnt, 'Contact count should increment by 1 after undelete.');
    }
}