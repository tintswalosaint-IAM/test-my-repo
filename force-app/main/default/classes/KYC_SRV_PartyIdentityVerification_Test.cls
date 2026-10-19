/***************************************************************************************
@Name of the Class :KYC_SRV_PartyIdentityVerification_Test
@Description :SFP-40755 Test Class for KYC_SRV_PartyIdentityVerification.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_SRV_PartyIdentityVerification_Test {
    /**
     * @description This method is for SavePartyIdentityVerification positive test
     */
    @isTest
    private static void testSavePartyIdentityVerificationTest() {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> { 
                PartyProfile.SObjectType, 
                PartyProfileAddress.SObjectType, 
                PartyIdentityVerification.SObjectType, 
                PartyScreeningSummary.SObjectType,
                PartyScreeningStep.SObjectType,
                PartyIdentityVerificationStep.SObjectType 
            }
        );
        PartyIdentityVerification partyIdentityVerification = new PartyIdentityVerification();
        Id partyProfileId = KYC_TestDataFactory.createPartyProfile('UG');
        partyIdentityVerification.PartyProfileId = partyProfileId;
        partyIdentityVerification.Name = 'Test Screening Step';
        partyIdentityVerification.Document_Type__c = 'Proof of identity';
        partyIdentityVerification.Status = 'Completed';
        partyIdentityVerification.Result = 'Accepted';
        try {
            Test.startTest();
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(new List<PartyIdentityVerification>{partyIdentityVerification}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'SavePartyIdentityVerification failed');
        }
       
    }  
    /**
     * @description This method is for SavePartyIdentityVerification negative test
     */
    @isTest
    private static void testSavePartyIdentityVerificationNegativeTest() {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> { 
                PartyProfile.SObjectType, 
                PartyProfileAddress.SObjectType, 
                PartyIdentityVerification.SObjectType, 
                PartyScreeningSummary.SObjectType,
                PartyScreeningStep.SObjectType,
                PartyIdentityVerificationStep.SObjectType 
            }
        );
        Id partyProfileId = KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyPartyIdentityVerification(partyProfileId, 'Completed', 'Accepted');
        List<PartyIdentityVerification> existingPartyIdentityVerificationList = new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>{partyProfileId});
        try {
            Test.startTest();
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(existingPartyIdentityVerificationList, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'SavePartyIdentityVerification failed');
        }
    }  
    /**
     * @description This method is for SavePartyIdentityVerification positive test
     */
    @isTest
    private static void testSavePartyIdentityVerificationWithPartyProfileIdTest() {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> { 
                PartyProfile.SObjectType, 
                PartyProfileAddress.SObjectType, 
                PartyIdentityVerification.SObjectType, 
                PartyScreeningSummary.SObjectType,
                PartyScreeningStep.SObjectType,
                PartyIdentityVerificationStep.SObjectType 
            }
        );
        PartyIdentityVerification partyIdentityVerification = new PartyIdentityVerification();
        Id partyProfileId = KYC_TestDataFactory.createPartyProfile('UG');
        partyIdentityVerification.PartyProfileId = partyProfileId;
        partyIdentityVerification.Name = 'Test Screening Step';
        partyIdentityVerification.Document_Type__c = 'Proof of identity';
        partyIdentityVerification.Status = 'Completed';
        partyIdentityVerification.Result = 'Accepted';
        try {
            Test.startTest();
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(partyProfileId,new List<PartyIdentityVerification>{partyIdentityVerification}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'SavePartyIdentityVerification failed');
        }
    }  
    
    /**
     * @description This method is for SavePartyIdentityVerification negative test
     */
    @isTest
    private static void testSavePartyIdentityVerificationWithPartyProfileIdNegativeTest() {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> { 
                PartyProfile.SObjectType, 
                PartyProfileAddress.SObjectType, 
                PartyIdentityVerification.SObjectType, 
                PartyScreeningSummary.SObjectType,
                PartyScreeningStep.SObjectType,
                PartyIdentityVerificationStep.SObjectType 
            }
        );
        Id partyProfileId = KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyPartyIdentityVerification(partyProfileId, 'Completed', 'Accepted');
        List<PartyIdentityVerification> existingPartyIdentityVerificationList = new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>{partyProfileId});
        try {
            Test.startTest();
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(partyProfileId,existingPartyIdentityVerificationList, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'SavePartyIdentityVerification failed');
        }
    }  
    /**
     * @description This method is for SavePartyIdentityVerification positive test
     */
    @isTest
    private static void testSavePartyIdentityVerificationWithPartyProfileTest() {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> { 
                PartyProfile.SObjectType, 
                PartyProfileAddress.SObjectType, 
                PartyIdentityVerification.SObjectType, 
                PartyScreeningSummary.SObjectType,
                PartyScreeningStep.SObjectType,
                PartyIdentityVerificationStep.SObjectType 
            }
        );
        PartyIdentityVerification partyIdentityVerification = new PartyIdentityVerification();
        Id partyProfileId = KYC_TestDataFactory.createPartyProfile('UG');
        partyIdentityVerification.PartyProfileId = partyProfileId;
        partyIdentityVerification.Name = 'Test Screening Step';
        partyIdentityVerification.Document_Type__c = 'Proof of identity';
        partyIdentityVerification.Status = 'Completed';
        partyIdentityVerification.Result = 'Accepted';
        List<PartyProfile> partyProfileList = new SEL_PartyProfile().selectByIds(new Set<Id>{partyProfileId});
        try {
            Test.startTest();
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(partyProfileList[0],new List<PartyIdentityVerification>{partyIdentityVerification}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'SavePartyIdentityVerification failed');
        }
    }  
    
    /**
     * @description This method is for SavePartyIdentityVerification negative test
     */
    @isTest
    private static void testSavePartyIdentityVerificationWithPartyProfileNegativeTest() {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType> { 
                PartyProfile.SObjectType, 
                PartyProfileAddress.SObjectType, 
                PartyIdentityVerification.SObjectType, 
                PartyScreeningSummary.SObjectType,
                PartyScreeningStep.SObjectType,
                PartyIdentityVerificationStep.SObjectType 
            }
        );
        Id partyProfileId = KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyPartyIdentityVerification(partyProfileId, 'Completed', 'Accepted');
        List<PartyIdentityVerification> existingPartyIdentityVerificationList = new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>{partyProfileId});
        List<PartyProfile> partyProfileList = new SEL_PartyProfile().selectByIds(new Set<Id>{partyProfileId});
        try {
            Test.startTest();
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(partyProfileList[0],existingPartyIdentityVerificationList, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'SavePartyIdentityVerification failed');
        }
    }  
}