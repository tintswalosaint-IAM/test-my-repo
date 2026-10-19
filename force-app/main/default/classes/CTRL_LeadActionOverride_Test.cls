/**
 * @description       : Test for CTRL_LeadActionOverride
 * @author            : Derek Hughes
 * @group             : Test
 * @last modified on  : 14-06-2023
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class CTRL_LeadActionOverride_Test {
    
    @IsTest
    static void testGetActionOverrid() {

        Boolean exceptionThrown = false;

        Test.startTest();

            CTRL_LeadActionOverride.ActionOverrideResult result = CTRL_LeadActionOverride.getActionOverride ('New', null, UserInfo.getUserId(), null);
            
            // test exception handling with invalud record type id
            try {
                CTRL_LeadActionOverride.ActionOverrideResult result2 = CTRL_LeadActionOverride.getActionOverride ('New', null, UserInfo.getUserId(), '123000000000789');
            }
            catch (Exception e) {
                exceptionThrown = true;
            }

        Test.stopTest();
        
        Assert.areEqual(result.userName, UserInfo.getName(), 'Incorrect user selected');
        Assert.isTrue(exceptionThrown, 'Exception should have been thrown for invalid record type Id');
    }

}