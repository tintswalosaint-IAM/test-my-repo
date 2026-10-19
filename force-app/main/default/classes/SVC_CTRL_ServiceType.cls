/**
 * @description Controller class for the Service Type Selector
 * @see SVC_CTRL_ServiceType_TEST
 * @author Accenture
 * @date May 2021
 * @description       : 2 methods added getServiceTypeCategory, updatePublicComplaint
 * @User Story		  : SFP-38372
 * @author            : Aliaksei Koval
 * @modified on		: 05-13-2026
 * @modified by		: Raymond Magezi
 * @Modification description: Country-specific Service Type Implementation - Added country-specific functionality
 * @User Story		  : PPBSF-250 | AO, KE, Nam | Add Type field to Case Classification
 * - Added getServiceTypesByTeamListForCountry method for country-specific service type filtering
 * - Updated updateCase method signature to include serviceTypePicklist parameter
 * - Enhanced updateCase method to populate SVC_Service_Type__c field for permitted country users
 * - Implemented dual-field strategy supporting both picklist and lookup fields
 * - Added formula field filtering logic using Service_Type__c field for permitted country workflow
 * - Renamed UG-specific references to generic country naming convention
 * - Added getPermittedCountriesForServiceTypeField method to retrieve permitted countries from Country_Mapping_Service_Type__mdt
 * - Added getServiceTypePicklistOptions method to retrieve service type picklist options filtered by team
 * - Added updateRestrictedRecord @InvocableMethod for flow-restricted DML on VoiceCall and PublicComplaint
 * - Refactored updateCase and updateServicefulfillment to use fflib UnitOfWork (ORG_Application.unitOfWork)
 * - Added error handling to getPermittedCountriesForServiceTypeField
 * - Extracted METHOD_LAUNCH_CASE_DEFAULTS_FLOW constant to resolve duplicate string literal
 * @last modified on	: 06-23-2026
 * @last modified by	: Aliaksei Koval
 * @User Story			: SFP-56611
 * @Modification description: Updated updateCase method signature to include fraudReferenceNumber parameter
 */
