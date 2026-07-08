public with sharing class DataTableController {
    
    // Serialisable wrapper class to replace Database.SaveResult
    public class SaveResultWrapper {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public List<String> errors { get; set; }

        public SaveResultWrapper(Database.SaveResult sr) {
            this.isSuccess = sr.isSuccess();
            this.recordId = sr.getId();
            this.errors = new List<String>();
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    this.errors.add(err.getMessage());
                }
            }
        }
    }

    /**
     * @description Retrieves records from a specified object with dynamic field list
     * @param objectName The API name of the object (e.g., 'Account', 'Contact')
     * @param fieldList List of field API names to retrieve
     * @param recordId Optional parent record ID for filtering
     * @return List of records as maps with field values
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRecords(String objectName, List<String> fieldList, String recordId) {
        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Object name is required');
        }

        if (fieldList == null || fieldList.isEmpty()) {
            throw new AuraHandledException('Field list cannot be empty');
        }

        List<Map<String, Object>> results = new List<Map<String, Object>>();

        try {
            // Validate that fields exist on the object
            validateFields(objectName, fieldList);

            // Build dynamic SOQL query
            String query = buildQuery(objectName, fieldList, recordId);
            List<SObject> records = Database.query(query);

            // Convert SObjects to maps
            for (SObject record : records) {
                Map<String, Object> recordMap = new Map<String, Object>();
                for (String field : fieldList) {
                    recordMap.put(field, record.get(field));
                }
                results.add(recordMap);
            }

            return results;
        } catch (Exception e) {
            System.debug('Error retrieving records: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving records: ' + e.getMessage());
        }
    }

    /**
     * @description Updates multiple records with the provided field values
     * @param objectName The API name of the object
     * @param records List of record maps containing Id and fields to update
     * @return List of SaveResultWrapper for each updated record
     */
    @AuraEnabled
    public static List<SaveResultWrapper> updateRecords(String objectName, List<Map<String, Object>> records) {
        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Object name is required');
        }

        if (records == null || records.isEmpty()) {
            throw new AuraHandledException('Records list cannot be empty');
        }

        try {
            List<SObject> recordsToUpdate = new List<SObject>();

            for (Map<String, Object> recordMap : records) {
                // Using JSON serialization guarantees safe type casting for Ids, dates, and numbers
                String jsonStr = JSON.serialize(recordMap);
                SObject record = (SObject) JSON.deserialize(jsonStr, Type.forName('Schema.' + objectName));
                recordsToUpdate.add(record);
            }

            // Perform partial updates (allOrNone = false)
            List<Database.SaveResult> results = Database.update(recordsToUpdate, false);
            List<SaveResultWrapper> wrappedResults = new List<SaveResultWrapper>();

            // Build wrapper response
            for (Database.SaveResult result : results) {
                wrappedResults.add(new SaveResultWrapper(result));
            }

            return wrappedResults;
        } catch (Exception e) {
            System.debug('Error updating records: ' + e.getMessage());
            throw new AuraHandledException('Error updating records: ' + e.getMessage());
        }
    }

    /**
     * @description Deletes a single record
     * @param recordId The ID of the record to delete
     * @return true if delete was successful
     */
    @AuraEnabled
    public static Boolean deleteRecord(String recordId) {
        if (String.isBlank(recordId)) {
            throw new AuraHandledException('Record ID is required');
        }

        try {
            Database.DeleteResult result = Database.delete(recordId, false);

            if (!result.isSuccess()) {
                List<String> errors = new List<String>();
                for (Database.Error error : result.getErrors()) {
                    errors.add(error.getMessage());
                }
                throw new AuraHandledException('Delete failed: ' + String.join(errors, ', '));
            }

            return true;
        } catch (Exception e) {
            System.debug('Error deleting record: ' + e.getMessage());
            throw new AuraHandledException('Error deleting record: ' + e.getMessage());
        }
    }

    /**
     * @description Validates that fields exist on the specified object
     * @param objectName The API name of the object
     * @param fieldList List of field names to validate
     */
    private static void validateFields(String objectName, List<String> fieldList) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        if (targetType == null) {
            throw new AuraHandledException('Invalid object name: ' + objectName);
        }

        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();

        for (String field : fieldList) {
            if (!fieldMap.containsKey(field.toLowerCase())) {
                throw new AuraHandledException('Field ' + field + ' does not exist on object ' + objectName);
            }
        }
    }

    /**
     * @description Builds a dynamic SOQL query based on object name and field list
     * @param objectName The API name of the object
     * @param fieldList List of field names to query
     * @param recordId Optional parent record ID for filtering
     * @return The SOQL query string
     */
    private static String buildQuery(String objectName, List<String> fieldList, String recordId) {
    String fieldString = String.join(fieldList, ',');
    String query = 'SELECT ' + fieldString + ' FROM ' + objectName;
    
    // Dynamically filter if a parent recordId is supplied
    if (String.isNotBlank(recordId)) {
        String relationshipField = getRelationshipField(objectName, recordId);
        if(String.isNotBlank(relationshipField)) {
            query += ' WHERE ' + relationshipField + ' = :recordId';
        }
    }
    
    query += ' ORDER BY CreatedDate DESC LIMIT 10000';
    return query;
}

// Helper method to dynamically deduce the foreign key field
private static String getRelationshipField(String objectName, String recordId) {
    if (String.isBlank(recordId)) return null;
    Id targetId = (Id)recordId;
    String parentObjectType = targetId.getSObjectType().getDescribe().getName();
    
    // Simple lookups for standard parent-child relationships
    if (parentObjectType == 'Account' && objectName == 'Contact') return 'AccountId';
    if (parentObjectType == 'Account' && objectName == 'Opportunity') return 'AccountId';
    if (parentObjectType == 'Account' && objectName == 'Case') return 'AccountId';
    
    // Fallback: search for custom matching __c patterns if needed
    return null; 
}

}
