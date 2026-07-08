import CoreUtilityBase from 'c/coreUtilityBase';
/**
 * lifecycleHooksParent
 * --------------------
 * Parent component used to demonstrate:
 *  - All major lifecycle hooks (constructor, connected, rendered, disconnected, error)
 *  - Re-rendering when reactive state (count) changes
 *  - Creating and destroying a child component via lwc:if
 *  - Handling errors thrown by the child using errorCallback
 */
export default class LifecycleHooksParent extends CoreUtilityBase {
    // Reactive state used to trigger re-renders
    count = 0;

    // Controls whether the child component is rendered in the DOM
    showChild = false;

    /**
     * constructor()
     *  - Called when the component instance is created.
     *  - Use for basic initialization (no DOM access here).
     */
    constructor() {
        super();
        this.logMessage(`LCH | Parent`, `constructor() → instance created`);
    }

    /**
     * connectedCallback()
     *  - Called when the component is inserted into the DOM.
     *  - Good place for initial data setup, timers, or subscriptions.
     */
    connectedCallback() {
        this.logMessage(`LCH | Parent`, `connectedCallback() → added to DOM`);
    }

    /**
     * renderedCallback()
     *  - Called after every render (initial render + each re-render).
     *  - Use only for logic that depends on the rendered DOM.
     */
    renderedCallback() {
        this.logMessage(
            `LCH | Parent`, `renderedCallback() → rendered with count=${this.count}, showChild=${this.showChild}`
        );
    }

    /**
     * disconnectedCallback()
     *  - Called when the component is removed from the DOM.
     *  - Use for cleanup (intervals, subscriptions, event listeners).
     */
    disconnectedCallback() {
        this.logMessage(`LCH | Parent`,`LIFECYCLE: disconnectedCallback() → removed from DOM`);
    }

    /**
     * errorCallback(error, stack)
     *  - Called when an error is thrown in this component
     *    or any of its child components.
     *  - Use to log, report, or show a user-friendly message.
     */
    errorCallback(error, stack) {
        this.logError(`LCH | Parent`,`errorCallback() → error received from child\nError: ${error},\nStack: ${stack},\nMessage: ${error?.message}`);
    }

    /**
     * UI handler: increment the count.
     *  - This updates reactive state and causes a re-render.
     */
    handleIncrement() {
        this.count++;
        this.logMessage(`LCH | Parent`,`EVENT: handleIncrement() → count updated to ${this.count}`);
    }

    /**
     * UI handler: toggle the child component.
     *  - When showChild changes:
     *      true  → child created & inserted → child's constructor/connected/rendered run
     *      false → child removed → child's disconnectedCallback runs
     */
    handleToggleChild() {
        this.showChild = !this.showChild;
        this.logMessage(`LCH | Parent`, `EVENT: handleToggleChild() → showChild set to ${this.showChild}`);
    }
}
