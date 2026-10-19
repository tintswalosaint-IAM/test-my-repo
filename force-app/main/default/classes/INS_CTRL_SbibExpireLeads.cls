/**
* @Description       : Controller Class for handling Expired Leads Report
* @Author            : Raja Arsalan
* @UserStory         : SFP-51744

**/

public with sharing class INS_CTRL_SbibExpireLeads {
    
    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_SbibExpireLeads');
    
    /**
* @description   : Retrieves a list of Lead records based on the provided search and filter criteria.
* 					The method builds a search DTO using the provided parameters and default values
* 					from the Insurance Lead Settings custom metadata. The DTO is then passed to the
* 					selector layer to fetch matching leads for manual expiry processing.
*
* @param         : status
* @param         : stage
* @param         : campaignSearch
* @param         : leadSearch
* @param 		 : fromDt
* @param 		 : toDt
* @return        : List<Lead>
*/
    @AuraEnabled(cacheable=true)
    public static List<Lead> fetchAllLeads(
        String status,
        String stage,
        String campaignSearch,
        String leadSearch,
        Datetime fromDt,
        Datetime toDt
    ){
        try{
            
            INS_Insurance_Lead_Settings__mdt leadSetting =
                INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
            
            
            
            INS_DTO_LeadSearchCriteria dto = new INS_DTO_LeadSearchCriteria();
            
            dto.leadType = leadSetting.INS_LeadType__c;
            dto.connexDate = leadSetting.INS_LeadDate__c;
            dto.productFamily = leadSetting.INS_ProductFamily__c;
            dto.status = status;
            dto.stage = stage;
            dto.searchKey = leadSearch;
            dto.campaignName = campaignSearch;
            dto.startDate = fromDt;
            dto.endDate = toDt;
            
            SEL_Lead selector = new SEL_Lead();
            
            List<Lead> leads = new list<Lead>();
            leads = selector.selectLeadsForManualExpiry(dto);
            
            LOGGER.debug('Fetched Leads Count: ' + leads.size());            
            return leads;
            
        }catch(Exception ex){
            
            LOGGER.error('INS_CTRL_SbibExpireLeads | fetchAllLeads | Exception', ex);            
            throw new AuraHandledException('Unable to fetch leads. Please contact your administrator.');
        }
    }
    
    /**
* @description   : Expires the provided list of Leads by updating their Status to 'Unqualified'
* 					and Stage to 'Closed Lost'. The updates are performed using the Unit Of Work
* 					pattern to ensure transactional consistency.
* @param 		 : leadIds
*/
    
    @AuraEnabled
    public static void expireLeads(List<Id> leadIds){
        
        try{
            LOGGER.debug('Leads expired successfully. Count: ' + leadIds.size());
            SEL_Lead selector = new SEL_Lead();
            if(leadIds != null){
                List<Lead> leadsToExpire = selector.selectLeadsByRecIds(leadIds);
                
                if(leadsToExpire.isEmpty()){
                    LOGGER.warn('No leads found for provided Ids');
                    return;
                }
                
                sbgplatform.fflib_SObjectUnitOfWork uow =
                    new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType>{Lead.SObjectType});
                
                for(Lead l : leadsToExpire){
                    
                    l.Status = 'Unqualified';
                    l.Stage__c = 'Closed Lost';
                    
                    uow.registerDirty(l);
                }
                
                uow.commitWork();
                
                LOGGER.debug('Leads expired successfully. Count: ' + leadsToExpire.size());
            }
            
            
        }catch(Exception ex){
            
            LOGGER.error('INS_CTRL_SbibExpireLeads | expireLeads | Exception', ex);
            throw new AuraHandledException('An error occurred while expiring leads. Please contact support if the issue persists.');
        }
    }
    
    /**
* @description  : Retrieves all available Lead Status picklist values from the Lead object.
*                 These values are typically used to populate UI filters for lead status selection.
*
* @return       : List<String>
*/
    @AuraEnabled(cacheable=true)
    public static List<String> getStatuses(){
        
        try{
            
            List<String> statuses = new List<String>();
            
            for(Schema.PicklistEntry p : Lead.Status.getDescribe().getPicklistValues()){
                statuses.add(p.getLabel());
            }
            
            return statuses;
            
        }catch(Exception ex){
            
            LOGGER.error('INS_CTRL_SbibExpireLeads | getStatuses | Exception', ex);           
            throw new AuraHandledException('Unable to retrieve statuses.');
        }
    }
    
    /**
* @description  : Checks whether the current logged-in user is a member of the
* 				   'INS_Dialer_Leads_Managers_PG' public group.
*                  This method is typically used to control UI access or enable
*                  certain features for Dialer Leads Managers.
*
* @return       : Boolean
*/
    @AuraEnabled
    public static Boolean isUserInDialerLeadsManagersGroup() {
        
        try {
            
            Id currentUserId = UserInfo.getUserId();
            
            SEL_GroupMember gpMember = new SEL_GroupMember();
            
            return gpMember.isUserInGroupByName(
                'INS_Dialer_Leads_Managers_PG',
                currentUserId
            );
            
        } catch (Exception ex) {
            
            LOGGER.error('INS_CTRL_SbibExpireLeads | isUserInDialerLeadsManagersGroup | Exception', ex);           
            throw new AuraHandledException('Failed to check group membership. Please contact your administrator.');
        }
    }
    
    
    
    
    
}