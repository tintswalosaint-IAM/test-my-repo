/**
* @description Bean Class for dealing with Customer Alert api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa (lokesh.bothsa@standardbank.co.za)
* Story Number- SFP-26345
* @date june 2023
*/
public class BCB_CustomerAlertSubscriptionBean {
    /**@description attribute*/
    public class CustomerAlert {
		/**description attribute*/
		public String uniqueIdentity;
		/**description attribute*/
		public EasCustomerInfo easCustomerInfo;
		/**description attribute*/
		public List<ChannelInfo> channelInfo;
		/**description attribute*/
		public AlertInfo alertInfo;
		/**description attribute*/
		public String alertFrequency;
		/**description attribute*/
		public List<AlertCriticalRecord> alertCriticalRecord;
	}
/**@description attribute*/
	public CustomerAlert customerAlert;
/**@description attribute*/
	public class AlertCriticalRecord {
		/**description attribute*/
		public String fieldValue;
		/**description attribute*/
		public String fieldType;
		/**description attribute*/
		public String fieldName;
		/**description attribute*/
		public String displayType;
		/**description attribute*/
		public String actualValue;
	}
/**@description attribute*/
	public class AlertInfo {
		/**description attribute*/
		public String alertName;
		/**description attribute*/
		public String alertDescriptionCategoryIdentity;
	}
/**@description attribute*/
	public class EasCustomerInfo {
	/**@description attribute*/
		public String customerType;
		/**@description attribute*/
		public String customerSubType;
		/**@description attribute*/
		public String customerIdentity;
		/**@description attribute*/
		public String customerHostIdentity;
	/**@description attribute*/
		public String alertCustomerCategory;
	}
/**@description attribute*/
	public class ChannelInfo {
		/**description attribute*/
		public String isChannelNeeded;
		/**description attribute*/
		public String channelldentity;
		/**@description attribute
		*@param channelldentity
        *@param isChannelNeeded
		*/
        public ChannelInfo(String channelldentity, String isChannelNeeded) {
            this.channelldentity = channelldentity;
            this.isChannelNeeded = isChannelNeeded;
        }
	}
}