global class VisualForceQueryParamsController {
    public String ani {get; private set;}
    public String dnis {get; private set;}
    public String uui {get; private set;}
    public String ucid {get; private set;}
    public String queue {get; private set;}
    public VisualForceQueryParamsController() {
        ani = 
ApexPages.currentPage().getParameters().get('ANI');
        dnis = 
ApexPages.currentPage().getParameters().get('DNIS');
        uui = 
ApexPages.currentPage().getParameters().get('UUI');
        ucid = 
ApexPages.currentPage().getParameters().get('UCID');
        queue = 
ApexPages.currentPage().getParameters().get('Queue');
        
    }
}