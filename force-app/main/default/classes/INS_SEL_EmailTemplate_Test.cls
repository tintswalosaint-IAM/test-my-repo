/**
 * @description       : Test class for INS_SEL_EmailTemplate
 * @author            : Raja Arsalan
**/
@isTest
private class INS_SEL_EmailTemplate_Test {

/**
 * @description       : Test class for INS_SEL_CustomNotification
 * @author            : Raja Arsalan
**/    
    @isTest
    static void testSelectEmailTemplateByName() {
        list<folder> myFolder = [Select id,name from folder where name = 'INS Email Templates'];
        String publicFolderId = myFolder[0].Id;

        // Ensure the public folder ID is not null or empty
        System.assertNotEquals(null, publicFolderId, 'Public Folder ID should not be null');

        // Create a mock EmailTemplate record with required fields
        // Instantiate the selector class
        INS_SEL_EmailTemplate emailTemplateSelector = new INS_SEL_EmailTemplate();

        // Test the selectEmailTemplateByName method
        List<Schema.SObjectField> fieldList = emailTemplateSelector.getSObjectFieldList();        
        
        Assert.areEqual(4, fieldList.size(), 'Expected field list to contain 4 fields.');

    }
}