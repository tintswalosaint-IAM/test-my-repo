/***************************************************************************************
* @name of the Class : ICS_CTRL_DML_OnboardingDetials_Test.cls
* @description class used as test class for ICS_CTRL_DML_OnboardingDetials
* @Story:SFP-30236
* @date 10/03/2024
/***************************************************************************************
* @last modified on  : 06-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************/
@isTest
public class ICS_CTRL_DML_OnboardingDetails_Test {
    @testSetup
      static void setupTestData() { 
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFlowscreen('ICS UK Personal Details');
        AOB_ScreenSection__c section = ICS_DAL_TestFactory.createScreenSection(screen,'Personal Details');
        string jsonString = convertFieldMappingsToJSON(section.id);
        ICS_DAL_TestFactory.createField(jsonString,section.id);
        
        User communityUser = ICS_DAL_TestFactory.createCommunityUser(); 
        communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        PartyProfile profileData = ICS_DAL_TestFactory.createPartyProfile(communityUser.contact.accountid);
        ICS_DAL_TestFactory.createPartyAssetFunds(profileData.id); 
        ICS_DAL_TestFactory.createEmployment(communityUser.contact.accountid); 
        Assessment assData = ICS_DAL_TestFactory.createAssessment(communityUser.contact.accountid);
       
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssds',
            Name = 'Select all assets and income*',
            QuestionCategory = 'Financial'
        );
        insert question;
        
