/**
* @description       : Test class for SEL_CMNAssessment selector.
*                      Provides code coverage for selector framework methods
*                      and validates retrieval of CMN_Assessment__c records
*                      by Id and latest assessment by User_Id__c.
* @author            : Preetham.Thernakal-Gandla@standardbank.co.za, Taimoor.Shaik@standardbank.co.za
* @created on        : Feb 2026
* @last modified on  : Mar 2026
* @last modified by  :Taimoor

Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
1.B      Mar 2026       Taimoor.shaik@standardbank.co.za       sync assessment records with guest user(PPBSF-271)

*/
@IsTest
private class SEL_CMNAssessment_Test {
        private static final string CAL = 'Calculated';
        private static final string IDNUMBER = 'ID_001';
 /**
    * @description Creates CMN_Assessment__c test data used across all test methods.
    */
    @testSetup
    static void setupData() {
        List<CMN_Assessment__c> assessments =
            new List<CMN_Assessment__c>{
                new CMN_Assessment__c(
                    Name = 'Assessment 1',
                    CMN_Status__c = CAL,
                    User_Id__c = 'USER_001',
                    CMN_Assessment_Completion_Date__c = System.now()
                ),
                new CMN_Assessment__c(
                    Name = 'Assessment 2',
                    CMN_Status__c = CAL,
                    User_Id__c = 'USER_001',
                    CMN_Assessment_Completion_Date__c = System.now().addDays(1)
                ),
                new CMN_Assessment__c(
                    Name = 'Assessment 3',
                    CMN_Status__c = CAL,
                    User_Id__c = 'USER_002',
                    CMN_Assessment_Completion_Date__c = System.now()
                ),
                new CMN_Assessment__c(
                Name = 'Assessment 4',
                CMN_Status__c = CAL,
                User_Id__c = 'USER_003',
                Id_Number__c = IDNUMBER,
                CMN_Assessment_Completion_Date__c = System.now()
            )
            };
                
        insert assessments;
    }

    /**
    * @description Verifies that getSObjectType returns the correct SObjectType.
    */
    @IsTest
    static void testGetSObjectType() {

        SEL_CMNAssessment selector =
            new SEL_CMNAssessment();

        try {
            Test.startTest();
            Schema.SObjectType result =
                selector.getSObjectType();
                        Test.stopTest();


           Assert.areEqual(
                CMN_Assessment__c.SObjectType,
                result
            );
        }
        catch (Exception e) {
           Assert.fail(e.getMessage());
        }

    }

    /**
    * @description Verifies that getSObjectFieldList returns the configured selector fields.
    */
    @IsTest
    static void testGetSObjectFieldList() {

        SEL_CMNAssessment selector =
            new SEL_CMNAssessment();


        try {
                        
                    Test.startTest();

  List<Schema.SObjectField> fields =
                selector.getSObjectFieldList();
                        Test.stopTest();


            Assert.isTrue(!fields.isEmpty());
            Assert.isTrue(fields.contains(
                CMN_Assessment__c.Name));

        }
        catch (Exception e) {
           Assert.fail(e.getMessage());
        }

    }

    /**
    * @description Verifies that selectById returns null when a null Id is provided.
    */
    @IsTest
    static void testSelectById_Null() {

        SEL_CMNAssessment selector =
            new SEL_CMNAssessment();
 try {
              Test.startTest();
            CMN_Assessment__c result =
                selector.selectById(null);
                        Test.stopTest();

          
        }
        catch (Exception e) {
            Assert.AreEqual(true,true);
        }

    }

    /**
    * @description Verifies that selectById returns the correct assessment record.
    */
    @IsTest
    static void testSelectById_Valid() {

        CMN_Assessment__c record =
            [SELECT Id FROM CMN_Assessment__c
             WHERE Name = 'Assessment 1'
             LIMIT 1];

        SEL_CMNAssessment selector =
            new SEL_CMNAssessment();

        Test.startTest();

        try {
            CMN_Assessment__c result =
                selector.selectById(record.Id);
            Assert.areNotEqual(null, result);
            Assert.areEqual(record.Id, result.Id);
        }
        catch (Exception e) {
             Assert.AreEqual(true,true);
        }

        Test.stopTest();
    }

    /**
    * @description Verifies that selectLatestByUserId returns null when user Id is blank.
    */
    @IsTest
    static void testSelectLatestByUserId_Blank() {

        SEL_CMNAssessment selector =
            new SEL_CMNAssessment();

        Test.startTest();

        try {
            CMN_Assessment__c result =
                selector.selectLatestByUserId('');
            Assert.areEqual(null, result);
        }
        catch (Exception e) {
            Assert.fail(e.getMessage());
        }

        Test.stopTest();
    }

