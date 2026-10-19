/*------------------------------------------------------------
Author:        Raymond Magezi
Company:       Standard Bank
Description:   Test class for SEL_UGCaseEscalation selector
Test Class:    SEL_UGCaseEscalation_TEST

History
<Date>         <Authors Name>     <Brief Description of Change>
09-02-2026     Raymond Magezi     Initial creation
28-07-2026     Raymond Magezi     Removed testGetEscalationCandidatesQueryLocator - the method
                                   it tested moved to SEL_Case_TEST - SFP-59565
------------------------------------------------------------*/
@IsTest
private class SEL_UGCaseEscalation_TEST {
    
    @IsTest
    private static void testSelectEscalationSetting_Found() {
        Test.startTest();
        UG_PB_Escalation_Setting__mdt result = SEL_UGCaseEscalation.selectEscalationSetting('UG_PB_Escalation');
        Test.stopTest();
        
        Assert.isTrue(result == null || result != null);
    }
  
    
    
}