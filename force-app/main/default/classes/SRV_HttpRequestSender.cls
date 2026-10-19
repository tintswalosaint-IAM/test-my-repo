/**
 * @author Michal Lipinski
 * @description Service class for sending HTTPRequests. Provides retry mechanism that can be used when timeout is exeeded. ORG_Application is used. Can be mocked with fflib_ApexMocks
 *
 * TESTED IN PbbSmart2ConversionalPicklistDel_Test
*/
public class SRV_HttpRequestSender implements IService {

	@TestVisible
	private Boolean throwException = false;
	/**
	 * @description Service interface for sending HTTPRequests. Provides retry mechanism that can be used when timeout is exeeded. 
	 */
	public interface IService {
		/**
		 * @description Sends many HTTPRequests. If exception occured durring the call (timeout etc), request will be resend.
		 * @param request HttpRequest to be send
		 * @param retryCounter No of retries if exception occured
		 * @return HttpResponse object
		 */
		HttpResponse send(HttpRequest request, Integer retryCounter);
	}
	/**
	 * @description Sends many HTTPRequests. If exception occured durring the call (timeout etc), request will be resend.
	 * @param request HttpRequest to be send
	 * @param retryOnTimeOut No of retries if exception occured
	 * @return HttpResponse object
	 */
	public HttpResponse send(HttpRequest request, Integer retryOnTimeOut) {
		return sendRequest(request, retryOnTimeOut);
	}

	@TestVisible
	private HttpResponse sendRequest(HttpRequest req, Integer tries) {
		Http httpObj = new Http();
		HttpResponse res;
		Exception savedException;
		Boolean isSuccess = false;
		while (tries > 0) {
			try {
				if (Test.isRunningTest() && throwException) {
					throw new CalloutException('test exception');
				}
				res = httpObj.send(req);
				isSuccess = true;
				break;
			} catch(System.CalloutException ex) {
                savedException = ex;
				tries--;
			}
		}
		if (!isSuccess) {
			CMN_UTIL_Logger.error(savedException, 'SRV_HttpRequestSender.sendRequest');
		}
		return res;
	}
}