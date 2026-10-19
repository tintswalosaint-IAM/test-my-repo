/**
* @description This class is used as delete related record
* @author Dayakar 
* @date June 30th 2023
*/

public class AOB_SCHED_DeleteAllfiles implements Schedulable{
    
    /**
    * @description  method  for execute SchedulableContext context
    * 
    * @param  context
    */
    public void execute(SchedulableContext context) {
        
        AOB_BOTS_CTRL_DeleteAllfiles.deleteAllfils();
        
    }

}