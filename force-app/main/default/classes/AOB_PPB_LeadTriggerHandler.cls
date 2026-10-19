/********************************************************************************************
@ Author                  : Narendra Gorrela
@ Date                    : 02-06-2025
@ Name of the Class       : AOB_PPB_LeadTirggerHandler
@ Description             : [SFP-49192] Handles Uganda Onboarding Lead updates and computes
durations spent in key statuses
********************************************************************************************/
public with sharing class AOB_PPB_LeadTriggerHandler {
    
    private static final String UG_ONBOARDING_METADATA_KEY         = 'UG_Onboarding_Record_Type';
    private static final String DEFAULT_UG_ONBOARDING_RECORDTYPE   = 'Uganda_Onboarding';
    private static final String UG_BUSINESS_HOURS                  = 'UG 08:00 - 17:00 (Mon - Fri)';
    
    private static final String STATUS_NEW                         = 'New';
    private static final String STATUS_WORKING                     = 'Working';
    private static final String STATUS_WAITING                     = 'Waiting for Customer';
    private static final String STATUS_QUALIFIED                   = 'Qualified';
    private static final String STATUS_UNQUALIFIED                 = 'Unqualified';
    private static final String AOB_STATUS_CLOSED                  = 'Closed';
    
    private static final String FIELD_WAITING_START_DATE           = 'Waiting_for_Customer_Start_Date__c';
    private static final String FIELD_WAITING_DURATION_HOURS       = 'Waiting_for_Customer_Duration_Hours__c';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_PPB_LeadTirggerHandler');
    
    /**
* Handles updates for Uganda Onboarding leads:
* - Sets Completed_Date__c and AOB_Status__c = 'Closed' when status is 'Qualified' or 'Unqualified'
* - Calculates time spent in 'New' and 'Working' and 'Waiting for Customer' statuses
*
* @param newList Updated Lead records (Trigger.new)
* @param oldMap  Previous Lead records (Trigger.oldMap)
*/
    public static void handleStatusUpdate(List<Lead> newList, Map<Id, Lead> oldMap) {
        
        String ugOnboardingRecordType;
        
        if (!Test.isRunningTest()) {
            try {
                PPB_Static_values__mdt ugOnboardingRecord = [
                    SELECT value__c
                    FROM PPB_Static_values__mdt
                    WHERE Developername = :UG_ONBOARDING_METADATA_KEY
                    WITH USER_MODE
                    LIMIT 1
                ];
                ugOnboardingRecordType = ugOnboardingRecord.value__c;
            } catch (Exception e) {
                LOGGER.error('Metadata fetch failed in handleStatusUpdate', e);
                return;
            }
        } else {
            ugOnboardingRecordType = DEFAULT_UG_ONBOARDING_RECORDTYPE;
        }
        
        if(!String.isBlank(ugOnboardingRecordType)){
            
            RecordTypeInfo info = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(ugOnboardingRecordType);
            
            Id targetRecordTypeId = info.getRecordTypeId(); 
            
            if(targetRecordTypeId != null){
                
                // Filter leads that match the target record type
                List<Lead> leadsToProcess = new List<Lead>();
                for (Lead newLead : newList) {
                    if (newLead.RecordTypeId == targetRecordTypeId) {
                        Lead oldLead = oldMap?.get(newLead.Id);
                        
                        // Set Completed_Date__c and AOB_Status__c if moved to final state
                        if ((oldLead?.Status != newLead.Status) &&
                            (newLead.Status == STATUS_QUALIFIED || newLead.Status == STATUS_UNQUALIFIED)) {
                                
                                newLead.Completed_Date__c = System.now();
                                newLead.AOB_Status__c     = AOB_STATUS_CLOSED;
                            }
                        
                        // Mark Working Start Date when entering Working
                        if (oldLead?.Status != newLead.Status && newLead.Status == STATUS_WORKING) {
                            newLead.put('Working_Start_Date__c', System.now());
                        }
                        
                        // Mark Waiting Start Date when entering Waiting for Customer
                        if (oldLead?.Status != newLead.Status && newLead.Status == STATUS_WAITING) {
                            newLead.put(FIELD_WAITING_START_DATE, System.now());
                        }
                        
                        leadsToProcess.add(newLead);
                    }
                }
                
                if (!leadsToProcess.isEmpty()) {
                    try {
                        calculateTimeSpentInStatuses(leadsToProcess, oldMap);
                    } catch (Exception ex) {
                        LOGGER.error('Error in calculating status durations in calculateTimeSpentInStatuses', ex);
                    }
                }
            }
        }
    }
    
    /**
* @description Calculates duration (in business hours) spent in New, Working, and Waiting for Customer statuses
* @param newList Updated Lead records
* @param oldMap  Map of old Lead records
*/
    private static void calculateTimeSpentInStatuses(List<Lead> newList, Map<Id, Lead> oldMap) {
        BusinessHours ugandaBH = [
            SELECT Id FROM BusinessHours 
            WHERE Name = :UG_BUSINESS_HOURS 
            WITH USER_MODE LIMIT 1
        ];
        
        for (Lead newLead : newList) {
            Lead oldLead = oldMap.get(newLead.Id);
            
            // --- New Status ---
            if (oldLead.Status == STATUS_NEW && newLead.Status != STATUS_NEW) {
                accumulateDuration(oldLead, newLead, 'CreatedDate', 'New_Duration_Hours__c', ugandaBH.Id);
            }
            
            // --- Working Status ---
            if (oldLead.Status == STATUS_WORKING && newLead.Status != STATUS_WORKING && 
                newLead.Working_Start_Date__c != null) {
                    accumulateDuration(oldLead, newLead, 'Working_Start_Date__c', 'Working_Duration_Hours__c', ugandaBH.Id);
                }
            
            // --- Waiting for Customer Status ---
            if (oldLead.Status == STATUS_WAITING && newLead.Status != STATUS_WAITING && newLead.Waiting_for_Customer_Start_Date__c != null) {
                accumulateDuration(oldLead, newLead, FIELD_WAITING_START_DATE, FIELD_WAITING_DURATION_HOURS, ugandaBH.Id);
            }
        }
    }
    
    /**
* @description Helper method to calculate and accumulate duration for a given status
*/
    private static void accumulateDuration(Lead oldLead, Lead newLead, String startDateField, String durationField, Id businessHoursId ) {
        Datetime startTime = (Datetime)newLead.get(startDateField);
        
        if (startTime == null) return;
        
        Long msDiff = BusinessHours.diff(businessHoursId, startTime, System.now());
        if (msDiff == null) return;
        
        Decimal hours = (msDiff / (1000.0 * 60 * 60)).setScale(2);
        Decimal prev = (Decimal)newLead.get(durationField);
        newLead.put(durationField, (prev != null ? prev + hours : hours));
    }
    
}