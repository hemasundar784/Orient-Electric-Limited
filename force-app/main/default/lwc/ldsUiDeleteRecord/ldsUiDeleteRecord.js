import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

export default class LdsUiDeleteRecord extends LightningElement {
    // recordId of the Account, injected when this component is on a Record Page
    @api recordId;
    /*
        handleDelete():
        1. Confirm with the user
        2. Call deleteRecord(recordId)
        3. Show toast based on success or failure
    */
    handleDelete() {
        // Basic guard: recordId must be present
        if (!this.recordId) {
            this.showNotification(
                'Error', 'No recordId found. Please add this component on an Account Record Page.',
                'error', 'sticky'
            );
            return;
        }
        // Simple browser confirmation (good enough for a demo)
        const confirmed = window.confirm('Are you sure you want to delete this record? This action cannot be undone.');
        if (!confirmed) return;
        // Delete the record using Lightning UI API
        deleteRecord(this.recordId)
            .then(() => {
                console.log(`LDSDRF:: Record deleted successfully`);
                this.showNotification(
                    'Success', 'Record deleted successfully.',
                    'success', 'dismissible'
                );
            })
            .catch(error => {
                console.error(`LDSDRF:: Error while deleting record:\n ${JSON.stringify(error)}`);
                this.showNotification(
                    'Error', 'Record deletion failed. Please try again or contact your admin.',
                    'error', 'sticky'
                );
            });
    }
    // Utility method to show toast messages
    showNotification(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant, mode}))
    }
}
