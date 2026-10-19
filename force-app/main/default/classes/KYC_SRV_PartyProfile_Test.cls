/***************************************************************************************
@Name of the Class :KYC_SRV_PartyProfile_Test
@Description :SFP-40755 Test Class for KYC_SRV_PartyProfile.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_SRV_PartyProfile_Test {
    /**
     * @description This method is for savePartyProfiles positive test
     */
    @isTest
    static void savePartyProfilesTest() {
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
        PartyProfile pp           = new PartyProfile(); 
        pp.FirstName              = 'TEST'; 
        pp.LastName               = 'SURNAME';
        pp.Name                   = 'TEST SURNAME';  
        pp.PrimaryEmail           = 'TEST_SURNAME@test.com';
        pp.PrimaryIdentifierType  = '10'; // National Identity Document
        pp.PrimaryIdentifier  = '218731831'; 
        pp.WI_PrimaryIdentificationName__c = 'Phone';
        pp.DateOfBirth = Date.valueOf('2001-09-17');
        pp.CMN_OccupationLevel__c = 'Self Employed';
        pp.EmploymentType = 'Unemployed';
       
        try {
            Test.startTest();
            KYC_SRV_PartyProfile.newInstance().savePartyProfiles(new List<PartyProfile>{pp}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyProfiles failed');
        }
        
    }
    /**
     * @description This method is for savePartyProfiles positive test
     */
    @isTest
    static void savePartyProfilesNegativeTest() {
        
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
        PartyProfile pp = new SEL_PartyProfile().selectById(ppId);
        
        try {
            Test.startTest();
            KYC_SRV_PartyProfile.newInstance().savePartyProfiles(new List<PartyProfile>{pp}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyProfiles failed');
        }

    }
}