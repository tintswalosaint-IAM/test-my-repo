/**
 * @description SFP-8916 - Whatsapp Enhancement
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 *
 * @date Nov 23th 2021
 */
@isTest
private class SVC_ChatBotCapacityHandler_TEST {
    
    /**
     * @description Checks agent availability
     */
    @isTest
    private static void isWhatsappAgentsAvailableTest() {
        Group whatsappQueue = [
            SELECT Id, DeveloperName 
            FROM Group 
            WHERE DeveloperName = :SVC_ChatBotCapacityHandler.WHATSAPP_QUEUE_DEVNAME 
                AND Type = 'Queue' 
            LIMIT 1
        ];
        Group whatsappPublicGroup = [
            SELECT Id, DeveloperName 
            FROM Group 
            WHERE DeveloperName = 'UG_Governance'
                AND Type = 'Regular' 
            LIMIT 1
        ];
        insert new List<GroupMember>{
            new GroupMember(
                GroupId = whatsappQueue.Id,
                UserOrGroupId = UserInfo.getUserId()
            ),
            new GroupMember(
                GroupId = whatsappQueue.Id,
                UserOrGroupId = whatsappPublicGroup.Id
            )
        };
        List<SVC_ChatBotCapacityHandler.ChatBotOutput> result = SVC_ChatBotCapacityHandler.isWhatsappAgentsAvailable();
        System.assertEquals(null, result[0].errorMessage, 'There is an error in the code execution process');
        System.assertEquals(false, result[0].isAgentsAvailable, 'Agents have an available status');
    }

}