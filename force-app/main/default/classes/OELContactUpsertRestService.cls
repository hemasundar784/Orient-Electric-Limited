// User Story:
// -----------
// As Orient Electric Product Owner, 
//   We want our SAP system to send contact details to Salesforce through a POST API, 
//   so that a new contact record can be created/updated directly in Salesforce when a new person is onboarded in SAP.
//   This helps us ensure that customer-facing teams using Salesforce always have the latest contact data that’s being maintained in SAP, 
//   without requiring manual duplication or syncing.
  
//OELContactUpsertRestService.apxc
@RestResource(urlMapping = '/oel/sap/v1/contacts')
global class OELContactUpsertRestService {
    // Standard API response wrapper used for all outcomes
    global class APIResponse {
        public Boolean success;
        public String message;
    }
    // Phone structure from SAP payload
    private class ContactPhones {
        public String phone, mobile, home, fax;
    }
    // Main request payload wrapper (maps 1:1 with SAP JSON)
    private class ContactWrapper {
        public String id, firstname, lastname, title, email, department, source;
        public ContactPhones phones;
    }
    /**
     * POST endpoint used by SAP to create/update a Contact in Salesforce.
     * Uses uniqueId__c as external Id for upsert.
     */
    @HttpPost
    global static void upsertContact() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            // Basic guard: body must be present
            if (req.requestBody == null) {
                sendResponse(res, 400, 'ERR-CONT-400: Request body is empty.', false);
                return;
            }
            // Deserialize JSON into wrapper
            ContactWrapper data = (ContactWrapper)
                JSON.deserialize(req.requestBody.toString(), ContactWrapper.class);
            // Basic validation: external Id is mandatory for integration
            if (String.isBlank(data.id)) {
                sendResponse(res, 400, 'ERR-CONT-400: Contact external id (id) is required.', false);
                return;
            }
            // Build Contact record to upsert via external Id
            Contact con = new Contact(
                uniqueId__c = data.id, FirstName = data.firstname, LastName = data.lastname,
                Title = data.title, Email = data.email, Department = data.department,
                LeadSource = data.source, Phone = data.phones.phone, Fax = data.phones.fax,
                MobilePhone = data.phones.mobile, HomePhone = data.phones.home
            );
            // Upsert by external Id; don't allow partial success flag from DML
            Database.UpsertResult result = Database.upsert(con, Contact.uniqueId__c, true);
            if(result.isSuccess()){
                String fullName = ((data.firstname != null ? data.firstname + ' ' : '') + data.lastname).trim();
                String message = 'Contact ' + fullName + ' ' +
                                    (result.isCreated() ? 'created' : 'updated') +
                                    ' successfully.';
                sendResponse(res, 200, message, true);
            }else{
                // Defensive: if success=false but no exception thrown (edge case)
                sendResponse(res, 400, 'ERR-CONT-400: Upsert failed without explicit DML exception.', false);
            }
        }catch(DmlException de){
            // Map DML errors to business error codes + HTTP 400 (Bad Request)
            String raw = de.getMessage();
            String message;
            if(raw.contains('CON-400-VR-PHONE-REQ')){
                message = '(CON-400-VR-PHONE-REQ): Phone number cannot be empty.';
            }else if (raw.contains('REQUIRED_FIELD_MISSING')) {
                message = '(CON-400-REQ-FIELD-MISSING): Required Keys Missing (LastName)).';
            }else if (raw.contains('INVALID_EMAIL_ADDRESS')) {
                message = '(CON-400-EMAIL-FORMAT-ERR): Email is not in email format.';
            }else {
                message = 'Unknown DML Error: ' + raw;
            }
            sendResponse(res, 400, message, false);
        }catch(Exception e){
            // Any unexpected error → 500 Internal Server Error
            sendResponse(res, 500, 'ERR-CONT-500: Unexpected Error. Details: ' + e.getMessage(), false);
        }
    }
    // Helper to standardize HTTP status + JSON response structure
    private static void sendResponse(RestResponse res, Integer statusCode, String message, Boolean success) {
        APIResponse api = new APIResponse();
        api.success = success;
        api.message = message;
        res.statusCode = statusCode;
        res.responseBody = Blob.valueOf(JSON.serializePretty(api, true));
    }
}