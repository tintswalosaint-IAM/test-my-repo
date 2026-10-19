/**
 * @description Get vehicle model
 * @author Alexandr Goryachko
 * @date 2024/07/26
 */
public with sharing class INS_SRV_VehicleCombobox implements INS_IData {
    private final static String PROCEDURE_NAME = 'InsIpApi_VehicleGet';
    private String path = 'api/Vehicle/{year}/{make}';
    /**
     * @description Get init data for the vehicle combobox
     * @param params for method
     * @return data wrapper
     */
    public Object getData(Map<String, Object> params) {
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();

        // Populating input map for an Integration Procedure. 
        this.path = this.path
            .replace('{year}', (String)params.get('year'))
            .replace('{make}', (String)params.get('make'))
            .replaceAll(' ', '%20');
        ipInput.put('request', new Map<String, String>{
            'path' => this.path,
            'body' => null
        });

        // Call the IP via runIntegrationService, and save the output to ipOutput
        ipOutput = (Map<String, Object>)omnistudio.IntegrationProcedureService.runIntegrationService(PROCEDURE_NAME, ipInput, ipOptions);

        return ipOutput;
    }
}