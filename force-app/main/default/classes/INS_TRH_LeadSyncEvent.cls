/**
 * @description Trigger Handler for Lead Sync Platform Events
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-10
 * 
 * Modifications Log
 * Date         Author          Modification
 * 2026-09-10   Raja Arsalan    Initial Version
 **/
public without sharing class INS_TRH_LeadSyncEvent extends CMN_TRH_BaseObject {
    
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_TRH_LeadSyncEvent.class.getName());
    
    private Map<Id, String> leadToSystemMap = new Map<Id, String>();
    private Integer eventCount = 0;
    
    public INS_TRH_LeadSyncEvent() {
        System.debug('=== CONSTRUCTOR CALLED ===');
        
        for (SObject so : Trigger.new) {
            INS_Lead_Sync_Event__e evt = (INS_Lead_Sync_Event__e) so;
            
            if (String.isNotBlank(evt.INS_LeadId__c) && 
                String.isNotBlank(evt.INS_TargetSystem__c)) {
                
                leadToSystemMap.put((Id) evt.INS_LeadId__c, evt.INS_TargetSystem__c);
                eventCount++;
            }
        }
        
        System.debug('=== leadToSystemMap size in constructor: ' + leadToSystemMap.size());
    }
    
    public override void bulkAfter() {
        System.debug('=== bulkAfter START ===');
        System.debug('=== leadToSystemMap size: ' + leadToSystemMap.size());
        super.bulkAfter();
        
        if (!leadToSystemMap.isEmpty()) {
            Database.executeBatch(
                new INS_Batch_LeadIntegration(leadToSystemMap), 
                20
            );
        }
    }
}