public class CustomerCalloutService {

    /**
     * @description Fetches customer details from the external CIF API
     * @param customerName The name of the customer to search for
     * @param customerNumber The unique customer identification number
     * @return String The JSON response body or an error message
     */
    public static String getCustomerDetails(String customerName, String customerNumber) {
        // 1. Configuration (Consider moving these to Custom Metadata or Named Credential)
        String clientId = '9eb72383f0657f9abce121ec7e4067b2';
        String clientSecret = '93b2350ec32ba839478a4987e770b87f';
        
        // 2. Build the Path and Query Parameters
        String encodedName = EncodingUtil.urlEncode(customerName, 'UTF-8');
        String pathWithParams = '/sit/sit/legal-entity-api/customer' 
                              + '?customerName=' + encodedName 
                              + '&customerNumber=' + customerNumber;

        // 3. Initialize the Request using the Named Credential
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CIF_Customer_API' + pathWithParams);
        req.setMethod('GET');

        // 4. Set Headers
        req.setHeader('X-IBM-Client-Id', clientId);
        req.setHeader('X-IBM-Client-Secret', clientSecret);
        req.setHeader('accept', 'application/json');

        // 5. Send the Request
        Http http = new Http();
        try {
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