/***************************************************************************************
@Name of the Class :INS_SearchEmployee_RemoteAction
@Description : SFP-40754 Class used for calling RAAS API for screening Customer Profile.	
@Author :Irshad 
@Created Date :06/03/2026
****************************************************************************************/
global with sharing class INS_SearchEmployee_RemoteAction implements Callable{
    private static final String ACCOUNT_NAME = 'External Referrer IAM AR Generic Account';
    private static final String CLIENT_CONTACT_RT_DEV_NAME = 'Client Contact';

	global Object call(String actionType, Map<String, Object> args) {

        if (actionType == 'SearchEmployee') {
			Map<String, Object> input = (Map<String, Object>)args.get('input');                        	
			Map<String, Object> output = (Map<String, Object>)args.get('output');
            return SearchEmployee(input,output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

/**
 * @description : Search Employee
 * @return object containing either userId or contactId based on the search result
 * @author Irshad | 06-03-2026
 */   
    @AuraEnabled(cacheable=false)
	public Static Object SearchEmployee(Map<String, Object> input, Map<String, Object> output){		
        String email = (String) input.get('Email');
		// Search user 
		List<User> users = new SEL_User().selectByUserEmail(email);		
		if(users != null && !users.isEmpty()){
			User user = users[0];
			output.put('assistedUserId', user.Id);
			return output;
		}else{
            // Search Account
            Id accountId = [Select Id, Name From Account Where Name =: ACCOUNT_NAME Limit 1].Id;
            Id contactId = SearchContactByEmail(email, accountId);
            if(contactId != null){
                output.put('assistedContactId', contactId);
                return output;
            }else{
                // build contact
                Contact contact = buildContact(input, accountId);
                insert contact;
                output.put('assistedContactId', contact.Id);
                return output;
            }
                  
        }

	} 

 /**
 * @description : Search for contact with matching emailId in a specific Account   *
 * @return ContactId or null if not found
 * @author Irshad | 06-03-2026
 */
    public static Id SearchContactByEmail(String email, Id accountId){
        
        // Search for contact..
        Id contactId = [Select Id,
                                Email,
                                AccountId
                            FROM Contact
                            WHERE Email=: email
                            AND AccountId =: accountId
                            LIMIT 1].Id;
        return contactId;
    }

/**
 * @description : Create Contact
 * @return Contact or null if not found
 * @author Irshad | 06-03-2026
 */

    public static Contact buildContact(Map<String, Object> input, Id accountId){
        String contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CLIENT_CONTACT_RT_DEV_NAME).getRecordTypeId();
        // Create Contact
        Contact contact = new Contact();
        contact.Email = (String) input.get('Email');
        contact.FirstName = (String) input.get('FirstName') != null? (String) input.get('FirstName') : '';
        contact.LastName = (String) input.get('LastName');
        contact.AccountId = accountId;
        contact.MobilePhone = (String) input.get('MobilePhone') != null? (String) input.get('MobilePhone') : '';
        contact.recordTypeId = contactRecordType;
        return contact;
    }

   

}