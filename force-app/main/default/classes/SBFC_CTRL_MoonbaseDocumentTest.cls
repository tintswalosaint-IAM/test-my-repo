/**
 * @description       : SFP-55759 - This is the test class for SBFC_CTRL_MoonbaseDocument.
 *                      It contains unit tests to validate the functionality of the Moonstone Disclosure controller, ensuring that disclosure 
 *                      generation, prefill data retrieval, Account linking, existing disclosure validation, PDF generation, 
 *                      and InfoAuthorizationRequest management work as expected. The tests cover both positive and negative scenarios, including successful disclosure generation, validation failures, existing disclosure reuse, response persistence, and exception handling to ensure the controller behaves reliably under different business conditions.
 * @author            : Gigyasu
 * @group             : SBFC
 * @last modified on  : 08-07-2026
 * @last modified by  : Gigyasu 
**/


@IsTest
public class SBFC_CTRL_MoonbaseDocumentTest {
    

    private static final String VALID_STAGE ='In Progress – Awaiting Signed Disclosure';

    /**
     * @description Sets up the common test data required for the
     *              SBFC_CTRL_MoonbaseDocument test methods.
     */
    @TestSetup
    static void setupData() {

        Schema.RecordTypeInfo rtInfo =
            Schema.SObjectType.Lead
                .getRecordTypeInfosByDeveloperName()
                .get('SBFC_Lead');

        Lead lead = new Lead(
            LastName = 'Moon Lead',
            Company = 'SBFC',
            Status = 'Nurturing',
            Stage__c = VALID_STAGE,
            RecordTypeId = rtInfo.getRecordTypeId()
        );
        insert lead;
    }
    
    /**
 * @description Creates the consent-management metadata (Legal Basis,
 *              Purpose, Authorization Form + Text + Data Use) that
 *              SBFC_Utils.createDisclosureInfoAuthorizationRequest
 *              relies on.
 */
private static void setupConsentManagementData() {

    DataUseLegalBasis legal = new DataUseLegalBasis(
        Name = 'Disclosure Data Use Legal Basis'
    );
    insert legal;

    DataUsePurpose purpose = new DataUsePurpose(
        Name = 'Disclosure - Authorization Form Text',
        LegalBasisId = legal.Id,
        IsActive = false
    );
    insert purpose;

    AuthorizationForm form = new AuthorizationForm(
        Name = 'Disclosure - Authorization Form'
    );
    insert form;

    AuthorizationFormText aft = new AuthorizationFormText(
        Name = 'Disclosure - Authorization Form Text',
        Locale = 'en_ZA',
        AuthorizationFormId = form.Id,
        IsActive = true,
        SummaryAuthFormText = 'Disclosure'
    );
    insert aft;

    form.DefaultAuthFormTextId = aft.Id;
    update form;

    AuthorizationFormDataUse afdu = new AuthorizationFormDataUse(
        Name = 'Disclosure - Authorization Form Data Use',
        AuthorizationFormId = form.Id,
        DataUsePurposeId = purpose.Id
    );
    insert afdu;

    purpose.IsActive = true;
    update purpose;
}

