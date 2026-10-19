/**
 * @description       : Selector Class for queues
 * @author            : Jagadish Thummala
 * @last modified on  : 16-08-2023
 * @last modified by  : jagadish Thummala
**/

public inherited sharing class SEL_Queue extends sbgplatform.fflib_SObjectSelector{

   
    
    private static Set<String> fields = new Set<String>{
        'Id', 
        'QueueId', 
        'SobjectType', 
        'CreatedById',
        'SystemModstamp'         
    };
        
    /**
    * @description Implementation method for QueueSobject Object as part of fflib framework
    * @author Jagadish | 16-08-2023
    * @return Schema.SObjectType 
    **/
     public override Schema.SObjectType getSObjectType() {
    	return QueueSobject.getSObjectType();
    } 
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Jagadish  | 16-08-2023
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            QueueSobject.Id,
            QueueSobject.QueueId,
            QueueSobject.SobjectType,
            QueueSobject.CreatedById,
            QueueSobject.SystemModstamp
        };
    }
    
    /**
     * Method to fetch list of QueueSobject based on Queue names
     *
     * @return List<QueueSobject>
     */
    public List<QueueSobject> selectQueueByQueueNames(List<string> queueNames) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('queue.name in :queueNames');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }


    
}