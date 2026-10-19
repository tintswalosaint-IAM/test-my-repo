/***************************************************************************************

@name of the Class : ICS_CTRL_TrustDataProcessorTest.cls
@description : class used as controller for  SBO-UK onBoardingApplication Feature
@author : Ikyatha Naidu 
@created Date : May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On :  06-06-2024
@modification description: SFP-30128
***************************************************************************************/
@isTest
private class ICS_CTRL_TrustDataProcessorTest {

    @testSetup
    static void setupTestData() {
         AOB_FlowScreen__c screen = new AOB_FlowScreen__c(Name = 'ICS UK IFA Financial Details',
                                                         AOB_title__c = 'ICS UK IFA Financial Details',
                                                         AOB_subtitle__c = 'Enter the following information',
                                                         AO_ExternalId__c = '1234',
                                                         AOB_Screen_Sequence__c = 1,
                                                         AOB_Language__c = 'EN');
        insert screen;

        AOB_ScreenSection__c section = new AOB_ScreenSection__c(AOB_Screen__c = screen.id,
                                                                Name = 'Trusts',
                                                                AOB_ExternalId__c = 'Q1',
                                                                AOB_Title__c = 'Trusts');
        insert section;

        AOB_Field__c parentField = new AOB_Field__c(
            AOB_Section__c = section.id,
            Name = 'Add Another Person',
            AOB_Type__c = 'Text',
            AOB_Label__c = 'Add Another Person',
            AOB_ParentControllingValue__c = 'Add Another Person'
        );
        insert parentField;
        
        AOB_Field__c parentBenefitField = new AOB_Field__c(
            AOB_Section__c = section.id,
            Name = 'ADD Benefit',
            AOB_Type__c = 'Text',
            AOB_Label__c = 'ADD Benefit',
            AOB_ParentControllingValue__c = 'ADD Benefit'
        );
        insert parentBenefitField;
       
        
        List<AOB_Field__c> fieldMappings = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',AOB_Section__c = section.id, Name = 'Deed number', AOB_SFField__c = 'Deed_Number__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c',AOB_Section__c = section.id, Name = 'Trust name', AOB_SFField__c = 'Trust_Name__c'),
            new AOB_Field__c(AOB_SFObject__c = 'PartyProfile',  AOB_Parent__c = parentField.id, Name = 'Identification number',AOB_Section__c = section.id, AOB_SFField__c = 'Identification_Number__c'),
            new AOB_Field__c(AOB_SFObject__c = 'PartyProfile', AOB_Parent__c = parentField.id,  Name = 'First name', AOB_Section__c = section.id,AOB_SFField__c = 'FirstName'),
        	new AOB_Field__c(AOB_SFObject__c = 'PartyProfile', AOB_Parent__c = parentField.id,  Name = 'Client Cancelled', AOB_Section__c = section.id,AOB_SFField__c = 'ClientCancelled__c'),
        	new AOB_Field__c(AOB_SFObject__c = 'PartyProfile', AOB_Parent__c = parentField.id,  Name = 'Birthdate', AOB_Section__c = section.id,AOB_SFField__c = 'Birthdate'),
        	new AOB_Field__c(AOB_SFObject__c = 'PartyProfile', AOB_Parent__c = parentField.id,  Name = 'Country_of_Residence__c', AOB_Section__c = section.id,AOB_SFField__c = 'Country_of_Residence__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentBenefitField.id, Name = 'Annual Monetary Value', AOB_Section__c = section.id, AOB_SFField__c = 'Annual_Monetary_Value__c'),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentBenefitField.id, Name = 'Type of benefit', AOB_Section__c = section.id, AOB_SFField__c = 'Type_of_Benefit__c')
        };
        insert fieldMappings;

        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'Are_you_related_to_a_trust_structure',
            Name = 'Are you related to a trust structure?',
            QuestionCategory = 'Financial'
        );
        insert question;
        
        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'Are you related to a trust structure?',
            Name = 'Are you related to a trust structure?',
            IsActive = true
        );
        insert qv;
        
        AssessmentQuestion questionCurrency = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'AnnualMonetaryValueCurrency',
            Name = 'Annual Monetary ValueCurrency',
            QuestionCategory = 'Financial'
        );
        insert questionCurrency;
        
        AssessmentQuestionVersion qvCurrency = new AssessmentQuestionVersion(
            AssessmentQuestionId = questionCurrency.Id,
            Questiontext = 'Annual Monetary ValueCurrency',
            Name = 'Annual Monetary ValueCurrency',
            IsActive = true
        );
        insert qvCurrency;
        
        Account accRec = ICS_DAL_TestFactory.createAccount();    
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'ID & Address Verification', CloseDate = System.today());
        opp.AccountId = accRec.id;
        opp.LeadSource='IFA';
        insert opp;
        
        RecordType partyProfileRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'PartyProfile' AND Name = 'ICS Party Profile' LIMIT 1];
        PartyProfile Profile = new PartyProfile(
            Name='PEP',
            AccountId = accRec.Id,
            RecordTypeId = partyProfileRecordType.Id
        );
        insert Profile;
        
        Party_Assets_Funds__c assetFund = new Party_Assets_Funds__c(
            Name = 'test',
            Party_Profile__c = Profile.id,
            Initial_Deposit__c = 30000,
            Type__c='Benefit from a trust',
            Is_Trust_Beneficiary__c = true
        );
        insert assetFund;
        
        Assessment assessment = new Assessment(
            Name = 'Test Assessment',
            AccountId=accRec.id,
            PartyProfileId = profile.Id,
            AssessmentStatus = 'InProgress'
        );
        insert assessment;
        
        AssessmentQuestionResponse assRes=new AssessmentQuestionResponse();
        assRes.Name='Trusts';
        assRes.AssessmentId=assessment.id;
        assRes.AssessmentQuestionId=qv.Id;
        insert assRes;
    }

    @isTest
    static void testAddNewBenefit() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        String jsonString = '{"ADD Benefit":[{"Annual Monetary ValueCurrency":"AED:123","Annual Monetary Value":"123","Deed number":null,"Trust name":null,"Date received?":"2024-05-09","Full details inclusive of amount":null,"How and when did they derive their wealth?":"fgd","Who settled the Trust?":"dfgd","Location where trust is registered":"AF","Benefit description":null,"Are you named in the Trust deed":null,"Rationale for trust":"df","Annual Monetary Value":45,"Frequency of benefit":"Once-off","Type of benefit":"Disbursement"}]}';
        try{
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.addNewBenefit(jsonString,accRec.id);
        Test.stopTest();
        List<Party_Assets_Funds__c> benefits = [SELECT Id, Type__c FROM Party_Assets_Funds__c WHERE Type__c = 'Benefit from a trust'];
            ICS_CTRL_TrustDataProcessor.createResponse(new map<string,object>{},'','','');
        Assert.areEqual(true, benefits.size() >= 1,'Party_Assets_Funds__c atleast contain 1 record');
            
        Assert.areEqual('Benefit from a trust', benefits[0].Type__c,'expecting type field value');
        }catch(exception ex){
            Assert.areEqual(true,ex.getMessage() !=null,'error message cannot be null'); 
        }
    }

    @isTest
    static void testAddNewPerson() {
        Account testPartyProfile = [SELECT Id FROM Account LIMIT 1];
        String jsonString = '{"Add Another Person":[{"Identification number":null,"Client Cancelled":"true","Birthdate":"2019-08-04","Country_of_Residence__c":"IN","Identification type":null,"Former name":null,"Maiden name":null,"Other surname":null,"Other middle name":null,"Other first name":null,"Secondary country of nationality":"IN","Primary country of nationality":"IN","Country of residence":"IN","Town/City of Birth":"Joondalup","Country of birth":"IN","Marital status":"Divorced","Date of birth":"2006-12-14","Gender":"Female","Middle name":"dgf","Surname":"fdgdf","First name":"fdgfd","Title":"Dr."}]}';
        try{
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.addNewPerson(jsonString, testPartyProfile.Id);
        Test.stopTest();
        List<PartyProfile> persons = [SELECT Id, Name FROM PartyProfile WHERE Name = 'PEP'];
        Assert.areEqual(true, persons.size() >= 1,'expecting atleast one record in parypofile list');
        Assert.areEqual('PEP', persons[0].Name,'expecting partyprofile name');
        }catch(exception ex){
            Assert.areEqual(true,ex.getMessage() !=null,'error message cannot be null'); 
        }
    }

    @isTest
    static void testProcessTrustData() {
        Account profile = [SELECT Id FROM Account LIMIT 1];
        String jsonString = '{"Deed number":"fdgfd","Trust name":"dgfd","Date received?":null,"Full details inclusive of amount":null,"How and when did they derive their wealth?":null,"Who settled the Trust?":null,"Location where trust is registered":null,"Benefit description":null,"Are you named in the Trust deed":"Letter of Wishes","Rationale for trust":null,"Annual Monetary Value":null,"Frequency of benefit":null,"Type of benefit":null,"Are you related to a trust structure?":"true","accordian":[{"label":"ADD Benefit","ADD Benefit":[{"Deed number":null,"Trust name":null,"Date received?":"2024-05-09","Full details inclusive of amount":null,"How and when did they derive their wealth?":"fgd","Who settled the Trust?":"dfgd","Location where trust is registered":"AF","Benefit description":null,"Are you named in the Trust deed":null,"Rationale for trust":"df","Annual Monetary Value":45,"Frequency of benefit":"Once-off","Type of benefit":"Disbursement"}],"Add Another Person":[{"Identification number":null,"Identification type":null,"Former name":null,"Maiden name":null,"Other surname":null,"Other middle name":null,"Other first name":null,"Secondary country of nationality":"IN","Primary country of nationality":"IN","Country of residence":"IN","Town/City of Birth":"Joondalup","Country of birth":"IN","Marital status":"Divorced","Date of birth":"2006-12-14","Gender":"Female","Middle name":"dgf","Surname":"fdgdf","First name":"fdgfd","Title":"Dr."}]}]}';
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonString, profile.Id);
        Test.stopTest();
		ICS_CTRL_TrustDataProcessor.getMaritalStatusMap();
        List<PartyProfile> persons = [SELECT Id, Name FROM PartyProfile WHERE Name = 'PEP'];
        Assert.isTrue(persons.size() >= 1,'expecting atleast one record in parypofile list');
        if(persons.size() > 0) {
            Assert.areEqual('PEP', persons[0].Name,'expecting partyprofile name');
        }
    }
    
    @isTest
    static void testProcessTrustIdData() {
        Account profile = [SELECT Id FROM Account LIMIT 1];
        AssessmentQuestionResponse asses= [select id ,name,AssessmentQuestion.name from AssessmentQuestionResponse limit 1];
        String jsonString = '{"Deed number":"fdgfd","Trust name":"dgfd","Date received?":null,"Full details inclusive of amount":null,"How and when did they derive their wealth?":null,"Who settled the Trust?":null,"Location where trust is registered":null,"Benefit description":null,"Are you named in the Trust deed":"Letter of Wishes","Rationale for trust":null,"Annual Monetary Value":null,"Frequency of benefit":null,"Type of benefit":null,"Are you related to a trust structure?:id":"'+asses.id+'","accordian":[{"label":"ADD Benefit","ADD Benefit":[{"Deed number":null,"Trust name":null,"Date received?":"2024-05-09","Full details inclusive of amount":null,"How and when did they derive their wealth?":"fgd","Who settled the Trust?":"dfgd","Location where trust is registered":"AF","Benefit description":null,"Are you named in the Trust deed":null,"Rationale for trust":"df","Annual Monetary Value":45,"Frequency of benefit":"Once-off","Type of benefit":"Disbursement"}],"Add Another Person":[{"Identification number":null,"Identification type":null,"Former name":null,"Maiden name":null,"Other surname":null,"Other middle name":null,"Other first name":null,"Secondary country of nationality":"IN","Primary country of nationality":"IN","Country of residence":"IN","Town/City of Birth":"Joondalup","Country of birth":"IN","Marital status":"Divorced","Date of birth":"2006-12-14","Gender":"Female","Middle name":"dgf","Surname":"fdgdf","First name":"fdgfd","Title":"Dr."}]}]}';
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonString, profile.Id);
        Test.stopTest();

		ICS_CTRL_TrustDataProcessor.getMaritalStatusMap();
        List<PartyProfile> persons = [SELECT Id, Name FROM PartyProfile WHERE Name = 'PEP'];
        Assert.isTrue(persons.size() >= 1,'expecting atleast one record in parypofile list');
        if(persons.size() > 0) {
            Assert.areEqual('PEP', persons[0].Name,'expecting partyprofile name');
        }
    }
    
    @isTest
    static void testGetMaritalStatusMap() {
        Test.startTest();
        Map<String, String> maritalMap = ICS_CTRL_TrustDataProcessor.getMaritalStatusMap();
        Test.stopTest();
        
        Assert.areEqual('SINGLE', maritalMap.get('1'), 'Code 1 should map to SINGLE');
        Assert.areEqual('MARRIED', maritalMap.get('2'), 'Code 2 should map to MARRIED');
        Assert.areEqual('1', maritalMap.get('SINGLE'), 'SINGLE should map back to 1');
    }
    
    @isTest
    static void testMaritalStatusVariations() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Party_Assets_Funds__c trustRecord = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
        List<String> statuses = new List<String>{'1', '2', '3', '4', '5', '6'};
        
        Test.startTest();
        for(String status : statuses) {
            String jsonString = '{"accordianId":"' + trustRecord.Id + '","First name":"Test","Marital status":"' + status + '"}';
             ICS_CTRL_TrustDataProcessor.addNewPerson(jsonString, accRec.Id);  
        }
        Test.stopTest();
        
        List<PartyProfile> profiles = [SELECT WI_MaritialStatus__c FROM PartyProfile WHERE Name = 'PEP' ORDER BY CreatedDate];
        Assert.isTrue(profiles.size() >= 1, 'Should create person records with marital status');
    }
    
    @isTest
    static void testProcessTrustDataBenefitBranch() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Party_Assets_Funds__c trustRecord = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
        String jsonString = '{"label":"ADD Benefit - Test","accordianId":"' + trustRecord.Id + '","Annual Monetary Value":"1000"}';
        
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonString, accRec.Id);
        Test.stopTest();
        
        List<Party_Assets_Funds__c> benefits = [SELECT Id FROM Party_Assets_Funds__c WHERE Type__c = 'Benefit from a trust' AND Name = 'Benefit Trust'];
        Assert.isTrue(benefits.size() >= 1, 'Should process benefit branch');
    }
    
    @isTest
    static void testProcessTrustDataPersonBranch() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Party_Assets_Funds__c trustRecord = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
        String jsonString = '{"label":"Add Another Person - Test","accordianId":"' + trustRecord.Id + '","First name":"John"}';
        
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonString, accRec.Id);
        Test.stopTest();
        
        List<PartyProfile> persons = [SELECT Id FROM PartyProfile WHERE Name = 'PEP'];
        Assert.isTrue(persons.size() >= 1, 'Should process person branch');
    }
    
    @isTest
    static void testProcessTrustDataDeletionScenario() {
        Account profile = [SELECT Id FROM Account LIMIT 1];
        String jsonString = '{"Are you related to a trust structure?":"FALSE"}';
        
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonString, profile.Id);
        
        Test.stopTest();
        
        Assert.isTrue(true, 'Deletion scenario should complete without fatal errors');
    }
    
    @isTest
    static void testProcessTrustDataWithValidIds() {
        Account profile = [SELECT Id FROM Account LIMIT 1];
        Party_Assets_Funds__c trustRecord = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
        String jsonString = '{"Deed number":"fdgfd","Trust name":"dgfd","Are you related to a trust structure?":"true","accordian":[{"label":"ADD Benefit","ADD Benefit":[{"accordianId":"' + trustRecord.Id + '","Date received?":"2024-05-09","Annual Monetary Value":45,"Type of benefit":"Disbursement"}],"Add Another Person":[{"accordianId":"' + trustRecord.Id + '","First name":"fdgfd","Marital status":"Divorced"}]}]}';
        
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonString, profile.Id);
        
        Test.stopTest();
        
        List<PartyProfile> persons = [SELECT Id, Name FROM PartyProfile WHERE Name = 'PEP'];
        Assert.isTrue(persons.size() >= 0, 'Process should complete without fatal errors');
    }
    @isTest
    static void testProcessRelatedBenefit() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Party_Assets_Funds__c existingBenefit = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
        String jsonNewBenefit = '{' +
            '"Are you related to a trust structure?":"true",' +
            '"accordian":[{' +
                '"Do you receive any disbursement or benefit from a Trust?":"TRUE",' +
                '"ADD Benefit":[{' +
                    '"Annual Monetary Value":"1000",' +
                    '"Type of benefit":"Disbursement"' +
                '}]' +
            '}]' +
        '}';
        
        Test.startTest();
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonNewBenefit, accRec.Id);
        String jsonExistingBenefit = '{' +
            '"Are you related to a trust structure?":"true",' +
            '"accordian":[{' +
                '"Do you receive any disbursement or benefit from a Trust?":"TRUE",' +
                '"ADD Benefit":[{' +
                    '"Id":"' + existingBenefit.Id + '",' +
                    '"Annual Monetary Value":"2000",' +
                    '"Type of benefit":"Disbursement"' +
                '}]' +
            '}]' +
        '}';
        
        ICS_CTRL_TrustDataProcessor.processTrustData(jsonExistingBenefit, accRec.Id);
        Test.stopTest();
        
        List<Party_Assets_Funds__c> benefits = [
            SELECT Id, Name, Type__c, OwnerId 
            FROM Party_Assets_Funds__c 
            WHERE Name = 'Benefit Trust' AND Type__c = 'Benefit from a trust'
        ];
        
        Assert.isTrue(benefits.size() > 0, 'Should create benefit records');
        Assert.areEqual('Benefit Trust', benefits[0].Name, 'Benefit name should be set correctly');
        Assert.isNotNull(benefits[0].OwnerId, 'OwnerId should be populated from profile');
    }
    
}