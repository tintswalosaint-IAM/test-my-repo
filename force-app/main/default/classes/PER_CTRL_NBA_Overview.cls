/**
 * @description       : Controller for the Portoflio and Customer Overview LWCs
 * @author            : Gul
 * @group             : Personalisation
 * @last modified on  : 14-05-2024
 * @last modified by  : Derek Hughes
 * Test class         : PER_CTRL_NBA_Overview_Test
 * 
 * Changes
 * 2024-04-16   Derek Hughes    Fix bug in determining the logged in users default portfolio code if they do not have ana ssigned AE Code on their user record
**/
public with sharing class PER_CTRL_NBA_Overview {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PER_CTRL_NBA_Overview');
    
    /**
    * @description Fetches all the actions for a single portfolio
    * @author Derek Hughes | 16-04-2024 
    * @param portfolioCode 
    * @return PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview 
    **/
    @AuraEnabled(cacheable=true)
    public static PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview fetchPortfolioOverviewForCode (String portfolioCode) {

        LOGGER.info('fetchPortfolioOverviewForCode: portfolioCode='+ portfolioCode);

        try {
            return loadPortfolioOverview(portfolioCode);
        } 
        catch (Exception e) {
            LOGGER.fatal('fetchPortfolioOverviewForCode: Unhandled Exception', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Fetches all the actions for the logged in user's default portfolio code (if they have one)
    * @author Derek Hughes | 16-04-2024 
    * @return PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview 
    **/
    @AuraEnabled(cacheable=true)
    public static PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview fetchPortfolioOverview() {

        LOGGER.info('fetchPortfolioOverview');

        try {
            return loadPortfolioOverview(null);
        }
        catch (Exception e) {
            LOGGER.fatal('fetchPortfolioOverview: Unhandled Exception', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description Called by both the fetch methods this class determins the users default portofolio if not specific code is provided and 
    *              then calls the Data Provider to get the load the reevant actions 
    * @author Derek Hughes | 16-04-2024 
    * @param selectedPortfolioCode 
    * @return PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview 
    **/
    private static PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview loadPortfolioOverview(String selectedPortfolioCode) {

        LOGGER.info('loadPortfolioOverview: User='+ System.UserInfo.getUserName() + ' selectedPortfolioCode='+selectedPortfolioCode);

        try {
            User loggedInUser = [
                SELECT id, RM_AE_Code__c, Portfolio_Codes__c, Portfolio_Role_Name__c, User_Country__c 
                FROM User 
                WHERE Id =: System.UserInfo.getUserId()
            ];

            String countryCode = loggedInUser.User_Country__c;
            List<PER_DTO_NBA_PortfolioOverview.SelectOption> portfolioOptions = new List<PER_DTO_NBA_PortfolioOverview.SelectOption>();

            if (String.IsNotBlank(loggedInUser.RM_AE_Code__c)) {
                String portfolioCode = loggedInUser.RM_AE_Code__c;

                PER_DTO_NBA_PortfolioOverview.SelectOption selectOption = new PER_DTO_NBA_PortfolioOverview.SelectOption();
                selectOption.disabled = false;
                selectOption.value = portfolioCode;
                selectOption.label = portfolioCode;
                portfolioOptions.add(selectOption);
            }

            if (String.IsNotBlank(loggedInUser.Portfolio_Codes__c)) {
                List<String> portfolioCodes = loggedInUser.Portfolio_Codes__c.split(',');
                for (String code : portfolioCodes) {
                    PER_DTO_NBA_PortfolioOverview.SelectOption selectOption = new PER_DTO_NBA_PortfolioOverview.SelectOption();
                    selectOption.disabled = false;
                    selectOption.value = code.trim();
                    selectOption.label = code.trim();
                    portfolioOptions.add(selectOption);
                }
            }

            // If there was no selected portfolio code then select one from the user if available
            if (String.IsBlank(selectedPortfolioCode)) {
                // Does this use have any defined portfolio codes?  If so, then select the first one
                if (portfolioOptions.size()>0) {
                    selectedPortfolioCode = portfolioOptions[0].value;
                }
            }

            selectedPortfolioCode = selectedPortfolioCode?.mid(2,100);

            PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview transformedPortOverData;
            transformedPortOverData=getPortfolioOverview(countryCode, selectedPortfolioCode);
            transformedPortOverData.portfolioOptions = portfolioOptions;
           
            LOGGER.info('loadPortfolioOverview: Loaded: selectedPortfolioCode='+selectedPortfolioCode);

            return transformedPortOverData;
        } 
        catch (Exception e) {
            LOGGER.fatal('loadPortfolioOverview: Unhandled Exception', e);
            throw e;
       //     throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Uses the API Service to get the Portfolio Overview data and then transforms them into the internal DTO format
    * @author Derek Hughes | 16-04-2024 
    * @param countryCode 
    * @param portfolioCode 
    * @return PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview 
    **/
    private static PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview getPortfolioOverview (String countryCode, String portfolioCode) {

        LOGGER.info('getPortfolioOverview: portfolioCode='+portfolioCode);

        PER_API_NBA_GetSinglePoap poapService = new PER_API_NBA_GetSinglePoap();
        PER_API_NBA_GetSinglePoap.DTO portOverData = new PER_API_NBA_GetSinglePoap.DTO();

        PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview transformedPortOverData;

        if (String.IsNotBlank(portfolioCode)) {
            portOverData = poapService.call(countryCode, portfolioCode);
            LOGGER.debug('getPortfolioOverview: portOverData: ' + portOverData);
        
            transformedPortOverData = PER_DTO_NBA_PortfolioOverview.transformPortfolioOverviewData(portOverData);
            transformedPortOverData.portfolioCode = countryCode+portfolioCode;
            if (String.IsBlank(transformedPortOverData.rmName)) {
                transformedPortOverData.rmName = null;
            }
        }
        else {
            transformedPortOverData = new PER_DTO_NBA_PortfolioOverview.DTO_PortfolioOverview();
            transformedPortOverData.portfolioCode = null;
            transformedPortOverData.rmName = null;
            transformedPortOverData.state = 'NOCODE';
        }
        
        LOGGER.debug('getPortfolioOverview: transformedPortOverData: ' + transformedPortOverData);
        return transformedPortOverData;
    }

    /**
    * @description Uses the API Service to get the Customer Overview data and then transforms them into the internal DTO format
    * @author Derek Hughes | 16-04-2024 
    * @param accountId 
    * @return PER_DTO_NBA_CustomerOverview.DTO_CustomerOverview 
    **/
    @AuraEnabled(cacheable=true)
    public static PER_DTO_NBA_CustomerOverview.DTO_CustomerOverview fetchCustomerOverview(String accountId) {

        LOGGER.info('fetchCustomerOverview: recordId='+accountId);

        try {
            Account currentAccount = [
                SELECT id,ExternalCIFId__c,ExternalCIFCountry__c, Type,PersonEmail,Phone,FinServ__KYCStatus__c,CMN_CustomerBPID__pc,FinServ__Gender__pc,EmploymentStatus__c,Branch__c,
                FinServ__CustomerSegment__c,FinServ__MaritalStatus__pc,Date_of_Birth__c,FinServ__CurrentEmployer__pc, CMN_IdentityNumber__pc
                FROM Account 
                WHERE Id =: accountId
            ];
            
            LOGGER.trace('fetchCustomerOverview: currentAccount: ' + currentAccount);

            PER_API_NBA_GetSingleCoap coapService = new PER_API_NBA_GetSingleCoap();
            PER_API_NBA_GetSingleCoap.DTO custOverData = new PER_API_NBA_GetSingleCoap.DTO();
            custOverData = coapService.call(currentAccount.ExternalCIFCountry__c, currentAccount.ExternalCIFId__c);
            LOGGER.trace('fetchCustomerOverview: custOverData: ' + custOverData);

            PER_DTO_NBA_CustomerOverview.DTO_CustomerOverview transformedCustOverData = PER_DTO_NBA_CustomerOverview.transformCustomerOverviewData(custOverData);

            transformedCustOverData.account = currentAccount;

            LOGGER.debug('fetchCustomerOverview: transformedCustOverData' + transformedCustOverData);
            return transformedCustOverData;
        } 
        catch (Exception e) {
            LOGGER.fatal('fetchCustomerOverview: Unhandled Exception', e);
            throw e;
            // throw new AuraHandledException(e.getMessage());
        }
    }

}