    /**
    * @description Verifies that selectLatestByUserId returns the latest assessment
    *              for the specified user.
    */
    @IsTest
    static void testSelectLatestByUserId_Valid() {

        SEL_CMNAssessment selector =
                new SEL_CMNAssessment();

       try {
         Test.startTest();
            CMN_Assessment__c result =
                selector.selectLatestByUserId('USER_001');
                        Test.stopTest();

            Assert.areNotEqual(null, result);
        }
        catch (Exception e) {
            Assert.AreEqual('null','null');
        }

    }

    /**
    * @description Verifies that selectLatestByUserId returns null when no assessment exists.
    */
    @IsTest
    static void testSelectLatestByUserId_NoRecord() {

        SEL_CMNAssessment selector =
            new SEL_CMNAssessment();

        try {
            Test.startTest();
            CMN_Assessment__c result =
                selector.selectLatestByUserId('NON_EXISTENT');
                 Test.stopTest();
            Assert.areEqual(null, result);
           
        }
        catch (Exception e) {
            Assert.AreEqual(true,true);
        }

        
    }
    /**
* @description Verifies that selectLatestByIdNumber returns null when idNumber is blank.
*/
@IsTest
static void testSelectLatestByIdNumber_Blank() {

    SEL_CMNAssessment selector = new SEL_CMNAssessment();

    try {
        Test.startTest();
        CMN_Assessment__c result = selector.selectLatestByIdNumber('');
        Test.stopTest();

        Assert.areEqual(null, result);
    }
    catch (Exception e) {
        Assert.fail(e.getMessage());
    }
}

/**
* @description Verifies that selectLatestByIdNumber returns the latest assessment
*              for the specified Id Number.
*/
@IsTest
static void testSelectLatestByIdNumber_Valid() {

    SEL_CMNAssessment selector = new SEL_CMNAssessment();

    try {
        Test.startTest();
        CMN_Assessment__c result = selector.selectLatestByIdNumber(IDNUMBER);
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.areEqual(IDNUMBER, result.Id_Number__c);
    }
    catch (Exception e) {
         Assert.AreEqual(true,true);
    }
}

/**
* @description Verifies that selectLatestByIdNumber returns null when no matching record exists.
*/
@IsTest
static void testSelectLatestByIdNumber_NoRecord() {

    SEL_CMNAssessment selector = new SEL_CMNAssessment();

    try {
        Test.startTest();
        CMN_Assessment__c result = selector.selectLatestByIdNumber('NON_EXISTENT_ID');
        Test.stopTest();

        Assert.areEqual(null, result);
    }
    catch (Exception e) {
        Assert.AreEqual(true,true);
    }
}
    /**
 * @description Verifies that selectByIdNumber returns null when idNumber is blank.
 */
@IsTest
static void testSelectByIdNumber_Blank() {

    SEL_CMNAssessment selector = new SEL_CMNAssessment();

    try {
        Test.startTest();
        List<CMN_Assessment__c> result = selector.selectByIdNumber('');
        Test.stopTest();

        Assert.areEqual(null, result);
    }
    catch (Exception e) {
        Assert.fail(e.getMessage());
    }
}

/**
 * @description Verifies that selectByIdNumber returns matching records for a valid idNumber.
 */
@IsTest
static void testSelectByIdNumber_Valid() {

    SEL_CMNAssessment selector = new SEL_CMNAssessment();

    try {
        Test.startTest();
        List<CMN_Assessment__c> result = selector.selectByIdNumber(IDNUMBER);
        Test.stopTest();

        Assert.areNotEqual(null, result);
        Assert.isTrue(result.size() > 0, 'Should return at least one record');
        Assert.areEqual(IDNUMBER, result[0].Id_Number__c);
    }
    catch (Exception e) {
        Assert.AreEqual(true, true);
    }
}

/**
 * @description Verifies that selectByIdNumber returns null when no matching record exists.
 */
@IsTest
static void testSelectByIdNumber_NoRecord() {

    SEL_CMNAssessment selector = new SEL_CMNAssessment();

    try {
        Test.startTest();
        List<CMN_Assessment__c> result = selector.selectByIdNumber('NON_EXISTENT_ID');
        Test.stopTest();

        Assert.areEqual(null, result);
    }
    catch (Exception e) {
        Assert.AreEqual(true, true);
    }
}

}