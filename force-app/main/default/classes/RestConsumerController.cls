/* ============================================================================
SALESFORCE REST INTEGRATION — END TO END (SERVICE PROVIDER ↔ SERVICE CONSUMER)

Provider Org  : DEVSB
Consumer Org  : QASB
Authentication: OAuth 2.0 (External Client App + Auth Provider)
Callouts      : Named Credential (Named Principal)
APIs Used     : GET  /oel/sap/v1/customers/{id}
                POST /oel/sap/v1/contacts
============================================================================ */

/* ========================= AUTHENTICATION FLOW =============================

STEP 1 — DEVSB (Provider): Integration Profile + User
- Account → Read, View All
- Contact → Read, Create, Edit, Modify All
- System Permissions → API Enabled, API Only User, Approve Uninstalled Connected Apps
- Create dedicated Integration User; capture username & password.

STEP 2 — DEVSB: Create External Client App
Setup → Apps → External Client App Manager → New
- Name: SAP Comm App
- Temporary Callback URL: https://www.swhizz.com/
- OAuth Scopes:
    api (or full)
    refresh_token, offline_access
- Save → Capture Consumer Key & Consumer Secret.

STEP 3 — QASB (Consumer): Create Auth Provider
Setup → Identity → Auth Providers → New
- Name: DEVSB_OAuth
- Consumer Key/Secret → From DEVSB
- Authorize URL → https://<DEVSB_DOMAIN>/services/oauth2/authorize
- Token URL     → https://<DEVSB_DOMAIN>/services/oauth2/token
- Default Scopes → api refresh_token
- Save → Copy Generated Callback URL.

STEP 4 — DEVSB: Update External Client App
- Replace Callback URL with QASB generated URL; Save.

STEP 5 — QASB: Create Named Credential (Legacy)
Setup → Security → Named Credentials → New Legacy
- Label: OEL Cred | Name: oelcred
- URL: https://<DEVSB_DOMAIN>
- Identity Type: Named Principal
- Auth Protocol: OAuth 2.0
- Auth Provider: DEVSB_OAuth
- Scope: api refresh_token
- Save → Authenticate using DEVSB integration user.

============================================================================ */

/* ============================================================================
FILE: RestConsumerController.apxc
ORG : QASB (Service Consumer)
PURPOSE: Consume Provider GET & POST REST services
============================================================================ */

public class RestConsumerController {

    private static final String NAMED_CRED = 'oelcred';
    private static final String CUSTOMER_LOOKUP_PATH = '/services/apexrest/oel/sap/v1/customers/';
    private static final String CONTACT_UPSERT_PATH  = '/services/apexrest/oel/sap/v1/contacts';

    /* ===================== RESPONSE WRAPPERS ===================== */

    public class APIResponse { public Boolean success; public String message; public OELAccount data; }

    public class OELAccount {
        public String id, name, phone, fax, email, type, industry, rating;
        public List<OELContact> contacts = new List<OELContact>();
    }

    public class OELContact { public String id, name, phone, mobile, email, title; }

    /* ===================== REQUEST WRAPPERS ===================== */

    public class ContactPhones { public String phone, mobile, home, fax; }

    public class ContactWrapper {
        public String id, firstname, lastname, title, email, department, source;
        public ContactPhones phones;
    }

    /* ===================== CORE CALLOUT HANDLER ===================== */

    private static APIResponse sendAndParse(HttpRequest req){
        Http http = new Http(); HttpResponse res = http.send(req);
        Integer sc = res.getStatusCode(); String body = res.getBody();

        if(sc < 200 || sc >= 300 || String.isBlank(body)){
            APIResponse fail = new APIResponse(); fail.success = false;
            fail.message = 'Callout failed → HTTP ' + sc + ' ' + res.getStatus(); return fail;
        }
        return (APIResponse)JSON.deserialize(body, APIResponse.class);
    }

    /* ===================== GET CUSTOMER ===================== */

    public static APIResponse getExternalCustomer(String customerId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NAMED_CRED + CUSTOMER_LOOKUP_PATH + EncodingUtil.urlEncode(customerId,'UTF-8'));
        req.setMethod('GET'); req.setHeader('Accept','application/json');
        return sendAndParse(req);
    }

    /* ===================== UPSERT CONTACT ===================== */

    public static APIResponse upsertExternalContact(ContactWrapper payload){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NAMED_CRED + CONTACT_UPSERT_PATH);
        req.setMethod('POST'); req.setHeader('Content-Type','application/json'); req.setHeader('Accept','application/json');
        req.setBody(JSON.serialize(payload)); return sendAndParse(req);
    }
}

/* ============================================================================
ANONYMOUS APEX — TESTING
============================================================================

    // --- Consume GET Service ---
    RestConsumerController.APIResponse getRes =
        RestConsumerController.getExternalCustomer('ACC5123');
    System.debug(JSON.serializePretty(getRes));

    // --- Consume POST Service ---
    RestConsumerController.ContactWrapper cw = new RestConsumerController.ContactWrapper();
    cw.id='JMAG-43533'; cw.firstname='Jahnavi'; cw.lastname='Malhotra'; cw.title='Assistant';
    cw.email='jahnavi.malhotra@gmail.com'; cw.department='IT Support'; cw.source='SAP';

    cw.phones = new RestConsumerController.ContactPhones();
    cw.phones.phone='040-12345678'; cw.phones.mobile='9999999999';
    cw.phones.home='040-11112222'; cw.phones.fax='040-87654321';

    RestConsumerController.APIResponse postRes =
        RestConsumerController.upsertExternalContact(cw);
    System.debug(JSON.serializePretty(postRes));

    SOAPAPI
    ======= */

