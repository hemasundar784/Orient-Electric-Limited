@isTest
private class DataTableControllerTest {
    /**
     * Test data setup
     */
    @testSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 15; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Phone = '555-000' + i,
                BillingCity = 'Test City ' + i
            ));
        }
        insert accounts;
    }

    /**
     * Test getRecords with valid parameters
     */
    @isTest
    static void testGetRecordsSuccess() {
        Test.startTest();
        List<Map<String, Object>> results = DataTableController.getRecords(
            'Account',
            new List<String>{'Id', 'Name', 'Phone'},
            null
        );
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null');
        Assert.isTrue(results.size() >= 15, 'Should return at least 15 test accounts');

        // Verify all expected fields are present
        for (Map<String, Object> record : results) {
            Assert.isTrue(record.containsKey('Id'), 'Record should contain Id field');
            Assert.isTrue(record.containsKey('Name'), 'Record should contain Name field');
            Assert.isTrue(record.containsKey('Phone'), 'Record should contain Phone field');
        }
    }

    /**
     * Test getRecords with null object name
     */
    @isTest
    static void testGetRecordsNullObjectName() {
        Test.startTest();
        try {
            DataTableController.getRecords(
                null,
                new List<String>{'Id', 'Name'},
                null
            );
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Object name is required'), 'Expected error message');
        }
        Test.stopTest();
    }

    /**
     * Test getRecords with empty field list
     */
    @isTest
    static void testGetRecordsEmptyFieldList() {
        Test.startTest();
        try {
            DataTableController.getRecords(
                'Account',
                new List<String>(),
                null
            );
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Field list cannot be empty'), 'Expected error message');
        }
        Test.stopTest();
    }

    /**
     * Test getRecords with invalid object name
     */
    @isTest
    static void testGetRecordsInvalidObjectName() {
        Test.startTest();
        try {
            DataTableController.getRecords(
                'InvalidObject',
                new List<String>{'Id', 'Name'},
                null
            );
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Invalid object name'), 'Expected error message');
        }
        Test.stopTest();
    }

    /**
     * Test getRecords with invalid field name
     */
    @isTest
    static void testGetRecordsInvalidFieldName() {
        Test.startTest();
        try {
            DataTableController.getRecords(
                'Account',
                new List<String>{'Id', 'InvalidField__c'},
                null
            );
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('does not exist'), 'Expected error message');
        }
        Test.stopTest();
    }

    /**
     * Test updateRecords with valid data
     */
    @isTest
    static void testUpdateRecordsSuccess() {
        // Get test account
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];

        // Create update map
        Map<String, Object> updateMap = new Map<String, Object>();
        updateMap.put('Id', testAccount.Id);
        updateMap.put('Name', 'Updated Account Name');
        updateMap.put('Phone', '555-9999');

        Test.startTest();
        // FIXED: Using wrapper type list instead of Database.SaveResult
        List<DataTableController.SaveResultWrapper> results = DataTableController.updateRecords(
            'Account',
            new List<Map<String, Object>>{updateMap}
        );
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null');
        // FIXED: Reading from wrapper class boolean property
        Assert.isTrue(results.get(0).isSuccess, 'Update should be successful');

        // Verify the update
        Account updatedAccount = [SELECT Id, Name, Phone FROM Account WHERE Id = :testAccount.Id];
        Assert.areEqual('Updated Account Name', updatedAccount.Name, 'Name should be updated');
        Assert.areEqual('555-9999', updatedAccount.Phone, 'Phone should be updated');
    }

    /**
     * Test updateRecords with null object name
     */
    @isTest
    static void testUpdateRecordsNullObjectName() {
        Test.startTest();
        try {
            DataTableController.updateRecords(
                null,
                new List<Map<String, Object>>()
            );
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Object name is required'), 'Expected error message');
        }
        Test.stopTest();
    }

    /**
     * Test updateRecords with empty records list
     */
    @isTest
    static void testUpdateRecordsEmptyRecordsList() {
        Test.startTest();
        try {
            DataTableController.updateRecords(
                'Account',
                new List<Map<String, Object>>()
            );
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Records list cannot be empty'), 'Expected error message');
        }
        Test.stopTest();
    }

    /**
     * Test updateRecords with multiple records
     */
    @isTest
    static void testUpdateMultipleRecords() {
        List<Account> testAccounts = [SELECT Id, Name FROM Account LIMIT 2];

        List<Map<String, Object>> updateMaps = new List<Map<String, Object>>();
        for (Integer i = 0; i < testAccounts.size(); i++) {
            Map<String, Object> updateMap = new Map<String, Object>();
            updateMap.put('Id', testAccounts[i].Id);
            updateMap.put('Name', 'Updated Account ' + i);
            updateMaps.add(updateMap);
        }

        Test.startTest();
        // FIXED: Using wrapper type list instead of Database.SaveResult
        List<DataTableController.SaveResultWrapper> results = DataTableController.updateRecords(
            'Account',
            updateMaps
        );
        Test.stopTest();

        Assert.isTrue(results.size() >= 2, 'Should return results for both records');
        for (DataTableController.SaveResultWrapper result : results) {
            // FIXED: Reading from wrapper class boolean property
            Assert.isTrue(result.isSuccess, 'All updates should be successful');
        }
    }

    /**
     * Test deleteRecord with valid record ID
     */
    @isTest
    static void testDeleteRecordSuccess() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        String recordId = testAccount.Id;

        Test.startTest();
        Boolean result = DataTableController.deleteRecord(recordId);
        Test.stopTest();

        Assert.isTrue(result, 'Delete should return true');

        // Verify the record is deleted
        List<Account> deletedAccounts = [SELECT Id FROM Account WHERE Id = :recordId];
        Assert.isTrue(deletedAccounts.isEmpty(), 'Account should be deleted');
    }

    /**
     * Test deleteRecord with null record ID
     */
    @isTest
    static void testDeleteRecordNullId() {
        Test.startTest();
        try {
            DataTableController.deleteRecord(null);
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Record ID is required'), 'Expected error message');
        }
        Test.stopTest();
    }

    /**
     * Test deleteRecord with blank record ID
     */
    @isTest
    static void testDeleteRecordBlankId() {
        Test.startTest();
        try {
            // FIXED: Fully completed your cut-off test method execution
            DataTableController.deleteRecord('   ');
            Assert.fail('Should throw AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Record ID is required'), 'Expected error message');
        }
        Test.stopTest();
    }
}
