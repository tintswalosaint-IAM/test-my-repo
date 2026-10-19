/**
 * @description class used as controller for  SBO-UK Adobe Feature
 *
 * Story:SFP-37439
 *
 * @author Ramya Gurram
 *
 * @date Dec 29 2023
 * @last modified on  : 29-01-2025
 * @last modified by  : Tushar Walse
 * @Modification Description :SFP-37439 class used to invoke for Adobe Flow
 */
public class ICS_CTRL_InvokeAdobeFlow {
     //Logger
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_InvokeAdobeFlow');

      /**
     * @description to ge the Account Name
     * @param List<string>  AccountId
     */
       @AuraEnabled
       public static void invokeFlow(List<string> AccountId) {
           try{
               Map<String, Object> params = new Map<String, Object>();
           params.put('AccountId', AccountId[0]);
           
           // Instantiate and start the Flow
           Flow.Interview.ICS_AdobePDFGeneration_StaffSource yourFlow = new Flow.Interview.ICS_AdobePDFGeneration_StaffSource(params);
           yourFlow.start(); 
           }
           catch(Exception e){
             LOGGER.error('Error while processing your request: ' + e.getMessage(), 'getFlow');
             throw new AuraHandledException('An error occurred while processing your request. Please try again later.');
               
           }
          
       }
      /**
     * @description to ge the Account Name
     * @param accId  AccountId
     * @return account Name
     */
    @Auraenabled
       Public static string fetchAccountName(string accId){
           sel_Account accountSelector = new sel_Account();
           Account acc=accountSelector.selectByID(accID);
           return acc.Name;
       }
    
   

   }