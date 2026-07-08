import { LightningElement, wire } from 'lwc';
// 3.2. Pubsub Communication: Import the CurrentPageReference from lightning/navigation
import { CurrentPageReference } from 'lightning/navigation';
// 3.4. Pubsub Communication: Import the fireEvent from pubsub.
import { fireEvent } from 'c/pubsub';
// 4.5 LMS  Communication: Import the publish & messageContext from LMS
import { publish, MessageContext } from 'lightning/messageService';
// 4.6 LMS Communication: Import the Communication Chanel from the prepared message channels
import COMM_CHANNEL from '@salesforce/messageChannel/CommunicationChannel__c';

export default class CommOuter extends LightningElement {
    toSendInner = null; toSendPubSub = null; toSendLMS = null;
    toReceiveInner = null;
    subscription = null;
    // 3.7. Pubsub Communication: Wire the CurrentPageReference to get the reference of the current page.
    @wire(CurrentPageReference) pageRef;
    // 4.12. LMS Communication: Wire the MessageContext to get the Message Context
    @wire(MessageContext) messageContext;
    // 3.3. Pubsub Communication: Wire the CurrentPageReference to get the reference of the current page.
    handleInner(){
        this.toSendInner = this.template.querySelector('.toInner').value
    }
    // 2.3. Outer Communication: Compose a method to execute when event occurs
    handleReceive(event){
        // 2.4. Outer Communication: use the key on event to capture the data.
        this.toReceiveInner = event.detail
    }
    handlePubSub(){
        this.toSendPubSub = this.template.querySelector('.toPubSub').value
        // 3.5. Pubsub Communication: Call the fireEvent function from pubsub in order to publish the event.
        fireEvent(this.pageRef, "datarush", this.toSendPubSub)
    }
    handleLms(){
        this.toSendLMS = this.template.querySelector('.toLMS').value
        // 4.8. LMS Communication:  Prepare payload to be sent using the attribute name from the message channel
        const payload = { message: this.toSendLMS };
        // 4.9. LMS Communication: Invoke the publish method with context, channel & payload.
        publish(this.messageContext, COMM_CHANNEL, payload);
    }
    connectedCallback(){
        // 3.9. Register the listener when the component is added to the DOM.
        registerListener( "datarush", data=> this.toReceivePubSub = data, this )
        // 4.13. LMS Communication: Register the listener when the component is added to the DOM.
        this.subscribeToMessageChannel();
    }
    subscribeToMessageChannel(){
        if(!this.subscription){
            // 4.14 LMS Communication: . Listen to the event invoking & capture the data.
            this.subscription = subscribe(
                this.messageContext,
                COMM_CHANNEL,
                (message) => {
                    this.toReceiveLMS = message.message;
                }
            );
        }
    }
    // 3.10. Pubsub Communication: Unregister the listener when the component is removed from the DOM.
    disconnectedCallback(){
        unregisterAllListeners(this)
    }
}