import { api, LightningElement } from 'lwc';

/**
 * designAttributes
 * ---------------------
 * Demonstrates:
 *  - How to expose LWC properties to App Builder using @api
 *  - How admins can configure values visually
 *  - How to use renderedCallback() for DOM styling
 */
export default class DesignAttributes extends LightningElement {
    // These values come from Lightning App Builder
    @api displayText;     // Text to show inside the component
    @api imageUrl;        // Image URL supplied by admin
    @api backgroundColor; // Background color selected by admin
    @api cardTitle;       // Card title shown on lightning-card

    /**
     * renderedCallback()
     *  - Runs after the component is rendered.
     *  - Used to apply background color dynamically.
     */
    renderedCallback() {
        const container = this.template.querySelector('.content-box');
        if (container && this.backgroundColor) {
            container.style.backgroundColor = this.backgroundColor;
        }
    }
}
