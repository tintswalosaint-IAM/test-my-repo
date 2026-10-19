/**
* @description                 : Class needed by Application flow stories to create hierarchical data tree
* @story 		               : SFP-34698 Application Approval flow, Queues and Sign off
* @author                      : Tushar Walse
* @date                        : 20-03-2024
* @modification description    : Created
* @ last modified on           : 15-08-2025
* @last modified on            : 03-10-2025
* @last modified by            : Tushar Walse
* @modification description    : SFP-52492 Reconfigure the GSD Referral Process - support reporting of triggering conditions
* @ last modified on            : 27-10-2025
* @ last modified by            : Tushar Walse
* @ modification description    : SFP-53907 New Client Queue & Approval Rules Reconfiguration - Make FieldValueReplace return last found value
* To provide access to flows triggered by community user and also to avoid issues around licensing we used without sharing
* @last modified on  : 05-03-2026
* @last modified by  :Ikyatha Naidu
* @Modification Description : SFP-56493  updated for loadData joint account handling 
*/
@SuppressWarnings('PMD.NcssTypeCount, PMD.ExcessiveClassLength, PMD.CognitiveComplexity, PMD.CyclomaticComplexity, PMD.TooManyMethods') //Complex solution, Need to access multiple objects and make code manageable at one place
public without sharing class ICS_CTRL_GetData {
    static ICS_CTRL_GetData dataObj;
    static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GetData');
    private static final string STRING_APPLY_OR = '\n\nApply OR operation';
    ICS_CTRL_GetDataUtils utils = new ICS_CTRL_GetDataUtils(this);
    public ICS_CTRL_GetDataTree dataTree = new ICS_CTRL_GetDataTree();
    
    String[] objectsLoaded = new String[]{};
    String[] relationsLoaded = new String[]{};
    String[] rootObjectsLoaded = new String[]{};
    String[] rootObjectsLoadedById = new String[]{};
    @testVisible
    String[] rootObjects = new String[]{};
    
    @testVisible
    Map<String, Map<Id, SObject[]>> allSObjects = new Map<String, Map<Id, SObject[]>>();

    public Map<String, String> variable = new Map<String, String>();
    Map<String, Map<String, Object>> fieldValueReplacementMap = new Map<String, Map<String, Object>>();
    Integer logLineNumber = 0;
    String[] businessUserLog = new String[]{};

    Integer relationsIndexLoadedUpto = -1;
    
    String[] relations = new String[]{
        'ProcessInstanceStep.ProcessInstanceStep.ProcessInstanceId.ProcessInstance',
        'ProcessInstanceStep.ProcessInstanceStep.OriginalActorId.Group',
        'ProcessInstanceStep.ProcessInstanceStep.ActorId.User',
        'ProcessInstance.ProcessInstanceWorkitem.ProcessInstanceId.ProcessInstanceWorkitem',
        'ProcessInstanceWorkitem.ProcessInstanceWorkitem.ProcessInstanceId.ProcessInstance',
        'ProcessInstance.ProcessInstance.TargetObjectId.Opportunity',
        'Opportunity.Opportunity.RecordTypeId.RecordType',
        'Opportunity.Opportunity.OwnerId.User',

        'Opportunity.ProcessInstance.TargetObjectId.ProcessInstance',
        'ProcessInstance.ProcessInstance.LastActorId.User',
        'ProcessInstance.ProcessInstanceWorkitem.ProcessInstanceId.ProcessInstanceWorkitem',
        'ProcessInstanceWorkitem.ProcessInstanceWorkitem.OriginalActorId.Group',
        'ProcessInstanceWorkitem.ProcessInstanceWorkitem.ActorId.User',
        'ProcessInstance.ProcessInstanceStep.ProcessInstanceId.ProcessInstanceStep',

        'Opportunity.Opportunity.AccountId.Account',
        'Account.Account.RecordTypeId.RecordType',
        'Opportunity.OpportunityLineItem.OpportunityId.OpportunityLineItem',
        'OpportunityLineItem.OpportunityLineItem.Product2Id.Product2',
        'Opportunity.ApplicationForm.OpportunityId.ApplicationForm',
        'ApplicationForm.ApplicationFormProduct.ApplicationFormId.ApplicationFormProduct',
        'ApplicationForm.ApplicationFormHistory.ApplicationFormId.ApplicationFormHistory',
        'ApplicationFormProduct.ApplicationFormProduct.ProductId.Product2',
        'Product2.Product2.RecordTypeId.RecordType',
        'ApplicationForm.Applicant.ApplicationFormId.Applicant',
        'Applicant.Applicant.PartyProfileId.PartyProfile',
        'PartyProfile.PartyProfile.RelatedPartyProfileId.PartyProfile.NoTransformId',
        'PartyProfile.PartyProfile.RecordTypeId.RecordType',
        'Applicant.Applicant.AccountId.Account',
        'Account.ContentDocumentLink.LinkedEntityId.ContentDocumentLink',
        'Account.IdentityDocument.RelatedLegalEntityId.IdentityDocument',
            
        'IdentityDocument.ContentDocumentLink.LinkedEntityId.ContentDocumentLink',

        'Account.TaxDetails__c.Account__c.TaxDetails__c',
        'Account.ContactPointPhone.ParentId.ContactPointPhone',
        'Account.ContactPointEmail.ParentId.ContactPointEmail',
        'Account.FinServ__Employment__c.Person_Account__c.FinServ__Employment__c',
        'FinServ__Employment__c.FinServ__Employment__c.RecordTypeId.RecordType',
        'PartyProfile.Party_Assets_Funds__c.Party_Profile__c.Party_Assets_Funds__c',
        'Party_Assets_Funds__c.Party_Assets_Funds__c.RecordTypeId.RecordType',
        'Party_Assets_Funds__c.Party_Assets_Funds__c.Trust__c.Party_Assets_Funds__c.NoTransformId',
        'PartyProfile.PartyProfileRisk.PartyProfileId.PartyProfileRisk',
        'PartyProfile.PartyScreeningSummary.PartyProfileId.PartyScreeningSummary',
        'PartyScreeningSummary.PartyScreeningSummary.RecordTypeId.RecordType',
        'PartyScreeningSummary.PartyScreeningStep.ScreeningSummaryId.PartyScreeningStep',
        'PartyProfile.PartyIdentityVerification.PartyProfileId.PartyIdentityVerification',
        'PartyIdentityVerification.PartyIdentityVerificationStep.PartyIdentityVerificationId.PartyIdentityVerificationStep',
        'PartyProfile.ContentDocumentLink.LinkedEntityId.ContentDocumentLink',

        'ContentDocumentLink.ContentDocumentLink.ContentDocumentId.ContentDocument',
        'ContentDocument.ContentDocument.LatestPublishedVersionId.ContentVersion',

        'PartyProfile.PartyProfileAddress.PartyProfileId.PartyProfileAddress',
        'Account.Assessment.AccountId.Assessment',
        'Assessment.AssessmentQuestionResponse.AssessmentId.AssessmentQuestionResponse',
        'AssessmentQuestionResponse.AssessmentQuestionResponse.AssessmentQuestionId.AssessmentQuestionVersion',
        'AssessmentQuestionVersion.AssessmentQuestionVersion.AssessmentQuestionId.AssessmentQuestion',
        'AssessmentQuestionResponse.AssessmentQuestionResponse.OwnerId.User',
        'User.GroupMember.UserOrGroupId.GroupMember',
        'User.User.UserRoleId.UserRole',
        'UserRole.Group.RelatedId.Group',
        'Group.GroupMember.UserOrGroupId.GroupMember',
        'GroupMember.GroupMember.GroupId.Group'

    };

    /**
    * @description Load all relations upto the specified object
    * @author Tushar Walse | 17th Sep 2024 
    * @param objectName The object upto relations to be loaded
    * @return Boolean true if successfull
    **/
    @testvisible
    Boolean checkAndLoadData(String objectName) {
        return checkAndLoadData(objectName, relations.size());
    }
    
    /**
    * @description Load all relations
    * @author Tushar Walse | 17th Sep 2024 
    **/
    @testvisible
    public void loadAllData() {
        for(String relation : relations) {
            loadData(relation);
        }
    }

    /**
     * @description Check and load if the queried object isn't loaded 
     * @param objectName object to be checked
     * @param indexBelow index of relations below which dependency to be loaded is checked
     * @return Boolean true if loaded successfully
     */
    @testvisible
    @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
    Boolean checkAndLoadData(String objectName, Integer indexBelow) {
        try {
            Boolean result = objectsLoaded.contains(objectName);
            if(result) {
                return result;
            }

            Integer j = indexBelow;
            String[] objects;
            Boolean objectFound = false;

            while (indexBelow > 0) {
                indexBelow--;
                objects = relations[indexBelow].split('\\.');
                String relationToProcess = objects[0] + '.' + objects[3];
                loadDependency(objectName == objects[3] || objectName == relationToProcess, objects, indexBelow);
                objectFound = setObjectFound(objectName == objects[3] || objectName == relationToProcess, objectFound);
            }
            if(!objectFound) {
                indexBelow = j;
                while (indexBelow > 0) {
                    indexBelow--;
                    objects = relations[indexBelow].split('\\.');
                    String relationToProcess = objects[3] + '.' + objects[0];
                    loadDependency(objectName == relationToProcess && (!objectsLoaded.contains(objects[0] + '.' + objects[3])), objects, indexBelow);
                    objectFound = setObjectFound(objectName == relationToProcess, objectFound);
                }    
            }
            if(!objectFound && rootObjects.contains(objectName)) {
                if(!rootObjectsLoaded.contains(objectName)) {
                    SObject[] objRecords = recordsByName(objectName);
                    dataTree.addRootNodes(objRecords, objectName);
                    rootObjectsLoaded.add(objectName);
                }
                objectFound = true;
            }

            if(!objectFound) {
                objectFound = objectName == relations[0].split('\\.')[0];
            }
                
            utils.myThrow(!objectFound, 'checkAndLoadData: Unknown object requested: ' + objectName);

            result = objectFound;
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in checkAndLoadData: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Load parent object
    * @author Tushar Walse | 17th Sep 2024 
    * @param condition Condition to check before loading parent
    * @param objects Parent relation description
    * @param indexBelow index of relations below which dependency to be loaded is checked
    **/
    @testvisible
    void loadDependency(Boolean condition, String[] objects, Integer indexBelow) {
        try {
            if(condition) {
                checkAndLoadData(objects[0], indexBelow);
                loadData(relations[indexBelow]);
            }
        } catch (Exception e) {
            LOGGER.error('Error in loadDependency: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description Function to check condition to determine if object is found and return true
    * @author Tushar Walse | 17th Sep 2024 
    * @param condition Condition determining whether the object is found
    * @param objectFound Original status of whether the object was already found or not
    * @return Boolean True if object was found, otherwise original status value
    **/
    @testvisible
    Boolean setObjectFound(Boolean condition, Boolean objectFound) {
        try {
            if(condition) {
                objectFound = true;
            }
            return objectFound;
        } catch (Exception e) {
            LOGGER.error('Error in setObjectFound: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Get the names of queues to which the current user is member of
    * @author Tushar Walse | 08-04-2025 
    * @return String[] Return DeveloperNames of Queues to which the current user is member of
    **/
    @testvisible
    public static String[] getQueueMembership() {
        try {
            List<String> memberOfQueues = new List<String>();
            Id roleId = UserInfo.getUserRoleId();
            if(roleId == null) {
                return memberOfQueues;
            }
            UserRole role = new Sel_UserRole().selectById(roleId);
            if(role == null) {
                return memberOfQueues;
            }
            Group roleRecord = new Sel_Group().selectByDeveloperNameAndType(role.DeveloperName, 'Role');
            if(roleRecord == null) {
                return memberOfQueues;
            }
            List<GroupMember> groupMemberRecords = new SEL_GroupMember().selectByUserOrGroupIds(new Set<Id>{roleRecord.Id, UserInfo.getuserid()});
            Set<Id> queueRecordIds = new Set<Id>();
            for(GroupMember groupMemberRecord : groupMemberRecords) {
                queueRecordIds.add(groupMemberRecord.GroupId);
            }
            List<Group> queueRecords = new SEL_Group().selectByIds(queueRecordIds);
            for(Group queueRecord : queueRecords) {
                memberOfQueues.add(queueRecord.DeveloperName);
            }

            return memberOfQueues;
        } catch (Exception e) {
            LOGGER.error('Error in getQueueMembership: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }
    
    /**
    * @description Set objects with Id in ids as roots to retrieve all children
    * @author Tushar Walse | 23-09-2024 
    * @param ids id of records to used as roots assuming all ids are of the same type of object
    **/
    @testvisible
    public void init(Set<Id> ids) {
        try {
            if(!variable.containsKey('LoggedUserId')) {
                Id id = UserInfo.getuserid();
                variable.put('LoggedUserId', JSON.serialize(id));
                variable.put('QueueMembership', JSON.serialize(getQueueMembership()));
                init(new Set<Id>{id});
            }

            String objectName = dataTree.getType(new List<Id>(ids)[0]);
            SObject[] objRecords = recordsByIds(objectName, ids);
            storeAllSobjects(objectName, objRecords);
            dataTree.addRootNodes(objRecords, objectName);
            rootObjectsLoadedById.add(objectName);
            rootObjects.add(objectName);
        } catch (Exception e) {
            LOGGER.error('Error in init: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
     * @description Use records in objectName as roots
     * @author Tushar Walse | 23-09-2024 
     * @param objectName Records of which are to be used as roots
     */
    @testvisible
    public void init(String objectName) {
        rootObjects.add(objectName);
    }

    /**
     * @description Use objects with Id in ids as roots to retrieve all children
     * @author Tushar Walse | 23-09-2024 
     * @param ids Id of records to used as roots
     */
    @testvisible
    public ICS_CTRL_GetData(Set<Id> ids) {
        init(ids);
    }

    /**
     * @description Use object with id as root to retrieve all children
     * @author Tushar Walse | 23-09-2024 
     * @param id Id of the record to be used as root
     */
    @testvisible
    public ICS_CTRL_GetData(Id id) {
        init(new Set<Id>{id});
    }

    /**
    * @description Construct the browse tree created from the query specified
    * @author Tushar Walse | 17th Sep 2024 
    * @param recordsQuery Query from which browse tree is to be constructed
    * @return ICS_CTRL_GetBrowseTree Reference to the browse tree constructed from the query
    **/
    @testvisible
    public ICS_CTRL_GetBrowseTree getRecords(String recordsQuery) {
        try {
            String[] keys = recordsQuery.split('\\.(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');

            ICS_CTRL_GetBrowseTree browseTree = new ICS_CTRL_GetBrowseTree(dataTree);

            String previousObjectName = '';
            for(String key : keys) {
                String index = utils.getBracketContent(key);
                String childObjectName = key.substringBefore('(');

                if(!String.isBlank(childObjectName) && (childObjectName.startsWith('<') || checkAndLoadData(previousObjectName + childObjectName))) {
                    browseTree.browse(childObjectName);
                }
                previousObjectName = childObjectName.remove('<') + '.';
                filterRecords(browseTree, index, childObjectName);
            }
            return(browseTree);
        } catch (Exception e) {
            LOGGER.error('Error in getRecords: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }
    
    /**
    * @description Get the table from fully qualified query specified
    * @author Tushar Walse | 17th Sep 2024 
    * @param fullyQualQuery Fully qualified query string 
    * @return List<Map<String, Object>> Result of the query as a table
    **/
    @testvisible
    public List<Map<String, Object>> getFieldValue(String fullyQualQuery) {
        try {
            
            String fieldDelimiter = '.(';

            utils.myThrow(!fullyQualQuery.contains(fieldDelimiter), fullyQualQuery + ' does not have field names enclosed in brackets');

            utils.myThrow(fullyQualQuery.substringAfter(fieldDelimiter).contains(fieldDelimiter), fullyQualQuery + ' fields specified twice!');

            String objectString = fullyQualQuery.substringBeforeLast(fieldDelimiter);
            fullyQualQuery = fullyQualQuery.substringAfterLast(fieldDelimiter).removeStart(fieldDelimiter).removeEnd(')');
            ICS_CTRL_GetBrowseTree sObjects = getRecords(objectString);

            String[] fieldSpecString = fullyQualQuery.split(', ');
            Integer i = 0;
            while(i < fieldSpecString.size()) {
                if(fieldSpecString[i].endsWith('\\') && i+1 < fieldSpecString.size()) {
                    fieldSpecString[i] = fieldSpecString[i].removeEnd('\\');
                    fieldSpecString[i] += ', ' + fieldSpecString[i+1];
                    fieldSpecString.remove(i+1);
                }
                i++;
            }
            return(getFieldValue(sObjects, fieldSpecString));
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }    

    /**
    * @description Return the log
    * @author Tushar Walse | 22-09-2024 
    * @return String[] Containing the log
    **/
    @testvisible
    public String[] getLog() {
        return businessUserLog;
    }


    /**
    * @description Clear variable while retaining some
    * @author Tushar Walse | 07-02-2025 
    **/
    private void clearVariable() {
        if(variable.containsKey('LoggedUserId')) {
            String loggedUserIdJSON = variable.get('LoggedUserId');
            String QueueMembershipJSON = variable.get('QueueMembership');
            variable.clear();
            variable.put('LoggedUserId', loggedUserIdJSON);
            variable.put('QueueMembership', QueueMembershipJSON);            
        } else {
            variable.clear();
        }
    }

    /**
    * @description Replace Serial Number string with number in the query before processing
    * @author Tushar Walse | 17th Sep 2024 
    * @param fullyQualQuery Fully qualified query string 
    * @param serialNumber value to replace Serial Number string in the query before processing
    * @return Map<String, Object> One set of tables for current serial number
    **/
    @testvisible
    public Map<String, Object> getFieldValueTables(String fullyQualQuery, Integer serialNumber) {
        try {
            String conditionQuery = fullyQualQuery;
            Map<String, Object> tables = new Map<String, Object>();
            String delimiter = '\n\n';
            String delimeterNewLine = '\n';
            clearVariable();
            

            while(conditionQuery.endsWith(delimeterNewLine)) {
                conditionQuery = conditionQuery.substringBeforeLast(delimeterNewLine);
            }
            conditionQuery += delimiter;

            do {
                String[] stringParts = conditionQuery.substringBefore(delimiter).split(delimeterNewLine);
                if(!stringParts[0].endsWith(' (To be Considered Inactive)') && !checkSetVariable(stringParts[1], serialNumber)) {
                    fetchTables(stringParts, tables, serialNumber);
                }
                
                conditionQuery = conditionQuery.substringAfter(delimiter);
                conditionQuery = variableReplace(conditionQuery);
            } while(conditionQuery.contains(delimiter));
            return(tables);
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValueTables: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Substitute variables that have been set uptil now
    * @author Tushar Walse | 04-02-2025 
    * @param conditionQuery String in which replacements to be made
    * @return String conditionQuery with replaced variable names
    **/
    @testvisible
    public String variableReplace(String conditionQuery) {
        try {
            for(String vName : variable.keySet()) {
                String token1 = ':' + vName;
                String token2 = '{' + vName + '}';
                String value = variable.get(vName);
        
                if (conditionQuery.contains(token1)) {
                    conditionQuery = conditionQuery.replace(token1, ':' + value);
                }
                if (conditionQuery.contains(token2)) {
                    conditionQuery = conditionQuery.replace(token2, value);
                }
            }
            return(conditionQuery);    
        } catch (Exception e) {
            LOGGER.error('Error in variableReplace: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Fetch the field value of the first record
    * @author Tushar Walse | 17th Sep 2024 
    * @param fullyQualQuery Fully qualified query string 
    * @param serialNumber value to replace Serial Number string in the query before processing
    * @return String Value of the first record, field as string
    **/
    @testvisible
    public String getSingleFieldValue(String fullyQualQuery, Integer serialNumber) {
        try {
            String result;
            List<Map<String, Object>> subResult = getFieldValue(fullyQualQuery, serialNumber);

            if(!subResult.isEmpty()) {
                result = '' + subResult[0].values()[0];
            }        
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getSingleFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Replace Serial Number string with number in the query before processing
    * @author Tushar Walse | 17th Sep 2024 
    * @param conditionQuery Query to be pre-processed and also to be processed
    * @param serialNumber Value to replace Serial Number string in the query before processing
    * @return Boolean Outcome of the query
    **/
    @testvisible
    public Boolean check(String conditionQuery, Integer serialNumber) {
        conditionQuery = preProcessQuery(conditionQuery, serialNumber);
        return(check(conditionQuery));
    }
    
    /**
    * @description Get new indices of the array after sorting
    * @author Tushar Walse | 17th Sep 2024 
    * @param query1 Query without sort clause
    * @param query2 Query with sort clause
    * @return Integer[] Indices of the sorted records
    **/
    @testvisible
    public Integer[] getSortIndex(String query1, String query2) {
        try {
            Integer[] result = new Integer[]{};
            SObject[] sObjs1 = getRecords(query1).getRecords();
            SObject[] sObjs2 = getRecords(query2).getRecords();
            Id[] ids2 = new Id[]{};

            if(sObjs1 != null && sObjs2 != null) {
                for(SObject sObj2 : sObjs2) {
                    ids2.add(sobj2.Id);
                }
    
                for(SObject sObj1 : sObjs1) {
                    result.add(ids2.indexOf(sObj1.Id));
                }    
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getSortIndex: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
     * @description get the id (ids->parent.pField) of the record to be retrieved
     * @author Tushar Walse | 17th Sep 2024 
     * @param ids set of Id of parent records having field pField containing id of child records
     * @param pField the field containing id of child records
     * @return Set<Id>
     */
    @testvisible
    Set<Id> toChildIds(Set<Id> ids, String pField) {
        try {
            Set<Id> result = new Set<Id>();
            for(Id id : ids) {
                result.add((Id)getNodeFieldValue(id, pField));
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in toChildIds: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
     * @description get the value of the field fieldName of the record having Id id
     * @author Tushar Walse | 17th Sep 2024 
     * @param id of the record
     * @param fieldName whose value is to be returned
     * @return Object containing value of the field
     */
    @testvisible
    Object getNodeFieldValue(Id id, String fieldName) {
        try {
            Object result;
            result = dataTree.toNodes.get(id)[0].record.get(fieldName);
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getNodeFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
     * @description retrieve child record by child id
     * @author Tushar Walse | 17th Sep 2024 
     * @param childId Id of the record to be retrieved
     * @param childRecordsMap map of child id vs child record
     * @return SObject The child record
     */
    @testvisible
    SObject getChildRecord(Id childId, Map<Id, SObject> childRecordsMap) {
        try {
            SObject childRecord;
            if(childRecordsMap.containsKey(childId)) {
                childRecord = childRecordsMap.get(childId);
            }
            return childRecord;
        } catch (Exception e) {
            LOGGER.error('Error in getChildRecord: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
     * @description add child record to map of parentId vs childRecord
     * @author Tushar Walse | 17th Sep 2024 
     * @param result map of parentId vs childRecord
     * @param parentId id of the parent
     */
    @testvisible
    void addChild(Map<Id, SObject[]> result, Id parentId, SObject childRecord) {
        try {
            if(!result.containsKey(parentId)) {
                result.put(parentId, new SObject[]{});
            }
            if(childRecord == null) {
                return;
            }
            result.get(parentId).add(childRecord);
        } catch (Exception e) {
            LOGGER.error('Error in addChild: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
     * @description get map of parentId vs only childRecord (parent has childIdField)
     * @author Tushar Walse | 17th Sep 2024 
     * @param parentIds Ids of parents
     * @param args contains childIdFieldName.childObjectName
     * @param childRecords child records to be mapped to their corresponding parents
     * @return Map<Id, SObject[]> map of parentId vs childRecord
     */
    @testvisible
    Map<Id, SObject[]> getChildMap1(Set<Id> parentIds, String[] args, SObject[] childRecords) {
        try {
            Map<Id, SObject[]> result = new Map<Id, SObject[]>();
            Map<Id, SObject> childRecordsMap = new Map<Id, SObject>(childRecords);
            String childIdField = args[0];
            
            for(Id parentId : parentIds) {
                Id childId = (Id)getNodeFieldValue(parentId, childIdField);
                SObject childRecord = getChildRecord(childId, childRecordsMap);
                addChild(result, parentId, childRecord);
            }

            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getChildMap1: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
     * @description get map of parentId vs childRecord (child has parentIdField)
     * @author Tushar Walse | 17th Sep 2024 
     * @param children collection of child records
     * @param parentIdField field containing Id of it's parent
     * @return Map of parent id vs child record
     */
    @testvisible
    Map<Id, SObject[]> getMapByIdField(SObject[] children, String parentIdField) {
        try {
            Map<Id, List<SObject>> result = new Map<Id, List<SObject>>();
            for (SObject child : children) {
                Id parentId = (Id)child.get(parentIdField);
                if(parentId == null) {
                    continue;
                }
                if(!result.containsKey(parentId)) {
                    result.put(parentId, new SObject[]{});
                }
                result.get(parentId).add(child);
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getMapByIdField: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
     * @description retrieve child records of parentId
     * @author Tushar Walse | 17th Sep 2024 
     * @param parentId Id of the parent record
     * @param childRecordsMap map of parent Id vs it's children
     * @return list of child Records
     */
    @testvisible
    SObject[] getChildRecords(Id parentId, Map<Id, SObject[]> childRecordsMap, String typeName) {
        try {
            SObject[] result = new SObject[]{};
            if(childRecordsMap.containsKey(parentId)) {
                result.addAll(childRecordsMap.get(parentId));
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getChildRecords: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
     * @description add parent Id vs Children to the Map
     * @author Tushar Walse | 17th Sep 2024 
     * @param Map of parent Id vs Children
     * @param parentId Id of the parent
     * @param childRecords child Records
     */
    @testvisible
    void addChildRecords(Map<Id, SObject[]> result, Id parentId, SObject[] childRecords) {
        try {
            if(!result.containsKey(parentId)) {
                result.put(parentId, new SObject[]{});
            }
            result.get(parentId).addAll(childRecords);
        } catch (Exception e) {
            LOGGER.error('Error in addChildRecords: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
     * @description get map of parentId vs childRecords (child has parentIdField)
     * @author Tushar Walse | 17th Sep 2024 
     * @param parentIds Id of parent records
     * @param args parentIdField.childObjectName
     * @return Map of parent id vs child records
     */
    @testvisible
    Map<Id, SObject[]> getChildMap2(Set<Id> parentIds, String[] args, SObject[] childRecords) {
        try {
            Map<Id, SObject[]> result = new Map<Id, SObject[]>();

            String parentIdField = args[0];
            String typeName = args[1];

            Map<Id, SObject[]> childRecordsMap = getMapByIdField(childRecords, parentIdField);

            for(Id parentId : parentIds) {
                childRecords = getChildRecords(parentId, childRecordsMap, typeName);
                addChildRecords(result, parentId, childRecords);
            }

            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getChildMap2: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Load child object from already available parents
    * @author Tushar Walse | 23-09-2024 
    * @param relation Details of location of ids to retrieve child objects
    **/
    @testvisible
    void loadData(String relation) {
        try {
            if(relationsLoaded.contains(relation)) {
                return;
            }

            String[] relationParts = relation.split('\\.');

            String parentType = relationParts[0];
            String childType = relationParts[3];            
            if(parentType == 'Opportunity' && childType == 'Account') {
                return;
            }
            String fromTo;
            SObject[] childRecords;

            Set<Id> parentIds = dataTree.toIds.get(parentType);
            Set<Id> childIds;
            Map<Id, SObject[]> toChild;

            if(parentIds == null) {
                return;
            }
            if(parentType == relationParts[1] && !(relationParts.size() >= 5 && relationParts[4] == 'NoTransformId')) {
                String childIdField = relationParts[2];
                childIds = toChildIds(parentIds, childIdField);
                fromTo = childType;
                childRecords = recordsByIds(fromTo, childIds);
                String[] args = new String[]{childIdField, childType};
                toChild = getChildMap1(parentIds, args, childRecords);
                storeAllSobjects(fromTo, childRecords);
            } else {
                fromTo = parentType + '.' + childType;
                childRecords = recordsByIds(fromTo, parentIds);
                String parentIdField = relationParts[2];
                String[] args = new String[]{parentIdField, childType};
                toChild = getChildMap2(parentIds, args, childRecords);
                storeAllSobjects(fromTo, toChild);
            }
            
            for(Id parentId : parentIds) {
                dataTree.addNodes(parentId, toChild.get(parentId), childType);
            }

            objectsLoaded.add(parentType + '.' + childType);
            relationsLoaded.add(relation);
        } catch (Exception e) {
            LOGGER.error('Error in loadData: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description Load records by object name
    * @author Tushar Walse | 17th Sep 2024 
    * @param objectName Name of object to retrieve records of
    * @return SObject[] List of records
    **/
    @SuppressWarnings('PMD.AvoidSoqlInLoops')
    @testvisible
    SObject[] recordsByName(String objectName) {
        try {
            SObject[] returnRecords = new SObject[]{};
            if(rootObjectsLoadedById.contains(objectName)) {
                return returnRecords;
            }
            switch on objectName {
                when 'ProcessInstance' {
                    returnRecords = new SEL_ProcessInstance().selectByTargetObjectTypeTargetObjectRecordTypeAndStatus('Opportunity', 'ICS Applicant', 'Pending');
                }
                when 'ProcessInstanceStep' {
                    returnRecords = new SEL_ProcessInstanceStep().selectByTargetObjectTypeTargetObjectRecordTypeAndStatus('Opportunity', 'ICS Applicant', 'Pending');
                }
                when 'AOB_ReferencedData__c' {
                    returnRecords = [SELECT Id, Name, AOB_Code__c, AOB_SAPField__c from AOB_ReferencedData__c where AOB_SAPField__c like 'ICS%' order by Name desc];
                }
                when 'BusinessHours' {
                    returnRecords = [SELECT Id from BusinessHours where Name = 'IoM Mon-Fri (07H00-17H00) GMT +00'];
                }
                when 'CurrencyType' {
                    returnRecords = [SELECT IsoCode, ConversionRate from CurrencyType];
                }                
                when else {
                    utils.myThrow(true, 'Unknown Object Name: ' + objectName);
                }
            }

            storeAllSobjects(objectName, returnRecords);

            return returnRecords;
        } catch (Exception e) {
            LOGGER.error('Error in recordsByName: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Maintain a map of SF Object, Id, Record
    * @author Tushar Walse | 17th Sep 2024 
    * @param objectName Name of the SF Object as key to store the records under
    * @param returnRecords List of records to maintain reference to for future use
    **/
    @testvisible
    void storeAllSobjects(String objectName, SObject[] returnRecords) {
        try {
            if(!allSObjects.containsKey(objectName)) {
                allSObjects.put(objectName, new Map<Id, SObject[]>());
            }
            for(SObject sObj : returnRecords) {
                allSObjects.get(objectName).put(sObj.Id, new SObject[]{sObj});
            }
        } catch (Exception e) {
            LOGGER.error('Error in storeAllSobjects: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description Maintain a map of SF Object, Id, Record
    * @author Tushar Walse | 17th Sep 2024 
    * @param objectName Name of the SF Object as key to store the records under
    * @param toChild Map of records to maintain reference to for future use
    **/
    @testvisible
    void storeAllSobjects(String objectName, Map<Id, List<SObject>> toChild) {
        try {
            if(!allSObjects.containsKey(objectName)) {
                allSObjects.put(objectName, new Map<Id, SObject[]>());
            }
            allSObjects.get(objectName).putAll(toChild);
        } catch (Exception e) {
            LOGGER.error('Error in storeAllSobjects: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description Retrieve records by ids if they aren't retrieved before
    * @author Tushar Walse | 23-09-2024 
    * @param relation Parent object name.Child object name
    * @param ids Set of ids to use to retrieve the records
    * @return SObject[] List of records retrieved
    **/
    @testvisible
    @SuppressWarnings('PMD.NPathComplexity, PMD.CyclomaticComplexity, PMD.ExcessiveMethodLength, PMD.NcssMethodCount') //Make code manageable at one place
    SObject[] recordsByIds(String relation, Set<Id> ids) {
        try {
            SObject[] returnRecords = new SObject[]{};

            for(Id id : ids) {
                if(allSObjects.containsKey(relation) && allSObjects.get(relation).containsKey(id)) {
                    returnRecords.addAll(allSObjects.get(relation).get(id));
                }
            }

            ids.removeAll(new Map<Id, SObject>(returnRecords).keySet());

            if(ids.isEmpty()) {
                return returnRecords;
            }

            switch on relation {
                when 'Opportunity' {
                    returnRecords.addAll(new SEL_Opportunity().selectByIds(ids));
                }
                when 'ProcessInstanceStep' {
                    returnRecords.addAll(new SEL_ProcessInstanceStep().selectByIds(ids));
                }
                when 'ProcessInstanceWorkitem' {
                    returnRecords.addAll(new SEL_ProcessInstanceWorkItem().selectByIds(ids));
                }
                when 'PartyProfile' {
                    returnRecords.addAll(new SEL_PartyProfile().selectByIds(ids));
                }
                when 'Account' {
                    returnRecords.addAll(new SEL_Account().selectByIds(ids));
                }
                when 'ProcessInstance' {
                    returnRecords.addAll(new SEL_ProcessInstance().selectByIds(ids));
                }
                when 'Group' {
                    returnRecords.addAll(new SEL_Group().selectByIds(ids));
                }
                when 'Product2' {
                    returnRecords.addAll(new SEL_Product2().selectByIds(ids));
                }
                when 'RecordType' {
                    returnRecords.addAll([SELECT Id, DeveloperName, SobjectType, Name, Description, BusinessProcessId, IsActive, IsPersonType, NamespacePrefix FROM RecordType where id IN :ids]);
                }
                when 'ContentVersion' {
                    returnRecords.addAll(new SEL_ContentVersion().selectByIds(ids));
                }
                when 'ContentDocument' {
                    returnRecords.addAll(CMN_DAL_ContentDocument.getContentDocumentsById(ids));
                }
                when 'AssessmentQuestion' {
                    returnRecords.addAll(new SEL_AssessmentQuestion().selectByIds(ids));
                }
                when 'AssessmentQuestionVersion' {
                    returnRecords.addAll(new SEL_AssessmentQuestionVersion().selectByIds(ids));
                }
                when 'User' {        
                    returnRecords.addAll(new SEL_User().selectUsersByIds(ids));
                }
                when 'UserRole' {
                    returnRecords.addAll(new SEL_UserRole().selectByIds(ids));
                }
                when 'PartyProfile.Party_Assets_Funds__c' {
                    returnRecords.addAll(new SEL_PartyAssetFunds().selectByPartyProfileIds(ids));
                }
                when 'Party_Assets_Funds__c.Party_Assets_Funds__c' {
                    returnRecords.addAll(new SEL_PartyAssetFunds().selectByTrusts(ids));
                }
                when 'PartyProfile.PartyProfile' {
                    returnRecords.addAll(new SEL_PartyProfile().selectByRelatedPartyProfileIds(ids));
                }
                when 'PartyProfile.PartyProfileRisk' {
                    returnRecords.addAll(new SEL_PartyProfileRisk().selectByPartyProfileIds(ids));
                }
                when 'PartyProfile.PartyScreeningSummary' {
                    returnRecords.addAll(new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(ids));
                }
                when 'PartyScreeningSummary.PartyScreeningStep' {
                    returnRecords.addAll(new SEL_PartyScreeningStep().selectBySummaryIds(ids));
                }
                when 'PartyProfile.ContentDocumentLink', 'IdentityDocument.ContentDocumentLink', 'Account.ContentDocumentLink' {
                    returnRecords.addAll(new SEL_ContentDocumentLink().selectByLinkedEntity(ids));
                }
                when 'Account.IdentityDocument' {
                    returnRecords.addAll(new SEL_IdentityDocument().selectByAccountIds(ids));
                }                    
                when 'PartyProfile.PartyIdentityVerification' {
                    returnRecords.addAll(new SEL_PartyIdentityVerification().selectByPartyProfileIds(ids));
                }
                when 'PartyIdentityVerification.PartyIdentityVerificationStep' {
                    returnRecords.addAll(new SEL_PartyIdentityVerificationStep().selectByVerificationId(ids));
                }
                when 'PartyProfile.PartyProfileAddress' {
                    returnRecords.addAll(new SEL_PartyProfileAddress().selectByPartyProfileIds(ids));
                }
                when 'Account.Assessment' {
                    returnRecords.addAll(new SEL_Assesment().selectByAccountIds(ids));
                }
                when 'User.GroupMember', 'Group.GroupMember' {
                    returnRecords.addAll(new SEL_GroupMember().selectByUserOrGroupIds(ids));
                }
                when 'UserRole.Group' {
                    returnRecords.addAll(new SEL_Group().selectByRelatedIdsAndType(ids, 'Role'));
                }
                when 'Assessment.AssessmentQuestionResponse' {
                    returnRecords.addAll(new SEL_AssesmentQuestionResponse().selectByAssessmentIds(ids));
                }
                when 'ApplicationForm.ApplicationFormProduct' {
                    returnRecords.addAll(new SEL_ApplicationFormProduct().selectByApplicationFormIds(ids));
                }
                when 'ApplicationForm.ApplicationFormHistory' {
                    returnRecords.addAll(new SEL_ApplicationFormHistory().selectByApplicationFormIds(ids));
                }
                when 'ProcessInstance.ProcessInstanceWorkitem' {
                    returnRecords.addAll(new SEL_ProcessInstanceWorkItem().selectByProcessInstanceIds(ids));
                }
                when 'Opportunity.OpportunityLineItem' {
                    returnRecords.addAll(new SEL_OpportunityLineItem().selectByOpportunityIds(ids));
                }
                when 'ProcessInstance.ProcessInstanceStep' {
                    returnRecords.addAll(new SEL_ProcessInstanceStep().selectByProcessInstanceId(ids));
                }
                when 'Account.TaxDetails__c' {
                    returnRecords.addAll(new SEL_TaxDetails().selectByAccountIds(ids));
                }
                when 'Account.ContactPointPhone' {
                    returnRecords.addAll(new SEL_ContactPointPhone().selectByParentIds(ids));
                }
                when 'Account.ContactPointEmail' {
                    returnRecords.addAll(new SEL_ContactPointEmail().selectByAccountIds(ids));
                }
                when 'Opportunity.ApplicationForm' {
                    returnRecords.addAll(new SEL_ApplicationForm().selectByOpportunityIds(new List<Id>(ids)));
                }
                when 'Opportunity.ProcessInstance' {
                    returnRecords.addAll(new SEL_ProcessInstance().selectByTargetObjectId(ids));
                }
                when 'ApplicationForm.Applicant' {
                    returnRecords.addAll(new SEL_Applicant().selectByApplicationFormIds(ids));
                }
                when 'Account.FinServ__Employment__c' {
                    returnRecords.addAll(new SEL_Employment().selectByAccountIds(ids));
                }
                when else {
                    utils.myThrow(true, 'Unknown relation: ' + relation);
                }
            }
            
            return returnRecords;
        } catch (Exception e) {
            LOGGER.error('Error in recordsByIds: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Sort or drop records that don't satisfy the specified condition clause
    * @author Tushar Walse | 17th Sep 2024 
    * @param returnVe Records to be filtered
    * @param filterCondition Clause in query to be used to filter records
    * @param objectName Name of the SF Object whose records we are currently dealing with 
    * @return SObject[] List of filtered records
    **/
    @SuppressWarnings('PMD.ConfusingTernary') //Code manageability
    @testvisible
    SObject[] filterRecords(SObject[] returnVe, String filterCondition, String objectName) {
        try {
                Integer index;
                String indexString = filterCondition.substringBefore(' ');
                if(indexString.isNumeric()) {
                    index = Integer.valueof(indexString);
                    filterCondition = filterCondition.substringAfter(' ');
                }
                String sortToken = 'Sort By ';
                if(filterCondition.contains(sortToken)) {
                    String sortString = filterCondition.substringAfter(sortToken);
                    filterCondition = filterCondition.substringBeforeLast(sortToken).trim();
                    String fieldName = sortString.substringBefore(' ');
                    String order = sortString.substringAfter(' ').trim();
                    returnVe.sort(new ICS_CTRL_GetDataUtils.SObjectComparator(utils.getField(objectName, fieldName), order));
                }

                if(!String.isBlank(filterCondition) && !filterCondition.contains(' || ')) {
                    String[] conditions = filterCondition.split(' && ');
                    for(String condition : conditions) {
                        returnVe = getRecordsSatisfyingCondition(returnVe, condition);
                    }
                } else if(!String.isBlank(filterCondition) && filterCondition.contains(' || ')) {
                    String[] conditions = filterCondition.split(' \\|\\| ');
                    SObject[] subReturnVe = new SObject[]{};
                    for(String condition : conditions) {
                        subReturnVe.addAll(getRecordsSatisfyingCondition(returnVe, condition));
                    }
                    returnVe = subReturnVe;
                }

                if(index != null) {
                    if(index < returnVe.size()) {
                        returnVe = new SObject[]{returnVe[index]};
                    } else {
                        returnVe = new SObject[]{};
                    }
                }
    
            return returnVe;
        } catch (Exception e) {
            LOGGER.error('Error in filterRecords: {0}\nfilterCondition: {1}\nobjectName: {2}\nline: {3}', new Object[]{e.getMessage(), filterCondition, objectName, e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description Fetch only those records that satisfy the specified condition clause
    * @author Tushar Walse | 17th Sep 2024 
    * @param filterCondition Clause in query to be used to filter records
    * @param objectName Name of the SF Object whose records we are currently dealing with 
    **/
    @testvisible
    void filterRecords(ICS_CTRL_GetBrowseTree browseTree, String filterCondition, String objectName) {
        try {
            if(filterCondition == null) {
                return;
            }
            SObject[] returnVe = new SObject[]{};
            Map<Id, ICS_CTRL_GetBrowseTree.BrowseNode[]> idToBrowseNodes = new Map<Id, ICS_CTRL_GetBrowseTree.BrowseNode[]>();
            for(ICS_CTRL_GetBrowseTree.BrowseNode browseNode : browseTree.leaves) {
                returnVe.add(browseNode.dataNode.record);
                if(!idToBrowseNodes.containsKey(browseNode.dataNode.record.Id)) {
                    idToBrowseNodes.put(browseNode.dataNode.record.Id, new ICS_CTRL_GetBrowseTree.BrowseNode[]{});
                }
                idToBrowseNodes.get(browseNode.dataNode.record.Id).add(browseNode);
            }
            
            returnVe = filterRecords(returnVe, filterCondition, objectName);

            ICS_CTRL_GetBrowseTree.BrowseNode[] newLeaves = new ICS_CTRL_GetBrowseTree.BrowseNode[]{};
            for(SObject sObj : new Set<SObject>(returnVe)) {
                newLeaves.addAll(idToBrowseNodes.get(sObj.Id));
            }
            browseTree.leaves = newLeaves;
        } catch (Exception e) {
            LOGGER.error('Error in filterRecords: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description Pre-process query, replace Serial Number string with actual numeric value
    * @author Tushar Walse | 23-09-2024 
    * @param conditionQuery Query to be pre-processed
    * @param serialNumber value to replace Serial Number string in the query before processing
    * @return String Pre-processed query
    **/
    @testvisible
    String preProcessQuery(String conditionQuery, Integer serialNumber) {
        try {
            utils.myThrow(serialNumber == null, 'Serial number cannot be null');
            return(conditionQuery.replace('(Serial number)', '(' + serialNumber + ')'));
        } catch (Exception e) {
            LOGGER.error('Error in preProcessQuery: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Evaluate condition when testValue is blank or null
    * @author Tushar Walse | 23-09-2024 
    * @param condition Existing value of condition
    * @param testValue Values specified as second operand
    * @return Boolean Outcome of evaluation
    **/
    @testvisible
    Boolean evaluateNull(Boolean condition, Object testValue) {
        condition = testValue == null;
        if(testValue instanceOf List<Object>) {
            condition = condition || ((List<Object>)testValue).contains(null);
        }
        return condition;
    }

    /**
    * @description Get records satisfying the condition
    * @author Tushar Walse | 17th Sep 2024 
    * @param returnVe Existing list of records
    * @param index Condition string to evaluate
    * @return SObject[] 
    **/
    @testvisible
    SObject[] getRecordsSatisfyingCondition(SObject[] returnVe, String index) {
        try {
            SObject[] s = new SObject[]{};
            String fieldName = index.substringBefore(' ');
            String operator = index.substringBetween(fieldName, ':').trim();
            Boolean flipCondition = false;
            if(operator.startsWith('!')) {
                operator = operator.substringAfter('!');
                flipCondition = true;
            }

            String vString = index.substringAfter(':');
            Object testValue = JSON.deserializeUntyped(vString);

            for(SObject sObj : returnVe) {
                Boolean condition = false;
                if(sObj.get(fieldName) == null) {
                    condition = evaluateNull(condition, testValue);
                } else {
                    condition = evaluateCondition(sObj, testValue, new String[]{fieldName, operator, vString});
                }
                condition = flipCondition ? !condition : condition;
                if(condition) {
                    s.add(sObj);
                }                
            }

            if(s.size() > 0) {
                String[] fieldNameAndValues = new String[]{};
                String fullFieldName = dataTree?.toNodes?.get(s[0]?.Id)[0]?.type + '.' + fieldName;
                fieldNameAndValues.add(fullFieldName);
                for(SObject sObj : s) {
                    fieldNameAndValues.add('' + sObj.get(fieldName));
                }

                businessUserLog.add('\nTriggers: ' + JSON.serialize(fieldNameAndValues));
            }

            return(s);
        } catch (Exception e) {
            LOGGER.error('Error in getRecordsSatisfyingCondition: {0}\nline: {1}\nindex: {2}', new Object[]{e.getMessage(), e.getLineNumber(), index});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param sObj 
    * @param testValue Values specified as second operand
    * @param params 
    * @return Boolean Outcome of evaluation
    **/
    @testvisible
    @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
    Boolean evaluateCondition(SObject sObj, Object testValue, String[] params) {
        try {
            String fieldName = params[0];
            String operator = params[1];

            Boolean condition = false;

            List<Object> testValues = new List<Object>();
            if(testValue instanceOf List<Object>) {
                testValues.addAll((List<Object>)testValue);
            } else {
                testValues.add(testValue);
            }
            
            switch on operator {
                when '=' {
                    utils.myThrow(testValues.size()>1, 'Array Provided Instead of Single Value!');
                    if(testValues[0] instanceOf Integer || testValues[0] instanceof Decimal) {
                        condition = (Decimal)sObj.get(fieldName) == (Decimal)testValues[0];
                    } else if(testValues.size()==0) {
                            condition = false;
                    } else {
                        condition = sObj.get(fieldName) == testValues[0];
                    }
                }
                when '>' {
                    utils.myThrow(testValues.size()>1, 'Array Provided Instead of Single Value!');
                    utils.myThrow(testValues.size()==0, 'Empty Array Provided Instead of Single Value!');
                    condition = (Decimal)sObj.get(fieldName) > (Decimal)testValues[0];
                }
                when '<' {
                    utils.myThrow(testValues.size()>1, 'Array Provided Instead of Single Value!');
                    utils.myThrow(testValues.size()==0, 'Empty Array Provided Instead of Single Value!');
                    condition = (Decimal)sObj.get(fieldName) < (Decimal)testValues[0];
                }
                when 'CONTAINS' {
                    utils.myThrow(testValues.size()>1, 'Array Provided Instead of Single Value!');
                    utils.myThrow(testValues.size()==0, 'Empty Array Provided Instead of Single Value!');
                    condition = ((String)sObj.get(fieldName)).contains((String)testValues[0]);
                }
                when 'iCONTAINS' {
                    utils.myThrow(testValues.size()>1, 'Array Provided Instead of Single Value!');
                    utils.myThrow(testValues.size()==0, 'Empty Array Provided Instead of Single Value!');
                    condition = ((String)sObj.get(fieldName)).toLowerCase().contains(((String)testValues[0]).toLowerCase());
                }
                when 'StartsWith' {
                    utils.myThrow(testValues.size()>1, 'Array Provided Instead of Single Value!');
                    utils.myThrow(testValues.size()==0, 'Empty Array Provided Instead of Single Value!');
                    condition = ((String)sObj.get(fieldName)).startsWith((String)testValues[0]);
                }
                when 'EndsWith' {
                    utils.myThrow(testValues.size()>1, 'Array Provided Instead of Single Value!');
                    utils.myThrow(testValues.size()==0, 'Empty Array Provided Instead of Single Value!');
                    condition = ((String)sObj.get(fieldName)).endsWith((String)testValues[0]);
                }
                when 'IN' {
                    if(testValues.size()==0) {
                        condition = false;
                    } else {
                        condition = testValues.contains(sObj.get(fieldName));
                    }
                }
                when 'iIN' {
                    if(testValues.size()==0) {
                        condition = false;
                    } else {
                        List<String> testValuesLower = new String[]{};
                        for(Object value : testValues) {
                            testValuesLower.add(('' + value).toLowerCase());
                        }
                        condition = testValuesLower.contains(((String)sObj.get(fieldName)).toLowerCase());
                    }
                }
                when else {
                    utils.myThrow(true, 'Unknown Operator: ' + operator);
                }
            }
            return condition;
        } catch (Exception e) {
            LOGGER.error('Error in evaluateCondition: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param sObjects 
    * @param fieldValues 
    * @param args 
    **/
    @testvisible
    void getFieldValue(ICS_CTRL_GetBrowseTree sObjects, Map<String, Object[]> fieldValues, String[] args) {
        try {
            String actualFieldName = args[0];
            String fieldName = args[1];
            String functionCall = args[2];
            if(functionCall == 'FieldValueReplace') {
                String fieldKey = actualFieldName.substringBefore(';');
                actualFieldName = actualFieldName.substringAfter(';');
                String[] subFields = actualFieldName.split('\\#');
                List<Map<String, Object>> subFieldValues = getFieldValue(sObjects, subFields);
                Object[] outValue = new Object[]{};
                for(Map<String, Object> subFieldValue : subFieldValues) {
                    Object[] objects = subFieldValue.values();
                    String key = String.join(utils.objectToString(objects), '');
                    if(fieldValueReplacementMap.containsKey(key) && fieldValueReplacementMap.get(key).containsKey(fieldKey)) {
                        outValue.add(fieldValueReplacementMap.get(key).get(fieldKey));                        
                    } else if(objects.size() > 0) {
                        outvalue.add(objects[objects.size()-1]);
                    }
                }
                fieldValues.put(fieldName, outValue);
            } else if(functionCall == 'FieldValueReplaceNull') {
                String fieldKey = actualFieldName.substringBefore(';');
                actualFieldName = actualFieldName.substringAfter(';');
                String[] subFields = actualFieldName.split('\\#');
                List<Map<String, Object>> subFieldValues = getFieldValue(sObjects, subFields);
                Object[] outValue = new Object[]{};
                for(Map<String, Object> subFieldValue : subFieldValues) {
                    Object[] objects = subFieldValue.values();
                    String key = String.join(utils.objectToString(objects), '');
                    if(fieldValueReplacementMap.containsKey(key) && fieldValueReplacementMap.get(key).containsKey(fieldKey)) {
                        outValue.add(fieldValueReplacementMap.get(key).get(fieldKey));                        
                    } else {
                        outvalue.add(null);
                    }
                }
                fieldValues.put(fieldName, outValue);
            } else if(actualFieldName.contains('+') && functionCall == 'Join2') {
                String delimeter = actualFieldName.substringBefore(';');
                actualFieldName = actualFieldName.substringAfter(';');
                String[] subFields = actualFieldName.split('\\+');
                List<Map<String, Object>> subFieldValues = getFieldValue(sObjects, subFields);
                String[] outValue = new String[]{};
                for(Map<String, Object> subFieldValue : subFieldValues) {
                    outValue.add(String.join(utils.objectToString2(subFieldValue.values()), delimeter));
                }
                fieldValues.put(fieldName, outValue);
            } else if(actualFieldName.contains('+')) {
                String delimeter = actualFieldName.substringBefore(';');
                actualFieldName = actualFieldName.substringAfter(';');
                String[] subFields = actualFieldName.split('\\+');
                List<Map<String, Object>> subFieldValues = getFieldValue(sObjects, subFields);
                String[] outValue = new String[]{};
                for(Map<String, Object> subFieldValue : subFieldValues) {
                    outValue.add(String.join(utils.objectToString(subFieldValue.values()), delimeter));
                }
                fieldValues.put(fieldName, outValue);
            } else {
                String arg = actualFieldName.substringAfter(';');
                actualFieldName = actualFieldName.substringBefore(';');
                fieldValues.put(fieldName, utils.applyFunction(functionCall, getFieldValue(sObjects, actualFieldName), arg));    
            }
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param sObjects 
    * @param fieldNames 
    * @return List<Map<String, Object>> 
    **/
    @testvisible
    List<Map<String, Object>> getFieldValue(ICS_CTRL_GetBrowseTree sObjects, String[] fieldNames) {
        try {

            List<Map<String, Object>> table;
            Map<String, Object[]> fieldValues = new Map<String, Object[]>();
            for(String fieldName : fieldNames) {
                String functionCall = fieldName.substringBefore(' As ');
                String actualFieldName = utils.getBracketContent(functionCall);                
                if(actualFieldName == null) {
                    actualFieldName = functionCall;
                    fieldValues.put(fieldName, getFieldValue(sObjects, actualFieldName));
                } else {
                    functionCall = functionCall.substringBefore('(');
                    getFieldValue(sObjects, fieldValues, new String[]{actualFieldName, fieldName, functionCall});
                }
            }
            table = getTable(fieldValues, fieldNames);
            return(table);
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param fieldValues 
    * @param fieldNames 
    * @return List<Map<String, Object>> 
    **/
    @testvisible
    List<Map<String, Object>> getTable(Map<String,List<Object>> fieldValues, String[] fieldNames) {
        try {
            List<Map<String, Object>> table = new List<Map<String, Object>>();
            Integer maxValuesCount = 0;
            for(String fieldName : fieldNames) {
                if(maxValuesCount < fieldValues.get(fieldName).size()) {
                    maxValuesCount = fieldValues.get(fieldName).size();
                }
            }

            for(Integer fieldValueIndex = 0; fieldValueIndex < maxValuesCount; fieldValueIndex++) {
                table.add(fillRow(fieldValues, fieldNames, fieldValueIndex));
            }
            return table;
        } catch (Exception e) {
            LOGGER.error('Error in getTable: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param fieldValues 
    * @param fieldNames 
    * @param fieldValueIndex 
    * @return Map<String, Object> 
    **/
    @testvisible
    Map<String, Object> fillRow(Map<String,List<Object>> fieldValues, String[] fieldNames, Integer fieldValueIndex) {
        try {
            Map<String, Object> row = new Map<String, Object>();
            for(String fieldName : fieldNames) {
                if(fieldValueIndex < fieldValues.get(fieldName).size()) {
                    String alias = fieldName.substringAfter(' As ');
                    alias = alias == '' ? fieldName : alias;
                    row.put(alias, fieldValues.get(fieldName)[fieldValueIndex]);    
                }
            }
            return row;
        } catch (Exception e) {
            LOGGER.error('Error in fillRow: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param fieldName 
    * @param serialNumber value to replace Serial Number string in the query before processing
    * @return List<Map<String, Object>> 
    **/
    @testvisible
    List<Map<String, Object>> getFieldValue(String fieldName, Integer serialNumber) {
        try {
            fieldName = preProcessQuery(fieldName, serialNumber);
            return(getFieldValue(fieldName));
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }
    
    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param browseTree 
    * @param fieldName 
    * @return Object[] 
    **/
    @testvisible
    Object[] getFieldValue(ICS_CTRL_GetBrowseTree browseTree, String fieldName) {
        try {
            Object[] returnVe = new Object[]{};
            for(ICS_CTRL_GetBrowseTree.BrowseNode browseNode : browseTree.leaves) {
                SObject sObj = browseNode.dataNode.record;
                Map<String, Object> fieldsToValue = sObj.getPopulatedFieldsAsMap();
                if(!fieldName.contains('.') && fieldsToValue.containsKey(fieldName)) {
                    returnVe.add(sObj.get(fieldName));
                } else {
                    returnVe.add(getAscendantUsedFieldValue(browseNode, fieldName));
                }
            }
            return(returnVe);
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param browseNode 
    * @param fieldName 
    * @return Object 
    **/
    @testvisible
    Object getAscendantUsedFieldValue(ICS_CTRL_GetBrowseTree.BrowseNode browseNode, String fieldName) {
        try {
            Object returnVe;
            if(fieldName.contains('.')) {
                String[] objects = fieldName.split('\\.');
                String actualFieldName = objects.remove(objects.size()-1);
                SObject sObj = browseNode.getAscendantUsed(objects);                
                if(sObj != null) {
                    Map<String, Object> fieldsToValue = sObj.getPopulatedFieldsAsMap();
                    if(fieldsToValue.containsKey(actualFieldName)) {
                        returnVe = sObj.get(actualFieldName);
                    }
                }
            }
            return(returnVe);
        } catch (Exception e) {
            LOGGER.error('Error in getAscendantUsedFieldValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param fieldName 
    * @param serialNumber value to replace Serial Number string in the query before processing
    * @param columnNamesString 
    * @return List<Map<String, String>> 
    **/
    @testvisible
    List<Map<String, String>> getFieldValuesHorizontally(String fieldName, Integer serialNumber, String columnNamesString) {
        try {
            String[] columnNames = (String[])(JSON.deserialize(columnNamesString, String[].class));
            List<Map<String, String>> returnVes = new List<Map<String, String>>();
            List<Map<String, Object>> records = getFieldValue(fieldName, serialNumber);
            if(records.isEmpty()) {
                return returnVes;
            }

            Set<String> keys = records[0].keySet();
            Boolean flagDisplayIfTrue = false;
            for(String key : keys) {
                Map<String, String> returnVe = new Map<String, String>();
                Integer j = 0;
                if(columnNames[j].startsWith('Display only if True')) {
                    flagDisplayIfTrue = true;
                    j++;
                }
                if(columnNames[j].startsWith('{\'FormatOfTheNextField')) {
                    returnVe.putAll(utils.fromJSONtoMap(columnNames[j].replace('\'', '"')));
                    j++;
                }
                returnVe.put(columnNames[j], key);
                j++;
                Boolean falseVeEncountered = fetchRows(records, returnVe, new Object[]{key, columnNames, j});

                if(!flagDisplayIfTrue || (flagDisplayIfTrue && !falseVeEncountered)) {
                    returnVes.add(returnVe);
                }
            }

            return(returnVes);
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValuesHorizontally: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }    

    /**
     * @description Function to retrieve rows having true values
     * @param records records to be processed
     * @param returnVe rows of data to be displayed
     * @param args containing key = name of false field, columnNames = name of all columns, j = current column number
     * @return Boolean true if false value is encountered in the record
     */
    @testvisible
    Boolean fetchRows(List<Map<String, Object>> records, Map<String, String> returnVe, Object[] args) {
        try {
            String key = (String)args[0];
            String[] columnNames = (String[])args[1];
            Integer j = (Integer)args[2];
            Boolean falseVeEncountered = false;
            for(Map<String, Object> record : records) {
                if(j < columnNames.size() && columnNames[j].startsWith('{\'FormatOfTheNextField')) {
                    returnVe.putAll(utils.fromJSONtoMap(columnNames[j].replace('\'', '"')));
                    j++;
                }
                String columnName;
                if(j >= columnNames.size()) {
                    columnName = columnNames[columnNames.size()-1] + ' '.repeat(j-columnNames.size()+1);
                } else {
                    columnName = columnNames[j];
                }
                returnVe.put(columnName, '' + record.get(key));
                if(returnVe.get(columnName).toLowerCase().trim() == 'false') {
                    falseVeEncountered = true;
                }
                j++;
            }
            return falseVeEncountered;
        } catch (Exception e) {
            LOGGER.error('Error in fetchRows: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Split semicolon seperated list of country names into seperate rows
    * @author Tushar Walse | 25-09-2024 
    * @param countryNameStrings List of semicolon seperated list of country names
    * @param columnNamesString Heading of the column
    * @return List<Map<String, String>> The table
    **/
    List<Map<String,String>> createCountryTable(String[] countryNameStrings, String columnNamesString) {
        List<Map<String,String>> theTable = new List<Map<String,String>>();
        for(String countryNameString : countryNameStrings) {
            for(String countryName : countryNameString.split(';')) {
                theTable.add(new Map<String, String>{columnNamesString => countryName});
            }
        }
        return theTable;
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param stringParts Column names
    * @param tables 
    * @param serialNumber value to replace Serial Number string in the query before processing
    **/
    @testvisible
    void fetchTables(String[] stringParts, Map<String, Object> tables, Integer serialNumber) {
        try {
            String[] specStrings = new String[]{' (To be Oriented Horizontally)', ' (Country codes to Names to be split by semicolon into lines)'};
            if(stringParts[0].contains(specStrings[0])) {
                String columnNamesString = stringParts[0].substringAfter(specStrings[0]);
                stringParts[0] = stringParts[0].remove(specStrings[0] + columnNamesString);
                tables.put(stringParts[0], getFieldValuesHorizontally(stringParts[1], serialNumber, columnNamesString));
            } else if(stringParts[0].contains(specStrings[1])) {
                String columnNamesString = stringParts[0].substringAfter(specStrings[1]);
                stringParts[0] = stringParts[0].remove(specStrings[1] + columnNamesString);
                columnNamesString = columnNamesString.removeStart(' ');
                String[] countryNameStrings = (String[])JSON.deserialize(stringParts[1], String[].class);
                tables.put(stringParts[0], createCountryTable(countryNameStrings, columnNamesString));
            } else {
                tables.put(stringParts[0], getFieldValue(stringParts[1], serialNumber));
            }
        } catch (Exception e) {
            LOGGER.error('Error in fetchTables: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description Check if another line is left to be processed
    * @author Tushar Walse | 17th Sep 2024 
    * @param stringParts Condition strings to be evaluated
    * @param i Index of current condition string
    * @return Boolean True if line is left to be processed
    **/
    @testvisible
    Boolean nextLineExists(String[] stringParts, Integer i) {
        try {
            Boolean result = false;
            i++;
            if(i < stringParts.size() && stringParts[i].trim().length()>0 && stringParts[i] != 'OR' && stringParts[i] != 'OR2' && stringParts[i] != 'AND') {
                result = true;
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in nextLineExists: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Increment only if a line to process exists
    * @author Tushar Walse | 24-09-2024 
    * @param stringParts Condition strings to be evaluated
    * @param i Index of current condition string
    * @return Integer New value of index of current condition string
    **/
    @testvisible
    Integer checkAndIncrement(String[] stringParts, Integer i) {
        try {
            if(nextLineExists(stringParts, i)) {
                i++;
            }
            return i;
        } catch (Exception e) {
            LOGGER.error('Error in checkAndIncrement: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Check if there is a line left to be processed
    * @author Tushar Walse | 24-09-2024 
    * @param stringParts List of all condition strings
    * @param i Index of condition string
    * @param toLog Outcome true if condition lines is still left to be processed
    * @return Boolean Outcome true if line left to be processed
    **/
    @testvisible
    Boolean checkToLog(String[] stringParts, Integer i, Boolean toLog) {
        try {
            if(nextLineExists(stringParts, i)) {
                toLog = true;
            }
            return toLog;
        } catch (Exception e) {
            LOGGER.error('Error in checkToLog: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Check condition and if true log the message
    * @author Tushar Walse | 24-09-2024 
    * @param condition Condition to check before logging
    * @param stringToLog Message to log
    **/
    @testvisible
    void checkAndLog(Boolean condition, String stringToLog) {
        try {
            if(condition) {
                businessUserLog.add(stringToLog);
            }
        } catch (Exception e) {
            LOGGER.error('Error in checkAndLog: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        }
    }

    /**
    * @description Evaluate subConditions with logical operators mentioned explicitly
    * @author Tushar Walse | 23-09-2024 
    * @param stringParts List of criteria with logical operators (suffix 2 for verbose)
    * @return Boolean Grand result of evaluation
    **/
    @testvisible
    @SuppressWarnings('PMD.CognitiveComplexity, PMD.UnusedLocalVariable, PMD.NcssMethodCount') //Make code manageable at one place
    Boolean runLoop(List<String> stringParts) {
        try {
            Boolean subCondition;
            Integer i = 1;
            while(i < stringParts.size() && stringParts[i].length() != 0) {
                Boolean toLog = false;
                if(i == 1) {
                    toLog = checkToLog(stringParts, i, toLog);
                    i = checkAndIncrement(stringParts, i);
                    subCondition = checkEach(stringParts[i]);
                    checkAndLog(toLog && subCondition != null, stringParts[i-1] + (subCondition != null && subCondition ? ': Satisfied' : ': NOT SATISFIED') + '\n\n');
                    i+=1;
                    continue;
                }
                switch on stringParts[i] {
                    when 'OR' {
                        i++;
                        i = checkAndIncrement(stringParts, i);
                        subCondition = subCondition || checkEach(stringParts[i]);                            
                    }
                    when 'OR2' {
                        i++;
                        toLog = checkToLog(stringParts, i, toLog);
                        i = checkAndIncrement(stringParts, i);
    
                        Boolean secondCondition = checkEach(stringParts[i]);
                        subCondition = subCondition == null || secondCondition == null ?
                            null :
                            subCondition || secondCondition;
                        String stringToLog = toLog ?
                            'OR\n' + stringParts[i-1] + ': Not Available\n' : '';
                        stringToLog = toLog && secondCondition != null ?
                            'OR\n' + stringParts[i-1] + (secondCondition ? ': Satisfied' : ': NOT SATISFIED') + '\n\n' : stringToLog;
                        businessUserLog.add(stringToLog);
                    }
                    when 'NOR2' {
                        i++;
                        toLog = checkToLog(stringParts, i, toLog);
                        i = checkAndIncrement(stringParts, i);
    
                        Boolean secondCondition = checkEach(stringParts[i]);
                        subCondition = subCondition == null || secondCondition == null ?
                            null :
                            !(subCondition || secondCondition);
                        String stringToLog = toLog ?
                            'NOR\n' + stringParts[i-1] + ': Not Available\n' : '';
                        stringToLog = toLog && secondCondition != null ?
                            'NOR\n' + stringParts[i-1] + (secondCondition ? ': Satisfied' : ': NOT SATISFIED') + '\n\n' : stringToLog;
                        businessUserLog.add(stringToLog);
                    }
                    when 'AND' {
                        i++;
                        i = checkAndIncrement(stringParts, i);
                        subCondition = subCondition && checkEach(stringParts[i]);                            
                    }
                    when 'AND2' {
                        i++;
                        toLog = checkToLog(stringParts, i, toLog);
                        i = checkAndIncrement(stringParts, i);

                        Boolean secondCondition = checkEach(stringParts[i]);
                        subCondition = subCondition == null || secondCondition == null ?
                            null :
                            subCondition && secondCondition;
                        String stringToLog = toLog ?
                            'AND\n' + stringParts[i-1] + ': Not Available\n' : '';
                        stringToLog = toLog && secondCondition != null ?
                            'AND\n' + stringParts[i-1] + (secondCondition ? ': Satisfied' : ': NOT SATISFIED') + '\n\n' : stringToLog;
                        businessUserLog.add(stringToLog);
                    }
                }

                i+=1;

            }
            return subCondition;
        } catch (Exception e) {
            LOGGER.error('Error in runLoop: {0}\n{1}\n', new Object[]{e.getMessage(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param condition 
    * @param value1 
    * @param value2 
    * @return Boolean 
    **/
    @testvisible
    Boolean checkAndAssign(Boolean condition, Boolean value1, Boolean value2) {
        try {
            return condition ? value1 : value2;
        } catch (Exception e) {
            LOGGER.error('Error in checkAndAssign: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param condition 
    * @param value1 
    * @param value2 
    * @return Boolean 
    **/
    @testvisible
    Boolean checkAndAssignAnd(Boolean condition, Boolean value1, Boolean value2) {
        try {
            return condition ? value2 && value1 : value2;
        } catch (Exception e) {
            LOGGER.error('Error in checkAndAssignAnd: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param conditionQuery 
    * @return Boolean 
    **/
    @testvisible
    @SuppressWarnings('PMD.NPathComplexity') //Place related code at one place
    public Boolean check(String conditionQuery) {
        try {
            clearVariable();
            conditionQuery = variableReplace(conditionQuery);
            businessUserLog.clear();
            Boolean returnve;

            conditionQuery = conditionQuery.remove('\r');

            String delimiter = '\n\n';
            String delimeterNewLine = '\n';

            while(conditionQuery.endsWith(delimeterNewLine)) {
                conditionQuery = conditionQuery.substringBeforeLast(delimeterNewLine);
            }
            Boolean applyOR = conditionQuery.endsWith(STRING_APPLY_OR);
            conditionQuery = applyOR ? conditionQuery.removeEnd(STRING_APPLY_OR) : conditionQuery;
            conditionQuery += delimiter;
            Boolean flagFirstIteration = true;
            do {
                String[] stringParts = conditionQuery.substringBefore(delimiter).split(delimeterNewLine);
                Boolean successSetVariable = checkSetVariable(stringParts[1]);
                if(!successSetVariable) {
                    Boolean subCondition = runLoop(stringParts);
                    String stringToLog = subCondition == null ?
                        stringParts[0] + ': Not Available\n\n' :
                        stringParts[0] + (subCondition == null || !subCondition ? ': NOT SATISFIED' : ': Satisfied') + '\n\n';
                    businessUserLog.add(stringToLog);
                    returnve = subCondition == null ? null : returnve;
                    returnve = flagFirstIteration || returnve == null ? 
                        returnve :
                        (applyOR ? returnve || subCondition : returnve && subCondition);
                    returnve = flagFirstIteration ? subCondition : returnve;
                    flagFirstIteration = false;
                }
                conditionQuery = conditionQuery.substringAfter(delimiter);
                conditionQuery = variableReplace(conditionQuery);
            } while(conditionQuery.contains(delimiter));

            businessUserLog.add(returnve == null || returnve == false ? 'All Not so Good' + '\n' : 'All Good');
            return(returnve);
        } catch (Exception e) {
            LOGGER.error('Error in check: {0}\n{1}\nconditionQuery: {2}\n', new Object[]{e.getMessage(), e.getStackTraceString(), conditionQuery});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param conditionQuery 
    * @param serialNumber 
    * @return Boolean 
    **/
    @testvisible
    Boolean checkSetVariable(String conditionQuery, Integer serialNumber) {
        try {
            conditionQuery = preProcessQuery(conditionQuery, serialNumber);
            return(checkSetVariable(conditionQuery));
        } catch (Exception e) {
            LOGGER.error('Error in checkSetVariable: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }


    /**
    * @description Check if string contains any of the characters specified
    * @author Tushar Walse | 17 Sep 2024 
    * @param pString String to be checked
    * @param chars Characters whose presence is to be checked
    * @return Boolean 
    **/
    @testvisible
    Boolean containsOR(String pString, String chars) {
        try {
            for (Integer i = 0; i < chars.length(); i++) {
                if (pString.indexOfChar(chars.charAt(i)) >= 0) {
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            LOGGER.error('Error in containsOR: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param variableValue 
    * @return String 
    **/
    @testvisible
    @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
    String evalAndAll(String variableValue) {
        String variableValue2 = variableValue;
        try {
            String action = variableValue.substringBefore('{');
            variableValue = variableValue.removeStart(action + '{').removeEnd('}');
            Boolean result;
            Boolean firstIteration = true;
            for(String eachVariableValue : variableValue.split(', ')) {
                if(firstIteration) {
                    firstIteration = false;
                    result = true;
                }
                if(eachVariableValue == 'true') {
                    result = result && true;
                } else if(eachVariableValue == 'false') {
                    result = result && false;
                } else if(eachVariableValue == 'null') {
                    result = null;
                } else if(result != null) {
                    result = result && checkEach(eachVariableValue);
                }
                if(result == null) {
                    break;
                }
            }
            if(action == 'NotAndAll' && result != null) {
                result = !result;
            }
            variableValue = JSON.serialize(result);
            return variableValue;
        } catch (Exception e) {
            LOGGER.error('Error in evalAndAll: {0}\nargument: {1}\nline: {2}', new Object[]{e.getMessage(), variableValue2, e.getLineNumber()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param eachVariableValue 
    * @param result 
    * @return Boolean 
    **/
    @testvisible
    Boolean evalOrAllEach(String eachVariableValue, Boolean result) {
        try {
            if(eachVariableValue == 'true') {
                result = result || true;
            } else if(eachVariableValue == 'false') {
                result = result || false;
            } else if(eachVariableValue == 'null') {
                result = null;
            } else if(result != null) {
                result = result || checkEach(eachVariableValue);
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in evalOrAllEach: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param variableValue 
    * @return String 
    **/
    @testvisible
    String evalOrAll(String variableValue) {
        try {
            String action = variableValue.substringBefore('{');
            variableValue = variableValue.removeStart(action + '{').removeEnd('}');
            Boolean result;
            Boolean firstIteration = true;
            for(String eachVariableValue : variableValue.split(', ')) {
                if(firstIteration) {
                    firstIteration = false;
                    result = false;
                }
                result = evalOrAllEach(eachVariableValue, result);
                if(result == null) {
                    break;
                }
            }
            if(action == 'NotOrAll' && result != null) {
                result = !result;
            }
            variableValue = JSON.serialize(result);
            return variableValue;
        } catch (Exception e) {
            LOGGER.error('Error in evalOrAll: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Put in variable key and values (variableName, variableValue)
    * @author Tushar Walse | 23-09-2024 
    * @param variableName The key to be used
    * @param variableValue The value to be evalueated and set
    * @param conditionQuery Used in calculate to report the query causing the error
    **/
    @testvisible
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.UnusedLocalVariable') //Make code manageable at one place
    void evaluate(String variableName, String variableValue, String conditionQuery) {
        try {
            if(variableName == 'ValueReplacementMap') {
                Integer i = 0;
                variableValue = variableValue.removeStart('{').removeEnd('}');
                for(Map<String, Object> mapOfValues : getFieldValue(variableValue)) {
                    String key = '' + mapOfValues.values()[0];
                    fieldValueReplacementMap.put(key, mapOfValues);
                    i++;
                }
                logLineNumber++;
                businessUserLog.add(logLineNumber + '.\n' + conditionQuery + '\nAdding to ValueReplacementMap ' + i + ' records\n\n' + JSON.serialize(fieldValueReplacementMap));
                return;
            }
            switch on variableValue.substringBefore('{') {
                when '' {
                    variableValue = variableValue.removeStart('{').removeEnd('}');
                    variableValue = JSON.serialize(getFieldValuesAsList(variableValue));
                }
                when 'Check' {
                    variableValue = variableValue.removeStart('Check{').removeEnd('}');
                    variableValue = JSON.serialize(checkEach(variableValue));
                }
                when 'getPicklistValues' {
                    variableValue = variableValue.removeStart('getPicklistValues{').removeEnd('}');
                    String jsonString = variableValue.substringAfter(';');
                    jsonString = jsonString.startsWith('[') ? jsonString : variable.get(jsonString);
                    Object[] keys = deserialize(jsonString, String.class);
                    Map<String, String> valuesMap = utils.getPickListValueMap(variableValue.substringBefore(';'));
                    String[] values = new String[]{};
                    for(Object key : keys) {
                        values.add(valuesMap.get('' + key));
                    }
                    variableValue = JSON.serialize(values);
                }
                when 'AndAll', 'NotAndAll' {
                    variableValue = evalAndAll(variableValue);
                }
                when 'OrAll', 'NotOrAll' {
                    variableValue = evalOrAll(variableValue);
                }
                when 'SumAll' {
                    String action = variableValue.substringBefore('{');
                    variableValue = variableValue.removeStart(action + '{').removeEnd('}');
                    Decimal result = 0;
                    for(String eachVariableValue : variableValue.split(', ')) {
                        if(eachVariableValue != 'null') {
                            result = result + Decimal.valueOf(eachVariableValue.remove('"').remove('[').remove(']'));
                        }
                    }
                    variableValue = JSON.serialize(result);
                }
                when 'LessThan' {
                    String action = variableValue.substringBefore('{');
                    variableValue = variableValue.removeStart(action + '{').removeEnd('}');
                    Boolean result;
                    String firstVar = variableValue.split(', ')[0].remove('"').remove('[').remove(']');
                    String secondVar = variableValue.split(', ')[1].remove('"').remove('[').remove(']');
                    result = Decimal.valueOf(firstVar) < Decimal.valueOf(secondVar);
                    variableValue = JSON.serialize(result);
                }
                when 'GreaterThanOrEqual' {
                    String action = variableValue.substringBefore('{');
                    variableValue = variableValue.removeStart(action + '{').removeEnd('}');
                    Boolean result;
                    String firstVar = variableValue.split(', ')[0].remove('"').remove('[').remove(']');
                    String secondVar = variableValue.split(', ')[1].remove('"').remove('[').remove(']');
                    result = Decimal.valueOf(firstVar) >= Decimal.valueOf(secondVar);
                    variableValue = JSON.serialize(result);
                }
                when 'Sum' {
                    variableValue = variableValue.removeStart('Sum{').removeEnd('}');
                    Decimal sum = 0;
                    for(Object value : getFieldValuesAsList(variableValue)) {
                        sum += toDecimal(value);
                    }
                    variableValue = JSON.serialize(sum);
                }
                when 'Calculate' {
                    variableValue = variableValue.removeStart('Calculate{').removeEnd('}');
                    String stringFirstNumber = variableValue.substringBetween('(', ')');
                    variableValue = variableValue.removeStart('('+stringFirstNumber+')');
                    variableValue = JSON.serialize(calculate(variableValue, conditionQuery, stringFirstNumber));
                }
                when else {
                    utils.myThrow(variableValue.contains('{') && variableValue.endsWith('}'), 'Unknown function: ' + variableValue.substringBefore('{'));
                }
            }
            variable.put(variableName, variableValue);
            logLineNumber++;
            businessUserLog.add(logLineNumber + '.\n' + conditionQuery + '\nSetting ' + variableName + ' = ' + variableValue + '\n\n');
        } catch (Exception e) {
            LOGGER.error('Error in evaluate: {0}\nline: {1}\nvariableValue: {2}\nvariable: {3}', new Object[]{e.getMessage(), e.getLineNumber(), variableValue, variable});
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 23-09-2024 
    * @param variableValue 
    * @param conditionQuery Used to report the query causing the error
    * @param stringFirstNumber 
    * @return Decimal 
    **/
    @testvisible
    Decimal calculate(String variableValue, String conditionQuery, String stringFirstNumber) {
        try {
            Decimal num = Decimal.valueOf(stringFirstNumber);
            switch on variableValue.substring(0, 4) {
                when ' * :' {
                    num *= Decimal.valueOf(variableValue.substringAfter(variableValue.substring(0, 4)).remove('"').remove('[').remove(']'));
                }
                when else {
                    utils.myThrow(true, conditionQuery + '\r\nCalculate: Syntax mismatch!');
                }
            }
            return num;
        } catch (Exception e) {
            LOGGER.error('Error in calculate: {0}\n{1}\n', new Object[]{e.getMessage(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Check whether we need to evaluate and set the values
    * @author Tushar Walse | 17th Sep 2024 
    * @param conditionQuery The query to check and evaluate
    * @return Boolean Whether successfull
    **/
    @testvisible
    Boolean checkSetVariable(String conditionQuery) {
        String variableName = conditionQuery?.substringBefore(' = ');
        String variableValue = conditionQuery?.substringAfter(' = ')?.trim();
        Boolean result = false;
        try {
            if(conditionQuery.contains(' = ') && !containsOR(variableName, '.(:')) {
                result = true;
                variableValue = variableValue.trim();
                evaluate(variableName, variableValue, conditionQuery);
                return result;
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in checkSetVariable: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return result;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param obj 
    * @return Decimal 
    **/
    @testvisible
    Decimal toDecimal(Object obj) {
        try {
            Decimal result;
            if(obj instanceOf String) {
                result = Decimal.valueOf((String)obj);
            } else if(obj instanceOf Decimal) {
                result = (Decimal)obj;
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in toDecimal: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param conditionQuery 
    * @return Boolean 
    **/
    @testvisible
    Boolean checkEach(String conditionQuery) {
        try {
            Boolean condition;
            logLineNumber++;
            businessUserLog.add(logLineNumber + '. Evaluation Start:\n' + conditionQuery);


            if(conditionQuery == 'true' || conditionQuery == 'false') {
                condition = conditionQuery == 'true';
                businessUserLog.add('\nEvaluation: ' + conditionQuery + ' is ' + condition + '\n');
                return(condition);
            }
            
            String fieldName = conditionQuery.substringBeforeLast(':').trim();
   
            String operator = fieldName.substringAfterLast(' ');
            Boolean flipCondition = false;
            if(operator.startsWith('!')) {
                operator = operator.substringAfter('!');
                flipCondition = true;
            }
   
            fieldName = fieldName.substringBeforeLast(' ');
            String vString = conditionQuery.substringAfterLast(':');
            Object[] dataValues = getFieldValuesAsList(fieldName);
            condition = evalConditions(condition, dataValues, new String[]{operator, conditionQuery, vString});
            condition = flipCondition ? !condition : condition;
            operator = flipCondition ? '!' + operator : operator;
            businessUserLog.add('\nEvaluation: ' + dataValues + ' ' + operator + ' ' + vString + ' is ' + condition + '\n');

            return(condition);
        } catch (Exception e) {
            LOGGER.error('Error in checkEach: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param vString 
    * @param pType 
    * @return Object[] 
    **/
    @testvisible
    Object[] deserialize(String vString, Type pType) {
        try {
            
            Object[] result;
            if(vString.startsWith('[')) {
                result = (Object[])JSON.deserialize(vString, Type.forName('List<' + pType + '>'));
            } else {
                result = new Object[]{JSON.deserialize(vString, pType)};
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in deserialize: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param o 
    * @return Type 
    **/
    @testvisible
    @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
    Type getType(Object o) {
        try {
            Type result = String.class;
            if(o instanceof String) {
                result = String.class;
            } else if(o instanceof Boolean) {
                result = Boolean.class;
            } else if(o instanceof Id) {
                result = Id.class;
            } else if(o instanceof Blob) {
                result = Blob.class;
            } else if(o instanceof Date) {
                result = Date.class;
            } else if(o instanceof Datetime) {
                result = Datetime.class;
            } else if(o instanceof Time) {
                result = Time.class;
            } else if(o instanceof Integer) {
                result = Integer.class;
            } else if(o instanceof Long) {
                result = Long.class;
            } else if(o instanceof Decimal) {
                result = Decimal.class;
            } else if(o instanceof Double) {
                result = Double.class;
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getType: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param dataValues Values generated by the query
    * @param vString 
    * @return Object[] 
    **/
    @testvisible
    Object[] getTestValue(Object[] dataValues, String vString) {
        try {
            Object[] result;
            if(dataValues.isEmpty()) {
                result = deserialize(vString, String.class);
                return result;
            }
            result = deserialize(vString, getType(dataValues[0]));
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getTestValue: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param objects 
    * @return Decimal 
    **/
    @testvisible
    Decimal getSum(Object[] objects) {
        try {
            Decimal sum = 0;
            for(Object obj : objects) {
                if(obj != null) {
                    sum += Decimal.valueOf('' + obj);
                }
            }
            return sum;
        } catch (Exception e) {
            LOGGER.error('Error in getSum: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param dataObject 
    * @param testObject 
    * @param operator 
    * @return Boolean 
    **/
    @testvisible
    @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
    Boolean compare(Object dataObject, Object testObject, String operator) {
        try {
            if(operator == '=') {
                return dataObject == testObject;
            }
            if(dataObject == null || testObject == null) {
                return null;
            }
            Decimal dataValue;
            if(dataObject instanceOf String) {
                dataValue = Decimal.valueOf((String)dataObject);
            } else {
                dataValue = (Decimal)dataObject;
            }
            Decimal testValue;
            if(testObject instanceOf String) {
                testValue = Decimal.valueOf((String)testObject);
            } else {
                testValue = (Decimal)testObject;
            }
            switch on operator {
                when '>' {
                    return dataValue > testValue;
                }
                when '<' {
                    return dataValue < testValue;
                }
                when '<=' {
                    return dataValue <= testValue;
                }
                when '>=' {
                    return dataValue >= testValue;
                }
                when else {
                    utils.myThrow(true, 'Unknown operator: ' + operator);
                    return null;
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in compare: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param dataValues Values generated by the query
    * @param testValue Values specified as second operand
    * @param operator 
    * @return Boolean 
    **/
    @testvisible
    Boolean compareAll(Object[] dataValues, Object testValue, String operator) {
        try {
            Boolean result = true;
            for(Object dataValue : dataValues) {
                Boolean subResult = compare(dataValue, testValue, operator);
                if(subResult == null) {
                    result = null;
                    break;
                }
                result = result && subResult;
                if(result == false) {
                    break;
                }
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in compareAll: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param dataValues Values generated by the query
    * @param testValue Values specified as second operand
    * @return Boolean 
    **/
    @testvisible
    Boolean allIn(Object[] dataValues, Object[] testValue) {
        try {
            Boolean result = true;
            for(Object dataValue : dataValues) {
                result = result && testValue.contains(dataValue);
                if(result == false) {
                    break;
                }
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in allIn: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description See if any of dataValues are present in testValues
    * @author Tushar Walse | 17th Sep 2024 
    * @param dataValues Values generated by the query
    * @param testValue Values specified as second operand
    * @return Boolean True if any of dataValues are present in testValues
    **/
    @testvisible
    Boolean anyIn(Object[] dataValues, Object[] testValue) {
        try {
            Boolean result = false;
            for(Object dataValue : dataValues) {
                result = result || testValue.contains(dataValue);
                if(result == true) {
                    break;
                }
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in anyIn: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Compare dataValues and testValues when operator is relational
    * @author Tushar Walse | 24-09-2024 
    * @param dataValues Values generated by the query
    * @param testValue Values specified as second operand
    * @param args Array of objects containing condition and operator
    * @return Boolean Outcome of evaluation
    **/
    @testvisible
    Boolean evalRelational(Object[] dataValues, Object[] testValue, Object[] args) {
        try {
            Boolean condition = (Boolean)args[0];
            String operator = (String)args[1];
            if(dataValues.size()==1) {
                condition = compare(dataValues[0], testValue[0], operator);
            } else if(dataValues.size() > 1) {
                condition = compare(getSum(dataValues), Decimal.valueOf('' + testValue[0]), operator);
            } else {
                condition = null;
            }
            return condition;
        } catch (Exception e) {
            LOGGER.error('Error in evalRelational: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Evaluate condition given in the condition query
    * @author Tushar Walse | 17th Sep 2024 
    * @param condition Initial value of condition
    * @param dataValues Values generated by the query
    * @param args String array containing operator, conditionQuery and vString
    * @return Boolean Outcome of evaluation
    **/
    @testvisible
    @SuppressWarnings('PMD.CyclomaticComplexity') //Make code manageable at one place
    Boolean evalConditions(Boolean condition, Object[] dataValues, String[] args) {
        try {
            
            String operator = args[0];
            String conditionQuery = args[1];
            String vString = args[2];

            Object[] testValue = getTestValue(dataValues, vString);
            utils.myThrow(testValue.isEmpty(), conditionQuery + ' operator: ' + operator + ' \r\nBlank Provided for Test Value!');
            if(testValue.isEmpty()) {
                return null;
            }
            if(dataValues.isEmpty()) {
                if(
                    new String[]{'IN', 'ALLIN'}.contains(operator) &&
                    testValue.contains(null)
                ) {
                    return true;
                } else {
                    return null;
                }
            }

            switch on operator {
                when '=', '<', '>', '<=', '>=' {
                    utils.myThrow(testValue.size() > 1, conditionQuery + ' operator: ' + operator + ' \r\nArray Provided for Test Value Instead of Single Value!');
                    condition = evalRelational(dataValues, testValue, new Object[]{condition, operator});
                }
                when 'ALL=', 'ALL<', 'ALL>', 'ALL<=', 'ALL>=' {
                    utils.myThrow(testValue.size() > 1, conditionQuery + ' operator: ' + operator + ' \r\nArray Provided for Test Value Instead of Single Value!');
                    condition = compareAll(dataValues, testValue[0], operator.substringAfter('ALL'));
                }
                when 'CONTAINS' {
                    utils.myThrow(testValue.size() > 1, conditionQuery + '\r\nArray Provided for Test Value Instead of Single Value!');
                    condition = dataValues.contains(testValue[0]);
                }
                when 'IN', 'ALLIN' {
                    condition = allIn(dataValues, testValue);
                }
                when 'ANYIN' {
                    condition = anyIn(dataValues, testValue);
                }
                when else {
                    utils.myThrow(true, 'Unknown Operator: ' + operator);
                    condition = null;
                }
            }
            return condition;
        } catch (Exception e) {
            LOGGER.error('Error in evalConditions: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 17th Sep 2024 
    * @param fieldName 
    * @return Object[] 
    **/
    @testvisible
    Object[] getFieldValuesAsList(String fieldName) {
        try {
            Object[] returnVe = new Object[]{};
            for(Map<String, Object> mapOfValues : getFieldValue(fieldName)) {
                returnVe.addAll(mapOfValues.values());
            }
            return(returnVe);
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValuesAsList: {0}\nline: {1}\nstactTrace: {2}', new Object[]{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
            return null;
        }
    }

    /**
    * @description Remove fields not mentioned in the query
    * @author Tushar Walse | 20-02-2025 
    * @param sObjects List of objects from which fields are to be removed
    * @param propertiesToKeep List of field names to keep
    * @return SObject[] Output list with retained fields
    **/
    public static SObject[] removeProperties(SObject[] sObjects, String[] propertiesToKeep){
        List<Object> deserializedList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(sObjects));

        for (Object deserialized : deserializedList) {
            Map<String, Object> obj = (Map<String, Object>) deserialized;
            for(String property : obj.keySet()){
                if(!propertiesToKeep.contains(property)) {
                    obj.remove(property);
                }
            }
        }
        return (SObject[]) JSON.deserialize(JSON.serialize(deserializedList), SObject[].class); 
    }
        
    /**
     * @description                 : Class to carry inputs from flow to processFlowRequests method
     * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
     * @author                      : Tushar Walse
     * @date                        : 21-09-2024
     * @last modified on            : 03-10-2025
     * @last modified by            : Tushar Walse
     * @modification description    : Created
     */
    public class InputOutput {
        @InvocableVariable
        public SObject[] sObjects;
        @InvocableVariable
        public SObject sObjectRecord;
        @InvocableVariable
        public String firstValue;
        @InvocableVariable
        public String str;
        @InvocableVariable
        public String secondValue;
    }

    /**
    * @description Method called by ICS_Opportunity_After_Trigger flow to drive approval the process
    * @author Tushar Walse | 21-09-2024 
    * @param inputs .firstValue containing value related to the task to do
    * @param inputs .str containing the request string to be processed
    * @param inputs .secondValue containing additional info like index
    * @return List<InputOutput> containing the response to be sent back to the flow
    **/
    @InvocableMethod(
        label = 'Invoke GetDataMethod'
        description = 'Do according to toDo label'
        category = 'Approvals'
    )
    public static List<InputOutput> processFlowRequests(List<InputOutput> inputs) {
        List<InputOutput> returnVe = new List<InputOutput>{new InputOutput()};
        try {
            switch on inputs[0].str {
                when 'Initialize' {
                    if(dataObj == null && inputs[0].firstValue != null) {
                        dataObj = new ICS_Ctrl_GetData(inputs[0].firstValue);
                    }
                }
                when 'Initialize AOB_ReferencedData__c' {
                    dataObj.init('AOB_ReferencedData__c');
                }
                when 'Get Records' {
                    inputs[0].firstValue = inputs[0].firstValue.replace(':"secondValue"', ':"' + inputs[0].secondValue + '"');
                    inputs[0].firstValue = inputs[0].firstValue.replace(':secondValue', ':' + inputs[0].secondValue);
                    String fieldDelimiter = '.(';
                    String fullyQualQuery = inputs[0].firstValue;
                    fullyQualQuery = fullyQualQuery.substringAfterLast(fieldDelimiter).removeStart(fieldDelimiter).removeEnd(')');
                    String[] propertiesToKeep = fullyQualQuery.split(', ');
                    propertiesToKeep.add('attributes');
                    SObject[] sObjects = dataobj.getRecords(inputs[0].firstValue).getRecords();
                    returnVe[0].sObjects = removeProperties(sObjects, propertiesToKeep);
                }
                when 'Get Record' {
                    inputs[0].firstValue = inputs[0].firstValue.replace(':"secondValue"', ':"' + inputs[0].secondValue + '"');
                    inputs[0].firstValue = inputs[0].firstValue.replace(':secondValue', ':' + inputs[0].secondValue);
                    SObject[] sObjects = dataobj.getRecords(inputs[0].firstValue).getRecords();
                    if(sObjects != null && sObjects.size() > 0) {
                        String fieldDelimiter = '.(';
                        String fullyQualQuery = inputs[0].firstValue;
                        fullyQualQuery = fullyQualQuery.substringAfterLast(fieldDelimiter).removeStart(fieldDelimiter).removeEnd(')');
                        String[] propertiesToKeep = fullyQualQuery.split(', ');
                        propertiesToKeep.add('attributes');
                        sObjects = removeProperties(sObjects, propertiesToKeep);
                        returnVe[0].sObjectRecord = sObjects[0];
                    }
                }
                when 'Get Single Field Value' {
                    inputs[0].firstValue = inputs[0].firstValue.replace(':"secondValue"', ':"' + inputs[0].secondValue + '"');
                    inputs[0].firstValue = inputs[0].firstValue.replace(':secondValue', ':' + inputs[0].secondValue);
                    returnVe[0].firstValue = dataobj.getSingleFieldValue(inputs[0].firstValue, 0);
                }
                when 'Update Field Value' {
                    inputs[0].sObjectRecord.put(inputs[0].firstValue, inputs[0].secondValue);
                    returnVe[0].sObjectRecord = inputs[0].sObjectRecord;
                }
            }    
        } catch(Exception e) {
            LOGGER.error('Error in processFlowRequests: {0}\nline: {1}\ninputs: {2}', new Object[]{e.getMessage(), e.getLineNumber(), inputs});
        }

        return returnVe;
    }
}