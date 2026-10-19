/***************************************************************************************
@Name of the Class :KYC_SRV_PartyScreeningSummary_Test
@Description :SFP-40755 Test Class for KYC_SRV_PartyScreeningSummary.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_SRV_PartyScreeningSummary_Test {
    /**
     * @description This meethod is used for savePartyScreeningSummary for positive test
     */
    @isTest
    static void savePartyScreeningSummaryTest() {
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
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyScreening(ppId);
        PartyScreeningSummary screeningSymmary = new PartyScreeningSummary();
        screeningSymmary.PartyProfileId = ppId;
        screeningSymmary.Name = 'Test Screening Summary';
        screeningSymmary.Status = 'In Progress';
        try {
            Test.startTest();
            KYC_SRV_PartyScreeningSummary.newInstance().savePartyScreeningSummary(new List<PartyScreeningSummary>{screeningSymmary}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyScreeningSummary failed');
        }
    }
    /**
     * @description This method is used for savePartyScreeningSummary for negative test
     */
    @isTest
    static void savePartyScreeningSummaryNegativeTest() {
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
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        Id screeningSymmaryId = KYC_TestDataFactory.createPartyScreening(ppId);
        PartyScreeningSummary screeningSymmary = new SEL_PartyScreeningSummary().selectById(screeningSymmaryId);
        try {
            Test.startTest();
            KYC_SRV_PartyScreeningSummary.newInstance().savePartyScreeningSummary(new List<PartyScreeningSummary>{screeningSymmary}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyScreeningSummary failed');
        }
    }
    /**
     * @description This method is used for savePartyScreeningSummary for positive test
     */
    @isTest
    static void savePartyScreeningSummaryWithPartyProfileIdTest() {
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
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyScreening(ppId);
        PartyScreeningSummary screeningSymmary = new PartyScreeningSummary();
        screeningSymmary.PartyProfileId = ppId;
        screeningSymmary.Name = 'Test Screening Summary';
        screeningSymmary.Status = 'In Progress';
        PartyProfile partyProfile = new SEL_PartyProfile().selectById(ppId);
        try {
            Test.startTest();
            KYC_SRV_PartyScreeningSummary.newInstance().savePartyScreeningSummary(partyProfile,new List<PartyScreeningSummary>{screeningSymmary}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyScreeningSummary failed');
        }
    }
    /**
     * @description This method is used for savePartyScreeningSummary for negative test
     */
    @isTest
    static void savePartyScreeningSummaryWithPartyProfileIdNegativeTest() {
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
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        Id screeningSymmaryId = KYC_TestDataFactory.createPartyScreening(ppId);
        PartyScreeningSummary screeningSymmary = new SEL_PartyScreeningSummary().selectById(screeningSymmaryId);
        PartyProfile partyProfile = new SEL_PartyProfile().selectById(ppId);
        try {
            Test.startTest();
            KYC_SRV_PartyScreeningSummary.newInstance().savePartyScreeningSummary(partyProfile,new List<PartyScreeningSummary>{screeningSymmary}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyScreeningSummary failed');
        }
    }
}