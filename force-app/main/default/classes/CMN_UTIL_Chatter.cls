/**
 * @description Utility class to create chatter posts
 *
 * @author Accenture
 * @date july 2021
 *
 */

public with sharing class CMN_UTIL_Chatter
{
	/**
	 * @description Create a chatter post
	 *
	 * @param messageText - The text message content of the post
	 * @param parentId - The Id of the recod on who's feed to display the post
	 */
	@AuraEnabled
	public static void postChatterMessage(String messageText, String parentId)
	{
		FeedItem post = new FeedItem();
		post.ParentId = parentId;
		post.Body = messageText;

		Database.insert(post);
	}
}