    /**
     * @description Creates and returns a test Lead record.
     */
    private static Lead getLead() {

        return [
            SELECT Id,
                   OwnerId,
                   Status,
                   Stage__c,
                   FinServ__RelatedAccount__c
            FROM Lead
            LIMIT 1
        ];
    }
    
    
    /**
     * @description Returns the Person Account Record Type Id used for testing.
     */
    private static Id getPersonAccountRecordType() {

        return SBFC_CTRL_MoonbaseDocument.getAccountRecordType();
    }
    
   
    /**
     * @description Retrieves the current test user.
     */
    private static User getCurrentUser() {

        return [
            SELECT Id,
                   RM_AE_Code__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }
    
    /**
     * @description Creates a test InfoAuthorizationRequest with the
     *              required Consent Management records.
     */
    private static InfoAuthorizationRequest createInfoAuthorizationRequest(Account acc) {

      setupConsentManagementData();

    // Info Authorization Request
    InfoAuthorizationRequest req = new InfoAuthorizationRequest(
        Name = acc.Name + ' Moonstone Disclosure',
        SBFC_Account__c = acc.Id,
        SourceRecordId = acc.Id,
        ConsenterId = acc.Id,
        PertainsToId = acc.Id,
        RequesterId = UserInfo.getUserId(),
        DataUsePurposeId = [SELECT Id FROM DataUsePurpose WHERE Name = 'Disclosure - Authorization Form Text' LIMIT 1].Id,
        Locale = 'en_US',
        CommunicationType = 'Email',
        ResponseStatus = 'New'
    );

    insert req;

    return req;
}
    
    /**
     * @description Creates and returns a Person Account for test scenarios.
     */

    private static Account createPersonAccount() {

        Account acc = new Account(
            RecordTypeId = getPersonAccountRecordType(),
            LastName = 'Moon Customer',
            Phone = '9999999999',
            PersonEmail = 'moon@test.com'
        );

        insert acc;

        return acc;
    }
    
    /**
     * @description Creates and returns a Person Account linked to a test Lead.
     */

    private static Account createLinkedPersonAccount() {

        User usr = getCurrentUser();

        usr.RM_AE_Code__c = 'UAE002';
        update usr;

        Account acc = new Account(
            RecordTypeId = getPersonAccountRecordType(),
            LastName = 'Moon Customer',
            Phone = '9999999999',
            PersonEmail = 'moon@test.com',
            CMN_IdentityNumber__pc = '6710115195081',
            OwnerId = usr.Id
        );

        insert acc;

        return acc;
    }

    
    /**
     * @description Verifies that the Person Account Record Type Id
     *              is returned successfully.
     */
    @IsTest
    static void testGetAccountRecordType() {

        Test.startTest();

        Id recordTypeId =
            SBFC_CTRL_MoonbaseDocument.getAccountRecordType();

        Test.stopTest();

        Assert.isNotNull(recordTypeId);
    }

    /**
     * @description Verifies successful and unsuccessful linking
     *              of a Person Account to a Lead.
     */
    @IsTest
    static void testLinkedAccountToLead() {

        Lead lead = getLead();
        Account acc = createPersonAccount();

        Test.startTest();

        // Success
        SBFC_CTRL_MoonbaseDocument.linkedAccountToLead(
            lead.Id,
            acc.Id
        );

        lead = getLead();

        Assert.areEqual(
            acc.Id,
            lead.FinServ__RelatedAccount__c
        );

        // Null Parameters
        try {

            SBFC_CTRL_MoonbaseDocument.linkedAccountToLead(
                null,
                null
            );

            Assert.fail('Expected AuraHandledException');

        } catch (AuraHandledException ex) {

            Assert.isNotNull(ex);

        }
        
        try {

            SBFC_CTRL_MoonbaseDocument.linkedAccountToLead(
                '00Q000000000000AAA',
                acc.Id
            );
        
            Assert.fail('Expected AuraHandledException');
        
        } catch (AuraHandledException ex) {
        
            Assert.isNotNull(ex);
        
        }

        Test.stopTest();
    }

    
    /**
     * @description Verifies the disclosure eligibility validation
     *              for valid and invalid Lead Stage and Status values.
     */
    @IsTest
    static void testValidateDisclosureEligibility() {

        Lead lead = getLead();

        Test.startTest();

        // Success
        SBFC_CTRL_MoonbaseDocument.validateDisclosureEligibility(
            lead
        );

        // Invalid Status
        lead.Status = 'Working';

        try {

            SBFC_CTRL_MoonbaseDocument.validateDisclosureEligibility(lead);

            Assert.fail('Expected AuraHandledException');

        } catch (AuraHandledException ex) {

            Assert.isNotNull(ex);

        }

        // Invalid Stage
        lead.Status = 'Nurturing';
        lead.Stage__c = 'Completed';

        try {

            SBFC_CTRL_MoonbaseDocument.validateDisclosureEligibility(lead);

            Assert.fail('Expected AuraHandledException');

        } catch (AuraHandledException ex) {

            Assert.isNotNull(ex);

        }

        // Invalid Status & Stage
        lead.Status = 'Working';
        lead.Stage__c = 'Completed';

        try {

            SBFC_CTRL_MoonbaseDocument.validateDisclosureEligibility(lead);

            Assert.fail('Expected AuraHandledException');

        } catch (AuraHandledException ex) {

            Assert.isNotNull(ex);

        }

        Test.stopTest();
    }
    
    /**
     * @description Verifies that validateDisclosureEligibility() throws an
     *              exception when the Lead is owned by a Queue instead of a User.
     */
    
    @IsTest
    static void testValidateDisclosureEligibility_QueueOwner() {

    // Create Queue
    Group queue = new Group(
        Name = 'Lead Queue',
        Type = 'Queue'
    );
    insert queue;

    insert new QueueSobject(
        QueueId = queue.Id,
        SobjectType = 'Lead'
    );

    System.runAs(getCurrentUser()) {

        Lead lead = getLead();

        lead.OwnerId = queue.Id;
        update lead;

        try {
            SBFC_CTRL_MoonbaseDocument.validateDisclosureEligibility(lead);
            Assert.fail();
        } catch (AuraHandledException ex) {
        }
    }
}
    
      /**
     * @description Verifies retrieval of Moonstone Disclosure
     *              prefill data and validation scenarios.
     */
    @IsTest
    static void testGetPrefillData() {

        Lead lead = getLead();
        Account acc = createLinkedPersonAccount();
        User usr = getCurrentUser();

        lead.FinServ__RelatedAccount__c = acc.Id;
        update lead;

        Test.startTest();
        setupConsentManagementData();

        // Success
        Map<String, String> result =
            SBFC_CTRL_MoonbaseDocument.getPrefillData(lead.Id);


        Assert.areEqual(
            acc.CMN_IdentityNumber__pc,
            result.get('identityNumber')
        );

        Assert.areEqual(
            'UAE002',
            result.get('cCode')
        );

        Assert.areEqual(
            acc.Id,
            result.get('accountId')
        );

        // Blank Lead Id
        try {

            SBFC_CTRL_MoonbaseDocument.getPrefillData(null);

            Assert.fail('Expected AuraHandledException');

        } catch (AuraHandledException ex) {

            Assert.isNotNull(ex);

        }

        // Missing RM Code
        usr.RM_AE_Code__c = null;
        update usr;

        try {

            SBFC_CTRL_MoonbaseDocument.getPrefillData(
                lead.Id
            );

            Assert.fail('Expected AuraHandledException');

        } catch (AuraHandledException ex) {

            Assert.isNotNull(ex);

        }

        Test.stopTest();
    }

    /**
     * @description Verifies whether an existing Moonstone Disclosure
     *              is correctly identified for a Lead.
     */
   @IsTest
  static void testHasExistingDisclosure() {

    Lead lead = getLead();

    Test.startTest();

    // Blank Lead Id
    try {

        SBFC_CTRL_MoonbaseDocument.hasExistingDisclosure(null);

        Assert.fail('Expected AuraHandledException');

    } catch (AuraHandledException ex) {

        Assert.isNotNull(ex);

    }

    // Lead without linked Account
    SBFC_DTO_ExistingDisclosure dto =
        SBFC_CTRL_MoonbaseDocument.hasExistingDisclosure(lead.Id);

    Assert.isNotNull(dto);
    Assert.areEqual(null, dto.contentDocumentId);
    Assert.areEqual(null, dto.infoAuthorizationRequestId);

    // Link Account but no Disclosure
    Account acc = createPersonAccount();

    lead.FinServ__RelatedAccount__c = acc.Id;
    update lead;

    dto = SBFC_CTRL_MoonbaseDocument.hasExistingDisclosure(lead.Id);

    Assert.isNotNull(dto);
    Assert.isNull(dto.contentDocumentId);
    Assert.isNull(dto.infoAuthorizationRequestId);

    InfoAuthorizationRequest req = createInfoAuthorizationRequest(acc);

    // Create ContentVersion
    ContentVersion cv = new ContentVersion(
        Title = 'Disclosure',
        PathOnClient = 'Disclosure.pdf',
        VersionData = Blob.valueOf('Test PDF')
    );
    insert cv;

    cv = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
    ];

    // Link document to InfoAuthorizationRequest
    ContentDocumentLink cdl = new ContentDocumentLink(
        LinkedEntityId = req.Id,
        ContentDocumentId = cv.ContentDocumentId,
        ShareType = 'V'
    );
    insert cdl;

    // Call again - should return existing disclosure
    dto = SBFC_CTRL_MoonbaseDocument.hasExistingDisclosure(lead.Id);

    Assert.isTrue(dto.hasDisclosure);
    Assert.areEqual(req.Id, dto.infoAuthorizationRequestId);
    Assert.areEqual(req.Name, dto.documentName);
    Assert.areEqual(cv.ContentDocumentId, dto.contentDocumentId);
    Assert.isNotNull(dto.createdDate);

    Test.stopTest();
}
    
