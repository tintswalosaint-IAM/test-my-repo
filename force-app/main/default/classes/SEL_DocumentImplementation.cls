/**
 * Domain class for Document_Management_Implementation__mdt SObject
 * Fetching records, processing Document_Management_Implementation__mdt should sit here
 *
 * @author Dhiraj Prajapati
 */
public with sharing class SEL_DocumentImplementation {

    public Document_Management_Implementation__mdt getImplementation(String sobjectName, String uniqueIdentifier) {
        List<Document_Management_Implementation__mdt> mdts = new List<Document_Management_Implementation__mdt>();
        mdts = [
            SELECT
                Id,
                Class_Name__c
            FROM
                Document_Management_Implementation__mdt 
            WHERE
                Object_API_Name__c =: sobjectName
            AND
                Unique_Identifier__c =: uniqueIdentifier WITH USER_MODE
            LIMIT 1 
        ];
        return mdts.isEmpty() ? new Document_Management_Implementation__mdt() : mdts?.get(0);
    }

    public Document_Management_Related_Object__mdt getRelatedObjImplementation(String sobjectName) {
        List<Document_Management_Related_Object__mdt> mdts = new List<Document_Management_Related_Object__mdt>();
        mdts = [
            SELECT
                Id,
                Related_SObject_Parent_Field_API_Name__c,
                Class_Name__c
            FROM
                Document_Management_Related_Object__mdt
            WHERE
                Related_SObject_API_Name__c =: sobjectName WITH USER_MODE
            LIMIT 1
        ];
        return mdts.isEmpty() ? new Document_Management_Related_Object__mdt() : mdts?.get(0);
    }
}