/**
* @description       : Test class for CMN_FHQ_SRV_RetirementCalculation service.
*                      Provides coverage for retirement score calculation,
*                      including success, validation failures, and edge cases
*                      such as missing inputs, zero values, and retirement age limits.
Ver       Date         Author                              Modification       
1.0      JAN 2026   preetham.gandla@standardbank.co.za     Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270) 
*/
@IsTest
private class CMN_FHQ_SRV_RetirementCalculation_Test {
    
    /**
    * @description Creates a CMN_Question_Response__c record with a numeric response value.
    * @param val Numeric response value
    * @return CMN_Question_Response__c Test response record
    */
    private static CMN_Question_Response__c buildResponse(Decimal val){
        CMN_Question_Response__c r = new CMN_Question_Response__c();
        r.CMN_Response_Value_Number__c = val;
        return r;
    }
    
    /**
    * @description Creates a valid CMN_Rule_Set_Version__c record for retirement calculations.
    * @return CMN_Rule_Set_Version__c Test rule set version
    */
    private static CMN_Rule_Set_Version__c buildRuleSet(){
        return new CMN_Rule_Set_Version__c(
            CMN_Return_Rate__c = 8,
            CMN_Withdrawal_Rate__c = 4,
            CMN_Default_Retirement_Age__c = 65
        );
    }
    
    /**
    * @description Verifies successful retirement score calculation with valid inputs.
    */
    @IsTest
    static void testCalculate_Success(){
        
        Map<String, CMN_Question_Response__c> responses =
            new Map<String, CMN_Question_Response__c>{
                PRX_CTRL_Constants.Q6  => buildResponse(12000),
                PRX_CTRL_Constants.Q9  => buildResponse(3000),
                PRX_CTRL_Constants.Q10 => buildResponse(80000)
            };
                        
        CMN_FHQ_SRV_RetirementCalculation srv =
            new CMN_FHQ_SRV_RetirementCalculation();
        
        Date dob = Date.today().addYears(-30);
        
        Test.startTest();
        Decimal score = srv.calculate(responses, buildRuleSet(), dob);
        Test.stopTest();
        
        Assert.areNotEqual(null, score);
        Assert.isTrue(score > 0);
        
        Assert.areNotEqual(null, srv.investmentBehaviourFutureValue);
        Assert.areNotEqual(null, srv.retirementTargetAmount);
        Assert.areNotEqual(null, srv.yearsOfRetirement);
        Assert.isTrue(srv.yearsOfRetirement > 0);
    }
    
    /**
    * @description Verifies calculation proceeds when Q9/Q10 are missing — defaults to 0.
    */
    @IsTest
    static void testCalculate_MissingResponses(){
        
        Map<String, CMN_Question_Response__c> responses =
            new Map<String, CMN_Question_Response__c>{
                PRX_CTRL_Constants.Q6 => buildResponse(5000)
            };
                        
        CMN_FHQ_SRV_RetirementCalculation srv =
            new CMN_FHQ_SRV_RetirementCalculation();
        
        Decimal score = srv.calculate(
            responses,
            buildRuleSet(),
            Date.today().addYears(-35)
        );
        
        Assert.areNotEqual(null, score, 'Score must not be null when Q9/Q10 are missing — they default to 0');
    }
    
    /**
    * @description Verifies calculation proceeds when Q6 is zero — retirement target becomes 0, score returns 0.
    */
    @IsTest
    static void testCalculate_ZeroValues(){
        
        Map<String, CMN_Question_Response__c> responses =
            new Map<String, CMN_Question_Response__c>{
                PRX_CTRL_Constants.Q6  => buildResponse(0),
                PRX_CTRL_Constants.Q9  => buildResponse(1000),
                PRX_CTRL_Constants.Q10 => buildResponse(50000)
            };
                        
        CMN_FHQ_SRV_RetirementCalculation srv =
            new CMN_FHQ_SRV_RetirementCalculation();
        
        Decimal score = srv.calculate(
            responses,
            buildRuleSet(),
            Date.today().addYears(-40)
        );
        
        Assert.areNotEqual(null, score, 'Score must not be null when Q6 is zero');
        Assert.areEqual(0, score, 'Score must be 0 when Q6 is zero — retirementTargetAmount is 0');
    }
    
    /**
    * @description Verifies calculation returns null when date of birth is not provided.
    */
    @IsTest
    static void testCalculate_DobNull(){
        
        Map<String, CMN_Question_Response__c> responses =
            new Map<String, CMN_Question_Response__c>{
                PRX_CTRL_Constants.Q6  => buildResponse(5000),
                PRX_CTRL_Constants.Q9  => buildResponse(1500),
                PRX_CTRL_Constants.Q10 => buildResponse(30000)
            };
                        
        CMN_FHQ_SRV_RetirementCalculation srv =
            new CMN_FHQ_SRV_RetirementCalculation();
        
        Decimal score = srv.calculate(
            responses,
            buildRuleSet(),
            null
        );
        
        Assert.areEqual(null, score);
    }
    
    /**
    * @description Verifies calculation when user has already reached retirement age.
    *              Ensures yearsOfRetirement is clamped to minimum value.
    */
    @IsTest
    static void testCalculate_AlreadyAtRetirementAge(){
        
        Map<String, CMN_Question_Response__c> responses =
            new Map<String, CMN_Question_Response__c>{
                PRX_CTRL_Constants.Q6  => buildResponse(9000),
                PRX_CTRL_Constants.Q9  => buildResponse(1000),
                PRX_CTRL_Constants.Q10 => buildResponse(20000)
            };
                        
        CMN_FHQ_SRV_RetirementCalculation srv =
            new CMN_FHQ_SRV_RetirementCalculation();
        
        Date dob = Date.today().addYears(-70);
        
        Decimal score = srv.calculate(
            responses,
            buildRuleSet(),
            dob
        );
        
        Assert.areNotEqual(null, score);
        Assert.areEqual(1, srv.yearsOfRetirement);
    }
}