/**
* @description Batch Class to handle drop offs and lead assignment
*
*
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date September 2022
*/
public class AOB_Batch_HandleDropOffs implements Database.Batchable<sObject>, Schedulable {
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Batch_HandleDropOffs');


    final Set<Id> leadIdSet = new Set<Id>();
   private static Boolean isMobileWalletCreated = false;
   private static Boolean isMobileWalletStatusCreated = false; 
   private static Boolean isODAccountCreated = false; 
   private static Boolean isDSXCreated = false;
    public static Map<String, String> sourceQueueMap = new Map<String, String> {
        'Mobile Wallet Status Check' => 'AOB_Unfunded_accounts',
        'Mobile Wallet' => 'AOB_Unfunded_accounts',
        'Customer Alert Profile' => 'AOB_Frozen_accounts',
        'OD Account Create' => 'AOB_Incomplete_account_opened',
        'DSX' => 'AOB_KYC_queue',
        'PEP Sanction' => 'AOB_Compliance_queue'
    };

    /**
    * @description default constructor
    */
    public AOB_Batch_HandleDropOffs() {}

    /**
    * @description parametrized constructor
    * @param leadIds
    */
    public AOB_Batch_HandleDropOffs(Set<Id> leadIds) {
        leadIdSet.addAll(leadIds);
    }

