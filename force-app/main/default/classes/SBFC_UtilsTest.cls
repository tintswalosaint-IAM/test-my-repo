/**
* @File Name : SBFC_UtilsTest.cls
* @Description : SFP-54443 - Test class for SBFC_Utils .
* @Author : Amlendu Bajpai
* @Last Modified By :Amlendu Bajpai
* @Last Modified On : November 10, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 10, 2025 |   | Initial Version
**/
@IsTest
private class SBFC_UtilsTest {

    @testSetup
    static void setup() {
        Account account = new Account(
            LastName = 'Moonstone Test',
            PersonEmail = 'test@test.com',
            CMN_IdentityNumber__pc = '7008200173082'
        );
        insert account;
    }

    
    @IsTest
    static void getSObjectFieldListtest(){
        List<Schema.SObjectField> purposeFields = new SEL_DataUsePurpose().getSObjectFieldList();
        new SEL_DataUseLegalBasis().getSObjectFieldList();
        new SEL_AuthorizationForm().getSObjectFieldList();
        new SEL_AuthorizationFormText().getSObjectFieldList();
        new SEL_AuthorizationFormDataUse().getSObjectFieldList();
        Assert.isNotNull(
        purposeFields,
        'DataUsePurpose field list should not be null.'
    );
    Assert.isFalse(
        purposeFields.isEmpty(),
        'DataUsePurpose field list should not be empty.'
    );
    }

    
    @IsTest
    static void testCreateDisclosureInfoAuthorizationRequest() {

        Account acc = [
            SELECT Id, Name
            FROM Account
            LIMIT 1
        ];

        Test.startTest();

        
        InfoAuthorizationRequest infoAuthReq =
            SBFC_Utils.createDisclosureInfoAuthorizationRequest(
                acc
            );
        

        Test.stopTest();

        Assert.isNotNull(
            infoAuthReq,
            'InfoAuthorizationRequest should be created.'
        );

        Assert.areEqual(
            acc.Id,
            infoAuthReq.SBFC_Account__c,
            'Account lookup should be populated.'
        );

        Assert.areEqual(
            acc.Id,
            infoAuthReq.SourceRecordId,
            'SourceRecordId should match Account.'
        );

        Assert.areEqual(
            acc.Id,
            infoAuthReq.PertainsToId,
            'PertainsToId should match Account.'
        );

        Assert.areEqual(
            acc.Id,
            infoAuthReq.ConsenterId,
            'ConsenterId should match Account.'
        );

        Assert.areEqual(
            acc.Name + ' Moonstone Disclosure',
            infoAuthReq.Name,
            'Name should follow the expected naming convention.'
        );

        Assert.areEqual(
            UserInfo.getUserId(),
            infoAuthReq.RequesterId,
            'RequesterId should be the running user.'
        );

        Assert.areEqual(
            'Email',
            infoAuthReq.CommunicationType,
            'CommunicationType should be Email.'
        );

        Assert.areEqual(
            'New',
            infoAuthReq.ResponseStatus,
            'ResponseStatus should be New.'
        );

        Assert.areEqual(
            'en_US',
            infoAuthReq.Locale,
            'Locale should be en_US.'
        );

        Assert.isNotNull(
            infoAuthReq.DataUsePurposeId,
            'DataUsePurposeId should be populated.'
        );

        Assert.isNotNull(
            infoAuthReq.RecordTypeId,
            'RecordTypeId should be populated.'
        );
    }
}