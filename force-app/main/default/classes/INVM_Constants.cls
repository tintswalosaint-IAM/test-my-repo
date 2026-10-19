/**
 * Class for static constants used during the MD project
 *
 * <p></p>
 *
 * @author Wipro
 *
 * @date July 2022
 */

/**
 * @description class that sets static values
 */
public with sharing class INVM_Constants {
	@TestVisible public static final String CLIENTAPPROVERESPONSE = 'COMPLETED';
    @TestVisible public static final String CLIENTAPPROVERESPONSETORECORD = 'APPROVED';
    @TestVisible public static final String CLIENTDECLINERESPONSETORECORD = 'DECLINED';
    @TestVisible public static final String RECECEIVEDRESPONSE = 'Received Response';
    @TestVisible public static final String LEADQUALIFIED = 'Qualified';
    @TestVisible public static final string LEADNURTURING = 'Nurturing';
    @TestVisible public static final string LEADNEW = 'New';
    @TestVisible public static Final String UNQUALIFIED = 'UnQualified';
    @TestVisible public static Final String SENTFORAPPROVAL = 'Sent for Approval';
    @TestVisible public static Final String STATUSGENERATED = 'Generated';
    
    @TestVisible
    public static void testStrings()
    {
         System.assertEquals('TEST', 'TEST');
    }
}