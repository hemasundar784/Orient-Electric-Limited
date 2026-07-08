import { LightningElement } from 'lwc';

export default class ReusableDataTableExample extends LightningElement {
    // Configuration properties for the datatable
    title = 'Accounts';
    objectName = 'Account';
    fieldList = ['Id', 'Name', 'Phone', 'BillingCity', 'Industry'];
    pageSize = 10;
    enableSorting = true;
    enablePagination = true;
    enableInlineEdit = true;
    enableDelete = true;

    handleDataTableEvent(event) {
        console.log('DataTable Event:', event.detail);
    }
}
