import { api, LightningElement, track } from 'lwc';
console.log("DBL:: component loaded into dom.")
export default class DataBinding extends LightningElement {
    greeting = null; personName = 'John Doe'; company = null; city = null; phone = null; state = null; country = null; clickedButtonLabel = null; isChecked = false
    popularCars = ['Audi', 'BMW', 'Mercedes', 'Porsche', 'Ferrari', 'Lamborghini', 'Bugatti']
    @track person = {
        name: 'John Doe', age: 30, city:'Hyderabad', hasCar: false, hasInsurance: true,
        get describe(){
            return `Name: ${this.name}, Age: ${this.age}, 
            City: ${this.city}, Has Car: ${this.hasCar},
            Has Insurance: ${this.hasInsurance}.`
        }
    }
    @api recordId
    constructor(){
        super()
        console.log("DBL:: constructor().")
        this.company = 'Swhizz Technologies'
    }
    connectedCallback(){
        console.log("DBL:: connectedCallback().")
        this.city = 'Hyderabad'
    }
    assignPhone(){
        console.log("DBL:: assignPhone().")
        this.phone = '+91 (93)-92-002299'
    }
    assignButtonLabel(event){
        console.log("DBL:: assignButtonLabel().\n"
            +"Event Type: "+event.type+"\n"
            +"Event Target: "+event.target+"\n"
            +"Event Target Label: "+event.target.label
        )
        this.clickedButtonLabel = event.target.label
    }
    captureCountry(event){
        if(event.keyCode == 13){
            console.log("DBL:: captureCountry().\n"
                +"Event Type: "+event.type+"\n"
                +"Event Target: "+event.target+"\n"
                +"Event Target Value: "+event.target.value
            )
            this.country = event.target.value
        }
    }
    captureState(event){
        /* console.log("DBL:: captureState().\n"
            +"Event Type: "+event.type+"\n"
            +"Event Target: "+event.target+"\n"
            +"Event Target Value: "+event.target.value
        ) */
        this.state = event.target.value
    }
    checkboxHandler(event){
        console.log("DBL:: checkboxHandler().\n"
            +"Event Type: "+event.type+"\n"
            +"Event Target: "+event.target+"\n"
            +"Event Target Checked: "+event.target.checked
        )
        this.isChecked = this.template.querySelector('.cbox').checked
    }
    get aboutPerson(){
        return `${this.person.name} is ${this.person.age} years old. He lives in
        ${this.person.city}. He has a car: ${this.person.hasCar} and 
        insurance: ${this.person.hasInsurance}.`
    }
    toggleCar(){
        this.person.hasCar = !this.person.hasCar
    }
    toggleInsurance(){
        this.person.hasInsurance = !this.person.hasInsurance
    }
}
