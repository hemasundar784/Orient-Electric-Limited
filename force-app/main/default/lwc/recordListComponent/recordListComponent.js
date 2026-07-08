import { LightningElement, track, wire } from 'lwc';
import { subscribe, unsubscribe, publish, MessageContext } from 'lightning/messageService';
import OBJECT_BROWSER_CHANNEL from '@salesforce/messageChannel/ObjectBrowserChannel__c';
import getRecordSummaries from '@salesforce/apex/ObjectBrowserController.getRecordSummaries';

export default class RecordListComponent extends LightningElement {
    @track records = [];
    objectApiName;
    subscription;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToChannel();
    }

    disconnectedCallback() {
        this.unsubscribeFromChannel();
    }

    // Subscribe to LMS for OBJECT_SELECTED events
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

    // Handle LMS message for object selection
    handleMessage(message) {
        if (message.action === 'OBJECT_SELECTED') {
            this.objectApiName = message.objectApiName;
            this.loadRecords();
        }
    }

    // Load records for current object via Apex
    loadRecords() {
        if (!this.objectApiName) {
            this.records = [];
            return;
        }
        getRecordSummaries({ objectApiName: this.objectApiName })
            .then(result => {
                this.records = result || [];
            })
            .catch(error => {
                this.records = [];
                // console.error(error);
            });
    }

    // When a record is clicked, publish RECORD_SELECTED to LMS
    handleRecordClick(event) {
        const recordId = event.currentTarget.dataset.id;
        const message = {
            action: 'RECORD_SELECTED',
            objectApiName: this.objectApiName,
            recordId: recordId
        };
        publish(this.messageContext, OBJECT_BROWSER_CHANNEL, message);
    }
}
