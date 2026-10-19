/**
* @description Bean Class for dealing with Customer Alert api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date june 2022
*/

public class AOB_CustomerAlertSubscriptionBean {
	 /** @description attribute **/
    public CustomerAlertInformation customerAlert;
    /** @description CustomerAlertInformation is using for CustomerAlertSubscription API request body **/
    public class CustomerAlertInformation {
         /** @description attribute **/
        public EachCustInformation easCustomerInfo;
         /** @description attribute **/
        public AlertInformation alertInfo;
         /** @description attribute **/
		public String alertFrequency;
         /** @description attribute **/
		public String uniqueIdentity;
         /** @description attribute **/
        public List<ChannelInfo> channelInfo;
         /** @description attribute **/
		public List<AlertCriticalRecordInfo> alertCriticalRecord;
    }
    /** @description EachCustInformation is using for CustomerAlertSubscription API request body **/
    public class EachCustInformation {
         /** @description attribute **/
        public String customerType;
         /** @description attribute **/
        public String customerSubType;
         /** @description attribute **/
        public String customerIdentity;
         /** @description attribute **/
        public String customerHostIdentity;
         /** @description attribute **/
        public String alertCustomerCategory;
    }
    /** @description AlertInformation is using for CustomerAlertSubscription API request body **/
    public class AlertInformation {
         /** @description attribute **/
        public String alertName;
         /** @description attribute **/
        public String alertDescriptionCategoryIdentity; 
    }
    /** @description ChannelInfo is using for CustomerAlertSubscription API request body **/
    public class ChannelInfo {
         /** @description attribute **/
        public String channelldentity;
         /** @description attribute **/
        public String isChannelNeeded;
        /** 
        * @description Method to Register QNA which will be invoked from parent class 
        * @param channelldentity
        * @param isChannelNeeded
        */
       public ChannelInfo(String channelldentity, String isChannelNeeded) {
            this.channelldentity = channelldentity;
            this.isChannelNeeded = isChannelNeeded;
        }
    }
    /** @description AlertCriticalRecordInfo is using for CustomerAlertSubscription API request body **/
    public class AlertCriticalRecordInfo {
         /** @description attribute **/
        public String actualValue;
         /** @description attribute **/
        public String displayType;
         /** @description attribute **/
        public String fieldName;
         /** @description attribute **/
        public String fieldValue;
         /** @description attribute **/
        public String fieldType;
    }
}