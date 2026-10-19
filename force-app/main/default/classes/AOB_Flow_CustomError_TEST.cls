@isTest
public class AOB_Flow_CustomError_TEST {

    @isTest
    public static void TestThrowCustomException(){
        AOB_Flow_CustomError.Inputs input=new AOB_Flow_CustomError.Inputs();
        input.message='There is an exception';
        List<AOB_Flow_CustomError.Inputs> inputs=new List<AOB_Flow_CustomError.Inputs>{input};
        Test.startTest();
        Boolean exceptionThrown;
        try{
        AOB_Flow_CustomError.throwCustomFlowException(inputs);
        }
        catch(AOB_Flow_CustomError.CustomException e){
            exceptionThrown=true;
        }
        Test.stopTest();
        system.assertEquals(exceptionThrown,true);
    }
}