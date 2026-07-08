# Reusable DataTable LWC Component

A flexible, reusable Lightning Web Component (LWC) for displaying, sorting, paginating, and editing data from any Salesforce object.

## Features

- ✅ **Dynamic Data Display** - Display any Salesforce object with custom field selection
- ✅ **Sorting** - Click column headers to sort ascending/descending
- ✅ **Pagination** - Navigate through large datasets with configurable page size
- ✅ **Inline Editing** - Edit records directly in the datatable
- ✅ **Delete Functionality** - Remove records with confirmation
- ✅ **Responsive Design** - Works on desktop and mobile devices
- ✅ **Error Handling** - Graceful error messages and loading states
- ✅ **Type Detection** - Automatic field type detection (email, phone, date, etc.)

## Component Structure

### Files

- `reusableDataTable.js` - Main component logic
- `reusableDataTable.html` - UI template with Lightning components
- `reusableDataTable.css` - Styling and responsive design
- `reusableDataTable.js-meta.xml` - Component configuration

### Apex Controller

- `DataTableController.cls` - Handles all CRUD operations
- `DataTableControllerTest.cls` - Comprehensive unit tests with 95%+ coverage

## Usage

### Basic Implementation

```html
<c-reusable-data-table
    title="Accounts"
    object-name="Account"
    field-list={fieldList}
    page-size="10"
    enable-sorting="true"
    enable-pagination="true"
    enable-inline-edit="true"
    enable-delete="true"
>
</c-reusable-data-table>
```

### Parent Component (JavaScript)

```javascript
import { LightningElement } from 'lwc';

export default class MyComponent extends LightningElement {
    title = 'My Accounts';
    objectName = 'Account';
    fieldList = ['Id', 'Name', 'Phone', 'BillingCity', 'Industry'];
    pageSize = 10;
}
```

## Configuration Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | String | 'Data Table' | Title displayed above the table |
| `objectName` | String | 'Account' | API name of the Salesforce object |
| `fieldList` | Array | ['Id', 'Name'] | List of field API names to display |
| `pageSize` | Integer | 10 | Number of records per page |
| `enableSorting` | Boolean | true | Enable column sorting |
| `enablePagination` | Boolean | true | Enable pagination controls |
| `enableInlineEdit` | Boolean | true | Allow inline record editing |
| `enableDelete` | Boolean | true | Show delete action |
| `recordId` | String | null | Optional: parent record ID for filtering |

## Apex Controller Methods

### getRecords()
Retrieves records from a specified object with dynamic field list.

```apex
List<Map<String, Object>> getRecords(
    String objectName,
    List<String> fieldList,
    String recordId
)
```

**Parameters:**
- `objectName` - API name of the object (e.g., 'Account', 'Contact')
- `fieldList` - List of field API names to retrieve
- `recordId` - Optional parent record ID for filtering

**Returns:** List of records as maps with field values

### updateRecords()
Updates multiple records with provided field values.

```apex
List<Database.SaveResult> updateRecords(
    String objectName,
    List<Map<String, Object>> records
)
```

**Parameters:**
- `objectName` - API name of the object
- `records` - List of record maps containing Id and fields to update

**Returns:** Database.SaveResult for each updated record

### deleteRecord()
Deletes a single record by ID.

```apex
Boolean deleteRecord(String recordId)
```

**Parameters:**
- `recordId` - The ID of the record to delete

**Returns:** true if delete was successful

## Unit Tests

The `DataTableControllerTest` class includes comprehensive tests covering:

- ✅ Successful data retrieval with multiple fields
- ✅ Error handling for null/invalid object names
- ✅ Error handling for empty/invalid field lists
- ✅ Successful record updates (single and multiple)
- ✅ Error handling for update operations
- ✅ Successful record deletion
- ✅ Error handling for invalid record IDs
- ✅ Field validation and type detection
- ✅ Large dataset handling
- ✅ Concurrent operations

**Test Coverage:** >95%

### Running Tests

```bash
# Run all tests in the class
sfdx force:apex:test:run -n DataTableControllerTest -r human

# Run with code coverage
sfdx force:apex:test:run -n DataTableControllerTest -r human -c
```

## Field Type Detection

The component automatically detects field types for proper rendering:

- `email` - Email fields
- `phone` - Phone number fields
- `date` - Date fields
- `number` - Numeric fields
- `text` - All other fields (default)

## Pagination Details

- Shows 5 page buttons at a time
- Automatically adjusts when at start/end of dataset
- Previous/Next buttons are disabled appropriately
- Page info displays: "Page X of Y" and "Record X-Y of Total"

## Security Considerations

- Component uses `with sharing` keyword for row-level security
- Field-level security is enforced through Apex
- Dynamic SOQL prevents injection attacks through validation
- All user input is sanitized

## Performance Optimization

- Results are cached via `@AuraEnabled(cacheable=true)` for read operations
- Limited to 10,000 records per query
- Pagination reduces DOM elements rendered
- Efficient sorting algorithm for client-side data

## Error Handling

Errors are displayed to users with clear, actionable messages:

- `Object name is required` - Specify a valid object
- `Field list cannot be empty` - Provide at least one field
- `Field X does not exist on object Y` - Check field API names
- `Invalid object name: X` - Object doesn't exist in org

## Example Implementation

See `reusableDataTableExample` LWC for a complete working example.

```javascript
// reusableDataTableExample.js
export default class ReusableDataTableExample extends LightningElement {
    title = 'Accounts';
    objectName = 'Account';
    fieldList = ['Id', 'Name', 'Phone', 'BillingCity', 'Industry'];
    pageSize = 10;
}
```

```html
<!-- reusableDataTableExample.html -->
<template>
    <lightning-card title={title} icon-name="standard:datatable">
        <div class="slds-var-m-around_medium">
            <c-reusable-data-table
                title={title}
                object-name={objectName}
                field-list={fieldList}
                page-size={pageSize}
                enable-sorting="true"
                enable-pagination="true"
                enable-inline-edit="true"
                enable-delete="true"
            >
            </c-reusable-data-table>
        </div>
    </lightning-card>
</template>
```

## Best Practices

1. **Limit Field List** - Only include necessary fields to improve performance
2. **Set Appropriate Page Size** - Balance between usability and performance (10-50 records)
3. **Monitor API Usage** - Large field lists and page sizes increase API calls
4. **Test with Real Data** - Pagination and sorting behavior varies with different data types
5. **Use in Record Pages** - Component works best in record pages with parent context
6. **Secure Object Access** - Ensure users have access to the objects and fields being displayed

## Troubleshooting

### "Unable to find Apex action method"
- Push changes to your org: `sfdx force:source:push`
- Reload VS Code: Ctrl+Shift+P → "Developer: Reload Window"
- Clear browser cache

### Records not loading
- Check browser console for errors (F12)
- Verify object name is correct
- Ensure fields exist on the object
- Check user permissions for object/fields

### Inline edit not working
- Verify `enableInlineEdit` is true
- Check field permissions (must be editable)
- Ensure field types are supported
- Verify no field-level security restrictions

### Pagination shows incorrect totals
- Check if field list contains all necessary fields
- Verify record count is accurate in your org
- Try refreshing the page

## API Version

Requires Salesforce API version 59.0 or higher

## License

This component is provided as-is for use in your Salesforce org.
