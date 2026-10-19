/**
 * @description Custom DML implementation that uses SYSTEM_MODE for all operations
 *              Required for Automated Process user context (Platform Event triggers)
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-21
 **/
public class INS_UTIL_SystemModeDML implements sbgplatform.fflib_SObjectUnitOfWork.IDML {
    
    public void dmlInsert(List<SObject> objList) {
        if (objList == null || objList.isEmpty()) return;
        Database.insert(objList, AccessLevel.SYSTEM_MODE);
    }
    
    public void dmlUpdate(List<SObject> objList) {
        if (objList == null || objList.isEmpty()) return;
        Database.update(objList, AccessLevel.SYSTEM_MODE);
    }
    
    public void dmlDelete(List<SObject> objList) {
        if (objList == null || objList.isEmpty()) return;
        Database.delete(objList, AccessLevel.SYSTEM_MODE);
    }
    
    public void eventPublish(List<SObject> objList) {
        if (objList == null || objList.isEmpty()) return;
        EventBus.publish(objList);
    }
    
    public void emptyRecycleBin(List<SObject> objList) {
        if (objList == null || objList.isEmpty()) return;
        Database.emptyRecycleBin(objList);
    }
}