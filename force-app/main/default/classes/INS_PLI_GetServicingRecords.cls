/**
 * @description       : Helper class for retrieving servicing records and customer details
 * @author            : Vershley Joyejob
 * @UserStory         : SFP-53079
 * @date              : 15-10-2025
 ***************************************************
 * Last Modified By Shams
 * Last Modified Date 24/07/2026
 * Last Modified Description: Added a new field ProductName
 * User Story : SFP-59435
**/
public without sharing class INS_PLI_GetServicingRecords {
 private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PLI_GetServicingRecords');
    /**
     * @description Get connected customer details for servicing
     * @author Vershley Joyejob
     * @date 15-10-2025
     * @param userId Connected Customer User Id
     * @return String JSON containing customer details
     */
    @AuraEnabled(Cacheable=false)
    public static String getConnectedCustomerDetails(String userId){
        Map<String, Object> personAccountDetails;
        try{
            // Validate input
            if (String.isBlank(userId)) {
                throw new AuraHandledException('User Id is required.');
            }
    
            User usr = new SEL_User().selectUserById(userId);
    
            if (usr.ContactId == null) {
                throw new AuraHandledException('No contact is associated with this user.');
            }
    
            // Fetch Contact / Person Account details
            Account personAcc = new SEL_Account().selectByIdWithServicingFields(usr.Contact.AccountId);
    
            // Prepare response JSON            
             personAccountDetails = new Map<String, Object>{
                    'Id' => personAcc.Id,
                    'FirstName' => personAcc.FirstName,
                    'LastName' => personAcc.LastName,
                    'EmailAddress' => personAcc.PersonEmail,
                    'PhoneNumber' => personAcc.Phone,
                    'IDNumber' => personAcc.CMN_IdentityNumber__pc,
                    'DateOfBirth' => personAcc.PersonBirthdate,
                    'AddressLine1' => personAcc.ShippingStreet,
                    'AddressLine2' => personAcc.ShippingState,
                    'City' => personAcc.ShippingCity,
                    'PostalCode' => personAcc.ShippingPostalCode,
                    'CountriesLiveIn' => personAcc.ShippingCountry,
                    'Country' => personAcc.ShippingCountry,
                    'employment_status' => personAcc.EmploymentStatus__c,
                    'nature_business_activity' => personAcc.NatureofBusiness__c,
                    'Employer' => personAcc.FinServ__CurrentEmployer__pc,
                    'source_wealth' => personAcc.Source_of_Funds__c,
                    'SourceOfWealth' => personAcc.Source_of_Funds_Type__c,
                    'sourceOfFunds' => personAcc.Source_of_Funds__c,
                    'Gender' => personAcc.FinServ__Gender__pc,
                    'Employment_type' => personAcc.EmploymentIndustry__c,
                    'Occupation' => personAcc.FinServ__Occupation__pc
            };    
            
        }catch(Exception e){
          LOGGER.error(e.getMessage(), new String[]{'INS_PLI_GetServicingRecords.getConnectedCustomerDetails', e.getMessage()},e);
			throw new AuraHandledException('Failed to get Connected Customer Details ' + e.getMessage());  
        }
        return JSON.serialize(personAccountDetails);
    }
    
    /**
     * @description Get tax details for the logged in user
     * @author Vershley Joyejob
     * @date 15-10-2025
     * @return List<TaxDetails__c> List of tax details for the user
     */
    @AuraEnabled(cacheable=true)
    public static List<TaxDetails__c> getTaxDetailsForLoggedInUser() {
        List<TaxDetails__c> taxList ;
        try{
            Id userId = UserInfo.getUserId();
            User currentUser = new SEL_User().selectUserById(userId);  
            
            if (currentUser.ContactId == null) {
                throw new AuraHandledException('No contact is associated with this user.');
            }
    
            taxList = new SEL_TaxDetails().selectByAccountIds(new Set<Id>{currentUser.Contact.AccountId});
    
            if (taxList.isEmpty()) {
                throw new AuraHandledException('No tax details found.');
            }
        }catch(Exception e){
          LOGGER.error(e.getMessage(), new String[]{'INS_PLI_GetServicingRecords.getTaxDetailsForLoggedInUser', e.getMessage()},e);
			throw new AuraHandledException('Failed to get Tax details for loggedin User ' + e.getMessage());  
        }
        return taxList;
    }

    @AuraEnabled(cacheable=true)
    public static List<PolicyWrapper> getPoliciesForUser() {       
        List<PolicyWrapper> result;
        try{
            Id userId = UserInfo.getUserId();
            User usr = new SEL_User().selectUserById(userId);
            
            result = new List<PolicyWrapper>();
            if (usr.Contact.AccountId == null) {
                PolicyWrapper errorWrapper = new PolicyWrapper();
                errorWrapper.errorMessage = 'No Account found for the logged-in user.';
                result.add(errorWrapper);
                return result;
            }
            List<InsurancePolicy> policies = new SEL_InsurancePolicy().selectByNameInsuredId(String.valueOf(usr.Contact.AccountId));   
            if (policies == null || policies.isEmpty()) {            
                PolicyWrapper errorWrapper = new PolicyWrapper();            
                errorWrapper.errorMessage = 'No Policies found for your account';
                result.add(errorWrapper);
                return result;
            }
            for (InsurancePolicy p : policies) {
                result.add(new PolicyWrapper(p.Id, p.Name, p.ProductId != null ? p.Product.Name : null, p.NameInsured.Name, p.TotalSumInsured, p.PremiumAmount));
            }
        }catch(Exception e){
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_GetServicingRecords.getPoliciesForUser', e.getMessage()},e);
			throw new AuraHandledException('Failed to get Policies for User' + e.getMessage()); 
        }
        return result;
    }

    /**
     * @description Get Insurance Products for Logged in User
     * @author Vic Wafula
     * @date 31-07-2026
     * @return List<PolicyWrapper> Policies for the user per product
     */

    @AuraEnabled(cacheable=true)
    public static List<PolicyWrapper> getPoliciesForUserByProductName(String productName) {
        List<PolicyWrapper> result;
        try{
            Id userId = UserInfo.getUserId();
            User usr = new SEL_User().selectUserById(userId);

            if (usr.Contact.AccountId == null) {
                //User not Found. Set result to Empty
                PolicyWrapper errorWrapper = new PolicyWrapper();
                errorWrapper.errorMessage = 'No Account found for your user';
                result.add(errorWrapper);
                return result;
            }
        
        List<InsurancePolicy> policies = new SEL_InsurancePolicy().selectPoliciesByNameInsuredAndProduct(productName,String.valueOf(usr.Contact.AccountId));
        for (InsurancePolicy p : policies) {
                result.add(new PolicyWrapper(p.Id, p.Name, p.ProductId != null ? p.Product.Name : null, p.NameInsured.Name, p.TotalSumInsured, p.PremiumAmount));
            }

        }catch(Exception e){
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_GetServicingRecords.getPoliciesForUserByProductName', e.getMessage()},e);
			throw new AuraHandledException('Failed to get Policies for User by Product Name' + e.getMessage()); 
        }
        return result;
        
    }

    
    public class PolicyWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String productName;
        @AuraEnabled public String name;
        @AuraEnabled public String owner;
        @AuraEnabled public String coverAmount;
        @AuraEnabled public String premium;
        @AuraEnabled public String errorMessage; 
        
		public PolicyWrapper() {} 
        
        public PolicyWrapper(String id, String name, String productName, String owner, Decimal coverAmount, Decimal premium) {
            this.id = id;
            this.productName = productName;
            this.name = name;
            this.owner = owner;
            this.coverAmount = (coverAmount != null) ? 'KES ' + String.valueOf(coverAmount) : '';
            this.premium = (premium != null) ? 'KES ' + String.valueOf(premium) + ' p.m' : '';
        }
    }

}