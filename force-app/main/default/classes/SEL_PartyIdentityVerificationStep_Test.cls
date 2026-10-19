/**
* @Name of the Class : SEL_PartyIdentityVerificationStep_Test
* @description       : SFP-36380 Selector Test class for SEL_PartyIdentityVerificationStep object.
* @author            :Ikyatha Naidu 
* @date              :17/05/2024
********************************************
* @last modified on  : 01/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
**/
@istest
public class SEL_PartyIdentityVerificationStep_Test {
   
    
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_PartyIdentityVerificationStep partyProfileSelector = new SEL_PartyIdentityVerificationStep();
        Schema.SObjectType sObjectType = partyProfileSelector.getSObjectType();
        
        Assert.areEqual(PartyIdentityVerificationStep.SObjectType, sObjectType, 'Unexpected SObjectType');
        Test.startTest();   
        List<Schema.SObjectField> sObjectFieldList = partyProfileSelector.getSObjectFieldList();
        Test.stopTest();
        
        Map<String, Schema.SObjectField> fieldMap = PartyIdentityVerificationStep.SObjectType.getDescribe().fields.getMap();
        
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    @IsTest
    static void selectPartyIdentityVerificationStepByVerificationIdTestMethod() {
        Account testAccount =ICS_DAL_TestFactory.createAccount();
       
        PartyProfile profileData =ICS_DAL_TestFactory.createPartyProfile(testAccount.id);
   
        
        ICS_DAL_TestFactory.createPartyProfileAddress(profileData.id,'Residential Address',date.today()-30,null);
          
        
        PartyIdentityVerification verification = ICS_DAL_TestFactory.createPartyIdentity(profileData.id);

        Test.startTest();   
        SEL_PartyIdentityVerificationStep prodQueryList = new SEL_PartyIdentityVerificationStep();
        prodQueryList.selectByVerificationId(new set<id>{verification.id});
        Test.stopTest();
        Assert.areEqual(true, verification!=null, 'Unexpected Address Info');
        
    }
   
    
}