/**
 * @description Tests LeadAutoconvert
 * @see Leads_AutoConvert
 * @author Facu
 * @date March 2023
 */
@IsTest(SeeAllData = false)
public class Leads_AutoConvert_TEST {

    private static Account acc;
    private static Lead l;
    private static Opportunity opp;
    
    /**
	 * @description Test Setup
	 */
	@TestSetup
	public static void setupScenario()
	{
        acc = CMN_DAL_DataFactory.newPersonAccount();
        acc.LastName='Smith';
        acc.FirstName='John';
        acc.PersonEmail  ='email@email.com';
        insert acc;
        
        LIST<RecordType> leadRecordType= [SELECT Id FROM RecordType WHERE SobjectType IN ('Lead') AND IsActive = true  AND DeveloperName in ('General') LIMIT 1];
        
        l = new Lead();
        l.LastName='Smith';
        l.FinServ__RelatedAccount__c=acc.id;
        l.RecordTypeId=leadRecordType[0].ID;
        insert l;
        
        opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name = acc.LastName + ' ' + acc.FirstName;
        OPP.StageName= 'Qualification';
        OPP.CloseDate = system.today();
        insert opp;
    }

    /**
	 * @description Converts a lead and creates an opportunity
	 */
	@IsTest
	private static void convertLead()
	{
        Test.startTest();
		
        List<Leads_AutoConvert.Request> requests = new List<Leads_AutoConvert.Request>();
        Leads_AutoConvert.Request em = new Leads_AutoConvert.Request();
        
        FOR(Lead  leadList : [SELECT Id, FinServ__RelatedAccount__c, RecordTypeId, LastName, status FROM LEAD LIMIT 10])
        {
            em.leadToConvert = leadList;
        }
        
        em.status = 'Qualified';
        requests.add (em);

        List<Leads_AutoConvert.Result> res = Leads_AutoConvert.LeadConvert(requests);
        
        Test.stopTest();

        // converts
		Assert.isTrue(res[0].isSuccess, 'Problem with conversion');
    }
    
    /**
	 * @description Convert a lead with a pre-existing opportunity
	 */
    @IsTest
	private static void convertLeadWithOpportunity()
	{
        Test.startTest();
		
        List<Leads_AutoConvert.Request> requests = new List<Leads_AutoConvert.Request>();
        Leads_AutoConvert.Request em = new Leads_AutoConvert.Request();
        
        FOR(Lead  leadList : [SELECT Id, FinServ__RelatedAccount__c, RecordTypeId, LastName, status FROM LEAD lIMIT 10])
        {
            em.leadToConvert = leadList;
        }
        
        
        FOR(Opportunity  oppList : [SELECT Id FROM OPPORTUNITY LIMIT 10])
        {
            em.opportunityToLink = oppList;
        }
        
        em.Status = 'Qualified';
        requests.add (em);
        
        List<Leads_AutoConvert.Result> res = Leads_AutoConvert.leadConvert(requests);
        
        Test.stopTest();

		// Result values back
        // converts
		Assert.isTrue(res[0].isSuccess, 'Problem with conversion');

    }
    
    /**
	 * @description Fails is the Status is not valid
	 */
    @IsTest
	private static void convertLeadWrongStatus()
	{
		//Start Test
        Test.startTest();
		
        List<Leads_AutoConvert.Request> requests = new List<Leads_AutoConvert.Request>();
        //CreateItem
        Leads_AutoConvert.Request em = new Leads_AutoConvert.Request();
        
        //Add to list
        FOR(Lead  leadList : [SELECT Id, FinServ__RelatedAccount__c, RecordTypeId, LastName, status FROM LEAD lIMIT 10])
        {
            em.leadToConvert = leadList;
        }
        
        //Set unavailable Status
        em.Status = 'XXXX';
        requests.add (em);
		
        //Request convertion
        List<Leads_AutoConvert.Result> res = Leads_AutoConvert.LeadConvert(requests);
        
        Test.stopTest();
        
        //Error expected        
		Assert.isFalse(res[0].isSuccess, 'The convertion should fail');

    }
    /**
	 * @description Fails id the related account is null on the Lead
	 */
    @IsTest
	private static void convertLeadMissingData()
	{
		//Start Test
        Test.startTest();
		
        List<Leads_AutoConvert.Request> requests = new List<Leads_AutoConvert.Request>();
        Leads_AutoConvert.Request em = new Leads_AutoConvert.Request();
        
        FOR(Lead  leadList : [SELECT Id, FinServ__RelatedAccount__c, RecordTypeId, LastName, status FROM LEAD lIMIT 10])
        {
     		//remove the account so the convertion failes
     		leadList.FinServ__RelatedAccount__c=null;
            em.leadToConvert = leadList;
        }
        
        em.status = 'Qualified';
        requests.add (em);
        
        List<Leads_AutoConvert.Result> res = Leads_AutoConvert.LeadConvert(requests);
        
        Test.stopTest();
		Assert.isFalse(res[0].isSuccess, 'The convertion should fail');
    }
}