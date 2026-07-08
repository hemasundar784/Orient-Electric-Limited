import { LightningElement } from 'lwc';
import { refreshApex } from '@salesforce/apex';

export default class CustomerWorkspace extends LightningElement {

    accountId;
    wiredContactsResult;

    /** Capture selected account */
    handleAccountChange(event) {
        this.accountId = event.detail.recordId;
    }

    /** Child → Parent communication */
    async handleContactCreated() {
        // Refresh child component via public method OR event
        const contactList = this.template.querySelector('c-contact-list-panel');
        if (contactList) {
            contactList.refreshData();
        }
    }
}