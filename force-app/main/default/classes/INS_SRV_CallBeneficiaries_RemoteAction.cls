/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : INS_SRV_CallBeneficiaries_RemoteAction
 * Author          : <YourName>
 * Created Date    : Apr 17, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Apr 17, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Apr 17, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

global with sharing class INS_SRV_CallBeneficiaries_RemoteAction implements Callable{

	global Object call(String actionType, Map<String, Object> args) {
        if (actionType == 'CallBeneficiaries') {
            Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return CallBeneficiaries(input, output);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

	@AuraEnabled(cacheable=false)
	public static Object CallBeneficiaries(Map<String, Object> input,Map<String, Object> output){
		String quoteId = (String) input.get('quoteId');		
		String verb = 'POST';
		String payloadJson = buildBeneficiaryPayload(quoteId, input);
		Boolean isAddBeneficiary = true;

		// Make API callout
		INS_SRV_QuickQuote_Beneficiaries service = new INS_SRV_QuickQuote_Beneficiaries(
			payloadJson, quoteId, isAddBeneficiary
		);
		CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
			INS_SRV_QuickQuote_Beneficiaries.SERVICE_NAME
		);
		service.process(obj);
		insert obj;

		Integer statusCode  = service.getResponseStatusCode();
		String responseBody = service.getResponseBody();
		output.put('BeneficiarySummary',processResponse(statusCode, responseBody));
		return output;

		 
		

	}


	private static Object processResponse(Integer statusCode, String responseBody) {

		if (statusCode == 200 || statusCode == 201) {
			try {
				Map<String, Object> responseMap =
					(Map<String, Object>) JSON.deserializeUntyped(responseBody);

				List<Object> beneficiaries =
					(List<Object>) responseMap.get('beneficiaries');

				String referenceNumber =
					(String) responseMap.get('referenceNumber');

				if (beneficiaries != null && !beneficiaries.isEmpty()) {

					List<Object> beneficiaryIdsList = new List<Object>();
					Boolean hasError = false;

					for (Object obj : beneficiaries) {
						Map<String, Object> ben = (Map<String, Object>) obj;
						String beneficiaryId = (String) ben.get('beneficiaryId');
						

						if (String.isNotBlank(beneficiaryId)) {
							beneficiaryIdsList.add(new Map<String, Object>{
								'beneficiaryId' => beneficiaryId
								
							});
						} else {
							hasError = true;
						}
					}

					if (!beneficiaryIdsList.isEmpty()) {
						return new Map<String, Object>{
							'hasError'        => hasError,
							'beneficiaries'   => beneficiaryIdsList,
							'referenceNumber' => referenceNumber
						};
					}

					return new Map<String, Object>{
						'hasError' => true,
						'error'    => 'No beneficiaryId returned for any beneficiary'
					};
				}

				return new Map<String, Object>{
					'hasError' => true,
					'error'    => 'No beneficiaries returned in API response'
				};

			} catch (Exception ex) {
				return new Map<String, Object>{
					'hasError' => true,
					'error'    => 'Failed to parse API response: ' + ex.getMessage()
				};
			}
		}

		return new Map<String, Object>{
			'hasError' => true,
			'error'    => 'API error ' + statusCode + ': ' + responseBody
		};
	}

	@TestVisible
	private static String buildBeneficiaryPayload(String quoteId, Map<String, Object> input) {

		BeneficiarySummary request = new BeneficiarySummary();
		request.referenceNumber = quoteId;
		request.beneficiaries = new List<Beneficiary>();

		//  Extract BeneficiarySummary node
		Map<String, Object> benSummary = (Map<String, Object>) input.get('BeneficiarySummary');
		if (benSummary == null) {
			return JSON.serialize(request);
		}

		List<Object> members = (List<Object>) benSummary.get('members');
		if (members == null || members.isEmpty()) {
			return JSON.serialize(request);
		}

		for (Object obj : members) {
			Map<String, Object> member = (Map<String, Object>) obj;

			Beneficiary ben = new Beneficiary();

			// Basic Info
			String firstName = (String) member.get('FirstName__c');
			String lastName  = (String) member.get('LastName__c');
			
			ben.firstName  = firstName;
			ben.surname    = lastName;
            ben.initials   = (String.isNotBlank(firstName) ? firstName.substring(0, 1).toUpperCase() : '') + 
                (String.isNotBlank(lastName)    ? lastName.substring(0, 1).toUpperCase()   : '');
        	ben.title            = (String) member.get('title');
			ben.relationship   = (String) member.get('RelationshipToInsured');
			ben.identityNumber = (String) member.get('IdentityNumber__c');
			ben.identityType   = (String) member.get('IdType__c');
			ben.gender         = (String) member.get('Gender__c');
            ben.idCountryOfIssue = 'KE';
			// Beneficiary ID (for Edit vs Add)
			ben.beneficiaryId = (String) member.get('beneficiaryId');

			// MemberId → PersonId mapping (if needed)
			ben.personId = (String) member.get('memberId');

			// Initials
			ben.initials =
				(String.isNotBlank(firstName) ? firstName.substring(0, 1).toUpperCase() : '') +
				(String.isNotBlank(lastName)  ? lastName.substring(0, 1).toUpperCase()  : '');

			// Static / configurable
			ben.benefitId      = '11.Extended Family Benefit';
			ben.allocationType = 'PERCENTAGE';

			// Allocation
			Object allocationObj = member.get('Allocation__c');
			ben.allocationAmount = allocationObj != null
				? Integer.valueOf(String.valueOf(allocationObj))
				: 0;

			//  Date of Birth
			String dobStr = (String) member.get('BirthDate__c');
			if (String.isNotBlank(dobStr)) {
				String cleanDate = dobStr.contains('T') ? dobStr.substringBefore('T') : dobStr;
				ben.dateOfBirth = DateTime.newInstance(
					Date.valueOf(cleanDate),
					Time.newInstance(0, 0, 0, 0)
				);
			}

			// Contacts
			ben.contacts = new List<contacts>();

			String email = (String) member.get('EmailAddress__c');
			if (String.isNotBlank(email)) {
				contacts emailContact = new contacts();
				emailContact.contactType = 'EMAIL';
				emailContact.text = email;
				ben.contacts.add(emailContact);
			}

			String phone = (String) member.get('PhoneNumber__c');
			if (String.isNotBlank(phone)) {
				contacts phoneContact = new contacts();
				phoneContact.contactType = 'MOBILE';
				phoneContact.text = phone;
				ben.contacts.add(phoneContact);
			}

			// Add to request list
			request.beneficiaries.add(ben);
		}

		return JSON.serialize(request);
	}


	// ========================================
    // WRAPPER CLASSES
    // ========================================

    public class BeneficiarySummary {
        public String            referenceNumber;
        public List<Beneficiary> beneficiaries;
    }

    public class Beneficiary {
        public String         title;
        public String         surname;
        public String         relationship;
        public String         personId;
        public String         initials;
        public String         identityType;
        public String         identityNumber;
        public String         idCountryOfIssue;
        public String         gender;
        public String         firstName;
        public Datetime       dateOfBirth;
        public String         benefitId;
        public String         beneficiaryId;
        public String         allocationType;
        public Integer        allocationAmount;
        public List<contacts> contacts;
    }

    public class contacts {
        public String text;
        public String contactType;
    }

}