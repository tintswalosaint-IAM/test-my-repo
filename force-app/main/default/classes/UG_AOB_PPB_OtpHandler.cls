/**
 * @description       : 
 * @author            : jagadish Thummala
 * @group             : 
 * @last modified on  : 10-24-2025
 * @last modified by  : jagadish Thummala
**/

public without sharing class UG_AOB_PPB_OtpHandler {
    private UG_AOB_PPB_OtpHandler() {}   
    /** 
    * @description This method used to generate OTP
    * @param leadList
    * @return Returns a OTP response in map format for remaining processing
    */
    public static String verifyEmail(List<Lead> leadList){     

        if(leadList != null && leadList.isEmpty() == false) {
			// Fetch the Address for the Org-Wide Email Address from Custom Metadata
			PPB_Static_values__mdt emailConfig = [
				SELECT Value__c
				FROM PPB_Static_values__mdt
				WHERE DeveloperName = 'Stanbic_Customer_Care_Email'
				LIMIT 1 
			];

			String customerCareEmail = emailConfig.Value__c;
            String randomIntegerString = string.valueof(Math.abs(Crypto.getRandomInteger()));
            String emailOTP = randomIntegerString.substring(0,4);                
            Messaging.SingleEmailMessage emailAlert = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[]{ leadList[0].Email};
            emailAlert.SetToAddresses(toAddress);
            emailAlert.setTargetObjectId(leadList[0].Id);
            emailAlert.setSubject('Hi '+ leadList[0].LastName +', Please verify your identity in Standard Bank');
    
            String emailContent = 'Dear '+ leadList[0].LastName + ' , <br/><br/>'
                + 'Use the ' + emailOTP +' OTP to complete your Sign Up procedure. OTP is valid for 1 minute<br/><br/>'
                + '<br/><br/> *** This is a System-Generated Email. Please Do Not Reply. <br/><br/>'
                + 'Please contact on the below address, if any queries. <br/><br/> '
                + 'Thanks & Regards, <br/> Credit Card Department, <br/> Standard  Bank,<br/>	Email us: informationn@standardbank.co.za';
        
            emailAlert.setHtmlBody(emailContent);  
            List<OrgWideEmailAddress> emailAddressList = [SELECT Id, IsAllowAllProfiles FROM OrgWideEmailAddress 
                WHERE Address = :customerCareEmail LIMIT 1
            ];
            if(emailAddressList.isEmpty() == false) {
                emailAlert.setOrgWideEmailAddressId(emailAddressList[0].Id);
            } else {
                emailAlert.setSenderDisplayName('Stanbic Bank Support');
            }
            Messaging.SendEmail(new Messaging.SingleEmailMessage[]{emailAlert});
            return JSON.serialize(new Map<String, String>{'emailOTP' => emailOTP});
        }
        return null;
    }
    
    /** 
    * @description Method to generate an OTP using crypto class generation
    */
    public static String generateOtpForPhone(){
		String randomIntegerStringPhone = string.valueof(Math.abs(Crypto.getRandomInteger()));
        return randomIntegerStringPhone.substring(0,4);
    }
}