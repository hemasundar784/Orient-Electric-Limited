import DEFAULT_CUSTOMER from '@salesforce/label/c.defaultCustomerId';
import CoreUtilityBase from 'c/coreUtilityBase';

/**
 * utilityDemoComponent
 * --------------------
 * Demo child component that:
 *  - Extends coreUtilityBase
 *  - Uses inherited values (defaultSObject, defaultAppName, etc.)
 *  - Uses shared helpers (toast, alert, navigation)
 *  - Renders buttons from config to avoid duplicate markup
 */
export default class UtilityDemoComponent extends CoreUtilityBase {
    // Shared message config for alert/toast
    config = {
        title: 'Child Component Message', message: 'This is triggered from the child component',
        variant: 'success', mode: 'dismissable'
    };

    // Button metadata for UI generation
    buttonConfigs = [
        { name: 'alert',  label: 'Alert',           variant: 'destructive' },
        { name: 'toast',  label: 'Toast',           variant: 'brand' },
        { name: 'record', label: 'Navigate Record', variant: 'destructive-text' },
        { name: 'app',    label: 'Navigate App',    variant: 'success' },
        { name: 'object', label: 'Navigate Object', variant: 'neutral' }
    ];

    // Map actions by button name
    actions = {
        alert: () => this.showAlert('Alert', this.config.message, 'warning'),
        toast: () =>
            this.showToast(
                this.config.title, this.config.message,
                this.config.variant, this.config.mode
            ),
        record: () => this.navigateToRecord(DEFAULT_CUSTOMER),
        app: () => this.navigateToApp(this.defaultAppName),
        object: () => this.navigateToObjectHome(this.defaultSObject)
    };

    /** Handle button click */
    handleAction(event) {
        const actionName = event.target.name;
        const action = this.actions[actionName];
        if (action) {
            action();
        }
    }
}