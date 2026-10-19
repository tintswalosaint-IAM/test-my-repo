/**
 * @description Test class for CMN_API_SoapOutboundExample
 *
 * @see CMN_API_SoapOutboundExample
 *
 * @author Accenture
 *
 * @date Apr 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_API_SoapOutboundExample_TEST
{
	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfull()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				CMN_API_SoapOutboundExample.PARAMETER_UBI_NUM => CMN_DAL_SObjectDomain.generateRandomNumber()

		};

		CMN_API_SoapOutboundExample hander = (CMN_API_SoapOutboundExample)CMN_API_RestBaseOutboundTestHelper.successfulCall(CMN_API_SoapOutboundExample.SERVICE_NAME, null, parameters);
		CMN_API_SoapOutboundExample.DTO_Response dtoResponse = (CMN_API_SoapOutboundExample.DTO_Response)hander.baseResponseDTO;

		System.assertEquals(true, String.isNotBlank(dtoResponse.NumberToWordsResult), 'Response not parsed correctly');
	}

	/**
	 * @description Checks that the call is aborted because required parameters were not provided
	 *
	 * @see CMN_API_SoapOutboundExample.getRequiredParameters
	 */
	@IsTest
	private static void abortedCallNoParameter()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(CMN_API_SoapOutboundExample.SERVICE_NAME, null);
	}
}