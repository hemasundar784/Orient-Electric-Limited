import { api, LightningElement } from 'lwc';

export default class LdsRecordForm extends LightningElement {
    // recordId will be provided by the Record Page
    @api recordId;
    objectApiName = 'Account';
    // Prepare the fields using the api names which the lds will use to fetch the record data
    fields = ["Id", "Name", "AccountNumber", "Phone", "Fax",
        "email__c", "Rating", "Industry", "BillingAddress"]
    handleSuccess(event) {
        const DISPLAY_FIELDS = ['Id', 'Name', 'AccountNumber', 'Phone', 'Fax', 'email__c', 'Rating', 'Industry',
            'BillingStreet', 'BillingCity', 'BillingStateCode', 'BillingPostalCode', 'BillingCountryCode'];
        const filteredFields = Object.fromEntries(
            Object.entries(event.detail.fields)
                .filter(([field]) => DISPLAY_FIELDS.includes(field))
        );
        console.log(
            `LDSRF:: The record updated successfully.\nRecord Id: ${event.detail.id}\nFields submitted: ${JSON.stringify(filteredFields, null, 2)}`
        )
    }
    handleError(event) {
        console.log(
            `LDSRF:: Error occurred while saving. \nError details: ${JSON.stringify(event.detail, null, 2)}`
        )
    }
}
