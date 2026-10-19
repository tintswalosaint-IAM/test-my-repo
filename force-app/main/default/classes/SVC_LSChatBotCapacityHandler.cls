/**
 * @description SFP-17280 - Whatsapp Enhancement
 *
 * @author Lavanya Ravirala (lavanya.ravirala@standardbank.co.za)
 * 26/07/2023 - added isWhatsAppChannel parameter that allows to check livechat agents capasity before creating a case in bot
 *
 * @date Aug 24th 2022
 */
public with sharing class SVC_LSChatBotCapacityHandler {

    private static final Decimal MAX_AGENT_CAPACITY = 30;//100% - 60%(whatsapp) + 10%(related case)
    private static final List<String> WHATSAPP_PRESENCE_STATUSES = new List<String>{'Available', 'Available_WhatsApp'};
    private static final List<String> LIVECHAT_PRESENCE_STATUSES = new List<String>{'Available', 'Available_Live_Agent', 'Available_Chat'};

    /**
     * @description Wrapper class with output result from the init method
     */
    public class ChatBotOutput {
        @InvocableVariable(required=true)
        public Boolean isAgentsAvailable;

        @InvocableVariable(required=false)
        public String errorMessage;
    }

    /**
     * @description Wrapper class with inputs from the bot
     */
    public class ChatBotTempInput {
        @InvocableVariable(required=true)
        public String queuenameforWhatsapp1;

        @InvocableVariable(required=false)
        public Boolean isWhatsAppChannel;
    }
    /**
     * @description Check agents capacity in the whatsapp queue
     * @param input inputs from the bot
     * @return If agent available and has capacity - return true
     */

    @InvocableMethod(Label='Check LS agents capacity' description='Check agents capacity in the whatsapp queue')
    public static List<ChatBotOutput> isWhatsappAgentsAvailable(List<ChatBotTempInput> input) {
        List<String> queueApiNames = new List<String>{
        };
        List<String> statuses = new List<String>();
        for (ChatBotTempInput chatBotInput : input) {
            if (!String.isEmpty(chatBotInput.queuenameforWhatsapp1)) {
                queueApiNames = chatBotInput.queuenameforWhatsapp1.split(',');
            }
            //selecting statuses depend is whatsApp or livechat.
            if (chatBotInput.isWhatsAppChannel == null || chatBotInput.isWhatsAppChannel) {
                statuses = WHATSAPP_PRESENCE_STATUSES;
            } else {
                statuses = LIVECHAT_PRESENCE_STATUSES;
            }
        }


        ChatBotOutput result = new ChatBotOutput();
        result.isAgentsAvailable = false;
        List<Group> whatsappQueue = [
                SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName = :queueApiNames
                AND Type = 'Queue'
                //LIMIT 1
        ];
        Set<Id> newsetID = new Set<Id>();
        for (Group whatsappId : whatsappQueue) {
            newsetID.add(whatsappId.Id);
        }
        Set<Id> memberIds = getWhatsappQueueMembers(newsetID);
        //get agents with active whatsapp or livechat presence status
        List<UserServicePresence> activeUserPresence = [
                SELECT Id, UserId, IsCurrentState, ServicePresenceStatus.DeveloperName
                FROM UserServicePresence
                WHERE IsCurrentState = true
                AND ServicePresenceStatus.DeveloperName IN :statuses
                AND UserId IN :memberIds
        ];
        Map<Id, Decimal> capacityByAgent = new Map<Id, Decimal>();
        for (UserServicePresence item : activeUserPresence) {
            capacityByAgent.put(item.UserId, 0);
        }
        //get curent agent capacity
        List<AgentWork> works = [
                SELECT Id, Status, UserId, CapacityPercentage
                FROM AgentWork
                WHERE Status = 'Assigned'
                AND UserId = :capacityByAgent.keySet()
                ORDER BY UserId DESC
        ];
        for (AgentWork item : works) {
            capacityByAgent.put(item.UserId, capacityByAgent.get(item.UserId) + item.CapacityPercentage);
        }
        for (Decimal item : capacityByAgent.values()) {
            if (item <= MAX_AGENT_CAPACITY) {
                result.isAgentsAvailable = true;
                break;
            }
        }
        return new List<ChatBotOutput>{result};
    }

    /**
     * @description Get all user members for a group
     * @param groupIds group ids
     * @return member Ids of the group 
     */
    private static Set<Id> getWhatsappQueueMembers(Set<Id> groupIds) {
        Set<Id> userMembers = new Set<Id>();
        List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :groupIds];
        groupIds.clear();
        for (GroupMember item : members) {
            if (item.UserOrGroupId.getSobjectType() == Schema.User.SObjectType) {
                userMembers.add(item.UserOrGroupId);
            } else {
                groupIds.add(item.UserOrGroupId);
            }
        }
        if (!groupIds.isEmpty()) {
            userMembers.addAll(getWhatsappQueueMembers(groupIds));
        }
        return userMembers;
    }
}