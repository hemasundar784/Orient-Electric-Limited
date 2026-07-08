import { LightningElement } from 'lwc';

export default class LdsRecordPicker extends LightningElement {
    // Object whose records we want to search and display
    objectApiName = 'Account'
    // Holds the currently selected record Id from lightning-record-picker
    selectedRecordId
    // Fields that lightning-record-form will show for the selected record
    fields = [
        "Id", "Name", "AccountNumber", "Phone",
        "Fax", "email__c", "Rating",
        "Industry", "BillingAddress"
    ]
    /*
        handleRecordSelection(event):
        • Fired whenever the user selects a record in lightning-record-picker.
        • event.detail.recordId contains the selected record's Id.
        • We store it in selectedRecordId, which:
            - Updates the value of the picker (two-way binding)
            - Triggers the lwc:if block to render lightning-record-form
    */
    handleRecordSelection(event){
        const recordId = event.detail.recordId;
        console.log(`LDSRP:: Selected Record Id:: +recordId`)
        this.selectedRecordId = recordId
    }
}
