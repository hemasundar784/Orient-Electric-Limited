import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import OBJECT_BROWSER_CHANNEL from '@salesforce/messageChannel/ObjectBrowserChannel__c';
import getRecordViewFields from '@salesforce/apex/ObjectBrowserController.getRecordViewFields';

export default class RecordViewerComponent extends LightningElement {
    objectApiName;
    recordId;
    @track fieldApiNames = [];
    subscription;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToChannel();
    }

    disconnectedCallback() {
        this.unsubscribeFromChannel();
    }

    // Subscribe to LMS for RECORD_SELECTED messages
    subscribeToChannel() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            OBJECT_BROWSER_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Unsubscribe from LMS
    unsubscribeFromChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    // Handle LMS messages - when record is selected from list
    handleMessage(message) {
        if (message.action === 'RECORD_SELECTED') {
            this.objectApiName = message.objectApiName;
            this.recordId = message.recordId;
            this.loadFields();
        }
    }

    // Load fields for the selected object from Apex config
    loadFields() {
        if (!this.objectApiName) {
            this.fieldApiNames = [];
            return;
        }
        getRecordViewFields({ objectApiName: this.objectApiName })
            .then(result => {
                this.fieldApiNames = result || [];
            })
            .catch(error => {
                this.fieldApiNames = [];
                // console.error(error);
            });
    }
}