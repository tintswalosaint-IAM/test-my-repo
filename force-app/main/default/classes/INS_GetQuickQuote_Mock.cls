/**
* @description  : Mock Test Class for INS_Create_Quick_Quote_Test, generating fake responses
* @Jira ticket	: SFP-50909
* @author       : Madito Tsilo
* @date         : October 2025
*/
@IsTest
global class INS_GetQuickQuote_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);

        // Return JSON exactly like the real API
        res.setBody('{' +
            '"quoteHeader": {' +
                '"totalPremium": 1000,' +
                '"quoteId": "Q123",' +
                '"quoteNumber": "QN-001"' +
            '},' +
            '"beneficiaries": [' +
                '{' +
                    '"beneficiaryId": "003000000000001AAA",' +
                    '"firstName": "John",' +
                    '"surname": "Doe",' +
                    '"gender": "Male",' +
                    '"relationship": "Spouse",' +
                    '"allocationAmount": 60,' +
                    '"dateOfBirth": "1985-05-01"' +
                '},' +
                '{' +
                    '"beneficiaryId": "003000000000001AQA",' +
                    '"firstName": "Anna",' +
                    '"surname": "Doe",' +
                    '"gender": "Female",' +
                    '"relationship": "Child",' +
                    '"allocationAmount": 40,' +
                    '"dateOfBirth": "2010-02-10"' +
                '}' +
            '],' +
            '"persons": [],' +
            '"members": []' +
        '}');

        return res;
    }
}