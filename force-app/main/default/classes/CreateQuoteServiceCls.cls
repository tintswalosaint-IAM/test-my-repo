/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : CreateQuoteServiceCls
 * Author          : <YourName>
 * Created Date    : Feb 12, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Feb 12, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Feb 12, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class CreateQuoteServiceCls {

	@AuraEnabled(cacheable=true)
	public static void call(String payloadJson) {
		String accessToken = KYC_SRV_GenerateAccessToken.getAccessToken(); 
		HttpRequest request = new HttpRequest();
       // request.setEndpoint('https://api-lb-test.liberty.co.za/dev-sbg-exp-insurance-lifequote-legacy-api/api/quotes');
        request.setEndpoint('callout:KYC_MulesoftConnect_NC'+'/dev-sbg-exp-insurance-lifequote-legacy-api/api/quotes');
        //request.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes');
        request.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_AUTHORIZATION, 'Bearer ' + accessToken);
        request.setHeader('country_code','KE');// KE or UG TBC to use custom me
        request.setHeader('transaction_id',UUID.randomUUID().toString());
        request.setHeader('client_id', '{!$Credential.KYC_MulesoftConnect_ENC.Kyc_client_id}');
        request.setHeader('org_client_id', 'Dev_Testing');
        request.setHeader('channel','Salesforce');
        request.setTimeout(120000);
        request.setMethod(INS_Quote_Helper.HTTP_METHOD_POST);
        request.setBody(payloadJson);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('response=='+response.getBody());
	}

}