import { api, LightningElement, wire } from 'lwc';
import fetchAccountOverview from '@salesforce/apex/LWCUtility.fetchAccountOverview';
export default class AccountOverview extends LightningElement {
    @api recordId; accountData; error;
    //Prepares field configuration for UI rendering
    get accountFields() {
        if (!this.accountData) return [];
        const acc = this.accountData;
        return [
            { label: 'Id'            , value: acc.recordId     , icon: 'utility:record'       , size: '12' },
            { label: 'Name'          , value: acc.name         , icon: 'standard:account'     , size: '12' },
            { label: 'Account Number', value: acc.accountNumber, icon: 'standard:number_input', size: '6' },
            { label: 'Phone'         , value: acc.phone        , icon: 'standard:call'        , size: '6' },
            { label: 'Fax'           , value: acc.fax          , icon: 'utility:print'        , size: '6' },
            { label: 'Email'         , value: acc.email        , icon: 'standard:email'       , size: '6' },
            { label: 'Rating'        , value: acc.rating       , icon: 'utility:favorite'     , size: '6' },
            { label: 'Industry'      , value: acc.industry     , icon: 'standard:account_info', size: '6' }
        ].filter(field => field.value);
    }
    // Wire method to fetch account overview data
    @wire(fetchAccountOverview, { accountId: '$recordId' })
    wiredAccountOverview({ data, error }) {
        if (data) {
            console.log(`AOV:: ${JSON.stringify(data, null, 1)}`)
            this.accountData = data; this.error = null;
        } else if (error) {
            console.error('AOV:: Error fetching account overview:', error);
            this.accountData = null; this.error = error;
        }
    }
}