import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

// Fields we want to retrieve using getRecord
const FIELDS = ['Account.Id', 'Account.Name', 'Account.AccountNumber',
    'Account.Phone', 'Account.Fax', 'Account.email__c' ];

export default class LdsUiUpdateRecord extends LightningElement {
    // Record id of the Account (injected from the Record Page)
    @api recordId;
    // Wire the getRecord adapter to fetch current data
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) accountRecord;
    /*
        handleUpdate():
        1. Reads latest values from the lightning-input fields
        2. Builds a "recordToUpdate" object
        3. Calls updateRecord(recordToUpdate)
        4. Shows toast based on success/error
    */
    handleUpdate() {
        // Collect latest field values from the template using data-field
        const inputs = this.template.querySelectorAll('lightning-input[data-field]');
        const fields = { Id: this.recordId };
        inputs.forEach(input => {
            const fieldApiName = input.dataset.field; // e.g. "Name", "Phone"
            fields[fieldApiName] = input.value;
        });
        const recordToUpdate = { fields };
        console.log(`LDSURF:: Record Input: \n${JSON.stringify(recordToUpdate, null, 1)}`)

        updateRecord(recordToUpdate)
        .then(() => {
            console.log(`LDSURF:: Record updated successfully`);
            this.showNotification('Success','Record updated successfully', 'success','dismissible');
        })
        .catch(error => {
            console.error(`LDSURF:: Error:\n ${JSON.stringify(error,null,1)}`);
            const errorBody = JSON.stringify(error);
            if (errorBody.includes('ACC-400-VR-FAX-REQ')) {
                this.showNotification('Error','Fax must not be empty while updating',
                    'error','sticky');
            } else {
                this.showNotification('Error','Record update failed',
                    'error','sticky');
            }
        });
    }
    // Utility to show Salesforce toast messages
    showNotification(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant, mode}))
    }
}
