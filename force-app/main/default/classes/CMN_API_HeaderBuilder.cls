public class CMN_API_HeaderBuilder {
    private Map<String, String> headers;
    private String namedCredentialName;

    /**
     * Default Constructor - Drops back to 'INS_Insurance_Leads'
     */
    public CMN_API_HeaderBuilder() {
        this('INS_Insurance_Leads');
    }

    /**
     * Dynamic Constructor - Allows future services to pass their own Named Credential Name
     * Example: new CMN_API_HeaderBuilder('AWS_Named_Credential')
     */
    public CMN_API_HeaderBuilder(String customNamedCredentialName) {
        this.headers = new Map<String, String>();
        this.namedCredentialName = String.isNotBlank(customNamedCredentialName) ? customNamedCredentialName : 'INS_Insurance_Leads';

        // 1. Standard Content Headers
        this.headers.put('Content-Type', 'application/json');
        this.headers.put('Accept', 'application/json');

        // 2. Dynamic Certificate Concatenation based on passed Named Credential
        String clientCertificate = '{!$Credential.' + this.namedCredentialName + '.XClientCertificate1}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate2}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate3}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate4}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate5}';

        this.headers.put('x-client-certificate', clientCertificate);

        // 3. Dynamic Environment & Auth Headers
        this.headers.put('x-env-key', '{!$Credential.' + this.namedCredentialName + '.xenvkey}');
        this.headers.put('X-IBM-Client-Id', '{!$Credential.' + this.namedCredentialName + '.clientId}');
        this.headers.put('X-IBM-Client-Secret', '{!$Credential.' + this.namedCredentialName + '.clientSecret}');
        this.headers.put('cifCountry', '{!$Credential.' + this.namedCredentialName + '.cifCountry}');
        this.headers.put('channelName', '{!$Credential.' + this.namedCredentialName + '.channelName}');
    }

    /**
     * Dynamic Channel ID
     */
    public CMN_API_HeaderBuilder setChannelId(String channelId) {
        if(String.isNotBlank(channelId)) {
            this.headers.put('channelId', channelId);
        }
        return this;
    }

    /**
     * Set/Override any generic header manually
     */
    public CMN_API_HeaderBuilder setHeader(String key, String value) {
        if(String.isNotBlank(key) && String.isNotBlank(value)) {
            this.headers.put(key, value);
        }
        return this;
    }

    public Map<String, String> build() {
        return this.headers;
    }
}