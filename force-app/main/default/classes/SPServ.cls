/* -----------------------------------------------------------
FILE: SPServ.apxc | ORG: Service Provider | TYPE: Apex SOAP Web Service
PURPOSE: Expose SOAP operations via `webservice static` methods; return String (JSON / messages) to keep WSDL stable.
----------------------------------------------------------- */

    global class SPServ {

    global class OELContact { global String id, name, phone, mobile, email, title; }
    global class OELAccount { global String id, name, phone, fax, email, type, industry, rating; global List<OELContact> contacts = new List<OELContact>(); }

    /* ========================== lookupProspect ========================== */
    webservice static String lookupProspect(String customerId){
        String response; System.debug('SPServ.lookupProspect(' + customerId + ')');
        try{
            Account acc = [SELECT Id, Name, Phone, Fax, email__c, Type, Industry, Rating FROM Account WHERE uniqueId__c = :customerId LIMIT 1];
            List<Contact> cons = [SELECT Id, Name, Phone, MobilePhone, Email, Title FROM Contact WHERE AccountId = :acc.Id ORDER BY Name];

            OELAccount dto = new OELAccount();
            dto.id=acc.Id; dto.name=acc.Name; dto.phone=acc.Phone; dto.fax=acc.Fax;
            dto.email=acc.email__c; dto.type=acc.Type; dto.industry=acc.Industry; dto.rating=acc.Rating;

            for(Contact c : cons){
                OELContact oc = new OELContact();
                oc.id=c.Id; oc.name=c.Name; oc.phone=c.Phone; oc.mobile=c.MobilePhone; oc.email=c.Email; oc.title=c.Title;
                dto.contacts.add(oc);
            }
            response = JSON.serialize(dto);
        }catch(QueryException qe){
            response = 'ERR-CUST-404: Customer not found for Unique Customer ID: ' + customerId;
        }catch(Exception e){
            response = 'ERR-SERVER-500: Unexpected error. Details: ' + e.getMessage();
        }
        return response;
    }

    /* ========================== upsertContact ========================== */
    webservice static String upsertContact(
        String id, String firstname, String lastname, String title, String email, String department, String source,
        String phone, String mobile, String home, String fax
    ){
        String response;
        Contact c = new Contact(
            uniqueId__c=id, FirstName=firstname, LastName=lastname, Title=title, Email=email, Department=department,
            LeadSource=source, Phone=phone, Fax=fax, MobilePhone=mobile, HomePhone=home
        );

        try{
            Database.UpsertResult r = Database.upsert(c, Contact.uniqueId__c, true); System.debug('UpsertResult → ' + r);
            if(r.isSuccess()){
                String fullName = ((String.isNotBlank(firstname) ? firstname + ' ' : '') + (lastname==null ? '' : lastname)).trim();
                response = 'Contact ' + (String.isBlank(fullName) ? '(No Name)' : fullName) + ' ' + (r.isCreated() ? 'created' : 'updated') + ' successfully.';
            }
        }catch(DmlException de){
            String raw = de.getMessage(); System.debug('RAW → ' + raw);
            String message;
            if(raw != null && raw.contains('CON-400-VR-PHONE-REQ')){
                message = '(CON-400-VR-PHONE-REQ): Phone number cannot be empty.';
            }else if(raw != null && raw.contains('REQUIRED_FIELD_MISSING')){
                message = '(CON-400-REQ-FIELD-MISSING): Required Keys Missing (LastName).';
            }else if(raw != null && raw.contains('INVALID_EMAIL_ADDRESS')){
                message = '(CON-400-EMAIL-FORMAT-ERR): Email is not in email format.';
            }else{
                message = 'Unknown DML Error: ' + raw;
            }
            response = message;
        }catch(Exception e){
            response = 'ERR-CONT-500: Unexpected error. Details: ' + e.getMessage();
        }
        return response;
    }
}

/* -----------------------------------------------------------
SOAPUI TEMPLATE ENVELOPE
-----------------------------------------------------------

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:sps="http://soap.sforce.com/schemas/class/SPServ">
  <soapenv:Header>
    <sps:SessionHeader>
      <sps:sessionId>?</sps:sessionId>
    </sps:SessionHeader>
  </soapenv:Header>
  <soapenv:Body>
    <sps:OPERATION_NAME/>
  </soapenv:Body>
</soapenv:Envelope>

----------------------------------------------------------- */

/* -----------------------------------------------------------
SOAP REQUEST — lookupProspect
-----------------------------------------------------------

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:sps="http://soap.sforce.com/schemas/class/SPServ">
  <soapenv:Header>
    <sps:SessionHeader>
      <sps:sessionId>?</sps:sessionId>
    </sps:SessionHeader>
  </soapenv:Header>
  <soapenv:Body>
    <sps:lookupProspect>
      <sps:customerId>EUR5544</sps:customerId>
    </sps:lookupProspect>
  </soapenv:Body>
</soapenv:Envelope>

----------------------------------------------------------- */

/* -----------------------------------------------------------
SOAP REQUEST — upsertContact
-----------------------------------------------------------

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                  xmlns:sps="http://soap.sforce.com/schemas/class/SPServ">
  <soapenv:Header>
    <sps:SessionHeader>
      <sps:sessionId>?</sps:sessionId>
    </sps:SessionHeader>
  </soapenv:Header>
  <soapenv:Body>
    <sps:upsertContact>
      <sps:id>Con123</sps:id>
      <sps:firstname>Saravana</sps:firstname>
      <sps:lastname>Kumar</sps:lastname>
      <sps:title>Associate Consultant</sps:title>
      <sps:email>saravana.kumar@ymail.net</sps:email>
      <sps:department>Home Depot</sps:department>
      <sps:source>Other</sps:source>
      <sps:phone>87659876</sps:phone>
      <sps:mobile>87659876</sps:mobile>
      <sps:home>87659876</sps:home>
      <sps:fax>87659876</sps:fax>
    </sps:upsertContact>
  </soapenv:Body>
</soapenv:Envelope>

----------------------------------------------------------- */