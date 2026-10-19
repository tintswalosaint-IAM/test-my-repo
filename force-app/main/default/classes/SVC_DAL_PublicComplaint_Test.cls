/**
 * @description       : Test Class for SVC_DAL_PublicComplaint
 * @author            : Aliaksei Koval
 * @last modified on  : 08-26-2025
 * @last modified by  : Aliaksei Koval
**/
@IsTest(SeeAllData = false)
public with sharing class SVC_DAL_PublicComplaint_Test {

    @TestSetup
	public static void setupScenario(){
        Contact c = SVC_DAL_DataFactory.newContact();
        insert c;
        Case testCase = SVC_DAL_DataFactory.newCase(c.Id);
        testCase.Subject = 'Test Case';
        testCase.Status = 'In Progress';
        insert testCase;
        PublicComplaint testPublicComplaint = new PublicComplaint(
            IncidentDate = Date.today(),
            Case__c = testCase.Id
        );
        insert testPublicComplaint;
    }
    
    @IsTest
	private static void testfindByCaseId(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Test.startTest();
        List<PublicComplaint> publicComplaints = SVC_DAL_PublicComplaint.findByCaseId(testCase.Id);
        Test.stopTest();

        Assert.isFalse(publicComplaints.isEmpty());
    }

    @IsTest
	private static void testfindById(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        PublicComplaint publicCompl = [SELECT Id FROM PublicComplaint WHERE Case__c = :testCase.Id];
        Test.startTest();
        PublicComplaint pc = SVC_DAL_PublicComplaint.findById(publicCompl.Id);
        Test.stopTest();
        Assert.isNotNull(pc);
    }
}