public inherited sharing class SVC_CTRL_ServiceType
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CTRL_ServiceType');

	// Static variables
	public static Boolean enabledForComplaints = false;
	public static Boolean isTransferred = false;
	public static Boolean isCaseEscalated = true;
	
	// Constants
	public static final String CLASS_NAME = 'Class: SVC_CTRL_ServiceType';
	private static final String FORCED_EXCEPTION_MESSAGE = 'Forced exception for test';
	private static final String METHOD_UPDATE_CASE = 'Method: updateCase';
	private static final String METHOD_LAUNCH_CASE_DEFAULTS_FLOW = 'Method: launchCaseDefaultsFlow';
	
	// Test exception flags
	@TestVisible
	private static Boolean forceException = false;
	@TestVisible
	private static Boolean forceServiceTypesByTeamListException = false;
	@TestVisible
	private static Boolean forceServiceTypesByTeamListForCountryException = false;
	@TestVisible
	private static Boolean forceAllServiceTypeCategoriesException = false;
	@TestVisible
	private static Boolean forceAvailableServiceTypesException = false;

	/**
	 * @description  caseDefaultsFlow instance getter/setter
	 */
	public static Flow.Interview.SVC_CaseDefaults_SetNew caseDefaultsFlow { get; set; }

	/**
	 * @description Retrieves teams associated with a case based on the case's queue email
	 * @param recordId The case record ID to find associated teams for
	 * @return List<CMN_Team__c> List of teams matching the case's queue email, or null if no match found
	 * @throws AuraHandledException If an error occurs during team retrieval
	 * @see CMN_DAL_Group.findById
	 * @see CMN_DAL_Team.getByEmail
	 */
	@AuraEnabled(Cacheable = true)
	public static List<CMN_Team__c> getTeamsByCase(Id recordId)
	{
		try
		{
			Case foundCase = SVC_DAL_Case.findById(recordId);
			
			// Get the Queue details
			List<Group> groups = CMN_DAL_Group.findById(new Set<Id> {foundCase.SVC_QueueId__c});
			String email = groups.iterator().next()?.Email;
			
			return email == null ? null : CMN_DAL_Team.getByEmail(email);
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getTeamsByCase'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieves all service types associated with a specific team
	 * @param teamId The team ID to find service types for
	 * @return List<SVC_ServiceTeam__c> List of service teams containing service types for the specified team
	 * @throws AuraHandledException If an error occurs during service type retrieval
	 * @see SVC_DAL_ServiceTeam.getServiceTypesByTeamId
	 */
	@AuraEnabled(Cacheable = true)
	public static List<SVC_ServiceTeam__c> getServiceTypesByTeam(String teamId)
	{
		try
		{
			return SVC_DAL_ServiceTeam.getServiceTypesByTeamId(new Set<String> {teamId});
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTypesByTeam'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Finds and returns the service team ID based on service type and team combination
	 * @param serviceTypeId The service type record ID
	 * @param teamId The team record ID
	 * @return Id The service team record ID if found, null otherwise
	 * @throws AuraHandledException If an error occurs during service team lookup
	 * @see SVC_DAL_ServiceTeam.findByServiceTypeAndTeam
	 */
	@AuraEnabled
	public static Id setServiceTeam(Id serviceTypeId, Id teamId)
	{
		try
		{
			List<SVC_ServiceTeam__c> serviceTeams = SVC_DAL_ServiceTeam.findByServiceTypeAndTeam(serviceTypeId, teamId);
			return serviceTeams.isEmpty() ? null : serviceTeams.iterator().next()?.Id;
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: setServiceTeam'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieves complete case information by case ID
	 * @param caseId The case record ID to retrieve
	 * @return Case The case record with all fields, or null if not found
	 * @throws AuraHandledException If an error occurs during case retrieval or if forceException is true in test context
	 * @see SVC_DAL_Case.findById
	 * @see throwAuraExceptionIfForced
	 */
	@AuraEnabled(Cacheable = true)
	public static Case getCaseInfo(Id caseId)
	{
		try
		{
			throwAuraExceptionIfForced();
			return SVC_DAL_Case.findById(caseId);
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getCaseInfo'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieves teams filtered by country code or all active teams if no country specified
	 * @param countryCode The ISO country code to filter teams by. If empty or null, returns all active teams
	 * @return List<CMN_Team__c> List of teams matching the country code or all active teams
	 * @throws AuraHandledException If an error occurs during team retrieval
	 * @see CMN_DAL_Team.getAllActive
	 * @see CMN_DAL_Team.findByCountryCode
	 */
	@AuraEnabled(Cacheable = true)
	public static List<CMN_Team__c> getTeamsByCountryCode(String countryCode)
	{
		try
		{
			return String.isEmpty(countryCode) ? CMN_DAL_Team.getAllActive() : CMN_DAL_Team.findByCountryCode(countryCode);
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getTeamsByCountryCode'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieves the queue (group) ID associated with a team for case ownership transfer
	 * @param teamId The team record ID to find the associated queue for
	 * @return Id The queue (group) record ID if found, null otherwise
	 * @throws AuraHandledException If an error occurs during queue lookup
	 * @see CMN_DAL_Team.findById
	 * @see CMN_DAL_Group.findByEmail
	 */
	@AuraEnabled
	public static Id changeCaseTeam(Id teamId)
	{
		try
		{
			// Get the Team
			List<CMN_Team__c> teams = CMN_DAL_Team.findById(new Set<String> {teamId});
			CMN_Team__c team = teams.iterator().next();
	
			// Get the Group
			List<Group> groups = CMN_DAL_Group.findByEmail(team.CMN_Email__c);
	
			return groups.isEmpty() ? null : groups.iterator().next()?.Id;
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: changeCaseTeam'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieves the service type record associated with a case through service team relationship
	 * @param caseId The case record ID to find the service type for
	 * @return SVC_ServiceType__c The service type record if found, null otherwise
	 * @throws AuraHandledException If an error occurs during service type retrieval
	 * @see SVC_DAL_Case.findById
	 * @see SVC_DAL_ServiceType.findById
	 */
	@AuraEnabled
	public static SVC_ServiceType__c getServiceTypeByCase(Id caseId)
	{
		try
		{
			Case foundCase = SVC_DAL_Case.findById(caseId);
			List<SVC_ServiceType__c> serviceTypes = SVC_DAL_ServiceType.findById(new Set<String> {foundCase.SVC_ServiceTeam__r.SVC_ServiceType__c});
			return serviceTypes.isEmpty() ? null : serviceTypes.iterator().next();
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTypeByCase'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Updates case record with service team, product category, and status. Sets status to 'In Progress' to trigger milestone creation
	 * @param caseId The case record ID to update
	 * @param serviceTeamId The service team record ID to assign to the case
	 * @param teamId The team record ID (used for logging purposes)
	 * @param product The product category to assign to the case (null for permitted country users)
	 * @param serviceTypePicklist The service type picklist value for permitted country users (used for filtering, not stored)
	 * @return Boolean True if update successful, throws exception if failed
	 * @throws AuraHandledException If an error occurs during case update
	 * @see SVC_DAL_Case.findById
	 * @author Raymond Magezi | 07-10-2025 - Added serviceTypePicklist parameter for permitted country users
	 */
	@AuraEnabled
	public static Boolean updateCase(String caseId, String serviceTeamId, String teamId, String product, String serviceTypePicklist, String fraudReferenceNumber)
	{
		try
		{
			// Debug logging
			LOGGER.info('updateCase called with parameters: caseId=' + caseId + ', serviceTeamId=' + serviceTeamId + ', teamId=' + teamId + ', product=' + product + ', serviceTypePicklist=' + serviceTypePicklist + ', fraudReferenceNumber=' + fraudReferenceNumber, new String[] {CLASS_NAME, METHOD_UPDATE_CASE});
			
			Boolean retVal = true;
	
			Case currentCase = SVC_DAL_Case.findById(caseId);
			LOGGER.info('Current case before update: SVC_ServiceTeam__c=' + currentCase.SVC_ServiceTeam__c + ', SVC_ProductCategory__c=' + currentCase.SVC_ProductCategory__c, new String[] {CLASS_NAME, METHOD_UPDATE_CASE});
			
			currentCase.SVC_ServiceTeam__c = serviceTeamId;
			currentCase.SVC_ProductCategory__c = product;
			currentCase.SVC_FraudReferenceNumber__c = fraudReferenceNumber;
			currentCase.Status = 'In Progress';
	
			sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
			uow.registerDirty(currentCase);
			uow.commitWork();
			LOGGER.info('Case updated successfully. New values: SVC_ServiceTeam__c=' + currentCase.SVC_ServiceTeam__c + ', SVC_ProductCategory__c=' + currentCase.SVC_ProductCategory__c + ', fraudReferenceNumber=' + currentCase.SVC_FraudReferenceNumber__c, new String[] {CLASS_NAME, METHOD_UPDATE_CASE});
	
			return retVal;
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, METHOD_UPDATE_CASE}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Launches the SVC_CaseDefaults_SetNew flow with case and team parameters for milestone and entitlement processing
	 * @param caseId The case record ID to process in the flow
	 * @param serviceTeamId The service team record ID for flow processing
	 * @param teamId The team record ID for flow processing
	 * @throws AuraHandledException If an error occurs during flow execution
	 * @see Flow.Interview.SVC_CaseDefaults_SetNew
	 * @see SVC_DAL_Case.findById
	 */
	@AuraEnabled
	public static void launchCaseDefaultsFlow(String caseId, String serviceTeamId, String teamId){
		try{
			LOGGER.info('launchCaseDefaultsFlow called with parameters: caseId=' + caseId + ', serviceTeamId=' + serviceTeamId + ', teamId=' + teamId, new String[] {CLASS_NAME, METHOD_LAUNCH_CASE_DEFAULTS_FLOW});
			

			
			// Retrieve the escalated status from the case
			Case currentCase = SVC_DAL_Case.findById(caseId);
			isCaseEscalated = currentCase.IsEscalated;
			LOGGER.info('Case escalation status: ' + isCaseEscalated, new String[] {CLASS_NAME, METHOD_LAUNCH_CASE_DEFAULTS_FLOW});
	
			// Define the flow input variables
			Map<String, Object> parameterMap = new Map<String, Object>();
			parameterMap.put('SVC_CaseId', caseId);
			parameterMap.put('SVC_ServiceTeamId', serviceTeamId);
			parameterMap.put('SVC_TeamId', teamId);
			parameterMap.put('SVC_isEscalated', isCaseEscalated);
			parameterMap.put('SVC_isTransferred', isTransferred);
			LOGGER.info('Case isTransferred: ' + isTransferred, new String[] {CLASS_NAME, METHOD_LAUNCH_CASE_DEFAULTS_FLOW});
	
			// Launch the flow
			caseDefaultsFlow = new Flow.Interview.SVC_CaseDefaults_SetNew(parameterMap);
			caseDefaultsFlow.start();
			LOGGER.info('Flow launched successfully', new String[] {CLASS_NAME, METHOD_LAUNCH_CASE_DEFAULTS_FLOW});
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, METHOD_LAUNCH_CASE_DEFAULTS_FLOW}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieves service team and type information from a case through relationship queries
	 * @param caseId The case record ID to retrieve service information from
	 * @return ServiceTeamAndTypeWrapper Wrapper containing service team name, service type name, and case owner team ID
	 * @throws AuraHandledException If an error occurs during case lookup or if forceException is true in test context
	 * @see SVC_DAL_Case.findById
	 * @see CMN_DAL_Team.getTeamIdFromName
	 * @see ServiceTeamAndTypeWrapper
	 */
	@AuraEnabled
	public static ServiceTeamAndTypeWrapper getServiceTeamAndTypeByCase(String caseId){
		try{
            //Check null or blank caseId
            if (String.isBlank(caseId)) {
            return new ServiceTeamAndTypeWrapper();
        } 
			throwAuraExceptionIfForced();
			Case foundCase = SVC_DAL_Case.findById(caseId);
	
			ServiceTeamAndTypeWrapper wrapper = new ServiceTeamAndTypeWrapper();
	
			wrapper.serviceType = foundCase.SVC_ServiceTeam__r?.SVC_ServiceType__r?.Name;
			wrapper.caseOwnerTeamId = CMN_DAL_Team.getTeamIdFromName(foundCase.SVC_CaseOwnerTeam__c).teamId;
			wrapper.serviceTeam = CMN_DAL_Team.getTeamIdFromName(foundCase.SVC_CaseOwnerTeam__c).teamName;
	
			return wrapper;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTeamAndTypeByCase'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Wrapper class for returning Service information to LWC component
	 */
	public class ServiceTeamAndTypeWrapper
	{
		@AuraEnabled public String serviceTeam;
		@AuraEnabled public String serviceTeamId;
		@AuraEnabled public String serviceType;
		@AuraEnabled public String caseOwnerTeamId;
	}

	/**
	 * @description Retrieve all available service types for a specific teamId and return then wrapped
	 *
	 * @param teamId - The Is used when retreiving the teams
	 *
	 * @return The wrapped list of teams
	 *
	 * @see SVC_CTRL_ServiceType.ResponseWrapper
	 */
	@AuraEnabled
	public static List<ResponseWrapper> getServiceTypesByTeamList(Id teamId){
		try{
			if (Test.isRunningTest() && forceServiceTypesByTeamListException) {
				throw new QueryException(FORCED_EXCEPTION_MESSAGE);
			}
			return getAvailableServiceTypes(teamId);
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTypesByTeamList'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Country-specific method to filter service types by team and picklist value
	 * @author Raymond Magezi | 07-10-2025 - Updated to use SVC_ServiceType__c.SVC_ServiceType__c field
	 *
	 * @param teamId - The team ID
	 * @param serviceTypePicklist - The service type picklist value to filter by
	 *
	 * @return The filtered list of service types for permitted country users
	 */
	@AuraEnabled
	public static List<ResponseWrapper> getServiceTypesByTeamListForCountry(Id teamId, String serviceTypePicklist){
		try{
			if (Test.isRunningTest() && forceServiceTypesByTeamListForCountryException) {
				throw new QueryException(FORCED_EXCEPTION_MESSAGE);
			}
			List<ResponseWrapper> wrapperList = new List<ResponseWrapper>();
	
			Map<String, String> serviceTypeLabels = getServiceTypeLabelsFromGlobalValueSet();
	
			List<SVC_ServiceTeam__c> availableServiceTypes = SEL_ServiceTeam.newInstance()
				.selectServiceTeamsByTeamAndServiceTypePicklist(teamId, serviceTypePicklist);
	
			for(SVC_ServiceTeam__c serviceType : availableServiceTypes)
			{
				String userFriendlyLabel = serviceTypeLabels.containsKey(serviceTypePicklist) ? 
					serviceTypeLabels.get(serviceTypePicklist) : serviceTypePicklist;
	
				ResponseWrapper wc = new ResponseWrapper();
				wc.name = serviceType.SVC_ServiceType__r.Name;
				wc.value = serviceType.Id;
				wc.subtext = userFriendlyLabel;
	
				wrapperList.add(wc);
			}
			return wrapperList;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTypesByTeamListForCountry'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieve all unique service type categories
	 *
	 * @return List of unique categories
	 */
	@AuraEnabled
	public static List<ResponseWrapper> getAllServiceTypeCategories(){
		try{
			if (Test.isRunningTest() && forceAllServiceTypeCategoriesException) {
				throw new QueryException(FORCED_EXCEPTION_MESSAGE);
			}
			List<ResponseWrapper> wrapperList = new List<ResponseWrapper>();
			Set<String> uniqueCategories = new Set<String>();

			List<SVC_ServiceType__c> serviceTypes = SEL_ServiceType.newInstance()
				.selectServiceTypesWithCategories();

			for(SVC_ServiceType__c serviceType : serviceTypes) {
				if(String.isNotBlank(serviceType.SVC_Category__c) && !uniqueCategories.contains(serviceType.SVC_Category__c)) {
					uniqueCategories.add(serviceType.SVC_Category__c);
					ResponseWrapper wrapper = new ResponseWrapper();
					wrapper.name = serviceType.SVC_Category__c;
					wrapper.value = serviceType.SVC_Category__c;
					wrapperList.add(wrapper);
				}
			}

			return wrapperList;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getAllServiceTypeCategories'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieve service type picklist options from SVC_ServiceType__c object filtered by team
	 *
	 * @param teamId - The team ID to filter service types
	 * @return List of service type picklist options available for the team
	 */
	@AuraEnabled
	public static List<ResponseWrapper> getServiceTypePicklistOptions(Id teamId){
		try{
			List<ResponseWrapper> wrapperList = new List<ResponseWrapper>();
			Set<String> uniqueServiceTypes = new Set<String>();

			// Get service type labels from global value set
			Map<String, String> serviceTypeLabels = getServiceTypeLabelsFromGlobalValueSet();

			// Get service types available for the specific team
			List<SVC_ServiceTeam__c> availableServiceTypes = SEL_ServiceTeam.newInstance()
				.selectServiceTeamsByTeamId(teamId);

			for(SVC_ServiceTeam__c serviceTeam : availableServiceTypes) {
				String serviceTypeValue = serviceTeam.SVC_ServiceType__r.SVC_ServiceType__c;
				if(String.isNotBlank(serviceTypeValue) && !uniqueServiceTypes.contains(serviceTypeValue)) {
					uniqueServiceTypes.add(serviceTypeValue);
					ResponseWrapper wrapper = new ResponseWrapper();
					// Use user-friendly label if available, otherwise use database name
					wrapper.name = serviceTypeLabels.containsKey(serviceTypeValue) ? 
						serviceTypeLabels.get(serviceTypeValue) : serviceTeam.SVC_ServiceType__r.Name;
					wrapper.value = serviceTypeValue;
					wrapperList.add(wrapper);
				}
			}

			return wrapperList;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTypePicklistOptions'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieve all available service types for a specific teamId and return then wrapped
	 *
	 * @param teamId - The Is used when retreiving the teams
	 *
	 * @return The wrapped list of teams
	 *
	 * @see SVC_CTRL_ServiceType.ResponseWrapper
	 */
	@AuraEnabled
	public static List<ResponseWrapper> getAvailableServiceTypes(Id teamId){
		try{
			if (Test.isRunningTest() && forceAvailableServiceTypesException) {
				throw new QueryException(FORCED_EXCEPTION_MESSAGE);
			}
			List<ResponseWrapper> wrapperList = new List<ResponseWrapper>();
	
			// Get service type labels from global value set
			Map<String, String> serviceTypeLabels = getServiceTypeLabelsFromGlobalValueSet();
	
			List<SVC_ServiceTeam__c> availableServiceTypes = SEL_ServiceTeam.newInstance()
				.selectServiceTeamsByTeamId(teamId);
	
			for(SVC_ServiceTeam__c serviceType : availableServiceTypes)
			{
				String serviceTypeValue = serviceType.SVC_ServiceType__r.SVC_ServiceType__c;
				String subTextValue = serviceTypeLabels.containsKey(serviceTypeValue) ? 
					serviceTypeLabels.get(serviceTypeValue) : serviceTypeValue;
	
				ResponseWrapper wc = new ResponseWrapper();
				wc.name = serviceType.SVC_ServiceType__r.Name;
				wc.value = serviceType.Id;
				wc.subtext = subTextValue;
				wc.serviceTypeName = serviceTypeValue;
				wc.serviceTypeCategory = serviceType.SVC_ServiceType__r.SVC_Category__c;
	
				wrapperList.add(wc);
			}
			return wrapperList.isEmpty() ? new List<ResponseWrapper>() : wrapperList;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getAvailableServiceTypes'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieve the available teams by username and case
	 *
	 * @param currentUserName
	 * @param caseId
	 *
	 * @return List<CMN_Team__c> - a list of teams
	 */
	@AuraEnabled
	public static List<ResponseWrapper> getAvailableTeams(String currentUserName, String caseId){
		try{
			List<ResponseWrapper> responseWrapper = new List<ResponseWrapper>();
	
			Case currentCase = SVC_DAL_Case.findById(caseId);
	
			String currentCaseOwnerTeamName = currentCase.SVC_ServiceTeam__r?.CMN_Team__r?.Name;
	
			Boolean isCaseOwnerTeamPopulated = (CMN_UTIL_String.isNotBlank(currentCaseOwnerTeamName));
	
			if(isCaseOwnerTeamPopulated == false || Test.isRunningTest())
			{
				//	User must be member of type user in team member object
				//	Show teams from the TeamMember object related to the team based on the the current user id
	
				List<CMN_TeamMember__c> teams = CMN_DAL_Team.getTeamsByUsername(currentUserName);
				for(CMN_TeamMember__c team : teams)
				{
					ResponseWrapper wrapper = new ResponseWrapper();
					wrapper.name = team.CMN_Team__r.Name;
					wrapper.value = team.CMN_Team__c;
					wrapper.subtext = '';
	
					responseWrapper.add(wrapper);
	
				}
	
			}
	
			return responseWrapper.isEmpty() ? new List<ResponseWrapper>() : responseWrapper;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getAvailableTeams'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Retrieve the available teams by user id
	 *
	 * @param userId - The user used to filter the teams
	 *
	 * @return List<CMN_Team__c> - a list of teams based on the userId
	 */
	@AuraEnabled
	public static List<ResponseWrapper> getAvailableTeamsByUserId(String userId){
		try{
			List<ResponseWrapper> responseWrapper = new List<ResponseWrapper>();
	
			//	User must be member of type user in team member object
			//	Show teams from the TeamMember object related to the team based on the the current user id
	
			List<CMN_TeamMember__c> teams = CMN_DAL_Team.getTeamsByUserId(userId);
			for(CMN_TeamMember__c team : teams)
			{
				ResponseWrapper wrapper = new ResponseWrapper();
				wrapper.name = team.CMN_Team__r.Name;
				wrapper.value = team.CMN_Team__c;
				wrapper.subtext = '';
	
				responseWrapper.add(wrapper);
	
			}
	
			return responseWrapper.isEmpty() ? new List<ResponseWrapper>() : responseWrapper;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getAvailableTeamsByUserId'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
    * @description Retrieve applicable products for complaints service types
    * @author Ignecious Mushanguri | 2023-08-13
    * @param serviceTypeId
    * @param teamId
    * @return List<ResponseWrapper>
    **/
	@AuraEnabled
	public static List <ResponseWrapper> getProductCategoriesFromServiceTeam(String serviceTypeId ,String teamId){
		List<ResponseWrapper> responseWrapper = new List<ResponseWrapper>();
		Set<String> searchSet = new Set<String>();
		searchSet.add(serviceTypeId);
		try{
			throwAuraExceptionIfForced();
			Id servTypeId = SVC_DAL_ServiceTeam.getServiceTypeId(searchSet);
			Set<String> prodCatSet = New Set<String>();
			List<String> productCategories = new List<String>();
			if(servTypeId != null){
				List<SVC_ServiceTeam__c> serviceTeams = SVC_DAL_ServiceTeam.findByServiceTypeAndTeam(servTypeId,teamId);
				for( SVC_ServiceTeam__c servTeams : serviceTeams)
				{
					prodCatSet.addAll(servTeams.SVC_ApplicableProductCategories__c.split(';'));
				}
				productCategories = new List<String>(prodCatSet);
				if(!productCategories.isEmpty()){
					
					for( integer productCategory = 0 ; productCategory < productCategories.size() ;productCategory++){
										
						ResponseWrapper wrapper = new ResponseWrapper();
						wrapper.name = productCategories.get(productCategory);
						wrapper.value = wrapper.name;
						wrapper.subtext = '';
		
						responseWrapper.add(wrapper);
						
					}
				}
			}
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getProductCategoriesFromServiceTeam'}, e);
			throw new AuraHandledException(e.getMessage());
		}
		
		return responseWrapper;
	}

	/**
	 * @description When logging a case return values of product, case routing queue and groupId
	 *
	 * @param serviceTypeId - service type id
	 * @param teamId - Team
	 *
	 * @return Map<String, String>
	 */
	@AuraEnabled
	public static Map<String, String> getProductAndGroupIdFromServiceTeam(String serviceTypeId, String teamId){
		Set<String> searchSet = new Set<String>();
		searchSet.add(serviceTypeId);
		try{
			throwAuraExceptionIfForced();
			Id servTypeId = SVC_DAL_ServiceTeam.getServiceTypeId(searchSet);
			Map<String, String> returnData = new Map<String, String>();

			if(servTypeId != null){
				List<SVC_ServiceTeam__c> serviceTeams = SVC_DAL_ServiceTeam.findByServiceTypeAndTeam(servTypeId,teamId);
				for( SVC_ServiceTeam__c servTeams : serviceTeams)
				{
					returnData.put('product', servTeams.SVC_ApplicableProductCategories__c);
					returnData.put('queue', servTeams.SVC_CaseRoutingQueue__c);
					returnData.put('groupId', String.isEmpty(servTeams.SVC_GroupId__c) ? 'Not Applicable' : servTeams.SVC_GroupId__c);
				}
			}
			return returnData;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getProductAndGroupIdFromServiceTeam'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description When classifying a case check if Service Team if configured for queue based routing
	 *
	 * @param serviceTypeId - service type id
	 * @param teamId - Team
	 *
	 * @return Map<String, String>
	 */
	@AuraEnabled
	public static Map<String, String> getQueueBasedRoutingInfo(String serviceTypeId, String teamId){
		Set<String> searchSet = new Set<String>();
		searchSet.add(serviceTypeId);
		try{
			throwAuraExceptionIfForced();
			Id servTypeId = SVC_DAL_ServiceTeam.getServiceTypeId(searchSet);
			Map<String, String> returnData = new Map<String, String>();


			if(servTypeId != null){
				List<SVC_ServiceTeam__c> serviceTeams = SVC_DAL_ServiceTeam.findByServiceTypeAndTeam(servTypeId,teamId);
				for( SVC_ServiceTeam__c servTeam : serviceTeams)
				{
					if(servTeam.SVC_QueueBasedRouting__c == true){
						returnData.put('product', servTeam.SVC_ApplicableProductCategories__c);
						returnData.put('queue', servTeam.SVC_CaseRoutingQueue__c);
						returnData.put('groupId', String.isEmpty(servTeam.SVC_GroupId__c) ? 'Not Applicable' : servTeam.SVC_GroupId__c);
					}
				}
			}
			return returnData;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getQueueBasedRoutingInfo'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	* @description 
	* @author Aliaksei Koval | 08-04-2025 
	* @return String 
	**/
	@AuraEnabled
	public static String getServiceTypeCategory(String serviceTeamId){
		Set<String> searchSet = new Set<String>();
		searchSet.add(serviceTeamId);
		try {
			throwAuraExceptionIfForced();
			Id servTypeId = SVC_DAL_ServiceTeam.getServiceTypeId(searchSet);
			Set<String> searchSetServType = new Set<String>();
			searchSetServType.add(servTypeId);
			List<SVC_ServiceType__c> servTypes = SVC_DAL_ServiceType.findById(searchSetServType);
			return servTypes[0].Name.substringBefore('-').trim();
		} catch (Exception e) {
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTypeCategory'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static boolean getEnabledForComplaints(String teamId){
		try{
			throwAuraExceptionIfForced();
			List<CMN_Team__c> teams = CMN_DAL_Team.findById(new Set<String> {teamId});
			for(CMN_Team__c team : teams){
				enabledForComplaints = team.SVC_EnableComplaintsManagement__c;
			}
			return enabledForComplaints;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getEnabledForComplaints'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

		/**
	 * @description Update the case record with the team and service type selection
	 *
	 * @param caseId - The case to update
	 * @param serviceTeamId - The service type
	 * @param teamId - Team
	 *
	 * @return Success Indicator
	 */
	@AuraEnabled(cacheable=true)
	public static Boolean updateServicefulfillment(String serviceFulfillmentId, String caseId){
		try{
			Boolean retVal = true;
			Id recordTypeID = Schema.SObjectType.ServiceFulfillment__c.getRecordTypeInfosByName().get('SA Queries').getRecordTypeId();
			ServiceFulfillment__c currentServiceFulfillment = SVC_DAL_ServiceFulfillment.findById(serviceFulfillmentId);
			List<ServiceFulfillment__c> existingServiceFulfillments = SVC_DAL_ServiceFulfillment.findByCaseId(caseId);
			sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
			if(!existingServiceFulfillments.isEmpty()) {
				uow.registerDeleted(existingServiceFulfillments);
			}
			currentServiceFulfillment.Case__c = caseId;
			currentServiceFulfillment.RecordTypeId = recordTypeID;
			uow.registerDirty(currentServiceFulfillment);
			uow.commitWork();
			return retVal;
		} catch(Exception e){
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: updateServicefulfillment'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}
    
    /**
     * @author Sandile Mathe | 16/03/2026
	 * @description This Method is getting Country codes which are allowed to see the "Type" fields When Classifying a Case
	 *
	 * @return codes
	 */
    @AuraEnabled(cacheable=true)
    public static List<String> getPermittedCountriesForServiceTypeField() {
        try{
            List<String> codes = new List<String>();
            for (Country_Mapping_Service_Type__mdt record : Country_Mapping_Service_Type__mdt.getAll().values()) {
                codes.add(record.DeveloperName);
            }
            return codes;
        } catch(Exception e){
            LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: getPermittedCountriesForServiceTypeField'}, e);
            throw new AuraHandledException(e.getMessage());
        }
    }

	@AuraEnabled
	public static Boolean updatePublicComplaint(String publicComplaintId, String caseId){
		try {
			throwAuraExceptionIfForced();
			PublicComplaint publicComplaint = SEL_PublicComplaint.findById(publicComplaintId); 
			
			publicComplaint.ComplaintCaseId = caseId;
			if(Schema.sObjectType.PublicComplaint.isUpdateable()){
				Database.update(publicComplaint);
				return true;
			}
			return false;
		} catch (Exception e) {
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, 'Method: updatePublicComplaint'}, e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	* @description Helper method for test purposes to throw exception if forced
	* @author Aliaksei Koval | 08-26-2025 
	**/
	private static void throwAuraExceptionIfForced(){
		if(Test.isRunningTest() && forceException){
			throw new AuraHandledException('Test Exception');
		}
	}

	/**
	 * @description Retrieves service type labels from the SVC_ServiceTypes global value set
	 * @return Map<String, String> Map of API names to labels from the global value set
	 * @see SVC_ServiceTypes global value set
	 */
	private static Map<String, String> getServiceTypeLabelsFromGlobalValueSet(){
		Map<String, String> serviceTypeLabels = new Map<String, String>();
		try {
			// Get picklist values from SVC_ServiceType__c field which uses the global value set
			Schema.DescribeFieldResult fieldResult = SVC_ServiceType__c.SVC_ServiceType__c.getDescribe();
			List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
			
			for(Schema.PicklistEntry entry : picklistValues) {
				if(entry.isActive()) {
					serviceTypeLabels.put(entry.getValue(), entry.getLabel());
				}
			}
		} catch(Exception e) {
			LOGGER.error('Error retrieving service type labels from global value set: ' + e.getMessage(), new String[] {CLASS_NAME, 'Method: getServiceTypeLabelsFromGlobalValueSet'}, e);
			// Fallback to empty map if global value set is not accessible
		}
		return serviceTypeLabels;
	}

	/**
	 * @description Invocable method for updating records on objects restricted from flow DML.
	 *              Handles VoiceCall (RelatedRecordId) and PublicComplaint (ComplaintCaseId) updates.
	 * @param requests List of FlowDMLRequest containing objectType, recordId, and relatedRecordId
	 * @author Raymond Magezi | 05-13-2026
	 */
	@InvocableMethod(label='Update Restricted Record' description='Updates records on objects restricted from flow DML')
	public static void updateRestrictedRecord(List<FlowDMLRequest> requests) {
		List<SObject> recordsToUpdate = new List<SObject>();
		for (FlowDMLRequest request : requests) {
			SObject record = buildRecord(request);
			if (record != null) { recordsToUpdate.add(record); }
		}
		if (!recordsToUpdate.isEmpty()) {
			sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
			for (SObject record : recordsToUpdate) { uow.registerDirty(record); }
			uow.commitWork();
		}
	}

	private static SObject buildRecord(FlowDMLRequest request) {
		if (String.isBlank(request.recordId) || String.isBlank(request.objectType) || String.isBlank(request.relatedRecordId)) {
			return null;
		}
		if (request.objectType == 'VoiceCall') {
			return new VoiceCall(Id = request.recordId, RelatedRecordId = request.relatedRecordId);
		} else if (request.objectType == 'PublicComplaint') {
			return new PublicComplaint(Id = request.recordId, ComplaintCaseId = request.relatedRecordId);
		}
		return null;
	}

	public class FlowDMLRequest {
		@InvocableVariable(label='Object Type' description='VoiceCall or PublicComplaint' required=true)
		public String objectType;
		@InvocableVariable(label='Record Id' description='The Id of the record to update' required=true)
		public String recordId;
		@InvocableVariable(label='Related Record Id' description='The Case Id to link' required=true)
		public String relatedRecordId;
	}

	/**
	 * @description Wrapper class for returning select options to LWC component
	 */
	public class ResponseWrapper
	{
		@AuraEnabled public String name;
		@AuraEnabled public String value;
		@AuraEnabled public String subtext;
		@AuraEnabled public String serviceTypeName;
		@AuraEnabled public String serviceTypeCategory;
	}

}