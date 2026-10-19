/**
 * @description Test class for SVC_API_SetSoftBlock
 *
 * @see SVC_API_SetSoftBlock
 *
 * @author Accenture
 *
 * @date January 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
private class SVC_API_SetSoftBlock_TEST
{
	/**
	 * @description Emulates a successful call
	 *
	 * @see SVC_API_SoftBlockBase.DTO_Request.populate
	 */
	@IsTest
	private static void successfulCall()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(SVC_API_SetSoftBlock.SERVICE_NAME, null, SVC_API_SoftBlockBase.REQUIRED_PARAMETERS);
	}

	/**
	 * @description Checks that the call is aborted because required parameters were not provided
	 *
	 * @see SVC_API_SoftBlockBase.getRequiredParameters
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_SetSoftBlock.SERVICE_NAME, null);
	}
}