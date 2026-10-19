/**
* @description Class for Otp handling from main flow screen mobile and Email including Resend
*
* Story:SFP-12449
*
* @author Vamshi Krishna (vamshi.marripelly@standardbank.co.za)
*
* @date June 2022
*/


public without sharing class AOB_OtpHandler {
   
    private static final String DISPLAY_NAME = 'Stanbic Customer Care';
    
    /** 
    * @description This method used to generate OTP
    * @param leadList
    * @return Returns a OTP response in map format for remaining processing
    */
    public static String verifyEmail(List<Lead> leadList){     

        if(leadList != null && leadList.isEmpty() == false) {

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
                WHERE DisplayName = :DISPLAY_NAME 
                ORDER BY LastModifiedDate DESC
                LIMIT 1
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
        String otpForPhone = randomIntegerStringPhone.substring(0,4);
        return otpForPhone;
    }
}