import { LightningElement, wire } from 'lwc';
import { getColumns, calculateTotalPages, getPaginatedData, getNextPage, getPreviousPage, 
    isPreviousDisabled  as checkPreviousDisabled, isNextDisabled as checkNextDisabled} from './utils';
import fetchProspects from '@salesforce/apex/LWCUtility.getProspects';

export default class ProspectListView extends LightningElement {
    columns = getColumns() // Datatable columns
    allProspects = []; // Full dataset
    visibleProspects = []; // Current visible records
    isLoading = true; noRecords = false; error; // UI states
    currentPage; totalPages; // Pagination state
    // Fetch records from Apex
    @wire (fetchProspects) wiredProspects({data, error}){
        this.isLoading = false;
        if(data) this.handleSuccess(data)
        else if(error)  this.handleError(error)
    }
    // Handle success response
    handleSuccess(data){
        this.error = null;
        this.log(`Total Records → ${data.length}`);
        this.noRecords = data.length == 0;
        this.allProspects = data;
        this.currentPage = 1;
        this.totalPages = calculateTotalPages(data.length)
        this.updatePaginatedData();
    }
    // Handle error response
    handleError(error){
        console.error('Error loading prospects: ', error);
        this.noRecords = true;
        this.allProspects = []
        this.visibleProspects = []
        this.error = error;
    }
    // Update current page records
    updatePaginatedData(){
        this.visibleProspects = getPaginatedData(this.allProspects, this.currentPage)
        this.log(`Visible Records:: ${JSON.stringify(this.visibleProspects, null, 1)}`)
        this.log(`Total Pages: ${this.totalPages},\n      Current Page: ${this.currentPage},\n      Visible Records: ${this.visibleProspects.length}`);
    }
    // Next page
    handleNext() {
        this.currentPage = getNextPage(this.currentPage,this.totalPages);
        this.updatePaginatedData();
    }
    // Previous page
    handlePrev() {
        this.currentPage = getPreviousPage(this.currentPage);
        this.updatePaginatedData();
    }
    // Disable previous button
    get isPrevDisabled() {
        return checkPreviousDisabled(this.currentPage);
    }
    // Disable next button
    get isNextDisabled() {
        return checkNextDisabled(this.currentPage, this.totalPages);
    }
    // Check records exist
    get hasData(){
        return this.allProspects?.length > 0
    }
    // logging function
    log(message){
        console.log(`PLV:: ${message}`)
    }
}