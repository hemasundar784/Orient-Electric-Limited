import { api,LightningElement, track } from 'lwc';
// Import the Navigation Service module
import { NavigationMixin } from 'lightning/navigation';

import { CloseActionScreenEvent } from 'lightning/actions';

   

export default class HelloBinding extends NavigationMixin(LightningElement) {
    @track person = {
        Name: "John Doe",
        Age: 30,
        City: "Hyderabad"
    };

    @api recordId; 

    get handleCancelOrClose() {
        // Simple ternary statement: If recordId exists, return the ID string, else return the warning text
        return this.recordId 
            ? `Working with Record: ${this.recordId}` 
            : 'No active record context detected. Please select a record first.';
    }


    name = ''; 
    popularCars = ['Tesla Model 3', 'Ford Mustang Mach-E', 'Porsche Taycan', 'BYD Seal'];

    // Handle Menu Item Selection & Redirect
    handleMenuSelect(event) {
        const selectedValue = event.detail.value;
        this.log(`Selected Menu Action: ${selectedValue}`);

        if (selectedValue === 'goToAccount') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Account',
                    actionName: 'home'
                }
            });
        }
            
            if (selectedValue === 'BankAccounts') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'BankAccount__c',
                    actionName: 'home'
                }
                });
        }
         if (selectedValue === 'DepositAccount__c') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'DepositAccount__c',
                    actionName: 'home'
                }
                });
        }
         if (selectedValue === 'LoanAccount__c') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'LoanAccount__c',
                    actionName: 'home'
                }
                });
        }
        if (selectedValue === 'Mortgage__c') {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Mortgage__c',
                    actionName: 'home'
                }
                });
        }
        }
    

    // Handle Keyboard Enter Press Input
    handleChange(event) {
        if (event.keyCode === 13) {
            this.log(`Type: ${event.type} | Target: ${event.target.tagName} | Value: ${event.target.value}`);
            this.name = event.target.value;
        }
    }

    // Getter for Person Details Computed String
    get personData() {
        return `${this.person.Name} age is ${this.person.Age} and he lives in ${this.person.City}`;
    }

    // Context Logger Utility Method
    log(message) {
        const componentName = this.constructor.name; 
        console.log(`[${componentName}] -> ${message}`);
    }
}