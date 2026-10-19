/**
 * @description This class is use to match user record when logging using ping identity.
 * Currently no staff user provisioning or updates supported - used only to link staff to the ping AD user account
 * <p/>
 * <p>VCCC-63</p>
 *
 * @author Accenture
 *
 * @date October 2020
 */
global inherited sharing class CMN_AUTH_PingStaffHandler implements Auth.RegistrationHandler
{
	private static final String ERROR_NO_FEDERATION_ID_PROVIDED = 'No FederationIdentifier was received';
	private static final String ERROR_NO_USER_FOUND = 'No user was found for FederationIdentifier "{0}".';

	/**
	 * @description Returns a User object using the specified portal Id and user information from ping,
	 * such as the username and email address.
	 * <p/>
	 * The User object corresponds to ping staff (AD) user information and for the staff use case may not be a new user.
	 *
	 * @param portalId The portalId value may be null or an empty key if there is no portal configured with this provider.
	 * @param userData user data returned from the oauth provider idp (Ping staff)
	 *
	 * @return user if found
	 */
	global User createUser(Id portalId, Auth.UserData userData)
	{
		try
		{
			// the sfdc auth framework will handle error if exception of if no user is found
			if(String.isBlank(userData.email))
			{
				throw new IllegalArgumentException(ERROR_NO_FEDERATION_ID_PROVIDED);
			}

			User foundUser = CMN_DAL_User.findUserByFederationId(userData.email);

			if(foundUser == null)
			{
				throw new SearchException(
						String.format(ERROR_NO_USER_FOUND, new List<String> {userData.email})
				);
			}

			/* identifier field is used to store the employee number returned from ping */
			checkUpdateStaffEmployeeNumber(foundUser, userData.identifier);

			return foundUser;
		}
		catch(Exception e)
		{
			CMN_UTIL_Logger.error(e, 'CMN_AUTH_PingStaffHandler.createUser');
			throw e;
		}
	}

	/**
	 * @description Updates the specified user’s information.
	 * This method is called if the user has logged in before with the authorization provider and then logs in again.
	 * Only employee staff employee number information is updated from ping - ping is used for AuthN and AuthZ.
	 * Employee number is required for some external gateway API calls.
	 *
	 * @param userId as input
	 * @param portalId as input
	 * @param userData as input
	 */
	global void updateUser(Id userId, Id portalId, Auth.UserData userData)
	{
		checkUpdateStaffEmployeeNumber(
				CMN_DAL_User.findByUserId(userId),
				userData.identifier
		);
	}

	/**
	 * @description check if staff user does not have c-number populated correctly and update if ping provides the
	 * c-number
	 *
	 * @param staffUser as input
	 * @param employeeNumber as input
	 */
	private void checkUpdateStaffEmployeeNumber(
			User staffUser,
			String employeeNumber
	)
	{
		if(
				String.isNotBlank(employeeNumber) &&
						!employeeNumber.equalsIgnoreCase(staffUser?.EmployeeNumber)
				)
		{
			staffUser.EmployeeNumber = employeeNumber;
			update staffUser;
		}
	}
}