/**
 * @description SFP-20422 Class for Renewal process of Concession record to unlock record before update
 *
 * @author Adam Redlinski
 *
 * @date 2023/06/23
 */
global class WI_FLOW_ConcessionRenewUnlock {

    @InvocableMethod(Label='Unlock record')
    global static List<ResultWrapper> unlockRecord(List<Id> recordId) {
        if (recordId == null) {
            return new List<ResultWrapper> {new ResultWrapper(false, 'Record Id must be provided', false)};
        }
        Map<Id,Boolean> resultMap = Approval.isLocked(recordId);
        List<Id> recordsToUnlock = new List<Id>();
        for (Id item : resultMap.keySet()) {
            if(resultMap.get(item)) {
                recordsToUnlock.add(item);
            }
        }
        if (recordsToUnlock.isEmpty()) {
            return new List<ResultWrapper> {new ResultWrapper(true, null, false)};
        }
        List<Approval.UnlockResult> resultsList;
        if (!recordsToUnlock.isEmpty()) {
            resultsList = Approval.unlock(recordsToUnlock);
        }

        String errors = '';
        Boolean allSuccess = true;
        for (Approval.UnlockResult res : resultsList) {
            errors += getErrorsString(res.errors);
            if (!res.isSuccess()) {
                allSuccess = false;
            }
        }
        return new List<ResultWrapper> {new ResultWrapper(allSuccess, errors, true)};
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

    global class ResultWrapper {
        @InvocableVariable(Label= 'Errors')
        global String errors;
        @InvocableVariable (Label= 'Is success')
        global Boolean isSuccess;
        @InvocableVariable (Label= 'Is locked')
        global Boolean isLocked;

        global ResultWrapper(Boolean isSucces, String errors, Boolean isLocked) {
            this.isSuccess = isSucces;
            this.errors = errors;
            this.isLocked = isLocked;
        }
    }
}