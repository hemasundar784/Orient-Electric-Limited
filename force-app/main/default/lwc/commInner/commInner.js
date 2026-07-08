import { api, LightningElement } from 'lwc';

export default class CommInner extends LightningElement {
    // 1.1 Inner Communication: Make the property public by decorating it with @api
    @api toReceiveOuter=null; toSendOuter = null;
    handleOuter(){
        this.toSendOuter = this.template.querySelector(".toOuter").value
        // 2.1. Outer Communication: Dispatch a custom event with name, payload.
        this.dispatchEvent(new CustomEvent("recieve", {detail:this.toSendOuter}))
    }
}