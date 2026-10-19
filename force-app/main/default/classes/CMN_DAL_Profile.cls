/**
 * @description Provides Queries related to Profile object
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_Profile {
  public static final String PROFILE_SYSTEM_ADMIN = 'System Administrator';
  public static final String PROFILE_STANDARD_USER = 'Standard User';
  public static final String PROFILE_READ_ONLY = 'Read Only';
  public static final String PROFILE_CHATTER_FREE_USER = 'Chatter Free User';
  public static final String PROFILE_BANKER_USER = 'SVC Agent Banker';
  public static final String PROFILE_INVESTMENT_MANAGER = 'Investment Manager';
  public static final String OBJECT_NAME = Profile.SObjectType.getDescribe()
    .getLocalName();

  /**
   * @description Method to return the profile name
   *
   * @param profileName name of the profile
   *
   * @return profiles
   */
  public static Profile findByName(String profileName) {
    List<Profile> profiles = [
      SELECT
        Description,
        Id,
        LastModifiedDate,
        LastReferencedDate,
        LastViewedDate,
        Name,
        UserLicenseId,
        UserType
      FROM Profile
      WHERE Name = :profileName
    ];

    return profiles.isEmpty() ? null : profiles[0];
  }
}