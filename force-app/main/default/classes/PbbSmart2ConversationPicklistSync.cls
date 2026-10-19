/**
 * @description This test class for Integration to collect data from Smart2
 *
 * @author		Emmanuel Mulea(Nocks)
 * @date	    April 2021
*/
public without sharing class PbbSmart2ConversationPicklistSync {
    private static final PBB_SRV_GatewayApi_Conversations.IService CONV_SERVICE = new PBB_SRV_GatewayApi_Conversations();
                                                
    /**
    * @description This method Merge the results of reason And Response
    **/
    public static void mergeResponseAndReason(){
        try {
            List<PBB_SRV_GatewayApi_Conversations.Smart2Response> respList = CONV_SERVICE.getResponse();
            List<PBB_SRV_GatewayApi_Conversations.Smart2Reason> reasList = CONV_SERVICE.getReason();
            Map<String, List<String>> respMaps = new Map<String, List<String>>();
            List<SObject> convserValues = new List<SObject>();
            for (PBB_SRV_GatewayApi_Conversations.Smart2Response resp : respList) {

                if (respMaps.get(resp.response) == null) {
                    respMaps.put(resp.response, new list<String>{
                            resp.subCategory
                    });
                } else {
                    respMaps.get(resp.response).add(resp.subCategory);
                }
            }
            for (PBB_SRV_GatewayApi_Conversations.Smart2Reason reas : reasList) {
                if (respMaps.get(reas.response) != null) {
                    for (String sCat : respMaps.get(reas.response)) {

                        convserValues.add(new Conversation_Value__c(Sub_Category__c = sCat, Response__c = reas.response, Reason__c = reas.reason));
                    }
                }
            }
            PbbSmart2ConversationPicklistSyncBatch bcCreateconvList = new PbbSmart2ConversationPicklistSyncBatch(convserValues);
            Database.executeBatch(bcCreateconvList,2000);
        }
        catch (Exception ex){
            CMN_UTIL_Logger.error(ex, 'PbbSmart2ConversationPicklistSync.mergeResponseAndReason');
        }
    }


    /**
    * @description This method is to get an Record Id
    * @param	recId Id of the Record
    * @return   Conversation object
    **/
    public class ConversationValue{
        public String subCategory;
        public String response;
        public String reason;
    }
}