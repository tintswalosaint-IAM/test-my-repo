/*------------------------------------------------------------
Author:        Raymond Magezi
Company:       Standard Bank
Description:   Helper class for User manager hierarchy operations.
               Extracted from CMN_DAL_User to reduce class complexity.
               Provides invocable method for Flow/Process Builder to
               retrieve managers at specified escalation levels.
Test Class:    CMN_DAL_UserManagerHierarchy_Test

History
<Date>         <Authors Name>     <Brief Description of Change>
29-01-2026     Raymond Magezi     Initial creation - extracted from CMN_DAL_User
04-02-2026     Raymond Magezi     Added static caching to reduce SOQL queries
------------------------------------------------------------*/
public inherited sharing class CMN_DAL_UserManagerHierarchy {
  
  private static final Integer MAX_MANAGER_LEVELS = 5;
  private static final sbgplatform.rflib_Logger LOGGER = 
    sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_DAL_UserManagerHierarchy');
  private static Map<Id, User> hierarchyCache = new Map<Id, User>();

  private CMN_DAL_UserManagerHierarchy() {}

  /*------------------------------------------------------------
   Purpose:    Gets managers at specified levels in hierarchy for multiple users.
               Optimized for bulk processing to respect governor limits.
   Parameters: requests - List of ManagerRequest containing ownerId and escalationLevel
   Returns:    List of ManagerResult with managerId, managerEmail, and errorMessage
   Throws:     ManagerLookupException if escalation level is invalid
  ------------------------------------------------------------*/
  @InvocableMethod(
    label='Get Manager By Escalation Level'
    description='Returns manager at specified level in hierarchy with error handling'
  )
  public static List<CMN_DAL_User.ManagerResult> getManagerByLevel(List<CMN_DAL_User.ManagerRequest> requests) {
    LOGGER.info('getManagerByLevel: Processing {0} request(s)', new Object[]{requests == null ? 0 : requests.size()});
    
    if (requests == null || requests.isEmpty()) {
      LOGGER.warn('getManagerByLevel: Received null or empty request list');
      return new List<CMN_DAL_User.ManagerResult>();
    }

    Set<Id> allSeedUserIds = new Set<Id>();
    List<CMN_DAL_User.ManagerRequest> validRequests = new List<CMN_DAL_User.ManagerRequest>();
    
    validateAndCollectSeedUsers(requests, allSeedUserIds, validRequests);
    
    if (allSeedUserIds.isEmpty()) {
      LOGGER.warn('getManagerByLevel: No valid User IDs found');
      return createEmptyResults(requests);
    }

    Map<Id, User> usersById = buildUserHierarchy(allSeedUserIds);
    List<CMN_DAL_User.ManagerResult> results = processRequests(validRequests, usersById);
    
    LOGGER.info('getManagerByLevel: Completed processing');
    return results;
  }

  /*------------------------------------------------------------
   Purpose:    Validates escalation levels and collects valid seed user IDs
   Parameters: requests - List of ManagerRequest to validate
               allSeedUserIds - Set to populate with valid user IDs
               validRequests - List to populate with valid requests
   Returns:    void
   Throws:     ManagerLookupException if escalation level is out of range
  ------------------------------------------------------------*/
  private static void validateAndCollectSeedUsers(
    List<CMN_DAL_User.ManagerRequest> requests, 
    Set<Id> allSeedUserIds, 
    List<CMN_DAL_User.ManagerRequest> validRequests
  ) {
    for (CMN_DAL_User.ManagerRequest req : requests) {
      if (req == null) {
        continue;
      }
      
      if (req.escalationLevel != null && (req.escalationLevel < 1 || req.escalationLevel > MAX_MANAGER_LEVELS)) {
        throw new CMN_DAL_User.ManagerLookupException(
          'Escalation level must be between 1 and ' + MAX_MANAGER_LEVELS
        );
      }
      
      if (req.ownerId != null && String.valueOf(req.ownerId).startsWith('005')) {
        allSeedUserIds.add(req.ownerId);
        validRequests.add(req);
      }
    }
  }

  /*------------------------------------------------------------
   Purpose:    Creates empty results for requests with invalid user IDs
   Parameters: requests - List of ManagerRequest to create empty results for
   Returns:    List of ManagerResult with error messages
  ------------------------------------------------------------*/
  private static List<CMN_DAL_User.ManagerResult> createEmptyResults(List<CMN_DAL_User.ManagerRequest> requests) {
    List<CMN_DAL_User.ManagerResult> results = new List<CMN_DAL_User.ManagerResult>();
    for (Integer i = 0; i < requests.size(); i++) {
      CMN_DAL_User.ManagerResult emptyResult = new CMN_DAL_User.ManagerResult();
      emptyResult.errorMessage = 'Owner is not a User (may be Queue/Group)';
      results.add(emptyResult);
    }
    return results;
  }

  private static Map<Id, User> buildUserHierarchy(Set<Id> allSeedUserIds) {
    queryUncachedUsers(allSeedUserIds);
    fetchManagerHierarchy(allSeedUserIds);
    LOGGER.debug('buildUserHierarchy: Cache size: {0}', new Object[]{hierarchyCache.size()});
    return hierarchyCache;
  }

  private static void queryUncachedUsers(Set<Id> userIds) {
    Set<Id> idsToQuery = new Set<Id>();
    for (Id userId : userIds) {
      if (!hierarchyCache.containsKey(userId)) {
        idsToQuery.add(userId);
      }
    }
    
    if (!idsToQuery.isEmpty()) {
      for (User u : [SELECT Id, ManagerId, Email FROM User WHERE Id IN :idsToQuery WITH USER_MODE]) {
        hierarchyCache.put(u.Id, u);
      }
      LOGGER.debug('queryUncachedUsers: Queried {0} new users', new Object[]{idsToQuery.size()});
    }
  }

  private static void fetchManagerHierarchy(Set<Id> seedUserIds) {
    Set<Id> currentLevelIds = seedUserIds;
    List<Set<Id>> allManagerIdsToQuery = new List<Set<Id>>();
    
    for (Integer i = 0; i < MAX_MANAGER_LEVELS; i++) {
      Set<Id> managerIds = collectUncachedManagerIds(currentLevelIds);
      
      if (managerIds.isEmpty()) {
        break;
      }
      
      allManagerIdsToQuery.add(managerIds);
      currentLevelIds = managerIds;
    }
    
    queryAllManagers(allManagerIdsToQuery);
  }

  private static void queryAllManagers(List<Set<Id>> allManagerIdsToQuery) {
    Set<Id> allIds = new Set<Id>();
    for (Set<Id> managerIds : allManagerIdsToQuery) {
      allIds.addAll(managerIds);
    }
    
    if (!allIds.isEmpty()) {
      for (User mgr : [SELECT Id, ManagerId, Email FROM User WHERE Id IN :allIds WITH USER_MODE]) {
        hierarchyCache.put(mgr.Id, mgr);
        LOGGER.debug('queryAllManagers: Fetched manager {0}', new Object[]{mgr.Id});
      }
    }
  }

  private static Set<Id> collectUncachedManagerIds(Set<Id> userIds) {
    Set<Id> managerIds = new Set<Id>();
    
    for (Id userId : userIds) {
      User u = hierarchyCache.get(userId);
      if (u != null && u.ManagerId != null && !hierarchyCache.containsKey(u.ManagerId)) {
        managerIds.add(u.ManagerId);
      }
    }
    
    return managerIds;
  }

  /*------------------------------------------------------------
   Purpose:    Processes requests using the pre-fetched user hierarchy
   Parameters: requests - List of valid ManagerRequest to process
               usersById - Map of User records by ID
   Returns:    List of ManagerResult with manager information or errors
  ------------------------------------------------------------*/
  private static List<CMN_DAL_User.ManagerResult> processRequests(
    List<CMN_DAL_User.ManagerRequest> requests, 
    Map<Id, User> usersById
  ) {
    List<CMN_DAL_User.ManagerResult> results = new List<CMN_DAL_User.ManagerResult>();
    for (CMN_DAL_User.ManagerRequest req : requests) {
      results.add(findManagerAtLevel(req, usersById));
    }
    return results;
  }

  /*------------------------------------------------------------
   Purpose:    Finds manager at specified level in hierarchy for a single request
   Parameters: req - ManagerRequest to process
               usersById - Map of User records by ID
   Returns:    ManagerResult with manager info or error message
  ------------------------------------------------------------*/
  private static CMN_DAL_User.ManagerResult findManagerAtLevel(
    CMN_DAL_User.ManagerRequest req, 
    Map<Id, User> usersById
  ) {
    CMN_DAL_User.ManagerResult result = new CMN_DAL_User.ManagerResult();
    Integer levelsUp = req.escalationLevel == null ? 1 : req.escalationLevel;
    Id currentUserId = req.ownerId;

    for (Integer level = 0; level < levelsUp && currentUserId != null; level++) {
      User currentUser = usersById.get(currentUserId);
      if (currentUser == null) {
        result.errorMessage = 'User not found at level ' + (level + 1);
        return result;
      }
      currentUserId = currentUser.ManagerId;
    }

    if (currentUserId == null) {
      result.errorMessage = 'Manager hierarchy ends before reaching level ' + levelsUp;
      return result;
    }
    
    User targetManager = usersById.get(currentUserId);
    if (targetManager == null) {
      result.errorMessage = 'Manager not found in hierarchy';
      return result;
    }
    
    result.managerId = targetManager.Id;
    if (targetManager.Email != null && !targetManager.Email.endsWith('.invalid')) {
      result.managerEmail = targetManager.Email;
    }
    
    return result;
  }
}