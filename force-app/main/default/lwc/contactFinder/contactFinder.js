import { LightningElement, wire } from 'lwc';
import findContacts from '@salesforce/apex/LWCUtility.findContacts';
import { NavigationMixin } from 'lightning/navigation';
export default class ContactFinder extends NavigationMixin(LightningElement) {
    queryTerm;    // Search input value
    results = []; // Search results
    // Fetch contacts based on search term
    @wire(findContacts, { searchKey: '$queryTerm' })
    wiredContacts({ data, error }) {
        this.log(`Received Data:: ${JSON.stringify(data,null,1)}`)
        if (data && this.queryTerm) this.results = data;
        else this.results = [];
        if (error) {
            console.error('Error fetching contacts:', error);
            this.results = [];
        }
    }
    // Handle input change (on change)
    handleSearch(event) {
        this.queryTerm = event.target.value;
        // Clear results if input is empty
        if (!this.queryTerm) this.results = [];
    }
    // Check if results exist
    get hasResults() {
        return this.results?.length > 0;
    }
    // Handle contact selection
    handleSelect(event) {
        const recordId = event.currentTarget.value;
        this.navigateToRecord(recordId, 'Contact');
    }
    // Navigate to record page
    navigateToRecord(recordId, objectApiName) {
        this.log(`Navigating to ${objectApiName} record with id ${recordId}`)
        /* this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId, objectApiName, actionName: 'view' }
        }); */
        // Incase you want to open the record in new tab replace above with the below code
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: { recordId, objectApiName, actionName: 'view' }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
    // logging function
    log(message){
        console.log(`CFN:: ${message}`)
    }
}
 