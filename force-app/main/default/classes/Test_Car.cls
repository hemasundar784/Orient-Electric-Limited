@IsTest class Test_Car {
    @IsTest static void testDriveMethod() {
        // Create test object
        Car c = new Car();
        c.brand = 'BMW'; c.color = 'Black';
        c.noOfAirbags = 4; c.hasSunroof = true;
        // Execute method
        c.drive();
    }
    @IsTest static void testParkMethod() {
        // Create test object
        Car c = new Car();
        c.brand = 'Audi'; c.color = 'White';
        c.noOfAirbags = 6; c.hasSunroof = false;
        // Execute method
        c.park();
    }
    @IsTest
    static void testShowSpecsMethod() {
        // Create test object
        Car c = new Car();
        c.brand = 'Mercedes'; c.color = 'Silver';
        c.noOfAirbags = 8; c.hasSunroof = true;
        // Execute method
        c.showSpecifications();
    }
}