/**
* @description       : Test class for PRX_DTO_QuestionnaireResponse DTO.
*                      Provides coverage for constructors, default values,
*                      and JSON serialization/deserialization of response
*                      and activity wrapper classes.
* Ver       Date         Author                              Modification       
   1.0      JAN 2026   Taimoor.Shaik@standardbank.co.za     Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270)

 */
@IsTest
private class PRX_DTO_QuestionnaireResponse_Test {

    /**
    * @description Verifies default constructor initializes ResponseWrapper with expected values.
    */
    @IsTest
    static void testDefaultConstructor() {

        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            new PRX_DTO_QuestionnaireResponse.ResponseWrapper();

        assert.areEqual(false, resp.success);
        assert.areEqual('', resp.message);
        assert.areEqual(0, resp.recordsSaved);
    }


    /**
    * @description Verifies ActivityDTO constructors populate activity name and percent correctly.
    */
    @IsTest
    static void testActivityDTOConstructors() {

        PRX_DTO_QuestionnaireResponse.ActivityDTO dto1 =
            new PRX_DTO_QuestionnaireResponse.ActivityDTO(
                'Insurance',
                85
            );

        PRX_DTO_QuestionnaireResponse.ActivityDTO dto2 =
            new PRX_DTO_QuestionnaireResponse.ActivityDTO(
                'General'
            );

        assert.areEqual('Insurance', dto1.activityName);
        assert.areEqual(85, dto1.activityPercent);

        assert.areEqual('General', dto2.activityName);
        assert.areEqual(null, dto2.activityPercent);
    }


    /**
    * @description Verifies JSON serialization of ResponseWrapper and nested ActivityDTO.
    */
    @IsTest
    static void testJSONSerialization() {

        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            new PRX_DTO_QuestionnaireResponse.ResponseWrapper();

        resp.success = true;
        resp.message = 'Success';
        resp.recordsSaved = 1;

        resp.activities =
            new List<PRX_DTO_QuestionnaireResponse.ActivityDTO>{
                new PRX_DTO_QuestionnaireResponse.ActivityDTO(
                    'Expenses',
                    70
                )
            };

        String jsonString = JSON.serialize(resp);

       Assert.isTrue(jsonString.contains('Success'));
       Assert.isTrue(jsonString.contains('Expenses'));
    }


    /**
    * @description Verifies JSON deserialization populates ResponseWrapper and ActivityDTO correctly.
    */
    @IsTest
    static void testJSONDeserialize() {

        String jsonString =
        '{' +
            '"success":true,' +
            '"message":"Done",' +
            '"recordsSaved":2,' +
            '"activities":[' +
                '{' +
                '"activityName":"Savings",' +
                '"activityPercent":90' +
                '}' +
            ']' +
        '}';


        PRX_DTO_QuestionnaireResponse.ResponseWrapper resp =
            (PRX_DTO_QuestionnaireResponse.ResponseWrapper)
            JSON.deserializeStrict(
                jsonString,
                PRX_DTO_QuestionnaireResponse.ResponseWrapper.class
            );

        assert.areEqual(true, resp.success);
        assert.areEqual('Done', resp.message);
        assert.areEqual(2, resp.recordsSaved);
        assert.areEqual('Savings', resp.activities[0].activityName);
    }

}