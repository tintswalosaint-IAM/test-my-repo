/***************************************************************************************
@Name of the Class :KYC_TestDataFactory
@Description :SFP-40755 KYC_TestDataFactory	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@testVisible
public with sharing class KYC_TestDataFactory {
     @testVisible
     private KYC_TestDataFactory(){}
    /**
     *@description Create test data for PartyProfile. 
     *@return partyProfile
     **/
    public static Id createPartyProfile(String identificationDocumentIssuingCountry)
    {
        Id recTypeId = Schema.getGlobalDescribe().get('PartyProfile').getDescribe().getRecordTypeInfosByDeveloperName().get('Know_Your_Customer').getRecordTypeId();
        PartyProfile pprofile           = new PartyProfile(); 
        pprofile.FirstName              = 'TEST'; 
        pprofile.LastName               = 'SURNAME';
        pprofile.Name                   = 'WFR';  
        pprofile.PrimaryEmail           = 'TEST_SURNAME@test.com';
        pprofile.PrimaryIdentifierType  = '10'; // National Identity Document
        pprofile.PrimaryIdentifier  = '218731831'; 
        pprofile.WI_IdentificationDocumentIssuingCountry__c = identificationDocumentIssuingCountry;
        pprofile.WI_PrimaryIdentificationName__c = 'Phone';
        pprofile.DateOfBirth = Date.valueOf('2001-09-17');
        pprofile.CMN_OccupationLevel__c = 'Self Employed';
        pprofile.EmploymentType = 'Unemployed';
        pprofile.Gender ='Male';
        pprofile.WI_CountryOfCitizenship__c = 'UG';
        pprofile.WI_PassportIssuingCountry__c = 'UG';
        pprofile.CMN_FICPIP__c = true;
        pprofile.CMN_FICPIPREL__c = true;
        pprofile.CMN_FICPIPRELFIRSTNAME__c = 'Test';
        pprofile.CMN_FICPIPRELLASTNAME__c = 'Test';
        pprofile.WI_PrimaryIdentificationName__c = '1f2r3tu';
        pprofile.Name = 'record';
        pprofile.WI_MaritialStatus__c='Married';
        pprofile.Has_different_First_Middle_Family_Name__c='Yes';
        pprofile.Has_Former_Name__c ='Yes';
        pprofile.RecordTypeId = recTypeId;
        insert pprofile; 
        return pprofile.Id; 
    }    
    /**
     *@description Create test data for Party Screening Summary. 
     *@return ScreeningSummaryId
     */
    public static Id createPartyScreening(Id ppId)
    {
        PartyScreeningSummary screeningSummary = new PartyScreeningSummary(); 
        screeningSummary.Name           = 'TEST SURNAME SCREENING'; 
        screeningSummary.PartyProfileId = ppId;
        screeningSummary.RecordTypeId   = Schema.SObjectType.PartyScreeningSummary.getRecordTypeInfosByDeveloperName().get('WI_Individual').getRecordTypeId();  
        screeningSummary.Status = 'In Progress';
        insert screeningSummary; 
        return screeningSummary.Id; 
    }
    /**
     * @description Create test data for Party Screening Step. 
     * @return screeningStepId
     */
    public static Id createPartyScreeningStep(Id screeingSummaryId, String status){
        PartyScreeningStep screeningStep = new PartyScreeningStep();
        screeningStep.ScreeningSummaryId = screeingSummaryId;
        screeningStep.Name = 'Test Screening Step';
        screeningStep.Type = 'PEP';
        screeningStep.Status = status;
        insert screeningStep;
        return screeningStep.Id; 
    }
    /**
     *@description Create test data for createPartyPartyIdentityVerification. 
     *@return Id
     **/
    public static Id createPartyPartyIdentityVerification(Id partyProfileId, String status, String result){
        PartyIdentityVerification partyIdentityVerification = new PartyIdentityVerification();
        partyIdentityVerification.PartyProfileId = partyProfileId;
        partyIdentityVerification.Name = 'Test Screening Step';
        partyIdentityVerification.Document_Type__c = 'Proof of identity';
        partyIdentityVerification.Status = status;
        partyIdentityVerification.Result = result;
        partyIdentityVerification.ThirdPartyVerfdentifier = '33844b1d-f770-4b6d-8cc3-ee6d5db52e1d';
        insert partyIdentityVerification;
        return partyIdentityVerification.Id; 
    }
     /**
     *@description Create test data for createPartyProfileAddress. 
     *@return Id
     **/
    public static Id createPartyProfileAddress(Id partyProfile){
        PartyProfileAddress ppAddress = new PartyProfileAddress();
        ppAddress.Name = 'Test Address';
        insert ppAddress;
        return ppAddress.Id;
    }
    /**
     *@description Create test data for createAccount. 
     *@return Account
     */
    public static Account createAccount() {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ICS_Applicant').getRecordTypeId();
        Account account = new Account( FirstName = 'TestACC',LastName = 'testet',AOB_CommerceSiteId__c = 'SB-COZA',AOB_TECH_CCCustomerId__c = 'XXX', FinServ__Gender__pc = 'Male',Phone = '+27823309876',
            ExternalCIFUUID__c = 'RandonBPGUID',
            RecordTypeId = personAccountRecordTypeId
        );
        insert account;
        return account;
    }
     /**
     *@description Create test data for createPartyProfile. 
     *@param accId
     *@return PartyProfile
     */
    public static PartyProfile createPartyProfile(Id accId) {
        Id recTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId();
        PartyProfile profile = new PartyProfile(
            Name = 'record',
            WI_MaritialStatus__c='Married',
            Has_different_First_Middle_Family_Name__c='Yes',
            AccountId = accId,
            Has_Former_Name__c ='Yes',
            RecordTypeId = recTypeId
        );
        insert profile;
        return profile;
    }
    /**
     *@description Create test data for createPartyIdentity. 
     *@param partyProfileId
     */
    public static PartyIdentityVerification createPartyIdentity(Id partyProfileId) {
        PartyIdentityVerification verification = new PartyIdentityVerification(
            Name = 'WFR',
            PartyProfileId = partyProfileId,
            ThirdPartyVerfdentifier = '5804832',
            Result = 'On Hold',
            ResultOverrideReason = 'OCR Failed'
        );
        insert verification;
        return verification;
    }
    /**
     *@description Create test data for createBusinessOwnerPartyProfile. 
     *@param accId
     *@return PartyProfile
     */
    public static PartyProfile createBusinessOwnerPartyProfile(Id accId) {
        Id recTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('ICS Additional Business Owner').getRecordTypeId();
        PartyProfile profile = new PartyProfile( 
            Name = 'record', 
            AccountId = accId,
            RecordTypeId = recTypeId 
        );
        insert profile;
        return profile;
    }
    
    /**
     * @description  method for to form request body
    */ 
    public Static String requestBody(){
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = '33844b1d-f770-4b6d-8cc3-ee6d5db52e1d';
        requestBody.IdentityNumber = '218731831';
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf('Test Attachment'));
        docReq.title = 'pancard.pdf';
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
        return JSON.serialize(requestBody);
    }
    
    /**
     * @description  method for to form request body
     */ 
    public Static String requestBodydiff(String uniqueIdentifier,String IdentityNumber,Boolean LivenessFRMatch ){
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = uniqueIdentifier;
        requestBody.IdentityNumber = IdentityNumber;
        requestBody.LivenessFRMatch = LivenessFRMatch;
        requestBody.LivenessFRScore = 21;
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf('Test Attachment'));
        docReq.title = 'pancard.pdf';
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            return JSON.serialize(requestBody);
    }
}