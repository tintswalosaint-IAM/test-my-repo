@isTest
private class SVC_LSChatBotCapacityHandler_TEST {
    private static final String QUEUE_TZ_VOICE_BRANCH_INBOUND = 'SVC_TZ_Voice_Branch_Inbound';


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
        SVC_LSChatBotCapacityHandler.ChatBotTempInput input = new SVC_LSChatBotCapacityHandler.ChatBotTempInput();
        input.queuenameforWhatsapp1 = 'SVC_LS_CCC,SVC_LS_Prestige_Banking';
        List<SVC_LSChatBotCapacityHandler.ChatBotOutput> result = SVC_LSChatBotCapacityHandler.isWhatsappAgentsAvailable(
            new List<SVC_LSChatBotCapacityHandler.ChatBotTempInput>{input}
        );

        Assert.areEqual(null, result[0].errorMessage, 'There is an error in the code execution process');
        Assert.areEqual(false, result[0].isAgentsAvailable, 'Agents have an available status');
    }

    @isTest
    private static void isLiveChatAgentsAvailableTest() {
        Group queue = [
                SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName = :QUEUE_TZ_VOICE_BRANCH_INBOUND
                AND Type = 'Queue'
                LIMIT 1
        ];
        Group publicGroup = [
                SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName = 'UG_Governance'
                AND Type = 'Regular'
                LIMIT 1
        ];
        insert new List<GroupMember>{
                new GroupMember(
                        GroupId = queue.Id,
                        UserOrGroupId = UserInfo.getUserId()
                ),
                new GroupMember(
                        GroupId = queue.Id,
                        UserOrGroupId = publicGroup.Id
                )
        };
        SVC_LSChatBotCapacityHandler.ChatBotTempInput input = new SVC_LSChatBotCapacityHandler.ChatBotTempInput();
        input.queuenameforWhatsapp1 = QUEUE_TZ_VOICE_BRANCH_INBOUND;
        input.isWhatsAppChannel = false;
        List<SVC_LSChatBotCapacityHandler.ChatBotOutput> result = SVC_LSChatBotCapacityHandler.isWhatsappAgentsAvailable(
                new List<SVC_LSChatBotCapacityHandler.ChatBotTempInput>{input}
        );

        Assert.areEqual(null, result[0].errorMessage, 'There is an error in the code execution process');
        Assert.areEqual(false, result[0].isAgentsAvailable, 'Agents have an available status');
    }
}