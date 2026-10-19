/**
 * @description       : This class sets the navigation menus on the experience site
 * @author            : Nicholas Bezuidenhout
 * @group             : Smartenup
 * @User Story        : SFP-47617
**/
public with sharing class INS_CTRL_Navigation extends VisualEditor.DynamicPickList {
    
    private List<NavigationLinkSet> navigationLinkSets;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_CTRL_Navigation.class.getName());

    public void setNavigationLinkSets(List<NavigationLinkSet> linkSets) {
        this.navigationLinkSets = linkSets;
    }

    Public INS_CTRL_Navigation() {
        try{
             LOGGER.info('INS_CTRL_Navigation setNavigationLinkSets()');

            this.navigationLinkSets =  [
                SELECT 
                    DeveloperName,
                    MasterLabel, 
                    NetworkId, 
                    Network.Name
                FROM NavigationLinkSet WHERE Network.Name = 'Direct Sales Agent Portal'
                ORDER BY MasterLabel
            ];
        }catch (Exception ex){
            LOGGER.fatal('INS_CTRL_Navigation.setNavigationLinkSets', ex.getMessage());
        }        
    }

    public override VisualEditor.DataRow getDefaultValue() {
         try{
             LOGGER.info('INS_CTRL_Navigation getDefaultValue()');
            NavigationLinkSet entry = this.navigationLinkSets[0];
            return new VisualEditor.DataRow(
                entry.MasterLabel + ' (' + entry.Network.Name + ')',
                entry.DeveloperName, 
                true
            );
         }
        catch (Exception ex){
            LOGGER.fatal('INS_CTRL_Navigation.getDefaultValue', ex.getMessage());
        } 
        return null;
    }
    public override VisualEditor.DynamicPickListRows getValues() {
        try{
            LOGGER.info('INS_CTRL_Navigation getValues()');
            Id networkId = Network.getNetworkId();
            VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();

            for (NavigationLinkSet entry : this.navigationLinkSets) {
                values.addRow(new VisualEditor.DataRow(
                    entry.MasterLabel + ' (' + entry.Network.Name + ')',
                    entry.DeveloperName
                ));
            }
            return values;
        }
        catch (Exception ex){
            LOGGER.fatal('INS_CTRL_Navigation.getValues', ex.getMessage());
        } 
        return null;
    }
}