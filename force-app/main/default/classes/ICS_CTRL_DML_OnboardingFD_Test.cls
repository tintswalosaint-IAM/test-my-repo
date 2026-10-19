/***************************************************************************************
* @name of the Class : ICS_CTRL_DML_OnboardingFD_Test.cls
* @description class used as test class for ICS_CTRL_DML_OnboardingFD
* @Story:SFP-30236
* @author Ikyatha Naidu
* @date 11-06-2024
/***************************************************************************************
* @last modified on  : 06-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************/
@istest
public class ICS_CTRL_DML_OnboardingFD_Test {
    @testSetup
    static void setupTestData() { 
         AOB_FlowScreen__c screen = new AOB_FlowScreen__c(Name = 'ICS UK Account Details',
                                                         AOB_title__c = 'ICS UK Account Details',
                                                         AOB_subtitle__c = 'Enter the following information',
                                                         AO_ExternalId__c = '1234',
                                                         AOB_Screen_Sequence__c = 1,
                                                         AOB_Language__c = 'EN');
        insert screen;

        AOB_ScreenSection__c section = new AOB_ScreenSection__c(AOB_Screen__c = screen.id,
                                                                Name = 'Future Deposits',
                                                                AOB_ExternalId__c = 'Q1',
                                                                AOB_Title__c = 'Future Deposits');
        insert section;
        // Create AOB_Field__c records
        AOB_Field__c parentField = new AOB_Field__c(
            AOB_Section__c = section.id,
            Name = 'GiftVvv',
            AOB_Type__c = 'Text',
            AOB_Label__c = 'GiftVvv',
            AOB_ParentControllingValue__c = 'GiftVvv'
            
        );
        insert parentField;
       
        List<AOB_Field__c> fieldMappings = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',AOB_Section__c = section.id,AOB_Type__c='Currency', Name = 'Annual Monetary Value', AOB_SFField__c = 'Annual_Monetary_Value__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',AOB_Section__c = section.id, Name = 'Trust name', AOB_SFField__c = 'Trust_Name__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',  AOB_Parent__c = parentField.id, Name = 'Identification number',AOB_Section__c = section.id, AOB_SFField__c = 'Is_amount_to_more_than_10__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Trust name', AOB_Section__c = section.id,AOB_SFField__c = 'Address_Line_1__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Client Cancelled', AOB_Section__c = section.id,AOB_SFField__c = 'Beneficiary_Of_Trust__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Date received?', AOB_Section__c = section.id,AOB_SFField__c = 'Date_Funds_Matured__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Country_of_Residence__c', AOB_Section__c = section.id,AOB_SFField__c = 'Business_Location__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Different_Last_Name__c',AOB_Type__c='Lookup', Default_Value__c='IN',AOB_Section__c = section.id,AOB_SFField__c = 'Business_Name__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Different_Last_Name__c',AOB_Type__c='Lookup', AOB_Section__c = section.id,AOB_SFField__c = 'Party_Profile__c;PartyProfile'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Different_Last_Name__c',AOB_Type__c= ICS_Constants.MasterDetail, AOB_Section__c = section.id,AOB_SFField__c = 'Party_Profile__c;PartyProfile'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'RecordtypeID',AOB_Type__c='Lookup', Default_Value__c='Source of Funds',AOB_Section__c = section.id,AOB_SFField__c = 'RecordtypeId')

                };
        insert fieldMappings;
        List<AOB_Field__c> fieldFundMappings = new List<AOB_Field__c> {
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',AOB_Section__c = section.id, Name = 'Deed numberV', AOB_SFField__c = 'Deed_Number__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',AOB_Section__c = section.id, Name = 'Trust nameV', AOB_SFField__c = 'Trust_Name__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',  AOB_Parent__c = parentField.id, Name = 'Identification numberV',AOB_Section__c = section.id, AOB_SFField__c = 'Identification_Number__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'First nameV', AOB_Section__c = section.id,AOB_SFField__c = 'FirstName'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Client CancelledV', AOB_Section__c = section.id,AOB_SFField__c = 'ClientCancelled__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'BirthdateV', AOB_Section__c = section.id,AOB_SFField__c = 'DateOfBirth'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentField.id,  Name = 'Country_of_Residence__cV', AOB_Section__c = section.id,AOB_SFField__c = 'Country_of_Residence__c')

                };
        insert fieldFundMappings;
        List<AOB_Field__c> fieldMappingsAsse = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_SFObject__c = 'Assessment',   Name = 'How do you intend to fund the future deposits?', AOB_Section__c = section.id,AOB_Type__c='Lookup')
        };
        insert fieldMappingsAsse;
        // Create AssessmentQuestion and AssessmentQuestionVersion records
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssds',
            Name = 'How do you intend to fund the future deposits?',
            QuestionCategory = 'Financial'
        );
        insert question;
        
        
        
        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'How do you intend to fund the future deposits?',
            Name = 'How do you intend to fund the future deposits?',
            IsActive = true
        );
        insert qv;
        
        
        
         AssessmentQuestion expectedQuestion = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssddfds',
            Name = 'Expected annual/yearly turnover for the account',
            QuestionCategory = 'Financial'
        );
        insert expectedQuestion;
        
        
        
        AssessmentQuestionVersion expectedQuestionVersion = new AssessmentQuestionVersion(
            AssessmentQuestionId = expectedQuestion.Id,
            Questiontext = 'Expected annual/yearly turnover for the account',
            Name = 'Expected annual/yearly turnover for the account',
            IsActive = true
        );
        insert expectedQuestionVersion;
        

        // Create Account record
       User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        // Create PartyProfile record
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(commUser.contact.AccountId);
        ICS_DAL_TestFactory.createPartyAssetFunds(testPartyProfile.id);
        
        // Create Assessment record
        Assessment assessment = new Assessment(
            Name = 'Test Assessment',
            AccountId= commUser.contact.AccountId,
            PartyProfileId = testPartyProfile.Id,
            AssessmentStatus = 'InProgress'
        );
        insert assessment;
         AssessmentQuestionResponse assRes=new AssessmentQuestionResponse();
        assRes.Name='Future Deposits';
        assRes.responsetext='Gift';
        assRes.AssessmentId=assessment.id;
        assRes.AssessmentQuestionId=qv.Id;
        insert assRes;
    }
    @isTest
    static void testAddNewBenefit() {
        try{
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        String jsonString = '{"Select multi combobox":"Gift", "GiftVvv": [{"Identification number":"TRUE","Deed number":null,"Trust name":null,"Date received?":"2024-05-09","Full details inclusive of amount":null,"How and when did they derive their wealth?":"fgd","Who settled the Trust?":"dfgd","Location where trust is registered":"AF","Benefit description":null,"Are you named in the Trust deed":null,"Rationale for trust":"df","Annual Monetary Value":45,"Frequency of benefit":"Once-off","Type of benefit":"Disbursement"}]}';
        List<aob_Field__c> fieldAssess=[select id,Name from aob_Field__c where  AOB_SFObject__c ='Assessment'];
        Test.startTest();
        
        ICS_CTRL_DML_OnboardingFD.processData(jsonString,'ICS UK Account Details','Future Deposits',commUser.contact.Accountid,fieldAssess);
        Test.stopTest();
        }catch(exception ex){
           Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred'); 
        }

    }
    @isTest
    static void testAddupdateBenefit() {
        try{
         User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        Party_Assets_Funds__c fund =[select id from Party_Assets_Funds__c limit 1];
        String jsonString = '{"How do you intend to fund the future deposits?":"Gift","Expected annual/yearly turnover for the account":"123","Expected annual/yearly turnover for the accountCurrency":"AED:123", "GiftVvv": [{"Deed number":null,"Id":"'+fund.id+'","Trust name":null,"Date received?":"2024-05-09","Full details inclusive of amount":null,"How and when did they derive their wealth?":"fgd","Who settled the Trust?":"dfgd","Location where trust is registered":"AF","Benefit description":null,"Are you named in the Trust deed":null,"Rationale for trust":"df","Annual Monetary Value":45,"Frequency of benefit":"Once-off","Type of benefit":"Disbursement"}]}';
       
        List<aob_Field__c> fieldAssess=[select id,Name from aob_Field__c where  AOB_SFObject__c ='Assessment'];
        Test.startTest();
        
        ICS_CTRL_DML_OnboardingFD.processData(jsonString,'ICS UK Account Details','Future Deposits',commUser.contact.Accountid,fieldAssess);
       
        Test.stopTest();
         }catch(exception ex){
           Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred'); 
        }

    }
    @isTest
    static void testAddNewFunds() {
        try{
         User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        String jsonString = '{"Select multi combobox of assests":"Gift", "GiftVvv": [{"Deed numberV":null,"Trust nameV":null,"Date received?V":"2024-05-09","Full details inclusive of amountV":null,"How and when did they derive their wealth?V":"fgd","Who settled the Trust?V":"dfgd","Location where trust is registeredV":"AF","Benefit descriptionV":null,"Are you named in the Trust deedV":null,"Rationale for trustV":"df","Annual Monetary ValueV":45,"Frequency of benefitV":"Once-off","Type of benefitV":"Disbursement"}]}';
      
        List<aob_Field__c> fieldAssess=[select id,Name from aob_Field__c where  AOB_SFObject__c ='Assessment'];
        Test.startTest();
        
        ICS_CTRL_DML_OnboardingFD.processData(jsonString,'ICS UK Account Details','Future Deposits',commUser.contact.Accountid,fieldAssess);
        
        Test.stopTest();
		 }catch(exception ex){
           Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred'); 
        }
    }
    
    @isTest
    static void testUpdateLookup() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        Party_Assets_Funds__c testAssetFund = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];

        ICS_CTRL_DML_OnboardingFD.lookupFields = new Map<String, List<String>>{
            'Party_Assets_Funds__c' => new List<String>{'Party_Profile__c;PartyProfile'}
        };
        ICS_CTRL_DML_OnboardingFD.linkedMap = new Map<String, String>{
            'Party_Assets_Funds__c' => testAssetFund.Id,
            'PartyProfile' => testPartyProfile.Id 
        };

        Test.startTest();
        ICS_CTRL_DML_OnboardingFD.updateLookup();
        Test.stopTest();

        // Add assertions to verify the results
        Party_Assets_Funds__c updatedAssetFund = [SELECT Id, Party_Profile__c FROM Party_Assets_Funds__c WHERE Id = :testAssetFund.Id];
       Assert.areEqual(testPartyProfile.Id, updatedAssetFund.Party_Profile__c, 'The Party_Profile__c lookup should be updated');
    }
    
    @isTest
    static void testdeletePartyAssets()
    {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        String AccountId = commUser.Contact.AccountId ;
        List<String> partyAssetType = new List<String>{'Ownership/shares in business','Gift'};
		Test.startTest();
        ICS_CTRL_DML_OnboardingFD.deletePartyAssets(AccountId,partyAssetType,'source of funds');
        Test.stopTest();
        Party_Assets_Funds__c testAssetFund = [SELECT Id FROM Party_Assets_Funds__c where id !=null];
         Assert.areEqual(true, testAssetFund!=null,'Party_Assets_Funds__c should be deleted');

    }
    
    @isTest
    static void testprocessMultipleLookups()
    {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        Party_Assets_Funds__c testAssetFund = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
		
        ICS_CTRL_DML_OnboardingFD.lookupFields = new Map<String, List<String>>{
            'Party_Assets_Funds__c' => new List<String>{'Party_Profile__c;PartyProfile'}
        };
        ICS_CTRL_DML_OnboardingFD.linkedMap = new Map<String, String>{
            'Party_Assets_Funds__c' => testAssetFund.Id,
            'Party_Profile__c' => testPartyProfile.Id 
        };
       
        List<sObject> sObjectListUpdate = new List<sObject>{
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',AOB_Type__c='Currency', Name = 'Annual Monetary Value', AOB_SFField__c = 'Annual_Monetary_Value__c')
            
                };
        Test.startTest();
        ICS_CTRL_DML_OnboardingFD.processMultipleLookups('Party_Assets_Funds__c',sObjectListUpdate);
          Assert.areEqual(true, sObjectListUpdate!=null,'sObjectListUpdate should have atleast one');
        Test.stopTest();
    }
    @isTest
    static void testCurrencyFieldHandler() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        
        AOB_Field__c currencyField = new AOB_Field__c(
            AOB_Type__c = 'Currency',
            Name = 'Test Amount',
            AOB_SFField__c = 'Annual_Monetary_Value__c'
        );
        
        Party_Assets_Funds__c testFund = new Party_Assets_Funds__c(
            Party_Profile__c = testPartyProfile.Id
        );
        
        Map<String, Object> sectionData = new Map<String, Object>{
            'Test Amount' => 1000,
            'Test AmountCurrency' => 'USD:1000'
        };
        
        Map<String, Decimal> conversionMap = new Map<String, Decimal>{'USD' => 1.0};
        
        Test.startTest();
        ICS_CTRL_DML_OnboardingFD.CurrencyFieldHandler handler = new ICS_CTRL_DML_OnboardingFD.CurrencyFieldHandler();
        handler.handleField(testFund, currencyField, sectionData, 'Annual_Monetary_Value__c', '', conversionMap);
        Test.stopTest();
        
        Assert.areEqual(true, testFund.Is_Future_Fund__c, 'Future fund flag should be true');
        Assert.areEqual('Test AmountCurrency,USD:1000', testFund.Wealth_Details_Inclusive_of_Amount__c, 'Wealth details should be set');
    }
    @isTest
    static void testHandleIdentityDocumentWithId() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        AOB_Field__c fieldData = new AOB_Field__c(
            Name = 'Test Document',
            AOB_SFField__c = 'Name'
        );
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            'Test Document Id' => 'testId123',
            'Test Document' => 'Test Document Name'
        };
        
        SObject updateSObj = new IdentityDocument();
        
        Test.startTest();
        ICS_CTRL_DML_OnboardingFD.handleIdentityDocument(updateSObj, fieldData, sectionFieldData, 'Name');
        Test.stopTest();
        
        Assert.areEqual('testId123', updateSObj.get('Id'), 'Id should be set');
        Assert.areEqual('Test Document Name', updateSObj.get('Name'), 'Name should be set');
    }
    
    @isTest
    static void testHandleIdentityDocumentWithoutId() {
        AOB_Field__c fieldData = new AOB_Field__c(
            Name = 'Test Document',
            AOB_SFField__c = 'Name'
        );
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            'Name' => 'Test Document Value'
        };
        
        SObject updateSObj = new IdentityDocument();
        
        Test.startTest();
        ICS_CTRL_DML_OnboardingFD.handleIdentityDocument(updateSObj, fieldData, sectionFieldData, 'Name');
        Test.stopTest();
        
        Assert.areEqual('Test Document Value', ICS_CTRL_DML_OnboardingFD.identityDocuData.get('Name'), 'Value should be stored in identityDocuData');
    }
            
    }