/**
* @description       : Test class for CMN_FHQ_Dashboard controller.
*                      Provides coverage for assessment score retrieval,
*                      question response retrieval, validation handling,
*                      and boundary value scenarios.
* @author            : Taimoor.shaik@standardbank.co.za
* @created on        : Feb 2026
*1.0   Mar-2026   preetham.Thernakal-gandla@standardbank.co.za   SyncGuestUser Assesment and Lead(PPBSF-341)

*/
@IsTest
private class CMN_FHQ_Dashboard_Test {

    /**
    * @description Creates a Lead record with Source_System_Reference__c populated.
    * @param userId External user identifier
    * @return Lead Inserted Lead record
    */
    private static Lead createLead(String userId) {

        Lead l = new Lead(
            LastName = 'Test',
            Company  = 'TestCo',
            Source_System_Reference__c = userId
        );

        insert l;
        return l;
    }


    /**
    * @description Creates a Lead record without Source_System_Reference__c.
    * @return Lead Inserted Lead record
    */
    private static Lead createLeadWithoutUserId() {

        Lead l = new Lead(
            LastName = 'NoUser',
            Company  = 'TestCo'
        );

        insert l;
        return l;
    }


    /**
    * @description Creates a CMN_Assessment__c record for the specified user.
    * @param userId External user identifier
    * @return CMN_Assessment__c Inserted assessment record
    */
    private static CMN_Assessment__c createAssessment(String userId) {

        CMN_Assessment__c assessment =
            new CMN_Assessment__c(
                Name = 'Assessment',
                User_Id__c = userId
            );

        insert assessment;
        return assessment;
    }


    /**
    * @description Creates CMN_Question_Response__c records for testing response retrieval.
    * @param assessmentId Assessment Id
    * @param userId External user identifier
    */
    private static void createResponses(
        Id assessmentId,
        String userId) {

        insert new List<CMN_Question_Response__c>{

            new CMN_Question_Response__c(
                CMN_Assessment__c = assessmentId,
                User_Id__c = userId,
                CMN_Question_Text__c = 'Q1',
                CMN_Response_Value__c = 'Answer1',
                CMN_Response_Value_Number__c = 10,
                CMN_Category__c = 'Category1',
                CMN_Sequence__c = 1
            ),

            new CMN_Question_Response__c(
                CMN_Assessment__c = assessmentId,
                User_Id__c = userId,
                CMN_Question_Text__c = 'Q2',
                CMN_Response_Value__c = 'Answer2',
                CMN_Response_Value_Number__c = 20,
                CMN_Category__c = null,
                CMN_Sequence__c = 2
            )
        };
    }


    /**
    * @description Verifies successful retrieval of assessment scores.
    */
    @IsTest
    static void testScoresSuccess() {

        try{

            Lead l = createLead('USER1');
            createAssessment('USER1');

            Test.startTest();

            CMN_FHQ_Dashboard.AssessmentScoreWrapper result =
                CMN_FHQ_Dashboard.getAssessmentScores(l.Id);

            Test.stopTest();

            assert.areNotEqual(null,result);

        }
        catch(Exception e){
            Assert.fail(e.getMessage());
        }
    }


    /**
    * @description Verifies behavior when no assessment exists for the user.
    */
    @IsTest
    static void testScoresNoAssessment() {

        try{

            Lead l = createLead('USER_NO');

            Test.startTest();

            CMN_FHQ_Dashboard.AssessmentScoreWrapper result =
                CMN_FHQ_Dashboard.getAssessmentScores(l.Id);

            Test.stopTest();

            assert.areEqual(null,result);

        }
        catch(Exception e){
            Assert.fail(e.getMessage());
        }
    }


    /**
    * @description Verifies retrieval of valid question responses.
    */
    @IsTest
    static void testResponsesSuccess() {

        try{

            String userId='USER_RESP';

            Lead l=createLead(userId);
            CMN_Assessment__c a=createAssessment(userId);

            createResponses(a.Id,userId);

            Test.startTest();

            List<CMN_FHQ_Dashboard.QuestionAnswerWrapper> listRes=
                CMN_FHQ_Dashboard.getQuestionResponses(l.Id);

            Test.stopTest();

            assert.areEqual(1,listRes.size());
            assert.areEqual('Q1',listRes[0].title);

        }
        catch(Exception e){
            Assert.fail(e.getMessage());
        }
    }


