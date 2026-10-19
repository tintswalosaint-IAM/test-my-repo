/* Class definition for throwing custom exceptions via Apex actions in Flows */
/**
 * Class used for throwing custom exceptions via Apex actions in Flows
 *
 * <p>DBP-2377</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Feb 11th 2021
 */
public class AOB_Flow_CustomError {
  public class CustomException extends Exception {
  }

  @InvocableMethod(label='Throw Custom Flow Exception')
  public static void throwCustomFlowException(Inputs[] input) {
    throw createCustomException(input[0].message);
  }

  public class Inputs {
    @InvocableVariable(label='Error message')
    public string message;
  }

  static CustomException createCustomException(String message) {
    CustomException ex = new CustomException(message);
    ex.setMessage(message);
    return ex;
  }
}