    /**
     * @description Verifies creation and update of the
     *              InfoAuthorizationRequest and Disclosure PDF.
     */
    @IsTest
    static void testSavePdfToLead() {

        Lead lead = getLead();

        Account acc = createPersonAccount();

        lead.FinServ__RelatedAccount__c = acc.Id;
        update lead;
        
        setupConsentManagementData(); 

        Test.startTest();

        // Create Disclosure
        SBFC_CTRL_MoonbaseDocument.savePdfToLead(
            lead.Id,
            'dGVzdA==',
            '{"status":"success","message":"Test Response"}'
        );

        // Update Existing Disclosure
        SBFC_CTRL_MoonbaseDocument.savePdfToLead(
            lead.Id,
            'dGVzdA==',
            '{"status":"success","message":"Test Response"}'
        );

        // Blank PDF
        SBFC_CTRL_MoonbaseDocument.savePdfToLead(
            lead.Id,
            null,
            '{"status":"success","message":"Test Response"}'
        );

        Test.stopTest();

        Assert.areEqual(
            1,
            [
                SELECT Count()
                FROM InfoAuthorizationRequest
                WHERE SourceRecordId = :acc.Id
            ]
        );

        Assert.areEqual(
            2,
            [
                SELECT Count()
                FROM ContentVersion
                WHERE Title LIKE 'Moon%'
            ]
        );
        try {
        SBFC_CTRL_MoonbaseDocument.savePdfToLead(lead.Id,'%%%INVALID%%%BASE64%%%STRING%%%','{"status":"success","message":"Test Response"}');

        Assert.fail('Expected AuraHandledException');

        } catch (AuraHandledException ex) {
          Assert.isNotNull(ex);
          }
    }

