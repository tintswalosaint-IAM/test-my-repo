/**
 * @description       : Query methods related to PublicComplaint object
 * @User Story		  : SFP-38372
 * @author            : Aliaksei Koval
 * @last modified on  : 09-08-2025
 * @last modified by  : Aliaksei Koval
**/
public inherited sharing class SEL_PublicComplaint {
    private SEL_PublicComplaint() {}

    public static final String OBJECT_NAME = PublicComplaint.SObjectType.getDescribe().getLocalName();
    private static final String FIELD_ID = PublicComplaint.Id.getDescribe().getLocalName();

    /**
	 * @description Will return base fields to return on a query
	 * @return A list of Public Complaint fields
	 */
	private static Set<String> getDefaultFields(){
		return new Set<String>
		{
            FIELD_ID
		};
	}

    /**
	 * @description Method to return Public Complaint by Id
	 * @param publicComplaintId
	 * @return PublicComplaint
	 */
	public static PublicComplaint findById(String publicComplaintId)
	{
		return (PublicComplaint)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, publicComplaintId, getDefaultFields());
	}

    /**
	 * @description Method to return a list of Public Complaints by Id
	 * @param caseId
	 * @return List of Public Complaint
	 */
	public static List<PublicComplaint> findByCaseId(String caseId)
	{
		return [SELECT Id FROM PublicComplaint WHERE ComplaintCaseId = :caseId];
	}
}