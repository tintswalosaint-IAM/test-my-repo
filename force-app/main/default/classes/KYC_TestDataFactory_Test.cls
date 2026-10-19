/***************************************************************************************
@Name of the Class :KYC_TestDataFactory
@Description :SFP-40755 Test Class for KYC_TestDataFactory_Test.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_TestDataFactory_Test {
    /**
     * @description Test method for createPartyProfile
     */
    @IsTest
    static void createPartyProfileTest() {
        String PartyProfileId=KYC_TestDataFactory.createPartyProfile('UG');
        Assert.areNotEqual(null, PartyProfileId,'Expected PartyProfileId not null');
    }
    
    /**
     * @description Test method for createPartyScreening
     */
    @IsTest
    static void createPartyScreeningTest() {
        String PartyProfileId=KYC_TestDataFactory.createPartyProfile('UG');
        String createPartyScreeningId=KYC_TestDataFactory.createPartyScreening(PartyProfileId);
        Assert.areNotEqual(null, createPartyScreeningId,'Expected PartyProfileId not null');
    }
    
     /**
     * @description Test method for createPartyScreeningStep
     */
    @IsTest
    static void createPartyScreeningStepTest() {
        String PartyProfileId=KYC_TestDataFactory.createPartyProfile('UG');
        String createPartyScreeningId=KYC_TestDataFactory.createPartyScreening(PartyProfileId);
        String createPartyScreeningStepId=KYC_TestDataFactory.createPartyScreeningStep(createPartyScreeningId,'Completed');
        Assert.areNotEqual(null, createPartyScreeningStepId,'Expected PartyProfileId not null');
    }
    
    /**
     * @description Test method for createPartyPartyIdentityVerification
     */
    @IsTest
    static void createPartyPartyIdentityVerificationTest() {
        String PartyProfileId=KYC_TestDataFactory.createPartyProfile('UG');
        String IdIdentityVerif= KYC_TestDataFactory.createPartyPartyIdentityVerification(PartyProfileId,'In Progress','');
        Assert.areNotEqual(null, IdIdentityVerif,'Expected IdentityVerification id not null');
    }
    
    /**
     * @description Test method for createAccount
     */
    @IsTest
    static void createAccountTest() {
        Account acc=KYC_TestDataFactory.createAccount();
        Assert.areEqual('TestACC', acc.FirstName,'Expected Name from Account');
        
    }
    
     /**
     * @description Test method for createPartyProfilet
     */
    @IsTest
    static void createPartyProfiletTest() {
        Account acc=KYC_TestDataFactory.createAccount();
        KYC_TestDataFactory.createPartyProfile(acc.id);
        Assert.areEqual('TestACC', acc.FirstName,'Expected value Account Name');
    }
    
    /**
     * @description Test method for createPartyIdentity
     */
    @IsTest
    static void createPartyIdentityTest() {
        String PartyProfileId=KYC_TestDataFactory.createPartyProfile('UG');
        PartyIdentityVerification piv= KYC_TestDataFactory.createPartyIdentity(PartyProfileId);
        Assert.areEqual('5804832', piv.ThirdPartyVerfdentifier,'Expected value ThirdPartyVerfdentifier'); 
    }
    
    /**
     * @description Test method for createPartyIdentity
     */
    @IsTest
    static void requestBodyTest() {
        String req=KYC_TestDataFactory.requestBody();
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(req);
        Assert.areEqual('33844b1d-f770-4b6d-8cc3-ee6d5db52e1d', (String) jsonMap.get('uniqueIdentifier'),'Expected value uniqueIdentifier');
    }
    
     /**
     * @description Test method for requestBodydiff
     */
    @IsTest
    static void requestBodydiffTest() {
        String req=KYC_TestDataFactory.requestBodydiff('ee6d5db52e1d','7574454',true);
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(req);
        Assert.areEqual('ee6d5db52e1d', (String) jsonMap.get('uniqueIdentifier'),'Expected value uniqueIdentifier');
    }


}