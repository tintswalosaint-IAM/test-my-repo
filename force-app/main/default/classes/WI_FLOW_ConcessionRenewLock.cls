/**
 * @description SFP-20422 Class for Renewal process of Concession record to lock record
 *
 * @author Adam Redlinski
 *
 * @date 2023/06/23
 */
global class WI_FLOW_ConcessionRenewLock {
    @InvocableMethod(Label='Lock record')
    global static List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> lockRecord(List<Id> recordId) {
        if (recordId == null || recordId.isEmpty()) {
            return new List <WI_FLOW_ConcessionRenewUnlock.ResultWrapper> {new WI_FLOW_ConcessionRenewUnlock.ResultWrapper(false, 'Record Id must be provided', false)};
        }

        List<Approval.LockResult> results = Approval.lock(recordId);


        String errors = '';
        Boolean allSuccess = true;
        for (Approval.LockResult res : results) {
            errors += getErrorsString(res.errors);
            if (!res.isSuccess()) {
                allSuccess = false;
            }
        }
        return new List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> {new WI_FLOW_ConcessionRenewUnlock.ResultWrapper(allSuccess, errors, true)};
    }

    private static String getErrorsString(List<Database.Error> errors) {
        String errorsStr = '';
        if (errors != null) {
            for (Database.Error singleError : errors) {
                errorsStr += singleError.message + ';';
            }
        }
        return errorsStr;
    }
}