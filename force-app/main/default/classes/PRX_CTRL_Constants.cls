/**
* @description       : SFP-31923, SFP-27425 - Class for static constants used during the PERX project
* @author            : mamidalar@stanbic.com
 * @ Name of the Class : PRX_CTRL_Constants
 * @ Last Modified By  : mamidalar@stanbic.com
 * @ Last Modified On  : 07-06-2024
 * @ Jira Description : SFP-31923, SFP-27425
* ---------------------------------------------------------------------------
*      version             Date            Developer        Description
* ---------------------------------------------------------------------------
  1.0   17-08-2023   mamidalar@stanbic.com   Initial Version
  1.A   07-03-2024   mamidalar@stanbic.com   Description, jira number and API version updated
  1.B    Feb 2026     jyothsna.datla@standardbank.co.za        Updated constants for CMN_FHQ_SRV_RetirementCalculation_Test class(PPBSF-179)
**/
public class PRX_CTRL_Constants {
     public String productInfo;
    /** @description Constant for Financial Health Quiz Queries. */
    public static final String PRXAPIFHQ ='PRX_API_FHQ';
    /*** @description Constant for PRX_Domain_Info. */
    public static final String PRXDOMAININFO ='PRX_Domain_Info';
      /*** @description Constant for UPCOMING. */
     public static final String UPCOMING = 'Upcoming';
       /*** @description Constant for LEAD_ID. */
       public static final String LEAD_ID = 'leadId';
         /*** @description Constant for STREET. */
        public static final String STREET = 'street';
          /*** @description Constant for CITY. */
        public static final String CITY = 'city';
          /*** @description Constant for PROVINCE. */
        public static final String PROVINCE = 'province';
          /*** @description Constant for POSTAL_CODE. */
        public static final String POSTAL_CODE = 'postalCode';
          /*** @description Constant for COUNTRY. */
        public static final String COUNTRY = 'country';
          /*** @description Constant for EMAIL. */
        public static final String EMAIL = 'email';
          /*** @description Constant for PHONE. */
        public static final String PHONE = 'phone';
          /*** @description Constant for APPOINTMENT_TYPE. */
        public static final String APPOINTMENT_TYPE = 'appointmentType';
          /*** @description Constant for QUERY. */
        public static final String QUERY = 'query';
           /*** @description Constant for STATUS_UPCOMING.*/
    public static final String STATUS_UPCOMING = 'Upcoming';
    /*** @description Constant for TIME_ZONE_SOUTH_AFRICA.*/
    public static final String TIME_ZONE_SOUTH_AFRICA = 'Africa/Johannesburg';
    /*** @description Constant for OFFSET_MINUTES. */
    public static final Integer OFFSET_MINUTES = -120;
    /*** @description Constant for DURATION_MINUTES. */
    public static final Integer DURATION_MINUTES = 30;
     public static final String SCHED_START_TIME = 'schedStartTime';
    public static final String ACTION_CANCELLED = 'cancelled';
    public static final String ACTION_CAPTURE_NOTES = 'captureNotes';
    public static final String ACTION_RESCHEDULE = 'reschedule';
    public static final String STATUS_CANCELED = 'Canceled';
    public static final String PMD_EXPARAM = 'PMD.ExcessiveParameterList';
    public static final String TEST_USER = 'testuser';
    public static final String Q10 = 'Q10';
    public static final String Q9 = 'Q9';
    public static final String Q6 = 'Q6';
    public static final String SOURCESYSREFERENCE = 'USR-001';

    
  /**
    * @description Constructor
    * @param
    * 
    */
 public PRX_CTRL_Constants() {
        productInfo = 'Perx';
        if (productInfo != null) {
            productInfo = 'Perx';
        }
    }
}