     /**
     * @description Verifies successful and unsuccessful
     *              Moonstone Disclosure generation.
     */
    @IsTest
    static void testSendDocument() {

        User usr = getCurrentUser();

        usr.RM_AE_Code__c = 'REP001';
        update usr;

        Account acc = new Account(
            RecordTypeId = getPersonAccountRecordType(),
            LastName = 'Moon Customer',
            Phone = '9999999999',
            PersonEmail = 'moon@test.com',
            CMN_IdentityNumber__pc = '7008200173082',
            OwnerId = usr.Id
        );
        insert acc;

        Schema.RecordTypeInfo rtInfo =
            Schema.SObjectType.Lead
                .getRecordTypeInfosByDeveloperName()
                .get('SBFC_Lead');

        Lead lead = new Lead(
            LastName = 'Moon Lead',
            Company = 'SBFC',
            Status = 'Nurturing',
            Stage__c = VALID_STAGE,
            RecordTypeId = rtInfo.getRecordTypeId(),
            FinServ__RelatedAccount__c = acc.Id
        );
        insert lead;
        
        setupConsentManagementData();


        String successResponse =
            '{"status":"success","msg":"Success","data":{"base64pdf":"dGVzdA=="}}';

        sbgplatform.ApiService.setMock(
            HttpCalloutMock.class,
            new SBFC_API_MoonbaseDocumentTest.MockResponse(
                200,
                successResponse
            )
        );

        Test.startTest();

        SBFC_DTO_MoonstoneResponse response =
            SBFC_CTRL_MoonbaseDocument.sendDocument(
                lead.Id,
                1,
                0,
                'Life'
            );

        Assert.areEqual(
            'success',
            response.status
        );

        Test.stopTest();

        Lead leadNoAccount = new Lead(
            LastName='No Account',
            Company='SBFC',
            Status='Nurturing',
            Stage__c=VALID_STAGE,
            RecordTypeId=rtInfo.getRecordTypeId()
        );

        insert leadNoAccount;

        try{

            SBFC_CTRL_MoonbaseDocument.sendDocument(
                leadNoAccount.Id,
                1,
                0,
                'Life'
            );

            Assert.fail('Expected AuraHandledException');

        }catch(Exception ex){

            Assert.isNotNull(ex);

        }

    }
    
    
    /**
     * @description Verifies that the Moonstone API response is
     *              stored on the existing InfoAuthorizationRequest.
     */
    @IsTest
    static void testSendDocument_UpdateMoonstoneResponse() {

    User usr = getCurrentUser();
    usr.RM_AE_Code__c = 'REP001';
    update usr;

    Account acc = new Account(
        RecordTypeId = getPersonAccountRecordType(),
        LastName = 'Moon Customer',
        Phone = '9999999999',
        PersonEmail = 'moon@test.com',
        CMN_IdentityNumber__pc = '7008200173082',
        OwnerId = usr.Id
    );
    insert acc;

    Schema.RecordTypeInfo rtInfo =
        Schema.SObjectType.Lead
            .getRecordTypeInfosByDeveloperName()
            .get('SBFC_Lead');

    Lead lead = new Lead(
        LastName = 'Moon Lead',
        Company = 'SBFC',
        Status = 'Nurturing',
        Stage__c = VALID_STAGE,
        RecordTypeId = rtInfo.getRecordTypeId(),
        FinServ__RelatedAccount__c = acc.Id
    );
    insert lead;

    // Create existing InfoAuthorizationRequest
    InfoAuthorizationRequest req = createInfoAuthorizationRequest(acc);

    String successResponse =
        '{"status":"success","msg":"Success","data":{"base64pdf":"dGVzdA=="}}';

    sbgplatform.ApiService.setMock(
        HttpCalloutMock.class,
        new SBFC_API_MoonbaseDocumentTest.MockResponse(
            200,
            successResponse
        )
    );

    Test.startTest();

    SBFC_DTO_MoonstoneResponse response =
        SBFC_CTRL_MoonbaseDocument.sendDocument(
            lead.Id,
            1,
            0,
            'Life'
        );

    Test.stopTest();

    req = [
        SELECT
            Id,
            SBFC_Moonstone_Response__c,
            Name,
            RequesterId
        FROM InfoAuthorizationRequest
        WHERE Id = :req.Id
    ];

    Assert.areEqual('success', response.status);
    Assert.isNotNull(req.SBFC_Moonstone_Response__c);
    Assert.areEqual(
        usr.Id,
        req.RequesterId
    );

    Integer maxLength =
        InfoAuthorizationRequest.SBFC_Moonstone_Response__c
            .getDescribe()
            .getLength();

    Assert.isTrue(
        req.SBFC_Moonstone_Response__c.length() <= maxLength
    );
}
    
