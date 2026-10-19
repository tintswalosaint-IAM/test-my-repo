public without sharing class INS_Batch_LeadIntegration implements 
    Database.Batchable<sObject>, 
    Database.AllowsCallouts, 
    Database.Stateful {
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_Batch_LeadIntegration.class.getName());
    
    private Map<Id, String> leadToSystemMap;
    
    private Map<String, INS_Insurance_Lead_Settings__mdt> settingsCache = 
        new Map<String, INS_Insurance_Lead_Settings__mdt>();
    
    private Integer successCount = 0;
    private Integer errorCount = 0;
    private List<String> errorMessages = new List<String>();
    
    public INS_Batch_LeadIntegration(Map<Id, String> leadToSystemMap) {
        this.leadToSystemMap = leadToSystemMap;
        LOGGER.info('Batch initialized with ' + leadToSystemMap.size() + ' leads');
    }
    
    public Iterable<Lead> start(Database.BatchableContext bc) {
        Set<Id> leadIds = leadToSystemMap.keySet();
        List<lead> leadsToProcess = new List<lead>();
        LOGGER.debug('Start : Processing ' + leadIds.size() + ' leads');
        
      /*  return Database.getQueryLocator([
            SELECT Id, Salutation, FirstName, LastName, Email, 
                   Campaign_Source_Id__c, MobilePhone, Phone, Company,
                   Status, OwnerId, External_Client_Identifier__c,
                   Referred_System_Reference_Number__c,
                   Dialer_Failure_Reason__c,
                   Lead_Closing_Comment__c
            FROM Lead 
            WHERE Id IN :leadIds
        ]); */
        List<Id> leadIdList = new List<Id>(leadIds);
        leadsToProcess = new SEL_Lead().selectLeadsByRecIds(leadIdList);
        return leadsToProcess;
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        LOGGER.debug('Execute : Processing ' + scope.size() + ' leads');
        
        String accessToken = getAccessToken();
        
        if (String.isBlank(accessToken)) {
            LOGGER.error('Failed to obtain access token');
            for (Lead lead : scope) {
                errorCount++;
                errorMessages.add('Lead ' + lead.Id + ': Token generation failed');
            }
            return;
        }
        
        for (Lead lead : scope) {
            processLead(lead, accessToken);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        LOGGER.info('Batch completed. Success: ' + successCount + ', Errors: ' + errorCount);
        
        if (!errorMessages.isEmpty()) {
            LOGGER.error('Error details: ' + String.join(errorMessages, ' | '));
        }
    }
    
    private String getAccessToken() {
        try {
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.INSSBIBInsurance');
            String cachedToken = (String) orgPart.get('INSDotsureToken');
            
            if (String.isNotBlank(cachedToken)) {
                return cachedToken;
            }
            
            String newToken = CMN_Generate_Token_Helper.getAccessToken();
            
            if (String.isNotBlank(newToken)) {
                orgPart.put('INSDotsureToken', newToken, 1500);
            }
            
            return newToken;
            
        } catch (Exception ex) {
            LOGGER.error('Failed to get access token: ' + ex.getMessage(), ex);
            return null;
        }
    }
    
    private void processLead(Lead lead, String accessToken) {
        String targetSystem = leadToSystemMap.get(lead.Id);
        
        try {
            INS_Insurance_Lead_Settings__mdt settings = getSettingsForSystem(targetSystem);
            
            if (settings == null) {
                errorCount++;
                errorMessages.add('Lead ' + lead.Id + ': No settings found for system: ' + targetSystem);
                return;
            }
            
            INS_IIntegrationHandler handler = INS_IntegrationFactory.getHandler(targetSystem);
            
            if (handler != null) {
                handler.processRecord(lead, accessToken, settings);
                successCount++;
                LOGGER.debug('Successfully processed Lead: ' + lead.Id);
            } else {
                errorCount++;
                errorMessages.add('Lead ' + lead.Id + ': No handler for system: ' + targetSystem);
            }
            
        } catch (Exception ex) {
            errorCount++;
            errorMessages.add('Lead ' + lead.Id + ': ' + ex.getMessage());
            LOGGER.error('Failed to process Lead: ' + lead.Id, ex);
        }
    }
    
    /**
     * @description Gets config for a specific system (cached)
     * @param targetSystem System name (e.g., "Dotsure")
     * @return INS_Insurance_Lead_Settings__mdt record or null
     **/
    private INS_Insurance_Lead_Settings__mdt getSettingsForSystem(String targetSystem) {
        if (settingsCache.containsKey(targetSystem)) {
            return settingsCache.get(targetSystem);
        }
        
        List<INS_Insurance_Lead_Settings__mdt> settings = [
            SELECT Id, DeveloperName, 
                   INS_Agentkey__c, 
                   INS_PreferredProduct__c
            FROM INS_Insurance_Lead_Settings__mdt
            WHERE DeveloperName = :targetSystem
            LIMIT 1
        ];
        
        if (settings.isEmpty()) {
            settingsCache.put(targetSystem, null);
            return null;
        }
        
        settingsCache.put(targetSystem, settings[0]);
        return settings[0];
    }
}