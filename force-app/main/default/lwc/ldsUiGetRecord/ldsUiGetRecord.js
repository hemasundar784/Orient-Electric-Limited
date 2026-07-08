import { api, LightningElement, track, wire } from 'lwc';
// Import the getRecord method from uiRecordApi
import { getRecord } from 'lightning/uiRecordApi';
// Constant array of fields we want from the Account record
const FIELDS = ['Account.Id', 'Account.Name',
    'Account.AccountNumber', 'Account.Phone',
    'Account.Fax', 'Account.email__c' ];

export default class LdsUiGetRecord extends LightningElement {
    // recordId will be injected when this component is placed on an Account record page
    @api recordId;
    // Holds a simplified view of the retrieved record for easy template binding
    retrievedRecord = {};
    /*
        Wire adapter: getRecord
        • Uses LDS to fetch the record data
        • recordId: the current page record
        • fields: the FIELDS constant defined above
    */
    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    retrieveRecord({error,data}){
        if(data){
            console.log(`LDSGRF:: Data: ${JSON.stringify(data,null,1)}`)
            // Map the LDS response to a simple JS object for the template
            this.retrievedRecord = {
                id: data.fields.Id.value, name: data.fields.Name.value,
                accountNumber: data.fields.AccountNumber.value,
                phone: data.fields.Phone.value, fax: data.fields.Fax.value,
                email: data.fields.email__c.value
            }
        }
        if(error){
            console.log(`LDSGRF:: Error: ${JSON.stringify(error,null,1)}`)
        }
    }
}
