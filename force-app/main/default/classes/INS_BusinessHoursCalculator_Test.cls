/***************************************************************************************

@Name of the Component : INS_BusinessHoursCalculator_Test.
@Description : Class to test the business hours calculator class.
@Author : Kenneth Dlamini
@Created Date : 2025-06-02
/***************************************************************************************
@Last Modified By :
@Last Modified On :
@Modification description: SFP-46473
***************************************************************************************/
@isTest
public with sharing class INS_BusinessHoursCalculator_Test {
    @testSetup
    static void setupData(){
        User testUser = INS_Load_Test_CaseData_Factory.createTestUser(1); 
        Account testAccount = INS_Load_Test_CaseData_Factory.createTestAccount(testUser);
        BusinessHours bhoursId = [select Id from BusinessHours where Name='ZA_Mon-Fri 08:00-17:00 GMT+02:00' limit 1];
        INS_Load_Test_CaseData_Factory.createTestCase(testUser, testAccount, 'Create Test Data - 01', 'This is Case Test Data - 01', bhoursId.Id);
        INS_Load_Test_CaseData_Factory.createTestCase(testUser, testAccount, 'Create Test Data - 02', 'This is Case Test Data - 02', bhoursId.Id);
        INS_Load_Test_CaseData_Factory.createServiceType();
    }

    @isTest
    static void timeTakenToAllocateCaseToUser(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 01'];  
        DateTime allocationDate = caseInfo.CreatedDate.addMinutes(30);
        allocationDate = allocationDate.addSeconds(45);
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_Case_Allocation_Date__c = allocationDate;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
        data.ClosedDate = caseData.SVC_Case_Allocation_Date__c;
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
    static void timeTakenToClassifyCaseAfterAllocationToUser(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02'];  
        DateTime allocationDate = caseInfo.CreatedDate.addMinutes(30);
        allocationDate = allocationDate.addSeconds(45);
        Datetime classificationDate = allocationDate.addHours(1);
        classificationDate = classificationDate.addMinutes(30);
        classificationDate = classificationDate.addSeconds(45);
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.Status = 'In Progress';
        updateCaseInfo.SVC_Case_Allocation_Date__c = allocationDate;
        updateCaseInfo.SVC_CaseClassificationDate__c = classificationDate;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = allocationDate;
        data.ClosedDate = classificationDate;
        Long milliSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        
        Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(milliSeconds);
        Integer minutes = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(milliSeconds);
        Integer seconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(milliSeconds);
        
        String sExpectedTime = '1:30:45';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime, sActualTime, 'Successful.');
    }

    @isTest
    static void timeTakenToResolveCaseAfterClassificationByUser(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02'];  
        DateTime allocationDate = caseInfo.CreatedDate.addMinutes(30);
        allocationDate = allocationDate.addSeconds(45);
        Datetime classificationDate = allocationDate.addHours(1);
        classificationDate = classificationDate.addMinutes(30);
        classificationDate = classificationDate.addSeconds(45);
        
        Datetime resolutionDate = classificationDate.addHours(10);
        resolutionDate = resolutionDate.addMinutes(70);
        resolutionDate = resolutionDate.addSeconds(59);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_Case_Allocation_Date__c = allocationDate;
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
        
        String sExpectedTime = '11:10:59';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime, sActualTime, 'Successful.');
    }

    @isTest
    static void allocateCaseToUser_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 01'];  
        DateTime allocationDate = caseInfo.CreatedDate.addMinutes(30);
        allocationDate = allocationDate.addSeconds(45);
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_Case_Allocation_Date__c = allocationDate;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
        data.ClosedDate = caseData.SVC_Case_Allocation_Date__c;
        Long milliSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        String sExpectedTime_TAT = INS_BusinessHoursCalculator.printTATInBusinessHours(milliSeconds);
        
        Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(milliSeconds);
        Integer minutes = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(milliSeconds);
        Integer seconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(milliSeconds);
        String sActualTime_TAT = hours + ' hrs ' + minutes + ' mins ' + seconds + ' secs.';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime_TAT, sActualTime_TAT, 'Successful.');
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
    static void timeTakenToResolveCase_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02'];  
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
    static void timeTakenFromCreationToCaseResolution_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02']; 
        
        Datetime classificationDate = caseInfo.CreatedDate.addHours(2);
        classificationDate = classificationDate.addMinutes(30);
        classificationDate = classificationDate.addSeconds(45);
        
        Datetime resolutionDate = caseInfo.CreatedDate.addHours(11);
        resolutionDate = resolutionDate.addMinutes(70);
        resolutionDate = resolutionDate.addSeconds(59);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        
        updateCaseInfo.Id = caseInfo.Id;         
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_ResolvedDate__c = resolutionDate;
        updateCaseInfo.SVC_CaseClassificationDate__c = classificationDate;
        updateCaseInfo.Status = 'Resolved';
        updateCaseInfo.SVC_RootCause__c = 'People';
        updateCaseInfo.SVC_RootCauseResolution__c = 'Test RCA';
        updateCaseInfo.SVC_ServiceType__c = svType.Id;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
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
    static void timeTakenToMakeCaseUnresolved_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02']; 
        
        Datetime classificationDate = caseInfo.CreatedDate.addHours(2);
        classificationDate = classificationDate.addMinutes(30);
        classificationDate = classificationDate.addSeconds(45);
        
        Datetime resolutionDate = caseInfo.CreatedDate.addHours(11);
        resolutionDate = resolutionDate.addMinutes(70);
        resolutionDate = resolutionDate.addSeconds(59);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        
        updateCaseInfo.Id = caseInfo.Id;         
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_ResolvedDate__c = resolutionDate;
        updateCaseInfo.SVC_CaseClassificationDate__c = classificationDate;
        updateCaseInfo.Status = 'Unresolved';
        updateCaseInfo.SVC_RootCause__c = 'People';
        updateCaseInfo.SVC_RootCauseResolution__c = 'Test RCA';
        updateCaseInfo.SVC_ReasonForUnresolved__c = 'Transferred Off Platform';
        updateCaseInfo.SVC_ServiceType__c = svType.Id;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
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
    static void timeTakenToMakeCaseDuplicate_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02']; 
        
        Datetime classificationDate = caseInfo.CreatedDate.addHours(2);
        classificationDate = classificationDate.addMinutes(30);
        classificationDate = classificationDate.addSeconds(45);
        
        Datetime resolutionDate = caseInfo.CreatedDate.addHours(11);
        resolutionDate = resolutionDate.addMinutes(70);
        resolutionDate = resolutionDate.addSeconds(59);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        
        updateCaseInfo.Id = caseInfo.Id;         
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_ResolvedDate__c = resolutionDate;
        updateCaseInfo.SVC_CaseClassificationDate__c = classificationDate;
        updateCaseInfo.Status = 'Duplicate';
        updateCaseInfo.SVC_RootCause__c = 'People';
        updateCaseInfo.SVC_RootCauseResolution__c = 'Test RCA';
        updateCaseInfo.SVC_ServiceType__c = svType.Id;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
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
    static void convertMilliSecondsToHoursTriggerAnError(){
        Boolean exceptionThrown = true;
        try {
            Integer a = 600;
            Test.startTest();
            Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(a);
            Test.stopTest(); 
        }
        catch(Exception ex){
            exceptionThrown = true;
        }
        finally{
            Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown');
        }
    }
    
    @isTest
    static void fromCaseCreationToResolution_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02'];  
        
        Datetime resolutionDate = caseInfo.CreatedDate.addHours(2);
        resolutionDate = resolutionDate.addMinutes(30);
        resolutionDate = resolutionDate.addSeconds(45);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_ResolvedDate__c = resolutionDate;
        updateCaseInfo.Status = 'Resolved';
        updateCaseInfo.SVC_RootCause__c = 'People';
        updateCaseInfo.SVC_RootCauseResolution__c = 'Test RCA';
        updateCaseInfo.SVC_ServiceType__c = svType.Id;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
        data.ClosedDate = resolutionDate;
        Long milliSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        
        Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(milliSeconds);
        Integer minutes = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(milliSeconds);
        Integer seconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(milliSeconds);
        
        String sExpectedTime = '2:30:45';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime, sActualTime, 'Successful.');
    }
    
    @isTest
    static void fromCaseCreationToClosed_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02'];  
        
        Datetime resolutionDate = caseInfo.CreatedDate.addHours(2);
        resolutionDate = resolutionDate.addMinutes(30);
        resolutionDate = resolutionDate.addSeconds(45);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.Status = 'Resolved';
        updateCaseInfo.SVC_RootCause__c = 'People';
        updateCaseInfo.SVC_RootCauseResolution__c = 'Test RCA';
        updateCaseInfo.SVC_ServiceType__c = svType.Id;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
        data.ClosedDate = resolutionDate;
        Long milliSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        
        Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(milliSeconds);
        Integer minutes = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(milliSeconds);
        Integer seconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(milliSeconds);
        
        String sExpectedTime = '2:30:45';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime, sActualTime, 'Successful.');
    }
    
    @isTest
    static void fromCaseCreationToClassification_TAT(){
        //Get case details
        Case caseInfo = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'Create Test Data - 02'];  
        
        Datetime classificationDate = caseInfo.CreatedDate.addHours(2);
        classificationDate = classificationDate.addMinutes(30);
        classificationDate = classificationDate.addSeconds(45);
        
        SVC_ServiceType__c svType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'Insurance: Test Service - Refunds'];
        
        Test.startTest();
        //Update case allocation date
        Case updateCaseInfo = new Case();
        updateCaseInfo.Id = caseInfo.Id;
        updateCaseInfo.SVC_CaseClassificationDate__c = classificationDate;
        updateCaseInfo.Status = 'In Progress';
        updateCaseInfo.SVC_ServiceType__c = svType.Id;
        update updateCaseInfo;
        Case caseData  = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(caseInfo.Id);
        
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData data = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        data.BusinessHoursId = caseData.businessHoursId;
        data.CreatedDate = caseData.CreatedDate;
        data.ClosedDate = classificationDate;
        Long milliSeconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(data);
        
        Integer hours = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(milliSeconds);
        Integer minutes = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(milliSeconds);
        Integer seconds = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(milliSeconds);
        
        String sExpectedTime = '2:30:45';
        String sActualTime = hours +':'+minutes +':'+seconds;
        Test.stopTest(); 
        Assert.areEqual(sExpectedTime, sActualTime, 'Successful.');
    }
}