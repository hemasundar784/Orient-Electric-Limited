@IsTest class Test_UserCredentials {
    @IsTest static void testInitialization() {
        // Create object without setting values
        UserCredentials user = new UserCredentials();
        // Accessing private members directly using @testVisible (allowed only in test context)
        Assert.isNull(user.loginName, 'Login name should be null by default.');
        Assert.isNull(user.loginPassword, 'Login password should be null by default.');
    }
    @IsTest static void testSetters() {
        // Create object and prepare test data
        UserCredentials user = new UserCredentials();
        String username = 'Bob Marley'; String password = 'Dummy@123';
        // Set values using setter methods
        user.setLoginName(username); user.setLoginPassword(password);
        // Verifying private members directly because they are marked as @testVisible
        Assert.isNotNull(user.loginName, 'Login name should not be null after setting value.');
        Assert.isNotNull(user.loginPassword, 'Login password should not be null after setting value.');
        Assert.areEqual(username, user.loginName, 'Login name should match value passed to setter.');
        Assert.areEqual(password, user.loginPassword, 'Login password should match value passed to setter.');
    }
    @IsTest static void testGetters() {
        // Create object and set values first
        UserCredentials user = new UserCredentials();
        String username = 'Bob Marley'; String password = 'Dummy@123';
        user.setLoginName(username); user.setLoginPassword(password);
        // Retrieve values using getter methods (standard encapsulation access)
        String actualUsername = user.getLoginName(); String actualPassword = user.getLoginPassword();
        // Verify getters return correct values
        Assert.isNotNull(actualUsername, 'Getter should return a non-null login name.');
        Assert.isNotNull(actualPassword, 'Getter should return a non-null login password.');
        Assert.areEqual(username, actualUsername, 'Getter should return correct login name.');
        Assert.areEqual(password, actualPassword, 'Getter should return correct login password.');
    }
}