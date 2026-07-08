import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactCreatorPanel extends LightningElement {
    @api accountId;
    objectApiName = 'Contact';
    fields = ["FirstName", "LastName", "Phone","Fax", "Email"]
    handleSave(event){
        event.preventDefault(); 
        const fields = event.detail.fields
        fields.AccountId = this.accountId; 
        this.template
            .querySelector('lightning-record-edit-form')
            .submit(fields);
    }
    handleSuccess(event){
        const recordId = event.detail.id;
        this.dispatchEvent(new CustomEvent('contactcreated'));
        this.showNotification(
            'Success!',
            'Record created successfully with Id: '+recordId,
            'success', 'dismissible'
        );
        const inputFields = this.template.querySelectorAll('.cfield');
        if (inputFields) {
            inputFields.forEach(field => field.reset());
        }
    }
    handleError(event){
        event.detail
        this.showNotification(
            'Failure!',
            'Record creation failed. Check console for more details',
            'error', 'dismissible'
        );
    }
    // Method to display toast message
    showNotification(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant, mode}))
    }
}
