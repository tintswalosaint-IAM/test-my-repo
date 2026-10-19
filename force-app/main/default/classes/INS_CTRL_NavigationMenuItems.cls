/**
 * @description       : This class gets and sets the navigation menu items on the experience site
 * @author            : Nicholas Bezuidenhout
 * @group             : Smartenup
 * @User Story        : SFP-47617
**/
public with sharing class INS_CTRL_NavigationMenuItems {

     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_CTRL_NavigationMenuItems.class.getName());

    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> getNavigationMenuItems(String menuName, String publishedState) {

        try{
            LOGGER.info('INS_CTRL_NavigationMenuItems getNavigationMenuItems()');
            Id networkId;
            if (String.isEmpty(menuName)) {
                return new List<NavigationMenuItem>();
            }
            networkId = Test.isRunningTest() ? [SELECT NetworkId FROM NavigationLinkSet WHERE DeveloperName=:menuName].NetworkId : Network.getNetworkId();

            // Query NavigationLinkSet
            List<NavigationLinkSet> linkSets = [
                SELECT Id
                FROM NavigationLinkSet
                WHERE DeveloperName = :menuName AND NetworkId = :networkId
            ];

            // Handle case where no NavigationLinkSet is found
            if (linkSets.isEmpty()) {
                return new List<NavigationMenuItem>();
            }

            Id linkSetId = linkSets[0].Id;

            // Query NavigationMenuItem and ensure correct path
            List<NavigationMenuItem> menuItems = [
                SELECT
                    Label,
                    Target,
                    Type,
                    DefaultListViewId,
                    AccessRestriction,
                    ParentId,
                    Position,
                    Status,
                    TargetPrefs
                FROM NavigationMenuItem
                WHERE NavigationLinkSetId = :linkSetId AND Status = :publishedState
                ORDER BY Position
            ];

            // Ensure correct path prefix for internal links
            for (NavigationMenuItem item : menuItems) {
                if (item.Target != null && !item.Target.startsWith('http')) {
                    if (!item.Target.startsWith('/quickquote/s/')) {
                        item.Target = '/quickquote/s' + (item.Target.startsWith('/') ? item.Target : '/' + item.Target);
                    }
                }
            }
            return menuItems;
        }
        catch (Exception ex){
            LOGGER.fatal('INS_CTRL_NavigationMenuItems.getNavigationMenuItems', ex.getMessage());
        }  
        return null;
    }
}