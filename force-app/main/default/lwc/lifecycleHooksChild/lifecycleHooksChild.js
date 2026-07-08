import CoreUtilityBase from 'c/coreUtilityBase';
/**
 * lifecycleHooksChild
 * -------------------
 * Child component used to demonstrate:
 *  - Its own lifecycle hooks (constructor, connected, rendered, disconnected)
 *  - How an error thrown here is caught by the parent`s errorCallback
 */
export default class LifecycleHooksChild extends CoreUtilityBase {
    constructor() {
        super();
        this.logMessage(`LCH | Child`, `constructor() → instance created`);
    }
    connectedCallback() {
        this.logMessage(`LCH | Child`, `connectedCallback() → added to DOM`);
    }
    renderedCallback() {
        this.logMessage(`LCH | Child`, `renderedCallback() → child rendered`);
    }
    disconnectedCallback() {
        this.logMessage(`LCH | Child`, `disconnectedCallback() → removed from DOM`);
    }
    handleRaiseError() {
        this.logMessage(`LCH | Child`, `EVENT: handleRaiseError() → throwing an error now`);
        throw new Error(`This is a deliberate error thrown from the child component.`);
    }
}
