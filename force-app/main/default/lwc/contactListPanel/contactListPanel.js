import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getContacts from '@salesforce/apex/CustomerWorkspaceController.getContacts';
import { refreshApex } from '@salesforce/apex';

export default class ContactListPanel extends NavigationMixin(LightningElement) {
    @api accountId; contacts = []; wiredResult;
    @wire(getContacts, { accountId: '$accountId' })
    wiredContacts(result) {
        this.wiredResult = result;
        this.contacts = result.data ? result.data : []
        console.log(JSON.stringify(this.contacts[0]))
    }
    handleClick(event){
        this.navigateToRecord(event.target.dataset.id, 'Contact')
    }
    navigateToRecord(recordId, objectApiName) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: { recordId, objectApiName, actionName: 'view' }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }

    get contactsCount() {
        return this.contacts.length;
    }
    /** Parent-triggered refresh */
    @api
    refreshData() {
        return refreshApex(this.wiredResult);
    }
}
