/**
 * @author Michal Lipinski
 * @description Gateway service class that provides authentication in Gateway IBM ( STANDARD BANK SOUTH AFRICA SYSTEM AUTHORISATION SERVER 2.0.0) https://developernp.standardbank.co.za/node/33784
 *				Provides HttpRequest object that can be used to call Gateway IBM endpoints
*/
public without sharing class PBB_SRV_GatewayRequestProvider implements IService {
	@TestVisible
	private static final String CERTICATE_NAME = 'Gateway'; 
	@TestVisible
	private static final String PARTITION_TOKENS = 'Tokens';
	@TestVisible
	private static final String PARTITION_TOKEN_NAME = 'gwnp';
	@TestVisible
	private static final String SCOPE = 'accounts prod write retail customer';

	/**
	 * @author Michal Lipinski
	 * @description Gateway service class that provides authentication in Gateway IBM ( STANDARD BANK SOUTH AFRICA SYSTEM AUTHORISATION SERVER 2.0.0) https://developernp.standardbank.co.za/node/33784
	 *				Provides HttpRequest object that can be used to call Gateway IBM endpoints
	 */
	public interface IService {
		/**
		 * @description Provides HttpRequest that contain Bearer oauth Token, unique transaction Id and certficate
		 * @return HttpRequest object with requeired by IBM Gateway headers. <br/>  x-client-certificate, x-fapi-interaction-id, authorization are filled in header
		 */
		HttpRequest getRequestWithToken();
	}

	/**
	 * @description Provides HttpRequest that contain Bearer oauth Token, unique transaction Id and certficate
	 * @return HttpRequest object with requeired by IBM Gateway headers. <br/>  x-client-certificate, x-fapi-interaction-id, authorization are filled in header
	 */
	public HttpRequest getRequestWithToken() {
		HttpRequest req = new HttpRequest();
		req.setHeader('x-client-certificate', certificate);
		req.setHeader('x-fapi-interaction-id', CMN_API_GetConversations.createGUID());
		req.setHeader('authorization', 'Bearer ' + getToken());
		return req;
	}

	private static final String certificate {
		private Set;
		get {
			if (certificate == null) {
				certificate = [SELECT Id, AOB_Body__c FROM AOB_Certificate__mdt where DeveloperName = :CERTICATE_NAME].AOB_Body__c;
			}
			return certificate;
		}
	}

	private String getToken() {
		Cache.OrgPartition orgPart = Cache.Org.getPartition(PARTITION_TOKENS);
		String token = (String) orgPart.get(PARTITION_TOKEN_NAME);
		if (token == null) {
			CMN_DTO_AuthenticationResponse newToken = authenticate();
			if (newToken == null) {
				throw new AuthException('Authentication is temporary unavailable');
			}
			orgPart.put(PARTITION_TOKEN_NAME, newToken.access_token, Integer.valueOf(newToken.expires_in) - 60, cache.Visibility.NAMESPACE, false);
			token = (String) orgPart.get(PARTITION_TOKEN_NAME);
		}
		return token;
	}
	private CMN_DTO_AuthenticationResponse authenticate() {
		return CMN_API_GetAccessToken.getAccessToken('customer prod retail');
	}

	/**
	 * @description Exception class for Auth errors
	 */
	public class AuthException extends Exception { }
}