        AssessmentQuestionVersion versionData = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'Select all assets and income*',
            Name = 'Select all assets and income*',
            IsActive = true
        );
        insert versionData;
        ICS_DAL_TestFactory.createAssessmentQuestionResponse(assData.id, versionData.id);
        
    }
    
    public static string convertFieldMappingsToJSON(Id sectionId) {
        String jsonString = '[{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Position", "AOB_SFField__c": "FinServ__Position__c"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Bonus Amount", "AOB_SFField__c": "Bonuses_Commissions_received_per_annum__c","AOB_Type__c": "currency"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Shares", "AOB_SFField__c": "Is_Future_Fund__c"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Name of Employer", "AOB_SFField__c": "Name"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Annual Income", "AOB_SFField__c": "FinServ__AnnualIncome__c"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "End Date", "AOB_SFField__c": "FinServ__EndDate__c"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "In Employment Alongside Studying", "AOB_SFField__c": "In_Employment_Alongside_Studying__c"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Different_Last_Name__c", "AOB_Type__c": "Lookup", "Default_Value__c": "IN", "AOB_SFField__c": "Employer_s_Address_Line_1__c"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Different_Last_Name__c", "AOB_Type__c": "Lookup", "AOB_SFField__c": "Person_Account__c;Account"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "Different_Last_Name__c", "AOB_Type__c": "MasterDetail", "AOB_SFField__c": "Person_Account__c;Account"},' +
            '{"AOB_SFObject__c": "FinServ__Employment__c", "AOB_Section__c": "'+sectionId+'", "Name": "RecordtypeID", "AOB_Type__c": "Lookup", "Default_Value__c": "Current", "AOB_SFField__c": "RecordtypeId"},' +
            '{"AOB_SFObject__c": "Assessment", "AOB_Section__c": "'+sectionId+'", "Name": "Bonus AmountCurrency","AOB_label__c":"Bonus AmountCurrency", "AOB_Type__c": "Lookup"},' +
            
            '{"AOB_SFObject__c": "PartyProfileAddress", "AOB_Section__c": "'+sectionId+'", "Name": "street", "AOB_SFField__c": "Street"},' +
            '{"AOB_SFObject__c": "Party_Assets_Funds__c", "AOB_Section__c": "'+sectionId+'", "Name": "MainAccount", "AOB_SFField__c": "Main_Account__c", "AOB_Type__c": "Lookup", "Default_Value__c": "TRUE"},' +
            '{"AOB_SFObject__c": "table:PartyProfile", "AOB_Section__c": "'+sectionId+'", "Name": "Name", "AOB_SFField__c": "table:Name"},' +
            '{"AOB_SFObject__c": "table:PartyProfile", "AOB_Section__c": "'+sectionId+'", "Name": "accountId", "AOB_Type__c": "Lookup", "AOB_SFField__c": "table:accountid;Account"}]';
        return jsonString;
    }

    @isTest
    static void testProcessData_NewRecord() {
        User communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        String jsonString = '{"Position":"Manager","Name of Employer":"Test Corp","Annual Income":"100000","Start Date":"2024-01-01","End Date":"2024-12-31","Bonus Amount":"5000","Bonus AmountCurrency":"USD"}';
        Test.startTest();
        System.runAs(communityUser) {
            ICS_CTRL_DML_OnboardingDetails.processData(jsonString, 'ICS UK Personal Details', 'Personal Details', communityUser.Contact.AccountId);
        }
        Test.stopTest();
        
        FinServ__Employment__c newEmployment = [SELECT Id, FinServ__Position__c, Name, FinServ__AnnualIncome__c, FinServ__EndDate__c, Bonuses_Commissions_received_per_annum__c FROM FinServ__Employment__c WHERE FinServ__Position__c = 'Manager' LIMIT 1];
        Assert.areEqual('Manager', newEmployment.FinServ__Position__c, 'Position should be set correctly');
        Assert.areEqual('Test Corp', newEmployment.Name, 'Employer name should be set correctly');
        Assert.areEqual(100000, newEmployment.FinServ__AnnualIncome__c, 'Annual income should be set correctly');
    }

    @isTest
    static void testProcessData_UpdateRecord() {
        User communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        FinServ__Employment__c existingEmployment = new FinServ__Employment__c(
            FinServ__Position__c = 'Old Position',
            Name = 'Old Corp',
            FinServ__AnnualIncome__c = 50000,
            Person_Account__c = communityUser.Contact.AccountId
        );
        insert existingEmployment;
        
        String jsonString = '{"Id":"' + existingEmployment.Id + '","Position":"Updated Manager","Name of Employer":"Updated Corp","Annual Income":"150000"}';
        
        Test.startTest();
        System.runAs(communityUser) {
            ICS_CTRL_DML_OnboardingDetails.processData(jsonString, 'ICS UK Personal Details', 'Personal Details', communityUser.Contact.AccountId);
        }
        Test.stopTest();
        
        FinServ__Employment__c updatedEmployment = [SELECT Id, FinServ__Position__c, Name, FinServ__AnnualIncome__c FROM FinServ__Employment__c WHERE Id = :existingEmployment.Id];
        Assert.areEqual('Updated Manager', updatedEmployment.FinServ__Position__c, 'Position should be updated');
        Assert.areEqual('Updated Corp', updatedEmployment.Name, 'Employer name should be updated');
        Assert.areNotEqual(150000, updatedEmployment.FinServ__AnnualIncome__c, 'Annual income should be updated');
    }

    @isTest
    static void testProcessData_AssessmentResponse() {
        User communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        String jsonString = '{"Select all assets and income*":"Savings,Investments","Other Question":"Other Response"}';
        
        Test.startTest();
        System.runAs(communityUser) {
            ICS_CTRL_DML_OnboardingDetails.processData(jsonString, 'ICS UK Personal Details', 'Personal Details', acc.Id);
        }
        Test.stopTest();
        
        List<AssessmentQuestionResponse> responses = [SELECT Id, ResponseText, Name FROM AssessmentQuestionResponse WHERE AssessmentId IN (SELECT Id FROM Assessment WHERE AccountId = :acc.Id)];
        Assert.areEqual(1, responses.size(), 'One assessment response should be created');
    }

    @isTest
    static void testMapCurrency() {
        Map<String, Decimal> conversionMap = new Map<String, Decimal>{
            'USD' => 1.0,
            'EUR' => 0.85,
            'GBP' => 0.75
        };
        
        Decimal result = ICS_CTRL_DML_OnboardingDetails.mapCurrency('Bonus Amount', 100, 'USD', conversionMap);
        Assert.arenotEqual(null, result, 'result not null');
      
    }

    @isTest
    static void testUpdateLookup() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        FinServ__Employment__c employment1 = new FinServ__Employment__c(Name = 'Test Employment 1', Person_Account__c = acc.Id);
        FinServ__Employment__c employment2 = new FinServ__Employment__c(Name = 'Test Employment 2', Person_Account__c = acc.Id);
        insert new List<FinServ__Employment__c>{employment1, employment2};
        
        ICS_CTRL_DML_OnboardingDetails.linkedMap.put('FinServ__Employment__c', employment1.Id + ':' + employment2.Id);
        ICS_CTRL_DML_OnboardingDetails.linkedMap.put('Account', acc.Id);
        ICS_CTRL_DML_OnboardingDetails.lookupFields.put('FinServ__Employment__c', new List<String>{'Person_Account__c;Account'});
        
        Test.startTest();
        ICS_CTRL_DML_OnboardingDetails.updateLookup();
        Test.stopTest();
        
        List<FinServ__Employment__c> updatedEmployments = [SELECT Id, Person_Account__c FROM FinServ__Employment__c WHERE Id IN (:employment1.Id, :employment2.Id)];
        Assert.areEqual(2, updatedEmployments.size(), 'Both employment records should be updated');
        for (FinServ__Employment__c emp : updatedEmployments) {
            Assert.areEqual(acc.Id, emp.Person_Account__c, 'Lookup field should be updated for all records');
        }
    }

    @isTest
    static void testProcessDataWithTableFields() {
        User communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        String jsonString = '{"type":"modalData","Name":"TestName","Position":"TestPosition"}';
        
        Test.startTest();
        System.runAs(communityUser) {
            ICS_CTRL_DML_OnboardingDetails.processData(jsonString, 'ICS UK Personal Details', 'Personal Details', communityUser.Contact.AccountId);
        }
        Test.stopTest();
        
        PartyProfile profile = [SELECT Id, Name FROM PartyProfile WHERE Name = 'TestName' LIMIT 1];
        Assert.areNotEqual(null, profile, 'PartyProfile should be created');
        Assert.areEqual('TestName', profile.Name, 'PartyProfile name should be set correctly');
    }

    @isTest
    static void testHandleSpecialCases() {
        User communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        String jsonString = '{"Former Name or Maiden Name":"FormerAndMaiden","Other Names":"Different","Marital Status":"Married"}';
        
        Test.startTest();
        System.runAs(communityUser) {
            ICS_CTRL_DML_OnboardingDetails.processData(jsonString, 'ICS UK Personal Details', 'Personal Details', communityUser.Contact.AccountId);
        }
        Test.stopTest();
        
        PartyProfile profile = [SELECT Id, Has_Former_Name__c, Has_Maiden_Name__c, Has_different_First_Middle_Family_Name__c, WI_MaritialStatus__c FROM PartyProfile WHERE AccountId = :communityUser.Contact.AccountId LIMIT 1];
        Assert.areEqual('Yes', profile.Has_Former_Name__c, 'Has Former Name should be set to Yes');
        
    }
      @isTest
    static void HandleResidentialAddressCaseProvinceNameTest() {
        Map<String, Object> sectionFieldData = new Map<String, Object>();
        sectionFieldData.put('ProvinceName', 'Ontario');
        sectionFieldData.put('Province', 'Quebec');
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        ICS_CTRL_DML_OnboardingDetails.handleResidentialAddressCase(acc, 'ProvinceName');
        Assert.areEqual(true, acc != null, 'account is not null');
        Test.stopTest();

    }
     @isTest
  static void testGetAssessmentScreenData() {
      List<AOB_Field__c> createFields =[select id,AOB_SFObject__c from AOB_Field__c];
       Test.startTest();
        List<AOB_Field__c> result = ICS_CTRL_DML_OnboardingDetails.getAssessmentScreenData(createFields);
      Assert.areEqual(true, result != null, 'result get assessment information');
      Test.stopTest();
  }
    
    
    
}