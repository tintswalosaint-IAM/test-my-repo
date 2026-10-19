/**
 * @description       : Test Class for SEL_PublicComplaint
 * User Story		  : SFP-38372
 * @author            : Aliaksei Koval
 * @last modified on  : 09-08-2025
 * @last modified by  : Aliaksei Koval
**/
@IsTest(SeeAllData = false)
public with sharing class SEL_PublicComplaint_Test {

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
            ComplaintCaseId = testCase.Id
        );
        insert testPublicComplaint;
    }
    
    @IsTest
	private static void testfindByCaseId(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        PublicComplaint testPublicComplaint = [SELECT Id FROM PublicComplaint WHERE ComplaintCaseId = :testCase.Id];
        Test.startTest();
        List<PublicComplaint> publicComplaints = SEL_PublicComplaint.findByCaseId(testCase.Id);
        Test.stopTest();

        Assert.isFalse(publicComplaints.isEmpty(), 'Public Complaint list empty');
        Assert.areEqual(testPublicComplaint.Id, publicComplaints[0].Id, 'Retrieved public Complaint subject does not match the expected one');
    }

    @IsTest
	private static void testfindById(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        PublicComplaint publicCompl = [SELECT Id, ComplaintCaseId FROM PublicComplaint WHERE ComplaintCaseId = :testCase.Id];
        Test.startTest();
        PublicComplaint pc = SEL_PublicComplaint.findById(publicCompl.Id);
        Test.stopTest();
        Assert.isNotNull(pc, 'Public Complaint was not found');
        Assert.areEqual(publicCompl.Id, pc.Id, 'Public Complaint not found');
    }
}