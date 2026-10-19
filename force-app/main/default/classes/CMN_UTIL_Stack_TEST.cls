/**
 * @description Test class is use to test the stack implementation.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_Stack_TEST {
  private static final String ERROR_THROWN_AS_EXPECTED = 'Error was thrown as expected';
  private static final String ERROR_NOT_THROWN_AS_EXPECTED = 'Error was not thrown as expected';

  /**
   * @description To test the apex object
   */
  @IsTest
  private static void push() {
    Test.startTest();

    CMN_UTIL_Stack.ObjectStack objectStack = new CMN_UTIL_Stack.ObjectStack();
    try {
      objectStack.push(null);
      System.assert(false, ERROR_NOT_THROWN_AS_EXPECTED);
    } catch (CMN_UTIL_Stack.NullValueNotAllowedException aNullValueNotAllowedException) {
      System.assert(true, ERROR_THROWN_AS_EXPECTED);
    }

    Test.stopTest();
  }

  @IsTest
  private static void peekFirstEmptyStack() {
    Test.startTest();

    CMN_UTIL_Stack.ObjectStack objectStack = new CMN_UTIL_Stack.ObjectStack();

    try {
      objectStack.peekFirst();
      System.assert(false, ERROR_NOT_THROWN_AS_EXPECTED);
    } catch (CMN_UTIL_Stack.StackUnderflowException aStackUnderflowException) {
      System.assert(true, ERROR_THROWN_AS_EXPECTED);
    }

    Test.stopTest();
  }

  @IsTest
  private static void peek() {
    Test.startTest();

    CMN_UTIL_Stack.ObjectStack objectStack = new CMN_UTIL_Stack.ObjectStack();

    try {
      objectStack.peek();
      System.assert(false, ERROR_NOT_THROWN_AS_EXPECTED);
    } catch (CMN_UTIL_Stack.StackUnderflowException aStackUnderflowException) {
      System.assert(true, ERROR_THROWN_AS_EXPECTED);
    }

    String test1 = CMN_DAL_SObjectDomain.generateRandomName();
    objectStack.push(test1);
    try {
      objectStack.peek(2);
      System.assert(false, ERROR_NOT_THROWN_AS_EXPECTED);
    } catch (CMN_UTIL_Stack.StackOverflowException aStackOverflowException) {
      System.assert(true, ERROR_THROWN_AS_EXPECTED);
    }

    Object test2 = objectStack.peek();

    System.assertEquals(
      test1,
      '' + test2,
      'Stack.peak has to return what was added'
    );

    Test.stopTest();
  }

  @IsTest
  private static void pop() {
    CMN_UTIL_Stack.ObjectStack objectStack = new CMN_UTIL_Stack.ObjectStack();

    objectStack.push(objectStack);

    System.assertEquals(1, objectStack.size(), 'Stack invalid size.');

    Test.startTest();

    Object poppedObject = objectStack.pop();

    System.assertEquals(objectStack, poppedObject, 'Objects do not  match');

    try {
      objectStack.pop();
      System.assert(false, ERROR_NOT_THROWN_AS_EXPECTED);
    } catch (Exception error) {
      System.assert(true, ERROR_THROWN_AS_EXPECTED);
    }

    Test.stopTest();
  }

  @IsTest
  private static void stackError() {
    CMN_UTIL_Stack.ObjectStack objectStack = new CMN_UTIL_Stack.ObjectStack();
    CMN_UTIL_Stack.MAX_STACK_DEPTH = 1;

    objectStack.push(objectStack);

    Test.startTest();

    try {
      objectStack.push(objectStack);
      System.assert(false, ERROR_NOT_THROWN_AS_EXPECTED);
    } catch (Exception error) {
      System.assert(true, ERROR_THROWN_AS_EXPECTED);
    }

    Test.stopTest();
  }
}