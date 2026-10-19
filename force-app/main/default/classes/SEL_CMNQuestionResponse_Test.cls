/**
* @description       : Test class for SEL_CMNQuestionResponse selector.
*                      Provides code coverage for selector framework methods
*                      and validates retrieval of CMN_Question_Response__c
*                      records by Id, User, Assessment, and completion status.
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026      Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270)
1.B      Mar 2026      Preetham.Thernakal-Gandla@standardbank.co.za   Fix FLS enforcement in deployment - runAs admin with PRX_FHQ_Standalone
*/
@IsTest
private class SEL_CMNQuestionResponse_Test {

    /**
    * @description Creates a test user with System Administrator profile and assigns
    *              PRX_FHQ_Standalone permission set to ensure correct FLS access
    *              to all CMN_Question_Response__c fields during deployment validation.
    * @return User A fully set up test user with required permissions
    */
    
    private static User createTestAdminUser() {
        Profile adminProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];

        User testUser = new User(
            FirstName         = 'Test',
            LastName          = 'SelCMNUser',
            Email             = 'sel.cmn.testuser@standardbank.test.com',
            Username          = 'sel.cmn.testuser.' + System.now().getTime() + '@standardbank.test.com',
            Alias             = 'selcmn',
            TimeZoneSidKey    = 'Africa/Johannesburg',
            LocaleSidKey      = 'en_ZA',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId         = adminProfile.Id
        );
        insert testUser;

        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'PRX_FHQ_Standalone'
            LIMIT 1
        ];

        insert new PermissionSetAssignment(
            AssigneeId      = testUser.Id,
            PermissionSetId = ps.Id
        );

        return testUser;
    }

    /**
    * @description Creates CMN_Assessment__c, CMN_Question__c, and
    *              CMN_Question_Response__c test data used across test methods.
    */
    @testSetup
    static void setupData() {
        User adminUser = createTestAdminUser();

        System.runAs(adminUser) {
            CMN_Assessment__c assessment = new CMN_Assessment__c(
                CMN_Status__c = 'Calculated',
                User_Id__c    = adminUser.Id
            );
            insert assessment;

            CMN_Question__c question = new CMN_Question__c(
                Name = 'Test Question',
                Is_Active__c = true
            );
        insert question;

            List<CMN_Question_Response__c> responses = new List<CMN_Question_Response__c>{
                new CMN_Question_Response__c(
                    User_Id__c        = adminUser.Id,
                    CMN_Question__c   = question.Id,
                    CMN_Assessment__c = assessment.Id,
                    Is_Completed__c   = false,
                    CMN_Sequence__c   = 1,
                    CMN_Category__c   = 'Cat A',
                     Id_Number__c      = '9001015009087'
                ),
                new CMN_Question_Response__c(
                    User_Id__c        = adminUser.Id,
                    CMN_Question__c   = question.Id,
                    CMN_Assessment__c = assessment.Id,
                    Is_Completed__c   = true,
                    CMN_Sequence__c   = 2,
                    CMN_Category__c   = 'Cat B',
                     Id_Number__c      = '9001015009087'
                )
            };
            insert responses;
        }
    }

    /**
    * @description Verifies that getSObjectType returns the correct SObjectType.
    */
    @IsTest
    static void testGetSObjectType() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

        System.runAs(adminUser) {
            SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

            Test.startTest();
            try {
                Assert.areEqual(
                    CMN_Question_Response__c.SObjectType,
                    sel.getSObjectType()
                );
            } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
    }

    /**
    * @description Verifies that getSObjectFieldList returns the configured selector fields.
    */
    @IsTest
    static void testGetSObjectFieldList() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

        System.runAs(adminUser) {
            SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

            Test.startTest();
            try {
                List<Schema.SObjectField> fields = sel.getSObjectFieldList();
                Assert.isTrue(!fields.isEmpty());
            } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
    }

    /**
    * @description Verifies selectById behavior with null and valid Ids.
    */
    @IsTest
    static void testSelectById() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

        System.runAs(adminUser) {
            SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

            Test.startTest();
            try {
            // Test null Id
            Assert.areEqual(null, sel.selectById(null));

            // Test valid Id
            Id id = [SELECT Id FROM CMN_Question_Response__c LIMIT 1].Id;
            CMN_Question_Response__c rec = sel.selectById(id);
            Assert.areEqual(id, rec.Id);

            } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
    }

    /**
    * @description Verifies retrieval of incomplete responses for a specific user.
    */
    @IsTest
    static void testSelectIncompleteResponseofUser() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

        System.runAs(adminUser) {
            SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

            Test.startTest();
            try {
                List<CMN_Question_Response__c> listRec =
                    sel.selectIncompleteResponseofUser(adminUser.Id);
                Assert.areEqual(1, listRec.size());
            } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
    }

    /**
    * @description Verifies selectQuestionResponsesById with valid and empty Id sets.
    */
    @IsTest
    static void testSelectQuestionResponsesById() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

        System.runAs(adminUser) {
            SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

            Test.startTest();
            try {
                // Test with valid Id set
                Set<Id> ids = new Map<Id, CMN_Question_Response__c>(
                    [SELECT Id FROM CMN_Question_Response__c]
                ).keySet();

            List<CMN_Question_Response__c> results =
                sel.selectQuestionResponsesById(ids);
            Assert.areEqual(2, results.size());

            // Test with empty Id set
            List<CMN_Question_Response__c> emptyResults =
                sel.selectQuestionResponsesById(new Set<Id>());
            Assert.isTrue(emptyResults.isEmpty());

            } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
    }

    /**
    * @description Verifies selectByUserId with blank and valid user Ids.
    */
    @IsTest
    static void testSelectByUserId() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

        System.runAs(adminUser) {
            SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

            Test.startTest();
            try {
            // Test with blank user Id
            List<CMN_Question_Response__c> blankResults =
                sel.selectByUserId('');
            Assert.isTrue(blankResults.isEmpty());

            // Test with valid user Id
            List<CMN_Question_Response__c> validResults =
                    sel.selectByUserId(adminUser.Id);
                Assert.areEqual(2, validResults.size());

            } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
    }

    /**
    * @description Verifies selectByAssessmentId with null and valid assessment Ids,
    *              including correct ordering by sequence.
    */
    @IsTest
    static void testSelectByAssessmentId() {
        User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

        System.runAs(adminUser) {
            SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

            Test.startTest();
            try {
            // Test with null assessment Id
            List<CMN_Question_Response__c> nullResults =
                sel.selectByAssessmentId(null);
            Assert.isTrue(nullResults.isEmpty());

            // Test with valid assessment Id
                Id assessId = [SELECT Id FROM CMN_Assessment__c LIMIT 1].Id;
            List<CMN_Question_Response__c> validResults =
                sel.selectByAssessmentId(assessId);
            Assert.areEqual(2, validResults.size());
            Assert.areEqual(1, validResults[0].CMN_Sequence__c);

            } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
    }
    
    /**
* @description Verifies selectByIdNumber with blank and valid Id numbers,
*              covering both the early-return guard clause and the query path.
*/
@IsTest
static void testSelectByIdNumber() {
    User adminUser = [SELECT Id FROM User WHERE LastName = 'SelCMNUser' LIMIT 1];

    System.runAs(adminUser) {
        SEL_CMNQuestionResponse sel = new SEL_CMNQuestionResponse();

        Test.startTest();
        try {
            // Test with blank Id number — covers the early return guard
            List<CMN_Question_Response__c> blankResults =
                sel.selectByIdNumber('');
            Assert.isTrue(blankResults.isEmpty());

            // Test with null Id number — covers null guard
            List<CMN_Question_Response__c> nullResults =
                sel.selectByIdNumber(null);
            Assert.isTrue(nullResults.isEmpty());

            // Test with valid Id number — covers the query execution path
            List<CMN_Question_Response__c> validResults =
                sel.selectByIdNumber('9001015009087');
            Assert.areEqual(2, validResults.size());

        } catch (Exception e) {
            Assert.fail(e.getMessage());
        }
        Test.stopTest();
    }
}
}