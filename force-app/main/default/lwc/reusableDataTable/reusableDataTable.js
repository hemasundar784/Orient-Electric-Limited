import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/DataTableController.getRecords';
import updateRecords from '@salesforce/apex/DataTableController.updateRecords';
import deleteRecord from '@salesforce/apex/DataTableController.deleteRecord';

export default class ReusableDataTable extends LightningElement {
    @api objectName = 'Account';
    @api fieldList = ['Id', 'Name', 'Phone', 'Website']; 
    @api pageSize = 10; // Records per page
    @api enableSorting = false; // Enable sorting
    @api enablePagination = false; // Enable pagination
    @api enableInlineEdit = false; // Enable inline edit
    @api enableDelete = false; // Enable delete functionality
    @api title = 'Data Table'; // Table title
    @api recordId; // Parent record ID for filtering (optional)

    @track records = [];
    @track visibleRecords = [];
    @track draftValues = [];
    @track columns = [];
    @track sortedBy = null;
    @track sortDirection = 'asc';
    @track currentPage = 1;
    @track totalPages = 1;
    @track totalRecords = 0;
    @track isLoading = false;
    @track error = null;
    @track hasRecords = false;

    wiredRecordsResult;

    connectedCallback() {
        this.generateColumns();
    }

    @wire(getRecords, {
        objectName: '$objectName',
        fieldList: '$fieldList',
        recordId: '$recordId'
    })
    wiredRecords(result) {
        this.wiredRecordsResult = result;
        this.isLoading = true;

        if (result.data) {
            this.records = result.data;
            this.totalRecords = result.data.length;
            this.hasRecords = this.totalRecords > 0;
            this.currentPage = 1;
            this.calculateTotalPages();
            this.updatePaginatedData();
            this.error = null;
            this.isLoading = false;
        } else if (result.error) {
            this.handleError(result.error);
            this.isLoading = false;
        }
    }

    generateColumns() {
    if (!this.fieldList || !Array.isArray(this.fieldList)) {
        this.columns = [];
        return;
    }

    // 1. Generate normal schema columns
    const generatedCols = this.fieldList.map(field => ({
        label: this.formatFieldLabel(field),
        fieldName: field,
        type: this.getFieldType(field),
        sortable: this.enableSorting,
        editable: this.enableInlineEdit && field.toLowerCase() !== 'id'
    }));

    // 2. Dynamically push a row action dropdown if delete configurations are turned on
    if (this.enableDelete) {
        generatedCols.push({
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Delete Record', name: 'delete', iconName: 'utility:delete' }
                ]
            }
        });
    }

    this.columns = generatedCols;
}


    formatFieldLabel(fieldName) {
        return fieldName
            .replace(/__c$/, '')
            .replace(/_/g, ' ')
            .split(' ')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }

    getFieldType(fieldName) {
        if (fieldName.includes('Email') || fieldName.includes('email')) return 'email';
        if (fieldName.includes('Phone') || fieldName.includes('phone')) return 'phone';
        if (fieldName.includes('Date') || fieldName.includes('date')) return 'date';
        if (fieldName.includes('Number') || fieldName.includes('number')) return 'number';
        return 'text';
    }

    handleSort(event) {
        if (!this.enableSorting) return;

        const { fieldName, sortDirection } = event.detail;
        this.sortedBy = fieldName;
        this.sortDirection = sortDirection;
        this.records = this.sortRecords([...this.records], fieldName, sortDirection);
        this.currentPage = 1;
        this.updatePaginatedData();
    }

    sortRecords(records, fieldName, sortDirection) {
        return records.sort((a, b) => {
            const aValue = a[fieldName];
            const bValue = b[fieldName];

            if (aValue == null || bValue == null) {
                return aValue == null ? 1 : -1;
            }

            const comparison = String(aValue).localeCompare(String(bValue), undefined, {
                numeric: true,
                sensitivity: 'base'
            });

            return sortDirection === 'asc' ? comparison : -comparison;
        });
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePaginatedData();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updatePaginatedData();
        }
    }

    handleGoToPage(event) {
        const pageNumber = parseInt(event.detail, 10);
        if (pageNumber >= 1 && pageNumber <= this.totalPages) {
            this.currentPage = pageNumber;
            this.updatePaginatedData();
        }
    }

    updatePaginatedData() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        this.visibleRecords = this.records.slice(startIndex, endIndex);
    }

    calculateTotalPages() {
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize) || 1;
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }

    get pageInfo() {
        const startRecord = (this.currentPage - 1) * this.pageSize + 1;
        const endRecord = Math.min(this.currentPage * this.pageSize, this.totalRecords);
        return `${startRecord} - ${endRecord} of ${this.totalRecords}`;
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;

        if (!updatedFields || updatedFields.length === 0) {
            this.showToast('Info', 'No records to update', 'info');
            return;
        }

        this.isLoading = true;

        try {
            await updateRecords({
                objectName: this.objectName,
                records: updatedFields
            });

            this.showToast('Success', 'Records updated successfully', 'success');
            this.draftValues = [];

            // Refresh data
            await refreshApex(this.wiredRecordsResult);
        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'delete') {
            this.confirmDelete(row.Id);
        }
    }

    async confirmDelete(recordId) {
        if (confirm('Are you sure you want to delete this record?')) {
            this.isLoading = true;

            try {
                await deleteRecord({ recordId });
                this.showToast('Success', 'Record deleted successfully', 'success');

                // Refresh data
                await refreshApex(this.wiredRecordsResult);
            } catch (error) {
                this.handleError(error);
            } finally {
                this.isLoading = false;
            }
        }
    }

    handleError(error) {
        const errorMessage = error?.body?.message || error?.message || 'An unexpected error occurred';
        this.error = errorMessage;
        this.showToast('Error', errorMessage, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    get pageNumbers() {
        const pages = [];
        const maxPagesToShow = 5;
        let startPage = Math.max(1, this.currentPage - Math.floor(maxPagesToShow / 2));
        let endPage = Math.min(this.totalPages, startPage + maxPagesToShow - 1);

        if (endPage - startPage < maxPagesToShow - 1) {
            startPage = Math.max(1, endPage - maxPagesToShow + 1);
        }

        for (let i = startPage; i <= endPage; i++) {
            pages.push({
                number: i,
                isActive: i === this.currentPage
            });
        }

        return pages;
    }
}
