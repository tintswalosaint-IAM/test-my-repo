public without sharing class INS_API_CIF_Customer {
   /**
     * @description Fetches customer details from the external CIF API
     * @param customerName The name of the customer to search for
     * @param customerNumber The unique customer identification number
     * @return String The JSON response body or an error message
     */
    public static String getCustomerDetails(String customerName, String customerNumber) {
        
        // 2. Build the Path and Query Parameters
        String encodedName = EncodingUtil.urlEncode(customerName, 'UTF-8');
        String pathWithParams = '/sit/sit/legal-entity-api/customer' 
                              + '?customerNumber=' + customerNumber ;
                             // + '&customerNumber=' + customerNumber;

        // 3. Initialize the Request using the Named Credential
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CIF_Customer' + pathWithParams);
        req.setMethod('GET');

        // 4. Set Headers
        req.setHeader('X-IBM-Client-Id', '{!$Credential.CIF_Customer_EndPoint.client_id}');
        req.setHeader('X-IBM-Client-Secret', '{!$Credential.CIF_Customer_EndPoint.client_secret}');
        req.setHeader('accept', 'application/json');

        // 5. Send the Request
        Http http = new Http();
        try {
            system.debug ('Send request : ' + req);
            HTTPResponse res = http.send(req);
            
            System.debug('Status Code: ' + res.getStatusCode());
            
            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                System.debug('HTTP Error: ' + res.getStatus() + ' - ' + res.getBody());
                return 'Error: ' + res.getStatusCode() + ' ' + res.getStatus();
            }
        } catch (Exception e) {
            System.debug('Callout Exception: ' + e.getMessage());
            throw new CalloutException('Failed to connect to Customer API: ' + e.getMessage());
        }
    }
}