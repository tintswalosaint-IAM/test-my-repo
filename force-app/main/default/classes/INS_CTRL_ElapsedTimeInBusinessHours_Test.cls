/***************************************************************************************

@Name of the Class : INS_ElapsedTimeInBusinessHoursCTRL_Test.
@Description : Class to test the Case Elapsed Time In Business Hours Controller class.
@Author : Kenneth Dlamini
@Created Date : 2025-08-12
/***************************************************************************************
@Last Modified By :Givebn Khupai
@Last Modified On :2026/07/31
@Modification description: SFP-46473
***************************************************************************************/
@isTest
public with sharing class INS_CTRL_ElapsedTimeInBusinessHours_Test {
    @testSetup
    static void setupData(){

        User testUser = INS_Load_Test_CaseData_Factory.createTestUser(1); 
        Account testAccount = INS_Load_Test_CaseData_Factory.createTestAccount(testUser);
        BusinessHours bhoursId = [select Id from BusinessHours where Name='ZA_Mon-Fri 08:00-17:00 GMT+02:00' limit 1];
        INS_Load_Test_CaseData_Factory.createTestCase(testUser, testAccount, 'Create Test Data - 01', 'This is Case Test Data - 01', bhoursId.Id);
        INS_Load_Test_CaseData_Factory.createServiceType();
    }

    @isTest
    static void validateCaseTestData(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 01'];  
        Test.startTest();
        Case caseData = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        Test.stopTest(); 
        String expectedCaseId = caseInfo.Id;
        String actualCaseId = caseData.Id;
        Assert.areEqual(expectedCaseId, actualCaseId, 'Successful.');
    }

    @isTest
    static void validateCaseElapsedMilliSeconds(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 01'];  
        DateTime currentDate = caseInfo.CreatedDate.addMinutes(30);
        currentDate = currentDate.addSeconds(45);
        Long milliSecondsPerMin = 60*1000;
        Long milliSecondPerSecond = 1000;
        Long expectedMilliSeconds = (milliSecondsPerMin*30) + (45*milliSecondPerSecond);
        
        Test.startTest();
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
        data.ClosedDate = currentDate;
        Long actualMilliSecondsTime = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        Test.stopTest(); 
        Assert.areEqual(expectedMilliSeconds, actualMilliSecondsTime, 'Successful.');
    }

    @isTest
    static void validateCaseElapsedTime(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 01'];  
        DateTime currentDate = caseInfo.CreatedDate.addMinutes(30);
        currentDate = currentDate.addSeconds(45);
        
        Test.startTest();
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
        data.ClosedDate = currentDate;
        Long milliSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        
        Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(milliSeconds);
        Integer minutes = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(milliSeconds);
        Integer seconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(milliSeconds);
        
        String sExpectedTime = '0:30:45';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime, sActualTime, 'Successful.');
    }

    @isTest
    static void getCustomMetaDataTypeProcessFrequencySetting(){
        Test.startTest();
        Integer actualSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.getMetaDataType();
        Integer expectedSeconds = 3000;
        Test.stopTest(); 
        Assert.areEqual(expectedSeconds, actualSeconds, 'Successful.');
    }

    @isTest
    static void elapsedMilliSecondsTriggerAnError(){
        Long actualMilliSecondsTime = 0;
        try {
            Test.startTest();
            INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
            data.BusinessHoursId = '0';
            actualMilliSecondsTime = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
            Test.stopTest(); 
        }
        catch(Exception ex){
            actualMilliSecondsTime = 0;
        }
        finally{
            Assert.areEqual(0, actualMilliSecondsTime, 'Expected exception was thrown');
        }
    }
    
    @isTest
    static void elapsedHoursTriggerAnError(){
        Integer actualHoursTime = 0;
        try {
            Test.startTest();
            Integer nullableInt = null;
            Integer nonNullableInt = nullableInt ?? 0; // nonNullableInt will be 0
            actualHoursTime = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(nullableInt);
            Test.stopTest(); 
        }
        catch(Exception ex){
            actualHoursTime = 0;
        }
        finally{
            Assert.areEqual(0, actualHoursTime, 'Expected exception was thrown');
        }
    }
}