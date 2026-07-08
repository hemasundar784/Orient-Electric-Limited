import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LdsRecordEditForm extends LightningElement {
    // recordId will be injected when this component is placed on an Account record page
    @api recordId;
    objectApiName = 'Account';
    // Fields we want to display/edit
    fields = ["Id", "Name", "AccountNumber", "Phone","Fax",
        "email__c",  "Rating", "Industry", "BillingAddress"]
    handleSave(event){
        event.preventDefault();
        const fields = event.detail.fields
        console.log(`REF:: ${JSON.stringify(fields, null, 1)}`)
        fields.Active__c = 'Yes';
        fields.details__c = 'This update happened via LDS.';
        console.log(`REF:: ${JSON.stringify(fields, null, 1)}`)
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showNotification(
            'Success!','Record updated successfully. Id: ' + this.recordId,
            'success','dismissible'
        );
    }
    // Method to display toast message
    showNotification(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant, mode}))
    }
}