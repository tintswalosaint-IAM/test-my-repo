/**
 * @description Trigger Handler framework handler class for platform event
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/05
 */
public inherited sharing class CMN_TRH_ChatterNotification extends CMN_TRH_BaseObject {
    /**
     * @description After insert handler
     *
     * @param so - New record
     */
    public override void afterInsert(SObject so) {
        super.afterInsert(so);

        WI_ChatterNotification__e pEvent = (WI_ChatterNotification__e)so;
        insert new FeedItem(
            ParentId = pEvent.WI_UserId__c,
            Body = pEvent.WI_Message__c
        );
    }
}