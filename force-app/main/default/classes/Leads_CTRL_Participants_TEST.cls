/**
 * @description Tests the Participant Controller class FlowSearch
 *
 * @see Leads_CRTL_Participants
 *
 * @author Facu
 *
 * @date Jan 2023
 */

@IsTest(SeeAllData = false)
public class Leads_CTRL_Participants_TEST {

    
     private static Account acc;
    
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
        
    }
    

    /**
	 * @description To check getParticipants
	 */
	@IsTest
	private static void getParticipants()
	{
		Test.startTest();
        
        
        List<Leads_CTRL_Participants.Request> requests = new List<Leads_CTRL_Participants.Request>();
        
        Leads_CTRL_Participants.Request em = new Leads_CTRL_Participants.Request();
        em.emails = new List<String>();
        em.emails.add ('email@email.com');
        requests.add (em);
         
        List<Leads_CTRL_Participants.Result> res = Leads_CTRL_Participants.getParticipantsByEmail(requests);
        
        Test.stopTest();

		// Result values back
		//System.assert(res != null, 'No Response Values');
        
        // One value
		System.assert(res[0].NumberOfResults != 0, 'No Response Values');

    }
    
    
    
    
    
    
    
}