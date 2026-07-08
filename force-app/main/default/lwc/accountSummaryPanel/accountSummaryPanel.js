import { LightningElement, api } from 'lwc';

export default class AccountSummaryPanel extends LightningElement {
    @api accountId;
    fields = [
        'Id', 'AccountNumber', 'Rating', 'Phone',
        'Name', 'email__c', 'Industry', 'totalContacts__c'
    ];
}