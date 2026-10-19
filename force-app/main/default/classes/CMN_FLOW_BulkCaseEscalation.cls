/*------------------------------------------------------------
Author:        Accenture
Company:       Standard Bank
Description:   Bulk case escalation handler for flow
Test Class:    CMN_FLOW_BulkCaseEscalation_TEST

History
<Date>         <Authors Name>     <Brief Description of Change>
04-02-2026     Raymond Magezi     Created for bulk escalation processing
------------------------------------------------------------*/
public without sharing class CMN_FLOW_BulkCaseEscalation
{
	private CMN_FLOW_BulkCaseEscalation() {}

	/*------------------------------------------------------------
	 Purpose:    Processes bulk case escalations and sends emails
	 Parameters: requests - List of escalation requests
	 Returns:    List of responses with success status
	------------------------------------------------------------*/
	@InvocableMethod(Label='Bulk Process Case Escalations' Description='Processes multiple case escalations, updates cases in bulk, and sends emails in bulk')
	public static List<DTO_Response> processEscalations(List<DTO_Request> requests)
	{
		DTO_Request request = requests[0];
		Map<Id, CaseEscalationData> escalationDataMap = new Map<Id, CaseEscalationData>();
		
		for(Case caseRecord : request.cases)
		{
			List<CMN_DAL_User.ManagerRequest> managerRequests = new List<CMN_DAL_User.ManagerRequest>();
			CMN_DAL_User.ManagerRequest managerRequest = new CMN_DAL_User.ManagerRequest();
			managerRequest.ownerId = caseRecord.OwnerId;
			managerRequest.escalationLevel = Integer.valueOf(caseRecord.SVC_Escalation_Level__c) + 1;
			managerRequests.add(managerRequest);
			
			List<CMN_DAL_User.ManagerResult> managerResponses = CMN_DAL_UserManagerHierarchy.getManagerByLevel(managerRequests);
			
			if(!managerResponses.isEmpty() && String.isNotBlank(managerResponses[0].managerId))
			{
				CaseEscalationData data = new CaseEscalationData();
				data.caseId = caseRecord.Id;
				data.ownerId = caseRecord.OwnerId;
				data.managerId = managerResponses[0].managerId;
				data.managerEmail = managerResponses[0].managerEmail;
				data.newEscalationLevel = managerRequest.escalationLevel;
				escalationDataMap.put(caseRecord.Id, data);
			}
		}
		
		if(!escalationDataMap.isEmpty())
		{
			bulkUpdateCases(escalationDataMap);
			bulkSendEmails(escalationDataMap, request.orgWideEmail, request.templateName);
		}
		
		DTO_Response response = new DTO_Response();
		response.processedCount = escalationDataMap.size();
		return new List<DTO_Response>{response};
	}
	
	/*------------------------------------------------------------
	 Purpose:    Updates all cases in bulk
	 Parameters: escalationDataMap - Map of case escalation data
	------------------------------------------------------------*/
	private static void bulkUpdateCases(Map<Id, CaseEscalationData> escalationDataMap)
	{
		List<Case> casesToUpdate = new List<Case>();
		
		for(CaseEscalationData data : escalationDataMap.values())
		{
			Case caseToUpdate = new Case(Id = data.caseId);
			caseToUpdate.SVC_Escalate_to__c = data.managerId;
			caseToUpdate.SVC_Escalation_Level__c = data.newEscalationLevel;
			casesToUpdate.add(caseToUpdate);
		}
		
		update as user casesToUpdate;
	}
	
	/*------------------------------------------------------------
	 Purpose:    Sends all emails in bulk
	 Parameters: escalationDataMap - Map of case escalation data
	             orgWideEmail - Org-wide email address
	             templateName - Email template name
	------------------------------------------------------------*/
	private static void bulkSendEmails(Map<Id, CaseEscalationData> escalationDataMap, String orgWideEmail, String templateName)
	{
		Map<Id, String> ownerEmailMap = getOwnerEmails(escalationDataMap);
		List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> emailRequests = new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>();
		
		for(CaseEscalationData data : escalationDataMap.values())
		{
			CMN_FLOW_SendEmail.DTO_SendEmailRequest emailRequest = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
			emailRequest.toAddress = data.managerEmail;
			emailRequest.ccAddress = new List<String>{ownerEmailMap.get(data.ownerId)};
			emailRequest.templateUniqueName = templateName;
			emailRequest.orgWideEmailAddress = orgWideEmail;
			emailRequest.whatId = data.caseId;
			emailRequests.add(emailRequest);
		}
		
		CMN_FLOW_SendEmail.sendEmail(emailRequests);
	}
	
	/*------------------------------------------------------------
	 Purpose:    Retrieves owner emails for CC
	 Parameters: escalationDataMap - Map of case escalation data
	 Returns:    Map of owner ID to email
	------------------------------------------------------------*/
	private static Map<Id, String> getOwnerEmails(Map<Id, CaseEscalationData> escalationDataMap)
	{
		Set<Id> ownerIds = new Set<Id>();
		for(CaseEscalationData data : escalationDataMap.values())
		{
			ownerIds.add(data.ownerId);
		}
		
		Map<Id, String> ownerEmailMap = new Map<Id, String>();
		List<User> owners = [SELECT Id, Email FROM User WHERE Id IN :ownerIds WITH USER_MODE];
		for(User owner : owners)
		{
			ownerEmailMap.put(owner.Id, owner.Email);
		}
		
		return ownerEmailMap;
	}
	
	private class CaseEscalationData
	{
		public Id caseId;
		public Id ownerId;
		public String managerId;
		public String managerEmail;
		public Integer newEscalationLevel;
	}
	
	public class DTO_Request
	{
		@InvocableVariable(Label='Cases' Description='Collection of cases to escalate' Required=true)
		public List<Case> cases;
		
		@InvocableVariable(Label='Org Wide Email' Description='Org-wide email address' Required=true)
		public String orgWideEmail;
		
		@InvocableVariable(Label='Template Name' Description='Email template developer name' Required=true)
		public String templateName;
	}
	
	public class DTO_Response
	{
		@InvocableVariable(Label='Processed Count' Description='Number of cases processed')
		public Integer processedCount;
	}
}