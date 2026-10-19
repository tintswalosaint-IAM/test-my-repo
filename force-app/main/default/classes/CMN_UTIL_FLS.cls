/**
 * @description Utility class for checking FLS permissions and updating records.
 * @author Ofentse Sacha
 * @version 1.0
 * @date June 2024
 */
public with sharing class  CMN_UTIL_FLS {
    
    /**
     * @description  CMN_UTIL_FLS constructor
     */
    @TestVisible
    private  CMN_UTIL_FLS() {
    }

    /**
     * @description Final logger instance used for logging messages in the  CMN_UTIL_FLS class.
     * Created using the sbgplatform.rflib_LoggerUtil factory method.
     */
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_UTIL_FLS');

    /**
     * @description Checks FLS permissions and updates the provided list of records.
     * @param records The list of records to be updated.
     * @throws DmlException if the update operation fails.
     */
    public static void updateRecordsWithFLSCheck(List<SObject> records) {
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.UPDATABLE,
            records, true
        );

        try {
            update decision.getRecords();
        } catch (DmlException e) {
            logger.error('Error updating records: ' + e.getMessage() + ' Records: ' + JSON.serializePretty(records));
            throw e;
        }
    }

    /**
     * @description Checks FLS permissions and updates the provided record.
     * @param record The record to be updated.
     * @throws DmlException if the update operation fails.
     */
    public static void updateRecordWithFLSCheck(SObject record) {
        List<SObject> records = new List<SObject>{ record };
        updateRecordsWithFLSCheck(records);
    }

    /**
     * @description Checks FLS permissions and inserts the provided list of records.
     * @param records The list of records to be inserted.
     * @throws DmlException if the insert operation fails.
     */
    public static void insertRecordsWithFLSCheck(List<SObject> records) {
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE, 
            records, true
        );

        try {
            insert decision.getRecords();
        } catch (DmlException e) {
            logger.error('Error inserting records: ' + e.getMessage() + ' Records: ' + JSON.serializePretty(records));
            throw e;
        }
    }

    /**
     * @description Checks FLS permissions and inserts the provided record.
     * @param record The record to be inserted.
     * @throws DmlException if the insert operation fails.
     */
    public static void insertRecordWithFLSCheck(SObject record) {
        List<SObject> records = new List<SObject>{ record };
        insertRecordsWithFLSCheck(records);
    }
}