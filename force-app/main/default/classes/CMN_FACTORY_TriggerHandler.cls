/**
 * @description Factory class to handle all trigger functions (uses underlying bulk functions)
 * Used to instantiate and execute Trigger Handlers associated with SObjects.
 * The Base code was originally sourced from https://meltedwires.com/2013/06/05/trigger-pattern-for-tidy-streamlined-bulkified-triggers-revisited/
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_FACTORY_TriggerHandler {

  private class TriggerFactoryException extends Exception {
  }

  /**
   * @description Class use to store the variable
   */
  public class TriggerStackEntry {
    public CMN_INT_TriggerHandler handler;
    public Boolean isBefore;
    public CMN_DAL_SObjectDomain.DatabaseOperation operation;
    public Type handlerType;

    /**
     * @description Class use to trigger entries
     *
     * @param triggerHandlerType The class type of the handler
     * @param triggerHandler An interface to the trigger handler
     */
    public TriggerStackEntry(
      Type triggerHandlerType,
      CMN_INT_TriggerHandler triggerHandler
    ) {
      handler = triggerHandler;
      isBefore = Trigger.isBefore;
      operation = CMN_DAL_SObjectDomain.getTriggerDBOperation();
      handlerType = triggerHandlerType;
    }
  }

  /**
   * @description This static stack contains (for the current context) the stack of trigger calls
   */
  private static CMN_UTIL_Stack.ObjectStack triggerStack = new CMN_UTIL_Stack.ObjectStack();

  /**
   * @description this static method returns a reference to an entry in the stack
   *
   * @param index The index at which to return a stack entry
   *
   * @return Stack entry at given index
   */
  public static TriggerStackEntry stackPeek(Integer index) {
    return (TriggerStackEntry) triggerStack.peek(index);
  }

  /**
   * @description This method returns the current size of the trigger stack
   *
   * @return trigger size
   */
  public static Integer stackSize() {
    return triggerStack.size();
  }

  /**
   * @description Will return true if the trigger was directly initiated by the object against
   * which this trigger handler is registered
   *
   * @param handlerType The class type of the handler
   *
   * @return handlerType
   */
  private static Boolean selfInitiated(Type handlerType) {
    Boolean isSelfInitiated = true;

    if (!triggerStack.isEmpty()) {
      TriggerStackEntry entry = (TriggerStackEntry) triggerStack.peekFirst();
      isSelfInitiated = entry.handlerType == handlerType;
    }

    return isSelfInitiated;
  }

  /**
   * @description Will return true if this trigger is being called for the second or later time in a transaction
   *
   * @param handlerType The class type of the handler
   *
   * @return Indicates whether trigger is being called recursively
   */
  private static Boolean inRecursion(Type handlerType) {
    Boolean inRecursion = false;

    if (!triggerStack.isEmpty()) {
      Integer count = 0;

      for (Integer i = 0; i < stackSize(); i++) {
        TriggerStackEntry entry = stackPeek(i);

        if (entry.handlerType == handlerType) {
          count++;
          if (count > 1) {
            inRecursion = true;
            break;
          }
        }
      }
    }

    return inRecursion;
  }

  /**
   * @description Public static method to create and execute a trigger handler Throws a TriggerException if no handler has been coded.
   *
   * @param handlerType The class type of the handler
   */
  public static void createHandler(Type handlerType) {
    if (handlerType == null) {
      throw new TriggerFactoryException('Handler class not provided');
    }

    CMN_INT_TriggerHandler handler = (CMN_INT_TriggerHandler) handlerType.newInstance();

    if (CMN_DAL_TriggersToDisable.isTriggerEnabled(handlerType.getName())) {
      //Ensure we push the current handler and operation onto the stack
      //Used for determining recursion
      triggerStack.push(new TriggerStackEntry(handlerType, handler));
      try {
        //Ensure that any handler that cannot handle recursion or expects to only be directly initiated not to execute
        Boolean canExecute =
          handler.allowRecursion() || !inRecursion(handlerType);
        canExecute =
          canExecute &&
          (handler.allowNonSelfInitiated() || selfInitiated(handlerType));

        if (canExecute) {
          execute(handler);
        }
      } catch (Exception error) {
        CMN_UTIL_Logger.error(
          error,
          'CMN_FACTORY_TriggerHandler.createHandler'
        );
        throw error;
      } finally {
        //if processing complete remove the handler from the stack
        triggerStack.pop();
      }
    }
  }

  /**
   * @description private static method to control the execution of the handler
   *
   * @param handler - A Trigger Handler to execute.
   */
  private static void execute(CMN_INT_TriggerHandler handler) {
    if (Trigger.isBefore) {
      executeBefore(handler);
    } else {
      executeAfter(handler);
    }

    handler.andFinally();
  }

  /**
   * @description Will handle the trigger's before processing
   *
   * @param handler Trigger handler
   */
  private static void executeBefore(CMN_INT_TriggerHandler handler) {
    handler.bulkBefore();

    if (Trigger.isDelete) {
      for (SObject so : Trigger.old) {
        handler.beforeDelete(so);
      }
    } else if (Trigger.isInsert) {
      for (SObject so : Trigger.new) {
        handler.beforeInsert(so);
      }
    } else if (Trigger.isUpdate) {
      for (SObject so : Trigger.old) {
        handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
      }
    }
  }

  /**
   * @description Will handle the triggers after processing
   *
   * @param handler Trigger Handler
   */
  private static void executeAfter(CMN_INT_TriggerHandler handler) {
    handler.bulkAfter();

    if (Trigger.isDelete) {
      for (SObject so : Trigger.old) {
        handler.afterDelete(so);
      }
    } else if (Trigger.isInsert) {
      for (SObject so : Trigger.new) {
        handler.afterInsert(so);
      }
    } else if (Trigger.isUpdate) {
      for (SObject so : Trigger.old) {
        handler.afterUpdate(so, Trigger.newMap.get(so.Id));
      }
    } else if (Trigger.isUndelete) {
      for (SObject so : Trigger.new) {
        handler.afterUndelete(so);
      }
    }
  }
}