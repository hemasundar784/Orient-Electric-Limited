import { api, LightningElement, wire } from 'lwc';
import fetchAccountKeyContacts from '@salesforce/apex/LWCUtility.fetchAccountKeyContacts';

export default class AccountKeyContacts extends LightningElement {
    @api recordId; contacts = []; error;  isLoading = true;
    // Datatable configuration
    columns = [
        {
            label: 'Name', fieldName: 'recordUrl', type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
        },
        { label: 'Phone', fieldName: 'Phone', type: 'phone' },
        { label: 'Fax', fieldName: 'Fax', type: 'phone' },
        { label: 'Email', fieldName: 'Email', type: 'email' }
    ];
    // Wire to fetch key contacts
    @wire(fetchAccountKeyContacts, { accountId: '$recordId' })
    wiredKeyContacts({ data, error }) {
        this.isLoading = false;
        if (data) {
            // Add URL for navigation
            this.contacts = data.map(contact => ({
                ...contact, recordUrl: `/lightning/r/Contact/${contact.Id}/view`
            }));
            this.error = null;
            const message = this.contacts.length
                ? JSON.stringify(this.contacts, null, 1)
                : 'No primary contacts found on this account.';
            console.log(`FKC:: ${message}`);
        } else if (error) {
            this.contacts = []; this.error = error;
            console.error(`FKC:: Error fetching key contacts: ${JSON.stringify(error)}`);
        }
    }
    // Derived state for UI
    get hasContacts() {
        return this.contacts.length > 0;
    }
}