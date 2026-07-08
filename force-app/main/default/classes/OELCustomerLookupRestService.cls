// Act as a Senior Salesforce Architect. Write a production-ready Apex REST inbound service class according to the following strict specifications:



// 1. SERVICE ANNOTATIONS & CONFIGURATION:

// - Annotate the class with @RestResource(urlMapping='/oel/sap/v1/customers/*').

// - Use the 'public with sharing' access modifier (ensure it can be safely globally exposed if needed).

// - Name the class 'OELCustomerLookupRestService'.



// 2. DATA TRANSFER OBJECTS (DTOs):

// Define explicit, lightweight, serialisable inner wrapper classes to map data structures cleanly without exposing raw SObjects:

// - 'APIResponse': Contains Boolean 'success', String 'message', and 'OELAccount data'.

// - 'OELAccount': Contains String fields for id, name, phone, fax, email, type, industry, rating, and a List<OELContact> initialized to an empty list.

// - 'OELContact': Contains String fields for id, name, phone, mobile, email, title.



// 3. ENDPOINT LOGIC (@HttpGet):

// - Implement an explicit @HttpGet global static void method named 'doGetCustomerDetails'.

// - Extract the unique customer ID string directly from the last segment of the incoming request URI (req.requestURI.substringAfterLast('/')).

// - Perform input validation: If the ID is blank, immediately return an HTTP 400 Bad Request with a message stating the ID is required.



// 4. DATABASE QUERIES & MAPPING:

// - Query the Account record where a custom field 'uniqueId__c' matches the extracted ID. Retrieve Id, Name, Phone, Fax, email__c, Type, Industry, and Rating.

// - Query all related child Contacts using an inner relationship subquery or a secondary relational query. Retrieve Id, Name, Phone, MobilePhone, Email, and Title.

// - Map the SObject fields cleanly into your DTO inner wrapper instances.



// 5. REST RESPONSE & EXCEPTION HANDLING:

// - Wrap your database execution code block tightly inside explicit catch filters.

// - If a 'QueryException' hits (record not found), return an HTTP 404 Status with an explicit 'Customer record not found' error code message.

// - Catch general 'Exception' errors to trap unexpected runtime failures and return an HTTP 500 Internal Server Error status containing the system message details.

// - Build a generic private helper function named 'sendResponse' that instantiates the 'APIResponse' class, sets the status code on RestContext.response, and serializes the body payload cleanly using JSON.serializePretty with null-suppression turned on (true) to strip out empty fields.


@RestResource(urlMapping='/oel/sap/v1/customers/*')
global with sharing class OELCustomerLookupRestService {

    // ==========================================
    // DATA TRANSFER OBJECTS (DTOs)
    // ==========================================
    global class APIResponse {
        public Boolean success;
        public String message;
        public OELAccount data;

        public APIResponse(Boolean success, String message, OELAccount data) {
            this.success = success;
            this.message = message;
            this.data = data;
        }
    }

    global class OELAccount {
        public String id;
        public String name;
        public String phone;
        public String fax;
        public String email;
        public String type;
        public String industry;
        public String rating;
        public List<OELContact> contacts;

        public OELAccount() {
            this.contacts = new List<OELContact>();
        }
    }

    global class OELContact {
        public String id;
        public String name;
        public String phone;
        public String mobile;
        public String email;
        public String title;
    }

    // ==========================================
    // ENDPOINT LOGIC
    // ==========================================
    @HttpGet
    global static void doGetCustomerDetails() {
        RestRequest req = RestContext.request;
        
        try {
            // 1. Extract unique ID from request URI
            String uniqueId = req.requestURI.substringAfterLast('/');
            
            // 2. Input Validation
            if (String.isBlank(uniqueId) || uniqueId == 'customers') {
                sendResponse(400, false, 'The customer uniqueId parameter is required in the URL path.', null);
                return;
            }

            // 3. Database Query (Account with Child Contacts relationship subquery)
            Account accRecord = [
                SELECT Id, Name, Phone, Fax, email__c, Type, Industry, Rating,
                       (SELECT Id, Name, Phone, MobilePhone, Email, Title FROM Contacts)
                FROM Account 
                WHERE uniqueId__c = :uniqueId 
                LIMIT 1
            ];

            // 4. Map SObjects to DTO Architecture
            OELAccount dtoAccount = new OELAccount();
            dtoAccount.id = accRecord.Id;
            dtoAccount.name = accRecord.Name;
            dtoAccount.phone = accRecord.Phone;
            dtoAccount.fax = accRecord.Fax;
            dtoAccount.email = accRecord.email__c;
            dtoAccount.type = accRecord.Type;
            dtoAccount.industry = accRecord.Industry;
            dtoAccount.rating = accRecord.Rating;

            for (Contact con : accRecord.Contacts) {
                OELContact dtoContact = new OELContact();
                dtoContact.id = con.Id;
                dtoContact.name = con.Name;
                dtoContact.phone = con.Phone;
                dtoContact.mobile = con.MobilePhone;
                dtoContact.email = con.Email;
                dtoContact.title = con.Title;
                dtoAccount.contacts.add(dtoContact);
            }

            // 5. Return Successful Payload
            sendResponse(200, true, 'Customer lookup successful.', dtoAccount);

        } catch (QueryException qe) {
            // Explicitly handles record missing variations
            sendResponse(404, false, 'Customer record not found matching the provided uniqueId.', null);
        } catch (Exception ex) {
            // Catches fallback generic platform exceptions securely
            sendResponse(500, false, 'Internal Server Error: ' + ex.getMessage(), null);
        }
    }

    // ==========================================
    // PRIVATE HELPER FRAMEWORK
    // ==========================================
    private static void sendResponse(Integer statusCode, Boolean success, String message, OELAccount data) {
        RestResponse res = RestContext.response;
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        // Set Headers and Status Codes
        res.statusCode = statusCode;
        res.addHeader('Content-Type', 'application/json');

        // Instantiate and Pack DTO
        APIResponse responseWrapper = new APIResponse(success, message, data);
        // Serialize pretty with null-suppression turned ON (true)
        res.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper, true));
    }
}