    /**
    * @description Verifies behavior when no question responses exist.
    */
    @IsTest
    static void testResponsesEmpty(){

        try{

            Lead l=createLead('USER_EMPTY');
            createAssessment('USER_EMPTY');

            Test.startTest();

            List<CMN_FHQ_Dashboard.QuestionAnswerWrapper> res=
                CMN_FHQ_Dashboard.getQuestionResponses(l.Id);

            Test.stopTest();

            assert.areEqual(0,res.size());

        }
        catch(Exception e){
            Assert.fail(e.getMessage());
        }
    }


    /**
    * @description Verifies numeric response value conversion and sequence ordering.
    */
    @IsTest
    static void testResponseNumberConversion(){

        try{

            String userId='USER_NUM';

            Lead l=createLead(userId);
            CMN_Assessment__c a=createAssessment(userId);

            insert new CMN_Question_Response__c(
                CMN_Assessment__c=a.Id,
                User_Id__c=userId,
                CMN_Question_Text__c='Numeric',
                CMN_Response_Value__c='500',
                CMN_Response_Value_Number__c=500,
                CMN_Category__c='Test',
                CMN_Sequence__c=5
            );

            Test.startTest();

            List<CMN_FHQ_Dashboard.QuestionAnswerWrapper> res=
                CMN_FHQ_Dashboard.getQuestionResponses(l.Id);

            Test.stopTest();

            assert.areEqual('500',res[0].responseValueNumber);
            assert.areEqual(5,res[0].sequence);

        }
        catch(Exception e){
            Assert.fail(e.getMessage());
        }
    }


    /**
    * @description Verifies score boundary handling (min 0, max 100).
    */
    @IsTest
    static void testScoreBoundaries(){

        try{

            String userId='USER_BOUND';

            Lead l=createLead(userId);

            CMN_Assessment__c a=
                new CMN_Assessment__c(
                    Name='Boundary',
                    User_Id__c=userId,
                    CMN_Expenses_Score__c=150,
                    CMN_Insurance_Score__c=-10,
                    CMN_Debt_to_Income_Score__c=50
                );

            insert a;

            Test.startTest();

            CMN_FHQ_Dashboard.AssessmentScoreWrapper res=
                CMN_FHQ_Dashboard.getAssessmentScores(l.Id);

            Test.stopTest();

            assert.areEqual(100,res.expensesScore);
            assert.areEqual(0,res.insuranceScore);
            assert.areEqual(50,res.debtScore);

        }
        catch(Exception e){
            Assert.fail(e.getMessage());
        }
    }


    /**
    * @description Verifies exception handling when Lead has no source system reference.
    */
    @IsTest
    static void testLeadWithoutSourceRef(){

        try{

            Lead l=createLeadWithoutUserId();

            Test.startTest();
            CMN_FHQ_Dashboard.getAssessmentScores(l.Id);
            Test.stopTest();

            Assert.fail();

        }
        catch(AuraHandledException e){

 Assert.isTrue(true, 'Expected exception caught');
         }
    }


    /**
    * @description Verifies exception handling when record Id is null.
    */
    @IsTest
    static void testBlankRecordId(){

        try{

            Test.startTest();
            CMN_FHQ_Dashboard.getQuestionResponses(null);
            Test.stopTest();

            Assert.fail();

        }
        catch(AuraHandledException e){
 Assert.isTrue(true, 'Expected exception caught');
         }
    }


    /**
    * @description Verifies exception handling when Lead has no user reference.
    */
    @IsTest
    static void testQuestionResponsesNoUserId(){

        try{

            Lead l=createLeadWithoutUserId();

            Test.startTest();
            CMN_FHQ_Dashboard.getQuestionResponses(l.Id);
            Test.stopTest();

            Assert.fail();

        }
        catch(AuraHandledException e){

 Assert.isTrue(true, 'Expected exception caught');
 
         }
    }

}