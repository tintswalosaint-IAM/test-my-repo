/***************************************************************************************
@Name of the Class :KYC_SRV_PartyProfileAddress_Test
@Description :SFP-40755 Test Class for KYC_SRV_PartyProfileAddress.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_SRV_PartyProfileAddress_Test {
    /**
     * @description This method is for SavePartyIdentityVerification positive test
     */
    @isTest
    static void savePartyProfileAddressTest() { 
       
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
        PartyProfileAddress ppAddress = new PartyProfileAddress();
        ppAddress.Name = 'Test Address';
        PartyProfile partyProfile = new SEL_PartyProfile().selectById(partyProfileId);
        try {
            Test.startTest();
            KYC_SRV_PartyProfileAddress.newInstance().savePartyProfileAddress(partyProfile,new List<PartyProfileAddress>{ppAddress}, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyProfileAddress failed');
        }
    }
    /**
     * @description This method is for SavePartyIdentityVerification negative test
     */
    @isTest
    static void savePartyProfileAddressNegativeTest() {
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
        Id ppAddressId = KYC_TestDataFactory.createPartyProfileAddress(partyProfileId);
        PartyProfile partyProfile = new SEL_PartyProfile().selectById(partyProfileId);
        List<PartyProfileAddress> ppAddressList = new SEL_PartyProfileAddress().selectById(ppAddressId);
        try {
            Test.startTest();
            KYC_SRV_PartyProfileAddress.newInstance().savePartyProfileAddress(partyProfile,ppAddressList, uow);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual(null, e, 'savePartyProfileAddress failed');
        }
    }
}