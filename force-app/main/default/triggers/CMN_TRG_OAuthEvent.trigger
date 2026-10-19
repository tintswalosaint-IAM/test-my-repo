/**
 * @description Oauth trigger for oauth events
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_TRH_OAuthEvent
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date November 2020
 */
trigger CMN_TRG_OAuthEvent on CMN_OAuthEvent__e (after insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_OAuthEvent.class);
}