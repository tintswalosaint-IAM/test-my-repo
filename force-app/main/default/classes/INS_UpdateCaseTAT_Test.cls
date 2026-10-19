/***************************************************************************************

@Name of the Component : INS_UpdateCaseTAT_Test.
@Description : Class to test the Update TAT class.
@Author : Kenneth Dlamini
@Created Date : 2025-08-12
/***************************************************************************************
@Last Modified By :
@Last Modified On :
@Modification description: SFP-46473
***************************************************************************************/
@isTest
public with sharing class INS_UpdateCaseTAT_Test {
    @testSetup
    static void setupData(){

        User testUser = INS_Load_Test_CaseData_Factory.createTestUser(1); 
        Account testAccount = INS_Load_Test_CaseData_Factory.createTestAccount(testUser);
        BusinessHours bhoursId = [select Id from BusinessHours where Name='ZA_Mon-Fri 08:00-17:00 GMT+02:00' limit 1];
        INS_Load_Test_CaseData_Factory.createTestCase(testUser, testAccount, 'Create Test Data - 01', 'This is Case Test Data - 01', bhoursId.Id);
        INS_Load_Test_CaseData_Factory.createServiceType();
    }

    @isTest
    static void timeTakenToResolveCase_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 01'];  
        Datetime classificationDate = caseInfo.CreatedDate.addHours(2);
        classificationDate = classificationDate.addMinutes(30);
        classificationDate = classificationDate.addSeconds(45);
        
        Datetime resolutionDate = classificationDate.addHours(11);
        resolutionDate = resolutionDate.addMinutes(70);
        resolutionDate = resolutionDate.addSeconds(59);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_CaseClassificationDate__c = classificationDate;
        updateCaseInfo.SVC_ResolvedDate__c = resolutionDate;
        updateCaseInfo.Status = 'Resolved';
        updateCaseInfo.SVC_RootCause__c = 'People';
        updateCaseInfo.SVC_RootCauseResolution__c = 'Test RCA';
        updateCaseInfo.SVC_ServiceType__c = svType.Id;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = classificationDate;
        data.ClosedDate = resolutionDate;
        Long milliSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        
        Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(milliSeconds);
        Integer minutes = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(milliSeconds);
        Integer seconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(milliSeconds);
        
        String sExpectedTime = '12:10:59';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime, sActualTime, 'Successful.');
    }

    @isTest
    static void updateCaseTAT_TriggerAnError(){
        Boolean exceptionThrown = true;
        try {
            Case updateCaseInfo = new Case();
            
            Test.startTest();
            INS_UpdateCaseTAT.updateCaseTAT (updateCaseInfo);
            Test.stopTest(); 
        }
        catch(Exception ex){
            exceptionThrown = true;
        }
        finally{
            Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown');
        }
    }
}