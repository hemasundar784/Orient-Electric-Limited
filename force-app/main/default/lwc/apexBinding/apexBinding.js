console.log("ADB::  JS File Executed.")
import { LightningElement, wire } from 'lwc';
// Apex methods
import fetchMessage from '@salesforce/apex/LWCUtility.sendMessage';
import fetchGreeting from '@salesforce/apex/LWCUtility.sendGreeting';
import performCalculation from '@salesforce/apex/LWCUtility.calculate';

export default class ApexBinding extends LightningElement {
    // ---------- Reactive Data ----------
    greetingText; result; errorMessage;
    // ---------- Form State ----------
    firstNumber; secondNumber; selectedOperation;
    // ---------- Lifecycle (Debug Only) ----------
    /* constructor() {
        super();
        this.log('Message (cns): ' + this.wiredMessage?.data);
        this.log('Greeting (cns): ' + this.greetingText);
    }

    connectedCallback() {
        this.log('Message (ccb): ' + this.wiredMessage?.data);
        this.log('Greeting (ccb): ' + this.greetingText);
    }

    renderedCallback() {
        this.log('Message (rcb): ' + this.wiredMessage?.data);
        this.log('Greeting (rcb): ' + this.greetingText);
    } */
    // ---------- Wire: Property ----------
    @wire(fetchMessage) wiredMessage;
    // ---------- Wire: Function ----------
    @wire(fetchGreeting, { person: 'John Doe' })
    wiredGreeting({ data, error }) {
        if (data) {
            this.log('Wire Data Received (Greeting): ' + data);
            this.greetingText = data;
        } else if (error) {
            this.log('Wire Error: ' + JSON.stringify(error));
            this.greetingText = 'Error loading greeting. Check console for details.';
        }
    }
    // ---------- Combobox Options ----------
    get operationOptions() {
        return [
            { label: 'Sum',        value: '1' },
            { label: 'Difference', value: '2' },
            { label: 'Product',    value: '3' },
            { label: 'Quotient',   value: '4' },
            { label: 'Remainder',  value: '5' }
        ];
    }
    // ---------- Input Handler ----------
    handleInputChange(event) {
        const { name, value } = event.target;
        switch (name) {
            case 'firstNumber': this.firstNumber = value; break;
            case 'secondNumber': this.secondNumber = value; break;
            case 'operation': this.selectedOperation = value; break;
        }
        // Reset output on change
        this.result = null; this.errorMessage = null;
    }
    // ---------- Calculate ----------
    handleCalculate() {
        this.log('Calculating...');
        const x = this.parseNumber(this.firstNumber);
        const y = this.parseNumber(this.secondNumber);
        const op = this.selectedOperation ? parseInt(this.selectedOperation, 10) : null;
        performCalculation({ x, y, op })
            .then(res => {
                this.result = res;
                this.errorMessage = null;
            })
            .catch(err => this.handleError(err) );
    }
    // ---------- Reset ----------
    handleReset() {
        this.firstNumber = null; this.secondNumber = null;
        this.selectedOperation = null;
        this.result = null; this.errorMessage = null;
    }
    // ---------- Helpers ----------
    parseNumber(value) {
        return value !== null && value !== '' ? parseInt(value, 10) : null;
    }
    handleError(error) {
        this.log('Apex error: ' + JSON.stringify(error));
        const body = error?.body || {};
        const type = body.exceptionType || '';
        if (type.includes('StringException')) {
            this.errorMessage = 'Select an operation';
        } else if (type.includes('NullPointerException')) {
            this.errorMessage = 'Inputs cannot be empty';
        } else if (type.includes('MathException')) {
            this.errorMessage = 'Division by zero not allowed';
        } else {
            this.errorMessage = 'Unexpected error occurred';
        }
        this.result = null;
    }
    log(message) {
        console.log(`ADB :: ${message}`);
    }
}