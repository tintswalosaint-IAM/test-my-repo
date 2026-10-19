/**
* @description Class used as Wrapper Class to display field info
*
* @author Yashwanth Tikkisetti (yaswanth.tikkisetti@standadrdbank.co.za)
*
* @date 12-03-2023
*
**********************************************
* @last modified on  : 29-02-2024
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-36380, Class to display Field types used for SBO-UK
*/
@isTest
public class AOB_DTO_FIELD_TEST {
    @isTest
    static void testBasicFieldTypes() {
        List<Application__c> testApps = BCB_DAL_TestFactory.createApplication(1);
        insert testApps;

        // Create and test each field type individually to ensure proper coverage
        List<AOB_Field__c> fields = new List<AOB_Field__c>{
            // Group 1 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Combobox'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'ComboboxReadonly'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'ConsentBox'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Radio'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Empty'),

            // Group 2 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Text'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Textdefault'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'MasterDetail'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'defaultcountry'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Textfunds'),

            // Group 3 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Pleasenote'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Accordian Count'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'photosignature'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'TextReadOnly'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Date'),

            // Group 4 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'isExpDate'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Text Area'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'isMutipleFiles'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Lookup'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Percent'),

            // Group 5 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Label'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'WarningInfo'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Table'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Sub Accordian'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Currency'),

            // Group 6 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Addbutton'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Accordian'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'SubSection'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Table'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Email'),

            // Group 7 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Currency'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Number'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'File Upload'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'MultiSelectSearch'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'MultiSelectReadonly'),

            // Group 8 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'PicklistWithInput'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Sub Accordian'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Add Accordian'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Checkbox'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Checkbox Group'),

            // Group 9 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'informalModal'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'isdataprivacy'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'directordetails'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'memberdetails'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Text Content'),

            // Group 10 of field types
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'Card'),
            new AOB_Field__c(AOB_Required__c = true, AOB_Type__c = 'TermsEngagement')
        };

        insert fields;

        Test.startTest();
        List<AOB_DTO_Field> dtoFields = new List<AOB_DTO_Field>();
        for(AOB_Field__c field : fields) {
            dtoFields.add(new AOB_DTO_Field(field, testApps));
        }
        Test.stopTest();