    /**
    * @description batch start method
    * @param bc
    * @return will returns the eligible leads to process
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {

        String queryString = 'SELECT Id, FirstName, LastName, (SELECT Id FROM Applications__r) FROM Lead ';

        if(Test.isRunningTest() == false) {
            queryString += 'WHERE Owner.Type != \'Queue\'';
        }

        if(Test.isRunningTest() == true) {
            queryString += 'WHERE FirstName != null ';
        }
        
        String onboardingRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Uganda_Onboarding').getRecordTypeId();
        queryString += ' AND RecordTypeId = :onboardingRecordTypeId ';
        
        if(leadIdSet.isEmpty() == false) {
            queryString += ' AND Id IN :leadIdSet';
        }
        
        return Database.getQueryLocator(queryString);
    }
    /**
    * @description execute method
    * @param bc
    * @param leadList
    */
    public void execute(Database.BatchableContext bc, List<Lead> leadList) {
        try {
            Map<String, Id> queueNameAndIdMap = new Map<String, Id>();
            for (Group groupRecord : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :sourceQueueMap.values()]) {
                queueNameAndIdMap.put(groupRecord.DeveloperName, groupRecord.Id);
            }
            List<Lead> leadToUpdateList = new List<Lead>();
            Set<Id> leadIdToUpdateSet = new Set<Id>();
    
            List<Id> applicationIdList = getApplicationIdsFromLeads(leadList, queueNameAndIdMap, leadToUpdateList, leadIdToUpdateSet);
            if (!applicationIdList.isEmpty()) {
                processApplications(applicationIdList, queueNameAndIdMap, leadToUpdateList, leadIdToUpdateSet);
            }
    
            if (!leadToUpdateList.isEmpty()) {
                updateLeads(leadToUpdateList);
            }
    
        } catch (Exception ex) {
             LOGGER.error('Some Un-Handled Exception Occurred', ex);

        }
    }
    
    private List<Id> getApplicationIdsFromLeads(List<Lead> leadList, Map<String, Id> queueNameAndIdMap, List<Lead> leadToUpdateList, Set<Id> leadIdToUpdateSet) {
        List<Id> applicationIdList = new List<Id>();
    
        for (Lead leadRecord : leadList) {
            if (leadRecord.Applications__r != null && leadRecord.Applications__r.isEmpty() == false ) {
                applicationIdList.add(leadRecord.Applications__r[0].Id);
            } else {
                updateLeadOwner(leadRecord, queueNameAndIdMap, leadToUpdateList, leadIdToUpdateSet, 'AOB_Incomplete_account_opened');
            }
        }
        return applicationIdList;
    }
    
    private void processApplications(List<Id> applicationIdList, Map<String, Id> queueNameAndIdMap, List<Lead> leadToUpdateList, Set<Id> leadIdToUpdateSet) {
        Datetime currentDateTime = System.now().addMinutes(-30);
        String queryString = buildApplicationQueryString(applicationIdList, currentDateTime);
    
        for (Application__c applicationRecord : Database.query(queryString)) {
            Lead leadRecordToUpdate = assignLeadToQueue(applicationRecord, queueNameAndIdMap);
            if (leadRecordToUpdate.OwnerId != null && !leadIdToUpdateSet.contains(leadRecordToUpdate.Id)) {
                leadToUpdateList.add(leadRecordToUpdate);
                leadIdToUpdateSet.add(leadRecordToUpdate.Id);
            }
        }
    }
    
    private String buildApplicationQueryString(List<Id> applicationIdList, Datetime currentDateTime) {
        String queryString = 'SELECT Id, Name, AOB_Sanction_Status__c, AOB_PEP_Status__c,AOB_FamilyInProminentPublicOffice__c, AOB_Are_you_a_PEP__c,AOB_PreviouslyHeldProminentOffice__c, AOB_Lead__c, AOB_Customer_Id__c, '
                + 'AOB_MNO_Name_Matched__c, AOB_Stage__c, AOB_MNO_Customer_Name__c,Application__c.AOB_Account_Number__c,'
                + '(SELECT Id, Verification_Source__c, Verification_Status__c FROM Verifications__r WHERE '
                + 'Verification_Source__c IN (\'Mobile Wallet Status Check\', \'Mobile Wallet\', \'Customer Alert Profile\', \'OD Account Create\', \'DSX\') ORDER BY CreatedDate ASC) '
                + 'FROM Application__c ';
    
        if (Test.isRunningTest()== false ) {
            queryString += 'WHERE Id IN :applicationIdList AND LastModifiedDate < :currentDateTime';
        } else {
            queryString += 'WHERE Name != null ';
        }
        return queryString;
    }
    
    private void updateLeads(List<Lead> leadToUpdateList) {
        Integer recordCount = 0;
        for (Database.SaveResult sr : Database.update(leadToUpdateList, false)) {
            if (!sr.isSuccess()) {
                String errorMsgStr = '';
                for (Database.Error err : sr.getErrors()) {
                    errorMsgStr += err.getMessage();
                }
                 LOGGER.error('Some Un-Handled Exception Occurred', errorMsgStr);
            }
            recordCount++;
        }
    }
    
    private void updateLeadOwner(Lead leadRecord, Map<String, Id> queueNameAndIdMap, List<Lead> leadToUpdateList, Set<Id> leadIdToUpdateSet, String queueName) {
        Lead leadRecordToUpdate = new Lead(
            Id = leadRecord.Id,
            OwnerId = queueNameAndIdMap.get(queueName)
        );
        if (!leadIdToUpdateSet.contains(leadRecordToUpdate.Id)) {
            leadToUpdateList.add(leadRecordToUpdate);
            leadIdToUpdateSet.add(leadRecordToUpdate.Id);
        }
    }
    
    /**
    * @description This method used for final task
    * @param bc
    */
    public void finish(Database.BatchableContext bc) { }

    /**
     * @description Method to construct lead record
     * @param applicationRecord
     * @param queueNameAndIdMap
     * @return lead record which was processed and assigned to queue
     */
    public static Lead assignLeadToQueue(Application__c applicationRecord, Map<String, Id> queueNameAndIdMap) {
        Lead leadRecordToUpdate = new Lead(Id = applicationRecord.AOB_Lead__c);
    
    
        if (applicationRecord.Verifications__r != null && applicationRecord.Verifications__r.isEmpty() == false) {
            checkVerificationStatuses(applicationRecord.Verifications__r, queueNameAndIdMap, leadRecordToUpdate);
        } else if (applicationRecord.AOB_Stage__c == 'Nationality and ID' 
                    && !applicationRecord.AOB_MNO_Name_Matched__c 
                    && applicationRecord.AOB_MNO_Customer_Name__c != null) {
            leadRecordToUpdate.OwnerId = queueNameAndIdMap.get('AOB_Incomplete_account_opened');
        }
    
        if (leadRecordToUpdate.OwnerId == null) {
            assignBasedOnApplicationStatus(applicationRecord, queueNameAndIdMap, leadRecordToUpdate, 
                                           isMobileWalletCreated, isMobileWalletStatusCreated, isODAccountCreated, isDSXCreated);
        }
    
        return leadRecordToUpdate;
    }
    
    private static void checkVerificationStatuses(List<Verification__c> verificationRecords, Map<String, Id> queueNameAndIdMap, 
                                                  Lead leadRecordToUpdate) {
        for (Verification__c verificationRecord : verificationRecords) {
            if (verificationRecord.Verification_Status__c == 'Failed' && leadRecordToUpdate.OwnerId == null) {
                leadRecordToUpdate.OwnerId = queueNameAndIdMap.get(sourceQueueMap.get(verificationRecord.Verification_Source__c));
            }
    
            if (verificationRecord.Verification_Source__c == 'Mobile Wallet') {
                isMobileWalletCreated = true;
            }
    
            if (verificationRecord.Verification_Source__c == 'Mobile Wallet Status Check') {
                isMobileWalletStatusCreated = true;
            }
    
            if (verificationRecord.Verification_Source__c == 'OD Account Create') {
                isODAccountCreated = true;
            }
    
            if (verificationRecord.Verification_Source__c == 'DSX') {
                isDSXCreated = true;
            }
        }
    }
   
    private static void assignBasedOnApplicationStatus(Application__c applicationRecord, Map<String, Id> queueNameAndIdMap, 
                                                       Lead leadRecordToUpdate, Boolean isMobileWalletCreated, 
                                                       Boolean isMobileWalletStatusCreated, Boolean isODAccountCreated, 
                                                       Boolean isDSXCreated) {
        if (isHighRisk(applicationRecord)) {
            leadRecordToUpdate.OwnerId = queueNameAndIdMap.get('AOB_Compliance_queue'); 
        } else if (isDSXCreated == false) {
            leadRecordToUpdate.OwnerId = queueNameAndIdMap.get('AOB_KYC_queue'); 
        } else if (isODAccountCreated == false) {
            leadRecordToUpdate.OwnerId = queueNameAndIdMap.get('AOB_Incomplete_account_opened');
        } else if ((!isMobileWalletCreated || !isMobileWalletStatusCreated) && applicationRecord.AOB_Account_Number__c == null) {
            leadRecordToUpdate.OwnerId = queueNameAndIdMap.get('AOB_Unfunded_accounts'); 
        } else {
            leadRecordToUpdate.OwnerId = queueNameAndIdMap.get('AOB_Incomplete_account_opened'); 
        }
    }
    
    private static Boolean isHighRisk(Application__c applicationRecord) {
        return applicationRecord.AOB_Sanction_Status__c == 'ACTIVE' 
               || applicationRecord.AOB_PEP_Status__c == 'ACTIVE'
               || applicationRecord.AOB_PreviouslyHeldProminentOffice__c 
               || applicationRecord.AOB_FamilyInProminentPublicOffice__c;
    }
    
    
    /**
    * @description This method used to execute AOB_Batch_HandleDropOffs
    * @param sc
    */
    public void execute(SchedulableContext sc) {
        
        Database.executeBatch(new AOB_Batch_HandleDropOffs());
    }
}