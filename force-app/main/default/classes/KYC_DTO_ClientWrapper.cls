/***************************************************************************************
@Name of the Class :KYC_DTO_ClientWrapper
@Description : SFP-38773 DTO Class request for KYC Process
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public with sharing class KYC_DTO_ClientWrapper {

    @InvocableVariable(label = 'Client Details')
    public KYC_DTO_ClientDetails clientDetails;

    @InvocableVariable(label = 'Checks')
    public Checks checks;

    public List<String> errorFields = new List<String> ();
    
    
    public class Checks {

        @InvocableVariable(label = 'ID Validation')
        public Boolean idValidation;
        
        
        @InvocableVariable(label = 'IDV')
        public Boolean idv;
        
        @InvocableVariable(label = 'RAAS')
        public Assessment assessment;    
    }

    public class Assessment {
        
        @InvocableVariable(label = 'PEP Screening')
        public Boolean PEP_Screening;

        
        @InvocableVariable(label = 'CRA')
        public Boolean CRA;

        @InvocableVariable(label = 'Screening')
        public Boolean screening;

    }

    public class Response  {
        @InvocableVariable(label = 'status')
        public string status;

        @InvocableVariable(label = 'message')
        public string message;

        @InvocableVariable(label = 'kycProfileId')
        public string kycProfileId;

        @InvocableVariable(label = 'responseCode')
        public Integer responseCode;

        @InvocableVariable(label = 'kycProfileId')
        public string url;
    }
    
    public Boolean checkForNullOrEmptyFields() {
        errorFields = new List<String>();
        
        if (clientDetails == null) {
            errorFields.add('Client Details is null');
            return !errorFields.isEmpty();
        } 
        checkClientDetailsFields(clientDetails);
        if (clientDetails?.addresses == null) {
            errorFields.add('Addresses is null');
            return !errorFields.isEmpty();
        }
        checkAddresses(clientDetails.addresses);

        if (checks == null) {
            errorFields.add('Checks is null');
            return !errorFields.isEmpty();
        }
        checkChecksFields(checks);
        
        return !errorFields.isEmpty();
    }
    private void checkClientDetailsFields(KYC_DTO_ClientDetails clientDetails) {
        checkField(clientDetails.title, 'Title');
        checkField(clientDetails.firstName, 'First Name');
        checkField(clientDetails.lastName, 'Last Name');
        checkField(clientDetails.gender, 'Gender');
        checkField(clientDetails.idNumber, 'ID Number');
        checkField(clientDetails.primaryPhone, 'Primary Phone');
        checkField(clientDetails.primaryEmail, 'Primary Email');
        checkField(clientDetails.countryOfCitizenship, 'Country of Citizenship');
        checkField(clientDetails.countryOfResidence, 'Country of Residence');
        checkField(clientDetails.passportIssuingCountry, 'Passport Issuing Country');
        checkField(clientDetails.employmentType, 'Employment Type');
        checkField(clientDetails.ficPipRelFirstName, 'FIC PIP REL FIRST NAME');
        checkField(clientDetails.ficPipRelLastName, 'FIC PIP REL LAST NAME');

        checkField(clientDetails.docAdd, 'Doc Add');
        checkField(clientDetails.ficPipRel, 'FIC PIP REL');

        checkField(clientDetails.idDocIssuingCountry, 'ID Document Issuing Country');
        checkField(clientDetails.idNumber, 'ID Number');
        checkField(clientDetails.primaryIdType, 'Primary ID Type');
        
        checkField(clientDetails.nationality, 'Nationality');
        checkField(clientDetails.dob, 'Date of Birth');
        checkField(clientDetails.occupationLevel, 'Occupation Level');
        checkField(clientDetails.cardNumber, 'Card Number');
    }

    private void checkAddresses(List<KYC_DTO_Address> addresses) {
        for (KYC_DTO_Address addr : addresses) {
            checkField(addr.type, 'Address Type');
            checkField(addr.street, 'Street');
            checkField(addr.city, 'City');
            checkField(addr.countryCode, 'Country Code');
            checkField(addr.postalCode, 'Postal Code');
        }
    }

    private void checkChecksFields(Checks checks) {
        if (checks.idValidation == false && checks.idv == false) {
            errorFields.add('None of the checks are selected, aborting KYC process.');
        } else {
            checkField(checks.idValidation, 'ID Validation');
            checkField(checks.idv, 'IDV');

            if (checks.assessment == null) {
                errorFields.add('Assessment is null');
            } else {
                checkField(checks.assessment.PEP_Screening, 'PEP Screening');
                checkField(checks.assessment.CRA, 'CRA');
                checkField(checks.assessment.screening, 'Screening');
            }
        }
    }


    private void checkField(Object fieldValue, String fieldName) {
        if (fieldValue == null || (fieldValue instanceof String && String.isBlank((String)fieldValue))) {
            errorFields.add(fieldName);
        }
    }
}