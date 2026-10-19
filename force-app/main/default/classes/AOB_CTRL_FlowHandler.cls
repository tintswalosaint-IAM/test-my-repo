/**
 * @description This class is used to orchestrate the screens to show the user based on the products selected
 *              Initiated as part of user story:DBP-1104
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 * @date October 2020
 *
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed N/A       08-06-2022 Gill Lumley   Restore new methods that were overwritten when prod was restored
 * Changed SFP-13220 20-06-2022 Gill Lumley   GetApplicationState changed to also check if lead created
 * Changed           24-06-2022 Mark Bailey   Add a method getWFRStatus to be called from Aura component AOB_COMP_CameraVerification
 */
public with sharing class AOB_CTRL_FlowHandler {
    public static final String LOGOUTREF = '/services/auth/rp/oidc/logout';
    public static final String WFRSCREEN ='Web Face Recognition';

    /**
     * @description This method will get an ordered list of flows to be shown for the products provided in parameter
     * @description Initiated as part of user story: DBP-1104
     *
     * @param applicationId : application identifier
     * @return ordered list of names of the flows to be shown
     */
    @auraEnabled
    public static Flows getFlows(id applicationId) {
        try {
            List<AOB_ApplicationLineItem__c> appLineItems = [SELECT Id, AOB_Application__c, AOB_Product__c FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c = :applicationId];
            Set<id> products = new Set<id>();
            for (AOB_ApplicationLineItem__c li : appLineItems) {
                products.add(li.AOB_Product__c);
            }
            List<AOB_ProductConfigurators__c> configs = [
                SELECT id, AOB_FlowScreen__c, AOB_FlowsConfigurator__c, AOB_Product__c
                FROM AOB_ProductConfigurators__c
                WHERE AOB_Product__c IN :products
                ORDER BY AOB_sequence__c
            ];
            Set<id> flowConfigIds = new Set<id>();
            for (AOB_ProductConfigurators__c li : configs) {
                flowConfigIds.add(li.AOB_FlowsConfigurator__c);
            }
            List<AOB_FlowsConfigurator__c> flowConfigs = [SELECT id, AOB_ScreenFlowAPIName__c, AOB_Label__c FROM AOB_FlowsConfigurator__c WHERE id IN :flowConfigIds];
            Map<string, string> screens = new Map<string, string>();
            for (AOB_FlowsConfigurator__c config : flowConfigs) {
                screens.put(config.AOB_Label__c, config.AOB_ScreenFlowAPIName__c);
            }
            AOB_Application__c app = [SELECT Id, AOB_TECH_FlowNames__c, AOB_currentScreen__c FROM AOB_Application__c WHERE Id = :applicationId];
            return new Flows(app.AOB_TECH_FlowNames__c, screens.get(app.AOB_currentScreen__c));
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error, 'AOB_CTRL_FlowHandler.getFlows');
            throw new AuraHandledException(error.getMessage());
        }
    }
    
    /**
     * @description This method will get the previous step and put it as current step so that the user sees his previous screen
     * @description Initiated as part of user story: DBP-1877
     *
     * @param applicationId : Application Id
     * @param index : index of the current flow
     */
    @AuraEnabled
    public static void goBacktoPreviousFlow(string applicationId, Integer index) {
        List<AOB_ApplicationLineItem__c> appLineItems = [SELECT Id, AOB_Application__c, AOB_Product__c FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c = :applicationId];
        Set<id> products = new Set<id>();
        for (AOB_ApplicationLineItem__c li : appLineItems) {
            products.add(li.AOB_Product__c);
        }
        List<AOB_ProductConfigurators__c> configs = [
            SELECT id, AOB_FlowScreen__c, AOB_FlowsConfigurator__c, AOB_Product__c
            FROM AOB_ProductConfigurators__c
            WHERE AOB_Product__c IN :products
            ORDER BY AOB_sequence__c
        ];
        Set<id> flowConfigIds = new Set<id>();
        for (AOB_ProductConfigurators__c li : configs) {
            flowConfigIds.add(li.AOB_FlowsConfigurator__c);
        }
        List<AOB_FlowsConfigurator__c> flowConfigs = [SELECT id, AOB_ScreenFlowAPIName__c, AOB_Label__c FROM AOB_FlowsConfigurator__c WHERE id IN :flowConfigIds];
        Map<string, string> screens = new Map<string, string>();
        for (AOB_FlowsConfigurator__c config : flowConfigs) {
            screens.put(config.AOB_ScreenFlowAPIName__c, config.AOB_Label__c);
        }

        AOB_Application__c app = [SELECT Id, AOB_TECH_FlowNames__c, AOB_PreviousScreen__c, AOB_CurrentScreen__c, AOB_TECH_NumOfScreens__c FROM AOB_Application__c WHERE Id = :applicationId];
        List<string> steps = app.AOB_TECH_FlowNames__c.split(',');
        app.AOB_TECH_NumOfScreens__c = steps.size(); //this depends on if the user has insurance
        if (!steps.isEmpty()) {
            if (!screens.isEmpty()) {
                app.AOB_CurrentScreen__c = screens.get(steps[index - 1]);
            }
            app.AOB_TECH_CurrentScreenNum__c = index - 1;

            if (steps[index - 2] != null) {
                app.AOB_PreviousScreen__c = screens.get(steps[index - 2]);
            } else {
                app.AOB_PreviousScreen__c = '';
            }
        }

        update app;
    }

    /**
     * @description This method will set the flow names list
     *
     * @param applicationId : Application Id
     * @return  flows  wrapper class containing the list of the current flows
     */
    @AuraEnabled
    public static Flows initFlowNames(string applicationId) {
        string token = aob_Utils.getAccessToken();
        List<AOB_FlowsConfigurator__c> flowConfigs = new List<AOB_FlowsConfigurator__c>();// AOB_SRV_ApplicationManagement.updateFlowNames(token, applicationId);
        Map<string, string> screens = new Map<string, string>();
        for (AOB_FlowsConfigurator__c config : flowConfigs) {
            screens.put(config.AOB_Label__c, config.AOB_ScreenFlowAPIName__c);
        }
        AOB_Application__c app = [SELECT Id, AOB_TECH_FlowNames__c, AOB_currentScreen__c FROM AOB_Application__c WHERE Id = :applicationId];
        return new Flows(app.AOB_TECH_FlowNames__c, screens.get(app.AOB_currentScreen__c));
    }

    /**
     * @description This method will refresh the token
     *
     */
    @AuraEnabled
    public static void refreshToken(){
        aob_Utils.getFreshAccessToken();
        //aob_Utils.getAccessToken();
    }
    
    /**
     * @description This method will send back to the component the adobe info (username/bpguid)
     *
     * @return String containing the adobe information serialized
     */
    @AuraEnabled
    public static String getAdobeInfo() {
        if (String.isNotBlank(aob_Utils.getAccessToken())) {
            List<Account> accounts = [SELECT Id, PersonEmail, ExternalCIFUUID__c FROM Account WHERE Id IN (SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId())];
            if (accounts.isEmpty()) {
                AuraHandledException exc = new AuraHandledException('Problem in AOB_CTRL_FlowHandler.getAdobeInfo: No account linked to the current user');
                CMN_UTIL_Logger.error(exc, 'AOB_CTRL_FlowHandler.getAdobeInfo');
                throw exc;
            } else {
                String emailString = String.isNotBlank(accounts.get(0).PersonEmail) ? accounts.get(0).PersonEmail : '';
                Blob hashedEmail = Crypto.generateDigest('SHA-256', Blob.valueOf(emailString));
                String hashedEmailString = EncodingUtil.convertToHex(hashedEmail);
                AdobeInfo adobeInfoObj = new AdobeInfo(accounts.get(0).ExternalCIFUUID__c, hashedEmailString);
                return JSON.serialize(adobeInfoObj);
            }
        } else {
            return null;
        }
    }

    /**
     * @description gets the mapping to show the back button for any specific screen
     *
     * @param flowNames List of string flow names
     * @return
     */
    @AuraEnabled
    public static Map<String, Boolean> getShowBackButtonMapping(List<String> flowNames) {
        List<AOB_FlowsConfigurator__c> flowConfigurators = new List<AOB_FlowsConfigurator__c>();
        Map<String, Boolean> showBackButtonMapping = new Map<String, Boolean>();
        if (flowNames != null && !flowNames.isEmpty()) {
            flowConfigurators = [SELECT Id, AOB_ScreenFlowAPIName__c, AOB_TECH_ShowBackButton__c FROM AOB_FlowsConfigurator__c WHERE AOB_ScreenFlowAPIName__c IN :flowNames];
        }
        if (flowConfigurators.isEmpty()) {
            AuraHandledException exc = new AuraHandledException('Problem in AOB_CTRL_FlowHandler.getAdobeInfo: No flow configurator found for the current flow name');
            CMN_UTIL_Logger.error(exc, 'AOB_CTRL_FlowHandler.getShowBackButton');
            throw exc;
        } else {
            for (AOB_FlowsConfigurator__c eachProdConfig : flowConfigurators) {
                showBackButtonMapping.put(eachProdConfig.AOB_ScreenFlowAPIName__c, eachProdConfig.AOB_TECH_ShowBackButton__c);
            }
            return showBackButtonMapping;
        }
    }

    /**
    * @description This class is used as a wrapped for flow screens
    */
    public class Flows {
        @auraEnabled
        public List<string> flowNames;
        @auraEnabled
        public Integer currentIndex;
        /**
        * @description constructor of flow wrapper
        * @param flowNames 
        * @param currentScreen 
        */
        public Flows(string flowNames, string currentScreen) {
            this.flowNames = flowNames.split(',');
            this.currentIndex = this.flowNames.indexOf(currentScreen) == -1 ? 0 : this.flowNames.indexOf(currentScreen);
        }
    }

    /**
    * @description This class is used as a wrapped for adobe report info
    */
    public class AdobeInfo {
        public String bpguid;
        public String encryptedUsername;
        /**
        * @description constructor of adobe info wrapper
        * @param bpguid
        * @param encryptedUsername
        */
        public AdobeInfo(String bpguid, String encryptedUsername) {
            this.bpguid = bpguid;
            this.encryptedUsername = encryptedUsername;
        }
    }
    
    /**
    * @description This method returns if the current screen is WFR
    *
    * @param applicationId : Application Id
    * @return  boolean indicating if current screen is WFR
    */
    @AuraEnabled
    public static Boolean isWFRStep(String applicationId) {
        
        List<AOB_Application__c> apps = [SELECT Id, AOB_currentScreen__c FROM AOB_Application__c WHERE Id = :applicationId];
        if(!apps.isEmpty()){
            if(!String.isBlank(apps[0].AOB_currentScreen__c)){
                return apps[0].AOB_currentScreen__c.contains(WFRSCREEN);
            }
        }
        return false;
    }

    /**
    * @description This method will set the flow names list
    *
    * @param applicationId : Application Id
    * @return  boolean indicating if user requested a call me back or created a lead on this app
    */
    @AuraEnabled
    public static Boolean getApplicationState(String applicationId) {
        
        List<AOB_Application__c> apps = [SELECT Id, AOB_Callback_Requested__c, Lead_Created__c FROM AOB_Application__c WHERE Id = :applicationId];
        if(!apps.isEmpty()){
            return (apps[0].AOB_Callback_Requested__c == true || apps[0].Lead_Created__c == true) ? true : false; // SFP-13220
        }
        else{
            throw new AuraHandledException('Unable to find application'+applicationId);
        }
    }

    /**
    * @description This method returns the current WFR Status on Application
    *
    * @param applicationId : Application Id
    * @return  string WFR Status
    */
    @AuraEnabled
    public static String getWFRStatus(String applicationId) {
        
        List<AOB_Application__c> apps = [SELECT AOB_TECH_WFRStatus__c FROM AOB_Application__c WHERE Id = :applicationId];
        if(!apps.isEmpty()){
            return apps[0].AOB_TECH_WFRStatus__c;
            }
        return '';
    }    
}