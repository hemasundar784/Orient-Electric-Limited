const PAGE_SIZE = 10;
// Datatable column configuration
export function getColumns() {
    return [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'Account Number', fieldName: 'accountNumber', type: 'text' },
        { label: 'Phone', fieldName: 'phone', type: 'phone' },
        { label: 'Fax', fieldName: 'fax', type: 'text' },
        { label: 'Email', fieldName: 'email', type: 'email' },
        { label: 'Rating', fieldName: 'rating', type: 'text' },
        { label: 'Industry', fieldName: 'industry', type: 'text' }
    ];
}
// Calculate total pages
export function calculateTotalPages(totalRecords) {
    return Math.ceil(totalRecords / PAGE_SIZE) || 1;
}
// Return records for current page
export function getPaginatedData(records, currentPage) {
    const startIndex = (currentPage - 1) * PAGE_SIZE;
    const endIndex = startIndex + PAGE_SIZE;
    return records.slice(startIndex, endIndex);
}
// Move to next page
export function getNextPage(currentPage, totalPages) {
    return currentPage < totalPages
        ? currentPage + 1
        : currentPage;
}
// Move to previous page
export function getPreviousPage(currentPage) {
    return currentPage > 1
        ? currentPage - 1
        : currentPage;
}
// Check previous button state
export function isPreviousDisabled(currentPage) {
    return currentPage <= 1;
}
// Check next button state
export function isNextDisabled(currentPage, totalPages) {
    return currentPage >= totalPages;
}