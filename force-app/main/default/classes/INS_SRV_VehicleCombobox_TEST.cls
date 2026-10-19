/**
* @description Test class for Vehicle Combobox
* @author Alexandr Goryachko
* @date 2024/07/30
*/
@isTest
public class INS_SRV_VehicleCombobox_TEST {
    /**
     * @description To check getting vehicle data via integration procedure from API 
     */
    @isTest
    private static void getDataPositiveTest() {
        Test.startTest();
        Map<String, Object> result = (Map<String, Object>)INS_FACTORY_Data.getData(
            INS_SRV_VehicleCombobox.class.getName(), 
            new Map<String, Object>{'year' => '2010', 'make' => 'BMW'}
        );
        Assert.isNotNull(result, 'Error when getting vehicle data');
        Test.stopTest();
    }
}