/**
 * @description Automatic Lead Conversion handler for the W&I Lead Automatic Convert flow
 *
 * @author Adam Redlinski
 *
 * @date 2023/04/18
 */
global without sharing class WI_FLOW_LeadConverter {

    static final String PRICE_BOOK_NAME = 'SA Wealth & Investment';
    static final String OPPORTUNITY_STAGE_DEFAULT = 'Setup';
    static final Id USER_ID = System.UserInfo.getUserId();
    private static final String OPPORTUNITY_TM_ACCESS_LVL = 'Edit';
    private static Map<String, String> roleByFieldName = new Map<String, String>{
        Schema.Application__c.WI_RelationshipManager__c.getDescribe().getName() => 'Relationship Manager',
        Schema.Application__c.WI_WealthManager__c.getDescribe().getName() => 'Wealth Manager',
        Schema.Application__c.WI_AccountManager__c.getDescribe().getName() => 'Account Manager',
        Schema.Application__c.WI_WealthAdministrator__c.getDescribe().getName() => 'Wealth Administrator'
    };

    /**
     * @description Method for Lead Conversion with additional checks and actions for W&I process
     *
     * @param List<LeadConversionInput> leadConversionInput - Wrapper contained lead and optionally opportunity name and recod type
     */
    @InvocableMethod(Label='Convert Leads')
    global static List<LeadConversionResult> convertLeads(List<LeadConversionInput> leadConversionInput) {
        if (leadConversionInput == null || leadConversionInput.size() == 0) {
            return null;
        }

        Map<String, String> opportunityRTByOpportunityName = new Map<String, String>();
        Map<String, RecordTypeInfo> opportunityRecordTypeIdsByDeveloperName = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
        Map<Id, Map<String, String>> opportunityDataMapByLeadId = new Map<Id, Map<String, String>>();
        Map<Id, Id> applicationIdByLeadId = new Map<Id, Id>();
        Map<Id, List<String>> opportunityRTNamesByLeadId = new Map<Id, List<String>>();

        List<Database.LeadConvert> leadConverts = handleInputData(leadConversionInput, opportunityRTByOpportunityName, opportunityDataMapByLeadId, applicationIdByLeadId, opportunityRTNamesByLeadId);

        Map<Id, Application__c> applicationById = new Map<Id, Application__c>([
                SELECT Id,
                        Correspondence_Province__c,
                        WI_RelatedLead__c,
                        AOB_FirstName__c,
                        AOB_LastName__c,
                        WI_IdentityType__c,
                        WI_WealthAdministrator__c,
                        WI_AccountManager__c,
                        WI_IdentificationNumber__c,
                        AOB_Title__c,
                        WI_CompanyRegistrationNumber__c,
                        Correspondence_Address_Line_1__c,
                        WI_WealthManager__c,
                        WI_RelationshipManager__c,
                        Correspondence_Postcode__c,
                        Correspondence_Country__c
                FROM Application__c
                WHERE Id IN :applicationIdByLeadId.values()
        ]);


        Set<Id> opportunitiesToUpdateIds = new Set<Id>();
        Set<Id> accountsToUpdateIds = new Set<Id>();
        Boolean resultFailed = false;
        List<Database.LeadConvertResult> results = new List<Database.LeadConvertResult>();
        try {
            for (Database.LeadConvertResult convertResult : Database.convertLead(leadConverts, true)) {
                if (!convertResult.isSuccess()) {
                    resultFailed = true;
                }
                opportunitiesToUpdateIds.add(convertResult.getOpportunityId());
                accountsToUpdateIds.add(convertResult.getAccountId());
                results.add(convertResult);
            }

            if (resultFailed) {
                return new List<LeadConversionResult>{
                        new LeadConversionResult(results)
                };
            }
        } catch (DmlException excep) {
            return new List<LeadConversionResult>{
                    new LeadConversionResult(false, excep.getMessage())
            };
        }


        List<Opportunity> createdOpportunities = getOpportunities(opportunitiesToUpdateIds);
        Pricebook2 pricebook = getPriceBook();
        List<Opportunity> opportunitiesToCreate = new List<Opportunity>();
        List<Account> accountsToUpdate = new List<Account>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Map<Id, String> teamRoleByLeadId = new Map<Id, String>();
        List<OpportunityTeamMember> opportunityTeamMembersList = new List<OpportunityTeamMember>();
        Application__c relatedApplication;
        for (LeadConversionInput leadInput : leadConversionInput) {
            relatedApplication = applicationById.get(applicationIdByLeadId.get(leadInput.lead.Id));
            teamRoleByLeadId.put(leadInput.lead.Id, leadInput.opportunityTeamRole);
            if (relatedApplication != null) {
                if (opportunityDataMapByLeadId.size() > 0 && opportunityDataMapByLeadId.get(leadInput.lead.Id) != null) {
                    handleOpportunityDataUpdate(leadInput, createdOpportunities, opportunitiesToUpdate, relatedApplication, opportunityDataMapByLeadId, opportunityRecordTypeIdsByDeveloperName, pricebook, opportunityTeamMembersList, opportunitiesToCreate, opportunityRTNamesByLeadId, oppLineItems);
                }
                for (Id accountId : accountsToUpdateIds) {
                    if (accountId == leadInput.lead.FinServ__RelatedAccount__c) {
                        Account temp = new Account(Id = accountId);
                        mapAccountFields(temp, relatedApplication);
                        accountsToUpdate.add(temp);
                    }
                }
            }
        }

        try {
            upsertObjects(opportunitiesToUpdate, accountsToUpdate, opportunityTeamMembersList,opportunitiesToCreate, leadConversionInput, oppLineItems, relatedApplication);
        } catch (DmlException ex) {
            return new List<LeadConversionResult>{
                    new LeadConversionResult(false, ex.getMessage())
            };
        }

        return new List<LeadConversionResult>{
                new LeadConversionResult(results)
        };
    }

    private static void upsertObjects(List<Opportunity> opportunitiesToUpdate, List<Account> accountsToUpdate, List<OpportunityTeamMember> opportunityTeamMembersList, List<Opportunity> newOpportunities, List<LeadConversionInput> leadConversionInput, List<OpportunityLineItem> oppLineItems, Application__c relatedApplication) {
        List<SObject> updateObjects = new List<SObject>();
        if(!newOpportunities?.isEmpty() != false) {
            insert newOpportunities;

            for (LeadConversionInput singleInput : leadConversionInput) {
                Integer iter = oppLineItems.size();
                for (Opportunity singleOpp : newOpportunities) {
                    /* if (singleOpp.Lead__c == singleInput.lead.Id) {
                        opportunityTeamMembersList.add(new OpportunityTeamMember(OpportunityId = singleOpp.Id, TeamMemberRole = singleInput.opportunityTeamRole, OpportunityAccessLevel = OPPORTUNITY_TM_ACCESS_LVL, UserId = USER_ID));
                    } */
                    if (singleInput.productsData != null && singleInput.productsData.size() >= iter + 1) {
                        List<String> pData = singleInput.productsData[iter].split(';');
                        oppLineItems.add(
                            new OpportunityLineItem(
                                OpportunityId = singleOpp.Id,
                                Product2Id = pData[1]
                            )
                        );
                        opportunityTeamMembersList.addAll(addTeamMembers(singleOpp.Id, relatedApplication, pData.size() == 3 ? pData[2] : null));
                    }
                    iter++;
                }
            }
        }
        if (!opportunitiesToUpdate?.isEmpty() != false) {
            updateObjects.addAll(opportunitiesToUpdate);
        }
        if (!accountsToUpdate?.isEmpty() != false) {
            updateObjects.addAll(accountsToUpdate);
        }
        if (!opportunityTeamMembersList?.isEmpty() != false) {
            updateObjects.addAll(opportunityTeamMembersList);
        }
        upsert updateObjects;
        insert oppLineItems;
    }

    private static void handleOpportunityDataUpdate(LeadConversionInput leadInput, List<Opportunity> createdOpportunities, List<Opportunity> opportunitiesToUpdate, Application__c relatedApplication, Map<Id, Map<String, String>> opportunityDataMapByLeadId, Map<String, RecordTypeInfo> opportunityRecordTypeIdsByDeveloperName, Pricebook2 pricebook, List<OpportunityTeamMember> opportunityTeamMembersList, List<Opportunity> opportunitiesToCreate, Map<Id, List<String>> opportunityRTNamesByLeadId, List<OpportunityLineItem> oLineItems) {
        if (leadInput == null || relatedApplication == null || createdOpportunities?.isEmpty() != false || opportunityDataMapByLeadId?.isEmpty() != false) {
            return;
        }

        if (opportunitiesToUpdate == null) {
            opportunitiesToUpdate = new List<Opportunity>();
        }
        Integer iter = 0;
        for (Opportunity createdOpportunity : createdOpportunities) {
            List<String> opportunityNameParts = createdOpportunity.Name.split('-');
            if ( !opportunityNameParts.isEmpty() ) {
                String leadName = opportunityNameParts[0], opportunityRTName = opportunityNameParts[1];
                if (leadName == leadInput.lead.name) {
                    if (!opportunityRTNamesByLeadId.isEmpty()) {
                        for (String singleOpportunityRT : opportunityRTNamesByLeadId.get(leadInput.lead.Id)) {
                            Id oppRTId = opportunityRecordTypeIdsByDeveloperName.get(singleOpportunityRT).getRecordTypeId();
                            String oppName = generateOpportunityName(leadInput.lead.Name, singleOpportunityRT);
                            Opportunity newOpp = new Opportunity(RecordTypeId = oppRTId, Name = oppName, Lead__c = leadInput.lead.Id, AccountId = leadInput.lead.FinServ__RelatedAccount__c, CloseDate = System.today().addMonths(3).toStartOfMonth().addDays(-1));
                            if (pricebook != null) {
                                newOpp.Pricebook2Id = pricebook.Id;
                            }
                            mapOpportunity(newOpp, relatedApplication);
                            opportunitiesToCreate.add(newOpp);
                        }
                    }
                    Opportunity opportunityToUdpdate = new Opportunity(Id = createdOpportunity.Id);
                    opportunityToUdpdate.RecordTypeId = opportunityRecordTypeIdsByDeveloperName.get(opportunityRTName).getRecordTypeId();

                    if (pricebook != null) {
                        opportunityToUdpdate.Pricebook2Id = pricebook.Id;
                    }
                    mapOpportunity(opportunityToUdpdate, relatedApplication);
                    opportunityToUdpdate.Lead__c = leadInput.lead.Id;
                    opportunitiesToUpdate.add(opportunityToUdpdate);
                    /* if (opportunityTeamMembersList != null) {
                        opportunityTeamMembersList.add(new OpportunityTeamMember(OpportunityId = createdOpportunity.Id, TeamMemberRole = leadInput.opportunityTeamRole, OpportunityAccessLevel = OPPORTUNITY_TM_ACCESS_LVL, UserId = USER_ID));
                    } */
                }
            }
            if (leadInput.productsData != null && leadInput.productsData.size() >= iter + 1) {
                List<String> pData = leadInput.productsData[iter].split(';');
                oLineItems.add(
                    new OpportunityLineItem(
                        OpportunityId = createdOpportunity.Id,
                        Product2Id = pData[1]
                    )
                );
                opportunityTeamMembersList.addAll(addTeamMembers(createdOpportunity.Id, relatedApplication, pData.size() == 3 ? pData[2] : null));
            }
            iter++;
        }
    }

    private static void mapAccountFields(Account relatedAccount, Application__c app) {
        relatedAccount.WI_InternationalRM__c = app.WI_RelationshipManager__c;
        relatedAccount.WI_DomesticRM__c = app.WI_RelationshipManager__c;
        relatedAccount.WI_WealthManager__c = app.WI_WealthManager__c;
        relatedAccount.WI_WealthAdministrator__c = app.WI_WealthAdministrator__c;
    }

    private static void mapOpportunity(Opportunity relatedOpportunity, Application__c app) {
        if (relatedOpportunity == null || app == null) {
            return;
        }
        relatedOpportunity.StageName = OPPORTUNITY_STAGE_DEFAULT;
    }

    private static String generateOpportunityName(String leadName, String recordTypeName) {
        return leadName + '-' + recordTypeName + '-' + System.today();
    }

    private static List<Database.LeadConvert> handleInputData(List<LeadConversionInput> leadConversionInput, Map<String, String> opportunityRTByOpportunityName, Map<Id, Map<String, String>> opportunityDataMapByLeadId, Map<Id, Id> applicationIdByLeadId, Map<Id, List<String>> opportunityRTNamesByLeadId) {
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        if (leadConversionInput == null || opportunityRTByOpportunityName == null || applicationIdByLeadId == null) {
            return leadConverts;
        }
        for (LeadConversionInput input : leadConversionInput) {
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            if (String.isNotBlank(input.opportunityRtName)) {
                List<String> chosenRTNamesList = input.opportunityRtName.split(';');
                String opportunityName = generateOpportunityName(input.lead.Name, chosenRTNamesList[0]);
                leadConvert.setOpportunityName(opportunityName);

                opportunityRTByOpportunityName.put(opportunityName, chosenRTNamesList[0]);
                opportunityDataMapByLeadId.put(input.lead.Id, opportunityRTByOpportunityName);
                chosenRTNamesList.remove(0);
                opportunityRTNamesByLeadId.put(input.lead.Id, chosenRTNamesList);
            } else {
                leadConvert.setDoNotCreateOpportunity(true);
            }

            leadConvert.setLeadId(input.lead.Id);
            LeadConvert.setConvertedStatus(input.leadStatus);
            leadConvert.setAccountId(input.lead.FinServ__RelatedAccount__c);
            applicationIdByLeadId.put(input.lead.Id, input.lead.WI_Application__c);
            leadConverts.add(leadConvert);
        }
        return leadConverts;
    }

    private static List<Opportunity> getOpportunities(Set<Id> opportunitiesToUpdateIds) {
        return [SELECT Id, Name FROM Opportunity WHERE Id IN :opportunitiesToUpdateIds];
    }

    private static Pricebook2 getPriceBook() {
        List<Pricebook2> pricebook2s = [SELECT Id FROM Pricebook2 WHERE Name = :PRICE_BOOK_NAME LIMIT 1];
        return pricebook2s.isEmpty() == true ? null : pricebook2s[0];
    }

    private static List<OpportunityTeamMember> addTeamMembers(Id oppId, Application__c app, Id waId) {
        List<OpportunityTeamMember> result = new List<OpportunityTeamMember>();
        for (String fieldName : roleByFieldName.keySet()) {
            if (app == null || app.get(fieldName) == null) continue;
            result.add(
                new OpportunityTeamMember(
                    OpportunityId = oppId, 
                    TeamMemberRole = roleByFieldName.get(fieldName), 
                    OpportunityAccessLevel = OPPORTUNITY_TM_ACCESS_LVL, 
                    UserId = (Id)app.get(fieldName)
                )
            );
        }
        if (waId != null) {
            result.add(
                new OpportunityTeamMember(
                    OpportunityId = oppId, 
                    TeamMemberRole = 'Wealth Administrator', 
                    OpportunityAccessLevel = OPPORTUNITY_TM_ACCESS_LVL, 
                    UserId = waId
                )
            );
        }
        return result;
    }

    global class LeadConversionResult {
        @InvocableVariable(Label='Success')
        global Boolean success;
        @InvocableVariable(Label='Error Message')
        global String errorMessage;

        global LeadConversionResult(Boolean success, String message) {
            this.success = success;
            this.errorMessage = message;
        }

        global LeadConversionResult(List<Database.LeadConvertResult> convertResults) {
            Boolean isFailed = false;
            for (Database.LeadConvertResult result : convertResults) {
                if (!result.isSuccess()) {
                    isFailed = true;
                }
                this.errorMessage += result.getErrors() != null && !result.getErrors().isEmpty()
                        ? result.getErrors()[0].getMessage()
                        : null;
            }
            this.success = !isFailed;
        }
    }

    global class LeadConversionInput {
        @InvocableVariable(Label='Lead')
        global Lead lead;
        @InvocableVariable(Label='Opportunity Record Type Name')
        global String opportunityRtName;
        @InvocableVariable(Label='Lead Status')
        global String leadStatus;
        @InvocableVariable(Label='Team Role')
        global String opportunityTeamRole;
        @InvocableVariable(Label='Products Data')
        global List<String> productsData;
    }
}