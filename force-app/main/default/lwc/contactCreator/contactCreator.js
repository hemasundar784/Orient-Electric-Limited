import { api, LightningElement, track } from 'lwc';
import createContact from '@salesforce/apex/LWCUtility.doCreateContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class ContactCreator extends NavigationMixin(LightningElement) {
    @api recordId; // Account Id from the record page (or parent context)
    /* Local state for the input fields.
    Keys must match the Apex ContactWrapper properties. */
    contact = {
        firstname: '', lastname: '', phone: '', fax: '', email: ''
    };
    // UI feedback state
    message; messageClass;
    /* Generic input handler.
    Uses data-field to map the input → contact property. */
    handleChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        /* this.log(`Field → ${field}, Value → ${value}`); */
        this.contact = {
            ...this.contact,
            [field]: value
        };
    }
    /* Main handler for "Create Contact" button.
    Calls Apex imperatively and handles the response. */
    handleCreate() {
        this.log(`Input Contact →\n${JSON.stringify(this.contact, null, 2)}`);
        // The above can also be replaced with filters to show only the required entities
        /* this.log(`Input Contact → \n${JSON.stringify(this.contact,["lastname", "phone", "email"],2)}`); */
        createContact({ctContact:this.contact, accountId: this.recordId}).
        then(result => {
            this.log(`Result →\n${JSON.stringify(result, null, 2)}`)
            this.message = result.message;
            if(result.isSuccess){
                this.messageClass = "slds-text-color_success";
                this.showToast("Success", result.message, "success", 'dismissible')
                setTimeout(() => this.navigateToRecord(result.recordId,'Contact') , 3000);
            }
            else{
                this.messageClass = "slds-text-color_error";
                this.showToast("Error", result.message, "error", 'sticky')
            }
        })
        .catch(error=>{
            this.log(`Error →\n${JSON.stringify(error, null, 2)}`)
            const errorMessage = 
                (error && error.body && error.body.message) 
                || error.message || 'Unkown client-side error';
            this.messageClass = "slds-text-color_error";
            this.message = 'Unexpected LWC error'+errorMessage;
            this.showToast("Error", errorMessage, "error", 'sticky')
        })
    }
    // Log helper.
    log(message) {
        console.log(`CONCR:: ${message}`);
    }
    //Toast helper.
    showToast(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant, mode}));
    }
    // Navigate to the created record.
    navigateToRecord(recordId, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId, objectApiName, actionName: 'view'
            }
        });
    }
}