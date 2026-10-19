/**
 * This class is used as handler class for the document trigger
 *
 * <p>DBP-1874</p>
 *
 * @author Maryem Bourhi (mbourhi@salesforce.com)
 *
 * @date Feb 15th 2021
 */

public with sharing class DOC_TRH_CotentDocumentLink extends CMN_TRH_BaseObject {
  private Map<id, id> contentDocMap = new Map<id, id>();

  /**
   * @description adds the document to the doc list to be treated after insert
   */
  public override void afterInsert(SObject so) {
    ContentDocumentLink newDoc = (ContentDocumentLink) so;
    super.afterInsert(newDoc);
    Schema.DescribeSObjectResult r = DOC_Document__c.sObjectType.getDescribe();
    String keyPrefix = r.getKeyPrefix();
    if(String.ValueOf(newDoc.LinkedEntityId).startsWith(keyPrefix)){
      contentDocMap.put(newDoc.LinkedEntityId, newDoc.id);
    }
  }
  /**
   * @description Updates documents with the right content oc link id
   */
  public override void andFinally() {
    super.andFinally();
    if(contentDocMap.size()>0){
    	DOC_SRV_Document.updateDocuments(contentDocMap);
    }
    List<Id> files = new List<Id>();
    files.addAll(contentDocMap.Keyset());
    if(!files.isEmpty()){
      DOC_SRV_Document.notifyFileNet(files);
    }
  }
}