        // Verify each field was created correctly
        for(AOB_DTO_Field dto : dtoFields) {
            Assert.areEqual(true, dto.isRequired, 'Field should be required');
        }
    }

    @isTest
    static void testOutputFieldType() {
        // Create test application with data
        List<Application__c> testApps = new List<Application__c>();
        Application__c app = new Application__c(
            AOB_Email__c = 'test@example.com'
        );
        testApps.add(app);
        insert testApps;

        // Test Output field with SFField
        AOB_Field__c outputField = new AOB_Field__c(
            AOB_Type__c = 'Output',
            AOB_SFField__c = 'AOB_Email__c',
            AOB_Required__c = true
        );

        Test.startTest();
        AOB_DTO_Field dtoField = new AOB_DTO_Field(outputField, testApps);
        Test.stopTest();

        Assert.areEqual(true, dtoField.isOutput, 'isOutput should be true');
        Assert.areEqual('test@example.com', dtoField.value, 'Value should match application field');
    }

    @isTest
    static void testParentChildFields() {
        List<Application__c> testApps = new List<Application__c>();

        // Create parent field
        AOB_Field__c parentField = new AOB_Field__c(
            AOB_Type__c = 'Text',
            AOB_Required__c = true,
            AOB_Label__c = 'Parent Field',
            AOB_sequence__c = '1'
        );
        insert parentField;

        // Create child field with parent reference
        AOB_Field__c childField = new AOB_Field__c(
            AOB_Type__c = 'Text',
            AOB_Required__c = true,
            AOB_Parent__c = parentField.Id,
            AOB_Label__c = 'Child Field',
            AOB_sequence__c = '2',
            AOB_ParentControllingValue__c = 'Test Value'
        );

        Test.startTest();
        AOB_DTO_Field parentDTO = new AOB_DTO_Field(parentField, testApps);
        AOB_DTO_Field childDTO = new AOB_DTO_Field(childField, testApps);
        Test.stopTest();

        Assert.areEqual(null, parentDTO.parent, 'Parent field should have no parent');
        Assert.areEqual(parentField.Id, childDTO.parent, 'Child field should reference parent');
        Assert.areEqual(true, childDTO.isHidden, 'Child field should be hidden');
        Assert.areEqual('Test Value', childDTO.parentControllingValue, 'Parent controlling value should be set');
    }

    @isTest
    static void testCompareToMethod() {
        List<Application__c> testApps = new List<Application__c>();

        // Create fields with different sequences
        List<AOB_Field__c> fields = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_Type__c = 'Text', AOB_Required__c = true, AOB_sequence__c = '1'),
            new AOB_Field__c(AOB_Type__c = 'Text', AOB_Required__c = true, AOB_sequence__c = '2'),
            new AOB_Field__c(AOB_Type__c = 'Text', AOB_Required__c = true, AOB_sequence__c = null),
            new AOB_Field__c(AOB_Type__c = 'Text', AOB_Required__c = true)
        };

        List<AOB_DTO_Field> dtoFields = new List<AOB_DTO_Field>();

        Test.startTest();
        for(AOB_Field__c field : fields) {
            dtoFields.add(new AOB_DTO_Field(field, testApps));
        }

        // Test all comparison scenarios
        Integer result1 = dtoFields[0].compareTo(dtoFields[1]); // 1 vs 2
        Integer result2 = dtoFields[1].compareTo(dtoFields[0]); // 2 vs 1
        Integer result4 = dtoFields[2].compareTo(dtoFields[0]); // null vs 1
        Integer result5 = dtoFields[2].compareTo(dtoFields[3]); // null vs null
        Test.stopTest();

        Assert.areEqual(-1, result1, 'Lower sequence should return -1');
        Assert.areEqual(1, result2, 'Higher sequence should return 1');
        Assert.areEqual(-1, result4, 'Null vs non-null should return -1');
        Assert.areEqual(0, result5, 'Null vs null should return 0');
    }

    @isTest
    static void testFieldAttributes() {
        List<Application__c> testApps = new List<Application__c>();

        AOB_Field__c field = new AOB_Field__c(
            AOB_Required__c = true,
            AOB_Type__c = 'Text',
            AOB_Label__c = 'Test Label',
            AOB_HelpText__c = 'Help Text',
            AOB_Placeholder__c = 'Placeholder',
            AOB_pattern__c = '[A-Z]+',
            AOB_ErrorMessage__c = 'Error Message',
            AOB_sequence__c = '1',
            AOB_Max_Length__c = '100',
            AOB_MinLength__c = '10',
            AOB_Values__c = 'Value1;Value2',
            AOB_SFField__c = 'TestField__c',
            AOB_SFObject__c = 'TestObject__c',
            AOB_MRITable__c = 'TestTable',
            Default_Value__c = 'Default'
        );

        Test.startTest();
        AOB_DTO_Field dtoField = new AOB_DTO_Field(field, testApps);
        Test.stopTest();

        // Verify all attributes were set correctly
        Assert.areEqual('Test Label', dtoField.label, 'Label should match');
        Assert.areEqual('Help Text', dtoField.helpTxt, 'Help text should match');
        Assert.areEqual('Placeholder', dtoField.placeholder, 'Placeholder should match');
        Assert.areEqual('[A-Z]+', dtoField.pattern, 'Pattern should match');
        Assert.areEqual('Error Message', dtoField.errorMessage, 'Error message should match');
        Assert.areEqual('100', dtoField.maxlength, 'Max length should match');
        Assert.areEqual('10', dtoField.minlength, 'Min length should match');
        Assert.areEqual('Value1;Value2', dtoField.values, 'Values should match');
        Assert.areEqual('TestField__c', dtoField.sfFieldAPIName, 'SF Field API Name should match');
        Assert.areEqual('TestObject__c', dtoField.sfObjectAPIName, 'SF Object API Name should match');
        Assert.areEqual('TestTable', dtoField.mriTable, 'MRI Table should match');
        Assert.areEqual('Default', dtoField.defaultValue, 'Default value should match');
    }
}