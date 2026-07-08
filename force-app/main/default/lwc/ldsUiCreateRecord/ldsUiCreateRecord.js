import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';

export default class LdsUiCreateRecord extends NavigationMixin(LightningElement) {
    // Form fields (tracked automatically in LWC)
    name = ''; accountNumber = ''; phone = ''; fax = ''; email = '';
    /*
        captureInputs(): Automatically updates the JS variable based on input name.
        Input name and variable names are SAME, so we can use bracket notation.
    */
    captureInputs(event) {
        this[event.target.name] = event.target.value;
    }
    /*
        submitHandler():
        1. Validate all inputs
        2. Build record data object
        3. Call createRecord()
        4. Show Toast + Navigate on success
    */
    submitHandler() {
        // Step 1: Validate using lightning-input's built-in validity check
        const allInputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;
        allInputs.forEach(input => {
            if (!input.reportValidity()) isValid = false;
        });
        if (!isValid) {
            this.showNotification('Check Inputs!!!', 'Mandatory inputs are missing or invalid!', 
                'warning', 'dismissible');
            return;
        }
        // Step 2: Build record object for Account
        const recordToCreate = {
            apiName: 'Account',
            fields: {
                Name: this.name, AccountNumber: this.accountNumber,
                Phone: this.phone, Fax: this.fax, email__c: this.email
            }
        };
        console.log(`LDSCRF:: Record to Create: ${JSON.stringify(recordToCreate, null, 1)}`);
        // Step 3: Call createRecord() API
        createRecord(recordToCreate)
        .then(result => {
            console.log(`LDSCRF:: Result: ${JSON.stringify(result, null, 1)}`);
            // Build success message
            const message = `A prospect "${result.fields.Name.value}"
                was created with Id: ${result.id}`;
            // Show Toast
            this.showNotification('Success!!!', message, 'success', 'dismissible');
            // Navigate to the new record page
            setTimeout(() => { this.navigateToRecord(result.id, result.apiName);}, 5000);
        })
        .catch(error => {
            console.log(`LDSCRF:: ERROR: ${JSON.stringify(error, null, 1)}`);
            // Custom user-friendly messages
            const errorBody = JSON.stringify(error);
            if (errorBody.includes('ACC-422-VR-ACCTNO-LEN')) {
                this.showNotification(
                    'Error!!!', 'Account Number should not exceed 10 characters!',
                    'error', 'sticky'
                );
            } else if (errorBody.includes('duplicate value found: email__c')) {
                this.showNotification(
                    'Error!!!', 'No two Accounts can have the same email.',
                    'error', 'sticky'
                );
            } else {
                // Generic fallback
                this.showNotification(
                    'Error!!!', 'Something went wrong while creating the record.',
                    'error', 'sticky'
                );
            }
        });
    }
    // clearHandler(): Clears the form fields and resets all input values.
    clearHandler() {
        this.name = ''; this.accountNumber = ''; this.phone = ''; this.fax = ''; this.email = '';
    }
    // showNotification(): Utility function to display toast messages to user.
    showNotification(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant, mode}))
    }
    // navigateToRecord(): Uses NavigationMixin to redirect user to the newly created Account record.
    navigateToRecord(recordId, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId, objectApiName, actionName: 'view'
            }
        });
    }
}