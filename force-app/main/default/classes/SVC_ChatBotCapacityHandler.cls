/**
 * @description SFP-8916 - Whatsapp Enhancement
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 * 
 * @lastModifiedBy Raymond Magezi (magezir2@stanbic.com)
 *
 * @date Nov 23th 2021
 * 
 * @lastModifiedDate July 07th 2025
 */
public with sharing class SVC_ChatBotCapacityHandler {
    
    /**
     * @description Private constructor to prevent instantiation
     */
    private SVC_ChatBotCapacityHandler() {}
    
    public static final String WHATSAPP_QUEUE_DEVNAME = 'UG_CCC_Whatsapp';
    private static final Decimal MAX_AGENT_CAPACITY = 30;//100% - 60%(whatsapp) + 10%(related case)
    private static final List<String> WHATSAPP_PRESENCE_STATUSES = new List<String>{'Available', 'Available_WhatsApp'};
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_ChatBotCapacityHandler');
    
    @TestVisible
    private static TestDataProvider testProvider;
    
    public interface TestDataProvider {
        List<UserServicePresence> getActivePresence(Set<Id> memberIds);
        List<AgentWork> getAgentWork(Set<Id> userIds);
    }
    
    @TestVisible
    private static Boolean hasAvailableCapacity(Map<Id, Decimal> capacityByAgent) {
        for (Decimal capacity : capacityByAgent.values()) {
            if (capacity <= MAX_AGENT_CAPACITY) {
                return true;
            }
        }
        return false;
    }

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
     * @description Check agents capacity in the whatsapp queue
     * @return If agent available and has capacity - return true
     */
    @InvocableMethod(Label ='Check agents capacity' description='Check agents capacity in the whatsapp queue')
    public static List<ChatBotOutput> isWhatsappAgentsAvailable() {
        LOGGER.warn('Checking WhatsApp agents availability');
        ChatBotOutput result = new ChatBotOutput();
        result.isAgentsAvailable = false;
        List<Group> queueList = [
            SELECT Id, DeveloperName 
            FROM Group 
            WHERE DeveloperName = :WHATSAPP_QUEUE_DEVNAME 
                AND Type = 'Queue' 
            WITH USER_MODE
            LIMIT 1
        ];
        if (queueList.isEmpty()) {
            LOGGER.warn('WhatsApp queue not found: ' + WHATSAPP_QUEUE_DEVNAME);
            return new List<ChatBotOutput>{result};
        }
        Group whatsappQueue = queueList[0];
        Set<Id> memberIds = getWhatsappQueueMembers(new Set<Id>{whatsappQueue.Id});
        LOGGER.warn('Found ' + memberIds.size() + ' queue members');
        //get agents with active whatsapp presence status
        List<UserServicePresence> activeUserPresence;
        if (testProvider == null) {
            activeUserPresence = [
                SELECT Id, UserId, IsCurrentState, ServicePresenceStatus.DeveloperName 
                FROM UserServicePresence 
                WHERE IsCurrentState = true
                    AND ServicePresenceStatus.DeveloperName IN :WHATSAPP_PRESENCE_STATUSES
                    AND UserId IN :memberIds
                WITH USER_MODE
            ];
        } else {
            activeUserPresence = testProvider.getActivePresence(memberIds);
        }
        Map<Id, Decimal> capacityByAgent = new Map<Id, Decimal>();
        for (UserServicePresence item : activeUserPresence) {
            capacityByAgent.put(item.UserId, 0);
        }
        //get curent agent capacity
        List<AgentWork> works;
        if (testProvider == null) {
            works = [
                SELECT Id, Status, UserId, CapacityPercentage 
                FROM AgentWork 
                WHERE Status = 'Assigned' 
                    AND UserId = :capacityByAgent.keySet()
                WITH USER_MODE
                ORDER BY UserId DESC
            ];
        } else {
            works = testProvider.getAgentWork(capacityByAgent.keySet());
        }
        for (AgentWork item : works) {
            capacityByAgent.put(item.UserId, capacityByAgent.get(item.UserId) + item.CapacityPercentage);
        }
        result.isAgentsAvailable = hasAvailableCapacity(capacityByAgent);
        LOGGER.warn('Agent availability check result: ' + result.isAgentsAvailable);
        return new List<ChatBotOutput>{result};
    }

    /**
     * @description Get all user members for a group
     * @param groupIds group ids
     * @return member Ids of the group 
     */
    private static Set<Id> getWhatsappQueueMembers(Set<Id> groupIds) {
        Set<Id> userMembers = new Set<Id>();
        List<GroupMember> members = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :groupIds WITH USER_MODE];
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