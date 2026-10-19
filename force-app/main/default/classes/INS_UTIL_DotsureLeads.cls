public class INS_UTIL_DotsureLeads {


    

    Public static void processLeadsForDotsure(List<Lead> leads) {
        List<INS_Lead_Sync_Event__e> eventsToPublish = new List<INS_Lead_Sync_Event__e>();
        if (leads.isEmpty()) {
            return;
        }

        Map<Id, Leads_ProductQueueAllocation__c> productMap = INS_UTIL_LeadTrigger.fetchProductAllocations(leads);

        for (Lead lead : leads) {
            system.debug('In dotsure util class');
            if (INS_UTIL_LeadTrigger.isValidProductLead(lead, productMap.get(lead.Expressed_Interest_Product__c),'Dotsure')) {  
                  system.debug('VALID DOTSURE LEAD');
                eventsToPublish.add(new INS_Lead_Sync_Event__e(
                INS_LeadId__c = lead.Id,
                INS_TargetSystem__c = 'DOTSURE'
            )); 
            }
            
        }

        if (!eventsToPublish.isEmpty()) {
            system.debug('EVENT SUBMITED');
        EventBus.publish(eventsToPublish);
    }
    }
}