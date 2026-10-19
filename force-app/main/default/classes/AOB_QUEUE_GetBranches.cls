/**
 * @description AOB_BATCH_GetBranches used for updating Branches values from API
 *
 * <p></p>
 *
 * @author Salesforce
 *
 * @date 2020
 */

public class AOB_QUEUE_GetBranches implements Queueable, Database.AllowsCallouts {
  public static final String FIELD_NAME = 'BRANCH';
  string accessToken;

  public AOB_QUEUE_GetBranches(string accessToken) {
    this.accessToken = accessToken;
  }

  public void execute(QueueableContext context) {
    List<AOB_API_GetBranches.ETdata8_Multi> newBranches = AOB_SRV_Branches.callGetBranches(
      accessToken
    );
    if (!newBranches.isEmpty()) {
      delete [
        SELECT id
        FROM AOB_ReferencedData__c
        WHERE AOB_SAPField__c = :FIELD_NAME
      ];
      AOB_SRV_Branches.insertBranches(newBranches);
    }
  }
}