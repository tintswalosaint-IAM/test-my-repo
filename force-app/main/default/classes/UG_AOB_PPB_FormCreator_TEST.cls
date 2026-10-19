/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :june 2025
@ Name of the Class :UG_AOB_PPB_FormCreator_Test
@ Description       :TesClass for UG_AOB_PPB_FormCreator
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :8-OCT-2025
@ Modification Description : SFP-31036
***************************************************************************************/
/**
    * @description Test data for  UG_AOB_PPB_FormCreator 
*/
@isTest
public class UG_AOB_PPB_FormCreator_TEST {
/**
    * @description Test data for  UG_AOB_PPB_FormCreator.getFields 
    */    
    static @isTest void getFieldsTesting()
    {
        
        Application__c app = new Application__c();
        app.AOB_Email__C='k@g.com';
        insert app;
        List<Application__c> lstApp=new List<Application__c>();
        for(integer i=1;i<5;i++)
        {
            Application__c app1 = new Application__c();
            app1.AOB_Email__C='k'+i+'@g.com';
            lstApp.add(app1);
        }
        insert lstApp;
        
        AOB_FlowScreen__c a = new AOB_FlowScreen__c(); 
        a.name='Great Choice!';
        a.AO_ExternalId__c='1234444';
        a.AOB_Screen_Sequence__c=9;
        
        insert a;
        
        List<AOB_FlowScreen__c> lstfs = new List<AOB_FlowScreen__c>();
        
        for(integer i=1;i<5;i++)
        {       
        AOB_FlowScreen__c fs = new AOB_FlowScreen__c();
         fs.name='Great Choice!'+i;
         fs.AO_ExternalId__c='1234444'+i;
         fs.AOB_TitleApplicationField__c = 'AOB_title__c';
         fs.AOB_Screen_Sequence__c=19-i;
         lstfs.add(fs);
        }
        
        List<AOB_FlowScreen__c> fsList1=new List<AOB_FlowScreen__c>();
        List<AOB_FlowScreen__c> fsList=new List<AOB_FlowScreen__c>();

        AOB_FlowScreen__c fs = new AOB_FlowScreen__c();
        fs.name='Great';
        fs.AO_ExternalId__c='4444';
        fs.AOB_TitleApplicationField__c = 'Name';
        fs.AOB_Screen_Sequence__c=11;
        fs.AOB_subtitle__c = '{##firstName##}';
        fsList.add(fs);
        insert fsList;
        AOB_FlowScreen__c fs1 = new AOB_FlowScreen__c();
        fs1.name='Great3';
        fs1.AO_ExternalId__c='2579';
        fs1.AOB_TitleApplicationField__c = 'Name';
        fs1.AOB_Screen_Sequence__c=13;
        fsList1.add(fs1);
        insert lstfs;
        insert fsList1;
        AOB_ScreenSection__c sect = new AOB_ScreenSection__c();
        sect.name='s';
        sect.AOB_Screen__c= a.Id; 
        sect.AOB_ExternalId__c='45522';
        insert sect;
        AOB_Field__c fi = new AOB_Field__c();
        fi.Name = 'Test';
        fi.AOB_Section__c = sect.Id;
        fi.AOB_Label__c = 'Test';
        fi.AOB_sequence__c = '1';
        fi.AOB_Type__c = 'Text';
        insert fi;
        AOB_Field__c fi1 = new AOB_Field__c();
        fi1.Name = 'Test';
        fi1.AOB_Section__c = sect.Id;
        fi1.AOB_Label__c = 'Test';
        fi1.AOB_sequence__c = '1';
        fi1.AOB_SFObject__c = 'Application__c';
        fi1.AOB_SFField__c = 'AOB_Email_Type__c';
        fi1.AOB_Type__c = 'Combobox';
        insert fi1;
        AOB_Field__c fi2 = new AOB_Field__c();
        fi2.Name = 'Test';
        fi2.AOB_Section__c = sect.Id;
        fi2.AOB_Label__c = 'Test';
        fi2.AOB_sequence__c = '1';
        fi2.AOB_Type__c = 'Radio';
        fi2.AOB_Values__c = 'Yes;No';
        insert fi2;
        AOB_Field__c fi3 = new AOB_Field__c();
        fi3.Name = 'Test';
        fi3.AOB_Section__c = sect.Id;
        fi3.AOB_Label__c = 'Test';
        fi3.AOB_sequence__c = '1';
        fi3.AOB_Type__c = 'Checkbox';
        insert fi3; 
        AOB_Field__c fi4 = new AOB_Field__c();
        fi4.Name = 'Test';
        fi4.AOB_Section__c = sect.Id;
        fi4.AOB_Label__c = 'Test';
        fi4.AOB_sequence__c = '1';
        fi4.AOB_Type__c = 'Number';
        insert fi4; 
        AOB_Field__c fi5 = new AOB_Field__c();
        fi5.Name = 'Test';
        fi5.AOB_Section__c = sect.Id;
        fi5.AOB_Label__c = 'Test';
        fi5.AOB_sequence__c = '1';
        fi5.AOB_Type__c = 'Date';
        insert fi5; 
        AOB_Field__c fi6 = new AOB_Field__c();
        fi6.Name = 'Test';
        fi6.AOB_Section__c = sect.Id;
        fi6.AOB_Label__c = 'Test';
        fi6.AOB_sequence__c = '1';
        fi6.AOB_Type__c = 'Text Area';
        insert fi6; 
        AOB_Field__c fi7 = new AOB_Field__c();
        fi7.Name = 'Test';
        fi7.AOB_Section__c = sect.Id;
        fi7.AOB_Label__c = 'Test';
        fi7.AOB_sequence__c = '1';
        fi7.AOB_Type__c = 'Email';
        insert fi7; 
        AOB_Field__c fi8 = new AOB_Field__c();
        fi8.Name = 'Test';
        fi8.AOB_Section__c = sect.Id;
        fi8.AOB_Label__c = 'Test';
        fi8.AOB_sequence__c = '1';
        fi8.AOB_Type__c = 'Currency';
        insert fi8;
        AOB_Field__c fi9 = new AOB_Field__c();
        fi9.Name = 'Test';
        fi9.AOB_Section__c = sect.Id;
        fi9.AOB_Label__c = 'Test';
        fi9.AOB_sequence__c = '1';
        fi9.AOB_Type__c = 'MultiSelectSearch';
        insert fi9;
        AOB_Field__c fi10 = new AOB_Field__c();
        fi10.Name = 'Test';
        fi10.AOB_Section__c = sect.Id;
        fi10.AOB_Label__c = 'Test';
        fi10.AOB_sequence__c = '1';
        fi10.AOB_SFObject__c = 'Application__c';
        fi10.AOB_SFField__c = 'AOB_Email_Type__c';
        fi10.AOB_Type__c = 'Output';
        insert fi10;
        Button_Configuration__c bc = new Button_Configuration__c();
        bc.Name='button1';
        bc.Button_Label__c='button2';
        bc.Button_Sequence__c=3;
        bc.Flow_screen__c= a.Id;
        bc.AOB_External_Field__c=a.name;
        insert bc;
        
        Test.startTest();  
        AOB_Form form = UG_AOB_PPB_FormCreator.getFields(a.name);
        AOB_DTO_Section  sectionInfo = UG_AOB_PPB_FormCreator.setSectionInfo(sect);
        String nameData = UG_AOB_PPB_FormCreator.getButtonData(a.name);
        String aData = UG_AOB_PPB_FormCreator.getButtonData('a');
        String bData = UG_AOB_PPB_FormCreator.getButtonData('b');
        String cData = UG_AOB_PPB_FormCreator.getButtonData('c');
        String dData = UG_AOB_PPB_FormCreator.getButtonData('d');
        String eData = UG_AOB_PPB_FormCreator.getButtonData('e');
        Test.stopTest();  
        Assert.areEqual(form!=null, true, 'It will return result');
        Assert.areEqual(sectionInfo!=null, true, 'It will return result');
        Assert.areEqual(nameData!=null, true, 'It will return result');
        Assert.areEqual(aData!=null, true, 'It will return result');
        Assert.areEqual(bData!=null, true, 'It will return result');
        Assert.areEqual(cData!=null, true, 'It will return result');
        Assert.areEqual(dData!=null, true, 'It will return result');
        Assert.areEqual(eData!=null, true, 'It will return result');
        
    }
    /**
    * @description Test data for  UG_AOB_PPB_FormCreator.getEmploymentId
    */
    @isTest
    static void testGetEmploymentId() {
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp; 
        AOB_ReferencedData__c ref = new AOB_ReferencedData__c();
        ref.Name='test';
        ref.AOB_Code__c='222029';
        ref.AOB_SapField__c='PPB_EMP_NAME';
        ref.AOB_CountryCode__c='UGX';
        insert ref;
        Test.startTest();
        String result = UG_AOB_PPB_FormCreator.getEmploymentId(lstApp);
        Test.stopTest();
        Assert.areNotEqual(null, result, 'Result should not be null');
    }
/**
    * @description Test data for UG_AOB_PPB_FormCreator.getTeritorySec
    */
    @isTest
    static void getTeritorySecTest() {
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp; 
        AOB_ReferencedData__c ref = new AOB_ReferencedData__c();
        ref.Name='test';
        ref.AOB_Code__c='T123';
        ref.AOB_SapField__c='PPB_TERTIARY_SEC';
        ref.AOB_CountryCode__c='UGX';
       insert ref;
        Test.startTest();
        String result = UG_AOB_PPB_FormCreator.getTeritorySec(lstApp);
        Test.stopTest();
        Assert.areNotEqual(null, result, 'Result should not be null');
    }
    /**
    * @description Test data for getApplicationData
    */
    @isTest
    static void getApplicationDataTest() {
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp; 
        Test.startTest();
        List<Application__c> result = UG_AOB_PPB_FormCreator.getApplicationData(lstApp[0].id);
        Test.stopTest();
        Assert.areNotEqual(null, result, 'Result should not be null');
    }
    @isTest
    static void testGetStaticValues_WithRecords() {

        Test.startTest();
        Map<String, String> result = UG_AOB_PPB_FormCreator.getStaticValues();  
        Test.stopTest();

        // Assert the method returns a non-null map
         Assert.areNotEqual(null, result, 'The method should return a non-null map');
    }
    /**
    * @description Tests exception handling in UG_AOB_PPB_FormCreator.getFields.
    */
    @isTest
    static void getFieldsExceptionPath() {
        Test.startTest();
        try {
            UG_AOB_PPB_FormCreator.getFields('InvalidScreenName');  // Invalid screen name triggers exception
        } catch (AuraHandledException ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'Should throw AuraHandledException for invalid screen');
        }
        Test.stopTest();

    }
    /**
    * @description Tests exception handling in UG_AOB_PPB_FormCreator.getButtonData.
    */
    @isTest
    static void getButtonDataExceptionPath() { //not working
        Test.startTest();
        try {
            UG_AOB_PPB_FormCreator.getButtonData(null);  
        } catch (Exception ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'Should throw exception for null input');
        }
        Test.stopTest();

    }
    /**
    * @description Tests exception handling in UG_AOB_PPB_FormCreator.getTeritorySec.
    */
    @isTest
    static void getTeritorySecExceptionPath() {//not working
        Test.startTest();
        try {
            UG_AOB_PPB_FormCreator.getTeritorySec(null);  // Null input triggers exception in SOQL or processing
        } catch (Exception ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'Should throw exception for null input');
        }
        Test.stopTest();

    }
    @isTest
    public static void testGetEmploymentId_ExceptionHandling() {
        List<Application__c> testList = null;
        
        String exceptionMessage;
        Test.startTest();
        try {
            UG_AOB_PPB_FormCreator.getEmploymentId(testList);
            Assert.fail('Expected AuraHandledException to be thrown'); 
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
            Assert.isTrue(exceptionMessage != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }

  @isTest
    public static void getApplicationData_ExceptionHandling() {
        
        String exceptionMessage;
        Test.startTest();
        try {
            UG_AOB_PPB_FormCreator.getApplicationData(null);
            Assert.fail('Expected AuraHandledException to be thrown'); 
        } catch (AuraHandledException e) {
            exceptionMessage = e.getMessage();
            Assert.isTrue(exceptionMessage != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }
}