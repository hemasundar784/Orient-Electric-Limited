import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';
import { NavigationMixin } from 'lightning/navigation';
/** coreUtilityBase:
 *  Shared base class for LWC components.
 *  Provides: Common default values, Toast helpers, Alert helper, Navigation helpers
 */
export default class CoreUtilityBase extends NavigationMixin(LightningElement) {
    // Common reusable values for all child components
    defaultRecordType = '012XXXXXXXXXXXX';      // Example record type Id
    defaultSObject = 'Contact';                // Common object API name
    defaultAppName = 'Banking_App_Lightning';  // Reusable Lightning app name
    /** Show a toast message */
    showToast(title, message, variant = 'info', mode = 'dismissable') {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
    }
    /** Show an alert dialog */
    async showAlert(label, message, theme = 'info') {
        await LightningAlert.open({ label, message, theme });
    }
    /** Generic navigation wrapper */
    navigate(config) {
        this[NavigationMixin.Navigate](config);
    }
    /** Navigate to a specific record */
    navigateToRecord(recordId) {
        this.navigate({
            type: 'standard__recordPage',
            attributes: { recordId, actionName: 'view' }
        });
    }
    /** Navigate to a Lightning app */
    navigateToApp(appName) {
        this.navigate({
            type: 'standard__app',
            attributes: { appTarget: `c__${appName}` }
        });
    }
    /** Navigate to sObject home page */
    navigateToObjectHome(objectApiName) {
        this.navigate({
            type: 'standard__objectPage',
            attributes: { objectApiName, actionName: 'home' }
        });
    }
    /** Log a message with the component key */
    logMessage(componentKey, message){
        console.log(componentKey+':: '+message)
    }
    /** Log an error with the component key */
    logError(componentKey, message){
        console.error(componentKey+':: '+message)
    }
}