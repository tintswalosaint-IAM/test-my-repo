/**
 * @description This class contains various Apex Stack Implementations
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_UTIL_Stack {
  @TestVisible
  private static Integer MAX_STACK_DEPTH = 1000;

  /**
   * @description Use this class for exceptions
   */
  public class NullValueNotAllowedException extends Exception {
  }

  /**
   * @description Use this class for exceptions
   */
  public class StackOverflowException extends Exception {
  }

  /**
   * @description Use this class for exceptions
   */
  public class StackUnderflowException extends Exception {
  }

  /**
   * @description This stack stores a list of Apex Objects
   */
  public class ObjectStack {
    private List<Object> stack;

    /**
     * @description This use to declare ObjectStack
     */
    public ObjectStack() {
      stack = new List<Object>();
    }

    /**
     * @description
     *
     * @param obj as input
     */
    public void push(Object obj) {
      if (obj == null) {
        throw new NullValueNotAllowedException();
      }

      if (this.isFull()) {
        throw new StackOverflowException();
      }

      stack.add(obj);
    }

    /**
     * @description
     *
     * @return Object popped
     */
    public Object pop() {
      if (isEmpty()) {
        throw new StackUnderflowException();
      }

      return stack.remove(lastItemIndex);
    }

    /**
     * @description Will return the last item in the stack without altering the stack
     *
     * @return The item stored in the stack
     */
    public Object peek() {
      return peek(lastItemIndex);
    }

    /**
     * @description Will return the first item in the stack without altering the stack
     *
     * @return The item stored in the stack
     */
    public Object peekFirst() {
      return peek(0);
    }

    /**
     * @description Will return the specfied item in the stack without altering the stack
     *
     * @param index The position of the item
     *
     * @return The item stored in the stack
     */
    public Object peek(Integer index) {
      if (isEmpty() || (index < 0)) {
        throw new StackUnderflowException();
      } else if (index >= size()) {
        throw new StackOverflowException();
      }

      return stack.get(index);
    }

    /**
     * @description Checks to see if the stack is empty
     *
     * @return if is empty or not
     */
    public Boolean isEmpty() {
      return stack.isEmpty();
    }

    /**
     * @description Checks to see if the stack is at it's maximum size
     *
     * @return if is full or not
     */
    public Boolean isFull() {
      return MAX_STACK_DEPTH == size();
    }

    /**
     * @description Size of stack
     *
     * @return stack size
     */
    public Integer size() {
      return stack.size();
    }

    /**
     * @description Check the size of last itmes
     */
    private Integer lastItemIndex {
      get {
        return size() - 1;
      }
    }
  }
}