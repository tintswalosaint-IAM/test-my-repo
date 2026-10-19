/**
 * Created by christopher.de.buys on 2021/07/21.
 */

@IsTest(SeeAllData=false)
public with sharing class CMN_UTIL_Chatter_TEST
{
	@IsTest private static void testPostChatterMessage()
	{
		String sampleMessage = 'Sample message for testing chatter post';
		Account testAccount = new Account();
		testAccount.Name = CMN_UTIL_String.generateRandomString(10);
		insert testAccount;

		Test.startTest();

		CMN_UTIL_Chatter.postChatterMessage(sampleMessage, testAccount.Id);
		//Retrieve the FeedItem
		List<FeedItem> chatterPosts = [SELECT Id FROM FeedItem WHERE ParentId = :testAccount.Id];

		System.assertEquals(chatterPosts.size() > 0, true, 'Error, Expected greater than o, Actual ' + chatterPosts.size());


		Test.stopTest();
	}
}