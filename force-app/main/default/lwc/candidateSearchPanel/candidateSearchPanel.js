import { LightningElement, wire } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class CandidateSearchPanel extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    searchKey = '';
    candidateCount = 0;
    connectedCallback() {
        registerListener('candidatecount', this.handleCountUpdate, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        fireEvent(this.pageRef,'candidatesearch', { searchKey: this.searchKey });
    }

    handleCountUpdate(payload) {
        console.log("Payload Count: "+payload.count)
        this.candidateCount = payload?.count || 0;
    }
}

