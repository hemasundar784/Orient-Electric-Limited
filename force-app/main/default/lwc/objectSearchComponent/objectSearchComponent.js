import { LightningElement, wire, track } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import OBJECT_BROWSER_CHANNEL from '@salesforce/messageChannel/ObjectBrowserChannel__c';
import getSupportedObjects from '@salesforce/apex/ObjectBrowserController.getSupportedObjects';

export default class ObjectSearchComponent extends LightningElement {
    @track objectOptions = [];
    selectedObject;

    @wire(MessageContext)
    messageContext;

    // Load supported objects from Apex and convert to combobox options
    @wire(getSupportedObjects)
    wiredObjects({ data, error }) {
        if (data) {
            this.objectOptions = data.map(objName => ({
                label: objName,
                value: objName
            }));
        } else if (error) {
            // In real project, surface error via toast or UI
            // console.error(error);
        }
    }

    // When object is changed, publish LMS message
    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        const message = {
            action: 'OBJECT_SELECTED',
            objectApiName: this.selectedObject
        };
        publish(this.messageContext, OBJECT_BROWSER_CHANNEL, message);
    }
}
