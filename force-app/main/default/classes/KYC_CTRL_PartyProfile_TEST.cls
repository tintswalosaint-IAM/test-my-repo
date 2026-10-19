/***************************************************************************************
@Name of the Class :KYC_CTRL_PartyProfile_TEST
@Description :SFP-40755 Test Class for KYC_CTRL_PartyProfile.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
public without sharing class KYC_CTRL_PartyProfile_TEST {
    public static String statusString = 'Status';
    public static String processKYCNegativeTestString = 'Assert failed in processKYCNegativeTest';
    public static String partyIdentityVerificationString = 'PartyIdentityVerification';
    public static String processKYCTestString = 'Assert failed in processKYCTest';
    
    
   /**
    * @description This is test method to valid Apex classes
    * @author Nagendra Mylavarapu | 26-03-2024 
    **/
    @TestSetup
    static void setupData() {
        PartyProfile existingProfile = new PartyProfile(
            Name = 'John',
            DateOfBirth = Date.newInstance(1990, 1, 1),
            WI_PrimaryIdentificationName__c = 'ID12345678'
        );
        insert existingProfile;
        PartyIdentityVerification piv = new PartyIdentityVerification(
            name='test',
            PartyProfileId = existingProfile.Id
        );
        insert piv;
        PartyScreeningSummary screeningSummary = new PartyScreeningSummary(
            Name='test',
            PartyProfileId = existingProfile.Id
            
        );
        insert screeningSummary;
    }
    
    
    /**
     * @description This is test method to valid Apex classes
     * @author Nagendra Mylavarapu | 26-03-2024 
     **/
    @isTest
    public static void processKYCTest(){
           try{
            Test.startTest();
            string pivStatusList = JSON.serialize(CMN_KYC_ExperienceUI.getPicklistValues(partyIdentityVerificationString,statusString));
            String iString = '{"clientDetails":{"title":"MR.","firstName":"TETS","kycProfileId":"0xUKN0000008PAH2A2","middleName":"IK","lastName":"TEST","gender":"Male","channel":"Website","idDocIssuingCountry":"UG","idNumber":"PD000123003X4A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"test@gmail.com","nationality":"UG","occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG","passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address;Proof of Identity","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"RAJ","stateCode":"RJ","countryCode":"UG","postalCode":"123"}]},"checks":{"idValidation":true,"idv":true, "raas":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
            KYC_CTRL_PartyProfile.KYCResponse res = KYC_CTRL_PartyProfile.processKYC(iString);
            string pivData = CMN_KYC_ExperienceUI.fetchPIV(res.kycProfileId,'WFR');
            List<PartyIdentityVerification> pivList = (List<PartyIdentityVerification>)JSON.deserialize(pivData,List<PartyIdentityVerification>.class);
            pivList[0].Status='In Progress';
            String updatedPIV = CMN_KYC_ExperienceUI.updatePIV(res.kycProfileId,JSON.serialize(pivList));
            pivList[0].Status='Completed';
            updatedPIV = CMN_KYC_ExperienceUI.updatePIV(res.kycProfileId,JSON.serialize(pivList));
            List<PartyProfileAddress> addLst = new SEL_PartyProfileAddress().selectByPartyProfileIds(new set<Id>{res.kycProfileId});
            List<PartyScreeningSummary> pssLst = new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(new set<Id>{res.kycProfileId});
            List<PartyIdentityVerification> pivLst = new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>{res.kycProfileId});
            Test.stopTest();
            Assert.isNotNull(pivStatusList, processKYCTestString);
            Assert.AreEqual(0, pivLst.size(), processKYCTestString);
            Assert.AreNotEqual(0, pivLst.size(), processKYCTestString);
            Assert.AreEqual(0, pssLst.size(), processKYCTestString);
            Assert.AreNotEqual(0, addLst.size(), processKYCTestString);
            Assert.isNotNull(updatedPIV, processKYCTestString);
           }Catch(Exception ex){
            Assert.areEqual('Script-thrown exception',ex.getMessage(),'Should receive Script-thrown exception  message');
           }
    }
    
    /**
* @description This is test method to valid Apex classes
* @author Nagendra Mylavarapu | 26-03-2024 
**/
    @isTest
    public static void processKYCWfrTest(){
        try{
            string pivStatusList = JSON.serialize(CMN_KYC_ExperienceUI.getPicklistValues(partyIdentityVerificationString,statusString));
            Assert.isNotNull(pivStatusList, processKYCTestString);
            String iString = '{"clientDetails":{"title":"MR.","firstName":"TETS","kycProfileId":"0xUKN0000008PAH2A2","middleName":"IK","lastName":"TEST","gender":"Male","channel":"Website","idDocIssuingCountry":"UG","idNumber":"PD000123003X4A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"test@gmail.com","nationality":"UG","occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG","passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address;Proof of Identity","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"RAJ","stateCode":"RJ","countryCode":"UG","postalCode":"123"}]},"checks":{"idValidation":true,"idv":true, "raas":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
            KYC_CTRL_PartyProfile.KYCResponse res = KYC_CTRL_PartyProfile.processKYC(iString);
            string pivData = CMN_KYC_ExperienceUI.fetchPIV(res.kycProfileId,'WFR');
            List<PartyIdentityVerification> pivList = (List<PartyIdentityVerification>)JSON.deserialize(pivData,List<PartyIdentityVerification>.class);
            pivList[0].Status='In Progress';
            pivList[0].result ='On Hold';
            CMN_KYC_ExperienceUI.updatePIV(res.kycProfileId,JSON.serialize(pivList));
            Map<String, Object> value = new Map<String, Object>();
            value.put('statuscode',200);
            value.put('PersonalNumber','200');
            value.put('DateOfExpiry','28.11.2090');        
            CMN_KYC_ExperienceUI.ocrResponseCheck(value,false,pivList);
            value = new Map<String, Object>();
            value.put('statuscode',200);
            value.put('PersonalNumber','');
            value.put('DateOfExpiry','28.11.2090');        
            CMN_KYC_ExperienceUI.ocrResponseCheck(value,false,pivList);
            Test.startTest();
            CMN_KYC_ExperienceUI.ugOcrCheck(res.kycProfileId);
            Test.stopTest();
            Assert.isNotNull(res, processKYCTestString);
        }Catch(exception ex){
            Assert.areEqual('Script-thrown exception',ex.getMessage(),'Should receive Script-thrown exception  message');
        }
        
    }
    
    /**
* @description This is test method to valid Apex classes
* @author Nagendra Mylavarapu | 26-03-2024 
**/
    @isTest
    public static void processKYCNegativeTest(){ 
            string pivStatusList = JSON.serialize(CMN_KYC_ExperienceUI.getPicklistValues(partyIdentityVerificationString,statusString));
            Assert.isNotNull(pivStatusList, processKYCNegativeTestString);
            String iString = '{"clientDetails":{"title":"MR.","firstName":"TETS","middleName":"IK","lastName":"TEST","gender":"Male","channel":"Website","idDocIssuingCountry":"UG","idNumber":"PD000123003X4A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"test@gmail.com","nationality":"UG","occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG","passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address;Proof of Identity","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"RAJ","stateCode":"RJ","countryCode":"UG","postalCode":"123"}]},"checks":{"idValidation":true,"idv":true, "raas":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
            Test.startTest();
            KYC_CTRL_PartyProfile.KYCResponse res = KYC_CTRL_PartyProfile.processKYC(iString);
            Test.stopTest();
            Assert.isNotNull(res, processKYCNegativeTestString);
        }
    
    
    
    /**
* @description This method used to test KYC functionality
* @author Nagendra Mylavarapu | 26-03-2024 
**/
    @isTest static void testUploadPIVDocument() {
        String iString = '{"clientDetails":{"title":"MR.","firstName":"TETS","middleName":"IK","lastName":"TEST","gender":"Male","channel":"Website","idDocIssuingCountry":"UG","idNumber":"PD000123003X4A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"test@gmail.com","nationality":"UG","occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG","passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address;Proof of Identity","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"RAJ","stateCode":"RJ","countryCode":"UG","postalCode":"123"}]},"checks":{"idValidation":true,"idv":true, "raas":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
        KYC_CTRL_PartyProfile.KYCResponse res = KYC_CTRL_PartyProfile.processKYC(iString);
        string pivData = CMN_KYC_ExperienceUI.fetchPIV(res.kycProfileId,'Document Upload');
        List<PartyIdentityVerification> testPIV = (List<PartyIdentityVerification>)JSON.deserialize(pivData,List<PartyIdentityVerification>.class);
        
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String fileName = 'TestFile.pdf';
        Test.startTest();
        Map<String,String> docData = new Map<String,String>();
        docData.put('fileName',fileName);
        docData.put('fileContent',base64Data);
        List<Object> testDocData = new List<Object>();
        testDocData.add(docData);
        Id contentVersionId = CMN_KYC_ExperienceUI.uploadPIVDocument(testPIV[0].Id, JSON.serialize(testDocData));
        Test.stopTest();
        Assert.isNotNull(contentVersionId, 'Content Version Id should not be null');
    }
    /**
     * @description This method used to test KYC updatePIV
     */
    @isTest
    static void  ExceptionHandlingTest() { 
        String partyProfileId = 'SomePartyProfileId';
        String pivData = '[{"Name": "Test Name"}]'; 
        try {
            Test.startTest();
            CMN_KYC_ExperienceUI.updatePIV(partyProfileId, pivData);
            Test.stopTest();
        } catch (Exception e) {
            Assert.isNotNull(e.getMessage().contains('Error fetching Profile Details'), 'Exception message should contain expected text');
        }
    }
    
    /**
     * @description This method used to test KYC updatePIV
     */
    @isTest
    static void ExceptionHandlingNegTEST() { 
        String pivId = 'SomePivId';
        String base64Data = 'InvalidBase64Data'; 
        String fileName = 'TestFile.txt';
        
        Test.startTest();
        Map<String,String> docData = new Map<String,String>();
        try {
            docData.put('fileName',fileName);
            docData.put('fileContent',base64Data);
            List<Object> testDocData = new List<Object>();
            testDocData.add(docData);
            CMN_KYC_ExperienceUI.uploadPIVDocument(pivId, JSON.serialize(testDocData));
        } catch (Exception ex) {
            Assert.isNotNull(docData, ex.getMessage());
        }
        Test.stopTest();
    }
    
    
    /**
     * @description This is test method to KYC none of the checks are Selected
     */
    @isTest
    public static void processKYCNotSelectedNegativeTest(){ 
        try{
            Test.startTest();
            string pivStatusList = JSON.serialize(CMN_KYC_ExperienceUI.getPicklistValues(partyIdentityVerificationString,statusString));
            Assert.isNotNull(pivStatusList, processKYCNegativeTestString);
            String iString = '{"clientDetails":{"title":"MR.","firstName":"TETS","middleName":"IK","lastName":"TEST","gender":"Male","channel":"Website","idDocIssuingCountry":"UG","idNumber":"PD000123003X4A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"test@gmail.com","nationality":"UG","occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG","passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address;Proof of Identity","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"RAJ","stateCode":"RJ","countryCode":"UG","postalCode":"123"}]},"checks":{"idValidation":true,"idv":true, "raas":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
            KYC_CTRL_PartyProfile.KYCResponse res = KYC_CTRL_PartyProfile.processKYC(iString);
            Test.stopTest();
            Assert.isNotNull(res, processKYCNegativeTestString);
        }
        catch(exception e){
            Assert.isNotNull(e, processKYCNegativeTestString);
        }
    }
    
    
    /**
     * @description This is test method to ProcessKycTestFailureDueToNullField
     */
    @IsTest
    static void testProcessKycTestFailureDueToNullFields() {
        String jsonString = '{"clientDetails": {"firstName": "John", "lastName": "Doe", "dob": "1990-01-01", "idNumber": "ID12345678"}, "checks": {}}';
        Test.startTest();
        KYC_DTO_ClientWrapper.Response result = KYC_CTRL_PartyProfile.processKycTest(jsonString);
        Test.stopTest();
        Assert.areEqual('Failed', result.status, 'Status should be Failed');
        Assert.areNOTEqual(null, result.message, 'Error message should be populated');
    }
    /**
     * @description This is test method to testProcessKycException
     */
    @IsTest
    static void  ProcessKycTestExceptionTest() {
        String jsonString = '{"clientDetails": null, "checks": {"assessment": "Test"}}';
        Test.startTest();
        KYC_DTO_ClientWrapper.Response result = KYC_CTRL_PartyProfile.processKycTest(jsonString);
        Test.stopTest();
        Assert.areEqual('Failed', result.status, 'Status should be Failed');
        Assert.areEqual(500, result.responseCode, 'Response code should be 500');
    }
    /**
     * @description This is test method to CheckInPendingPartyIdentityVerification_PendingVerification
     */
    @IsTest
    static void  CheckInPendingPartyIdentityVerification_PendingVerificationTest() {
        Test.startTest();
        PartyProfile partyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        Boolean isPending = KYC_CTRL_PartyProfile.checkInPendingPartyIdentityVerification(partyProfile.Id);
        Test.stopTest();
        Assert.areEqual(true, isPending, 'There is a pending PartyIdentityVerification');
    }
    /**
     * @description This is test method to checkInPendingPartyScreeningSummary
     */
    @IsTest
    static void  checkInPendingPartyScreeningSummaryTest() {
        Test.startTest();
        PartyProfile partyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        Boolean isPending = KYC_CTRL_PartyProfile.checkInPendingPartyScreeningSummary(partyProfile.Id);
        Test.stopTest();
        Assert.areEqual(true, isPending, 'There is a pending PartyIdentityVerification');
    }
    /**
     * @description This is test method to UpsertPartyProfile_Success
     */
    @IsTest
    static void  UpsertPartyProfile_SuccessTest() {
        try{
            Test.startTest();
            String jsonString = '[{"FirstName":"John","LastName":"Doe","DateOfBirth":"1985-05-15","WI_PrimaryIdentificationName__c":"ID12345678","Status__c":"Verified"}]';
            List<PartyProfile> result = KYC_CTRL_PartyProfile.upsertPartyProfile(jsonString);
            PartyProfile upsertedProfile = result[0];
            Test.stopTest();
            Assert.areEqual('John', upsertedProfile.FirstName, 'FirstName should be John');
            Assert.areEqual('Doe', upsertedProfile.LastName, 'LastName should be Doe');
            Assert.areEqual('ID12345678', upsertedProfile.WI_PrimaryIdentificationName__c, 'Primary Identification should be ID12345678');
            Assert.areEqual(null, result, 'Returned PartyProfile list should not be null');
            Assert.areEqual(1, result.size(), 'One PartyProfile should have been upserted');
        }catch(exception ex){
            Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred');
        }
    }
    
    /**
     * @description This is test method to handleExistingPartyProfile
     */
    @IsTest
    static void  handleExistingPartyProfileTest() {
        PartyProfile partyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        Test.startTest();
        KYC_DTO_ClientWrapper.Response response=KYC_CTRL_PartyProfile.handleExistingPartyProfile(partyProfile);
        Test.stopTest();
        Assert.areEqual(200, response.responseCode,'should return a successful response code 200');
    }
    
    /**
     * @description This is test method to createNewScreeningSummary
     */
    @IsTest
    static void  createNewScreeningSummaryTest() {
        PartyProfile partyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        Test.startTest();
        KYC_CTRL_PartyProfile.createNewScreeningSummary(partyProfile);
        Test.stopTest();
        Set<Id> partyProfileIds = new Set<Id>{partyProfile.Id};
        List<PartyScreeningSummary> PartyScreeningSummaryList = new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(partyProfileIds);
         Assert.areEqual(2, PartyScreeningSummaryList.size(),'should return a successful response code 200');
    }

    /**
     * @description Builds a valid KYC_DTO_ClientWrapper request for processKycTest
     * @param idValidation ID Validation check flag
     * @param idv IDV check flag
     * @param assessmentJson JSON for the assessment node, or 'null'
     * @return String
     */
    private static String buildClientWrapperJson(Boolean idValidation, Boolean idv, String assessmentJson) {
        return '{"clientDetails":{"title":"MR.","firstName":"Wrapper","middleName":"IK","lastName":"Client","gender":"Male",'
            + '"idDocIssuingCountry":"UG","idNumber":"WRAP123456","primaryIdType":"National Identity Document",'
            + '"primaryPhone":"123-456-7890","primaryEmail":"wrapper@test.com","nationality":"UG","occupationLevel":"Unemployed",'
            + '"dob":"1995-05-05","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG",'
            + '"passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":false,"ficPipRel":false,'
            + '"ficPipRelFirstName":"Wrapper","ficPipRelLastName":"Client","docAdd":"Proof Of Address;Proof of Identity",'
            + '"addresses":[{"type":"Billing","primaryAddress":true,"street":"Main Street","city":"Kampala","stateCode":"KA","countryCode":"UG","postalCode":"123"}]},'
            + '"checks":{"idValidation":' + idValidation + ',"idv":' + idv + ',"assessment":' + assessmentJson + '}}';
    }

    /**
     * @description processKycTest creates a new profile with checks and screening summary steps
     *              (covers checkExistingPartyProfile, createOrUpdateChecks and createOrUpdateScreeningSummary)
     */
    @IsTest
    static void processKycTestCreatesNewProfileTest() {
        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        String jsonString = buildClientWrapperJson(true, true, '{"PEP_Screening":true,"CRA":true,"screening":true}');

        Test.startTest();
        KYC_DTO_ClientWrapper.Response result = KYC_CTRL_PartyProfile.processKycTest(jsonString);
        Test.stopTest();

        Assert.areEqual('Success', result.status, 'Status should be Success: ' + result.message);
        Assert.areEqual(200, result.responseCode, 'Response code should be 200');
        Assert.isNotNull(result.kycProfileId, 'KYC profile Id should be returned');

        Id profileId = result.kycProfileId;
        List<PartyIdentityVerification> pivList = new SEL_PartyIdentityVerification().selectByPartyProfileIds(new Set<Id>{profileId});
        Assert.areEqual(2, pivList.size(), 'Id Validation and WFR checks should be created');
        List<PartyScreeningSummary> pssList = new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(new Set<Id>{profileId});
        Assert.areEqual(1, pssList.size(), 'One assessment screening summary should be created');
    }

    /**
     * @description processKycTest with validation ignored, no checks and no assessment
     *              (covers the empty check list and null assessment branches)
     */
    @IsTest
    static void processKycTestNoChecksIgnoreValidationTest() {
        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        String jsonString = buildClientWrapperJson(false, false, 'null');

        Test.startTest();
        KYC_DTO_ClientWrapper.Response result = KYC_CTRL_PartyProfile.processKycTest(jsonString, true);
        Test.stopTest();

        Assert.areEqual('Success', result.status, 'Status should be Success: ' + result.message);
        Id profileId = result.kycProfileId;
        Assert.areEqual(0, new SEL_PartyIdentityVerification().selectByPartyProfileIds(new Set<Id>{profileId}).size(), 'No checks should be created');
        Assert.areEqual(0, new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(new Set<Id>{profileId}).size(), 'No screening summary should be created');
    }

    /**
     * @description processKycTest with an assessment where every step is false creates no screening summary
     */
    @IsTest
    static void processKycTestAssessmentWithoutStepsTest() {
        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        String jsonString = buildClientWrapperJson(true, false, '{"PEP_Screening":false,"CRA":false,"screening":false}');

        Test.startTest();
        KYC_DTO_ClientWrapper.Response result = KYC_CTRL_PartyProfile.processKycTest(jsonString);
        Test.stopTest();

        Assert.areEqual('Success', result.status, 'Status should be Success: ' + result.message);
        Id profileId = result.kycProfileId;
        Assert.areEqual(1, new SEL_PartyIdentityVerification().selectByPartyProfileIds(new Set<Id>{profileId}).size(), 'Only the Id Validation check should be created');
        Assert.areEqual(0, new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(new Set<Id>{profileId}).size(), 'No screening summary without steps');
    }

    /**
     * @description checkExistingPartyProfile returns the matching profile, and processKycTest
     *              then routes to the existing-profile handling
     */
    @IsTest
    static void checkExistingPartyProfileMatchTest() {
        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        PartyProfile existing = new PartyProfile(
            Name = 'Wrapper Client',
            FirstName = 'Wrapper',
            LastName = 'Client',
            DateOfBirth = Date.newInstance(1995, 5, 5),
            WI_PrimaryIdentificationName__c = 'WRAP123456'
        );
        insert existing;
        String jsonString = buildClientWrapperJson(true, true, '{"PEP_Screening":true,"CRA":true,"screening":true}');
        KYC_DTO_ClientWrapper wrapper = (KYC_DTO_ClientWrapper) JSON.deserialize(jsonString, KYC_DTO_ClientWrapper.class);

        Test.startTest();
        PartyProfile found = KYC_CTRL_PartyProfile.checkExistingPartyProfile(wrapper);
        KYC_DTO_ClientWrapper.Response result = KYC_CTRL_PartyProfile.processKycTest(jsonString);
        Test.stopTest();

        Assert.areEqual(existing.Id, found.Id, 'The existing profile should be found');
        Assert.areEqual(200, result.responseCode, 'Existing profile should return 200');
        Assert.areEqual(String.valueOf(existing.Id), result.kycProfileId, 'Existing profile Id should be returned');
    }

    /**
     * @description checkExistingPartyProfile returns null for incomplete requests or no match
     */
    @IsTest
    static void checkExistingPartyProfileNoMatchTest() {
        KYC_DTO_ClientWrapper noChecks = new KYC_DTO_ClientWrapper();
        noChecks.clientDetails = new KYC_DTO_ClientDetails();
        KYC_DTO_ClientWrapper noMatch = (KYC_DTO_ClientWrapper) JSON.deserialize(
            buildClientWrapperJson(true, true, 'null'), KYC_DTO_ClientWrapper.class);

        Test.startTest();
        PartyProfile nullWrapper = KYC_CTRL_PartyProfile.checkExistingPartyProfile(null);
        PartyProfile missingChecks = KYC_CTRL_PartyProfile.checkExistingPartyProfile(noChecks);
        PartyProfile notFound = KYC_CTRL_PartyProfile.checkExistingPartyProfile(noMatch);
        Test.stopTest();

        Assert.isNull(nullWrapper, 'Null request should return null');
        Assert.isNull(missingChecks, 'Request without checks should return null');
        Assert.isNull(notFound, 'No matching profile should return null');
    }
}