    /**
     * @description Verifies that sendDocument() returns a failed response
     *              when the Moonstone API response body is blank.
     */
    @IsTest
    static void testSendDocument_BlankResponse() {

    User usr = getCurrentUser();
    usr.RM_AE_Code__c = 'REP001';
    update usr;

    Account acc = new Account(
        RecordTypeId = getPersonAccountRecordType(),
        LastName = 'Moon Customer',
        Phone = '9999999999',
        PersonEmail = 'moon@test.com',
        CMN_IdentityNumber__pc = '7008200173082',
        OwnerId = usr.Id
    );
    insert acc;

    Schema.RecordTypeInfo rtInfo =
        Schema.SObjectType.Lead
            .getRecordTypeInfosByDeveloperName()
            .get('SBFC_Lead');

    Lead lead = new Lead(
        LastName = 'Moon Lead',
        Company = 'SBFC',
        Status = 'Nurturing',
        Stage__c = VALID_STAGE,
        RecordTypeId = rtInfo.getRecordTypeId(),
        FinServ__RelatedAccount__c = acc.Id
    );
    insert lead;

    sbgplatform.ApiService.setMock(
        HttpCalloutMock.class,
        new SBFC_API_MoonbaseDocumentTest.MockResponse(
            200,
            ''
        )
    );

    Test.startTest();

    SBFC_DTO_MoonstoneResponse response =
        SBFC_CTRL_MoonbaseDocument.sendDocument(
            lead.Id,
            1,
            0,
            'Life'
        );

    Test.stopTest();

    Assert.areEqual('FAILED', response.status);
}
}