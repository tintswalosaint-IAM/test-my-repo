/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 * Utility class for checking FLS/CRUD. NOTE: all "check" methods will throw a SecurityException (or subclass) if the
 * user does not have the proper security granted.
 * <p/>
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 * <p/>
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 * <p/>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 * <p>VCCC-378</p>
 **/
public inherited sharing class CMN_UTIL_Security {
  private enum OperationType {
    CREATE,
    READ,
    MODIFY,
    DEL
  }

  /**
   * @description SecurityException is never be thrown directly by CMN_UTIL_Security, instead all
   * 				forms of CRUD and FLD violations throw subclasses of it. It is provided as a convenience
   * 				in the event you wish to handle CRUD and FLS violations the same way (e.g. die and display an error)
   */
  public virtual class SecurityException extends Exception {
    protected OperationType m_operation;
    protected Schema.SObjectType m_objectType;
  }

  /**
   * @description CrudException represents a running user's lack of read/create/update/delete access at a profile (or permission set)
   * 				level. Sharing and field level security issues will never cause this.
   */
  public class CrudException extends SecurityException {
    private CrudException(
      OperationType operation,
      Schema.SObjectType objectType
    ) {
      this.m_operation = operation;
      this.m_objectType = objectType;

      if (operation == OperationType.CREATE) {
        this.setMessage('Security Error: Object not insertable');
      } else if (operation == OperationType.READ) {
        this.setMessage('Security Error: Object not readable');
      } else if (operation == OperationType.MODIFY) {
        this.setMessage('Security Error: Object not updatable');
      } else if (operation == OperationType.DEL) {
        this.setMessage('Security Error: Object not deleteable');
      }

      this.setMessage(
        String.format(
          this.getMessage(),
          new List<String>{ objectType.getDescribe().getName() }
        )
      );
    }
  }
  /**
   * @description FlsException represents a running user's lack of field level security to a specific field at a profile (or permission set) level
   * 				Sharing and CRUD security issues will never cause this to be thrown.
   */
  public class FlsException extends SecurityException {
    private Schema.SObjectField m_fieldToken;

    private FlsException(
      OperationType operation,
      Schema.SObjectType objectType,
      Schema.SObjectField fieldToken
    ) {
      this.m_operation = operation;
      this.m_objectType = objectType;
      this.m_fieldToken = fieldToken;
      if (operation == OperationType.CREATE) {
        this.setMessage('Security Error: Object not insertable');
      } else if (operation == OperationType.READ) {
        this.setMessage('Security Error: Object not readable');
      } else if (operation == OperationType.MODIFY) {
        this.setMessage('Security Error: Object not updatable');
      }

      this.setMessage(
        String.format(
          this.getMessage(),
          new List<String>{
            objectType.getDescribe().getName(),
            fieldToken.getDescribe().getName()
          }
        )
      );
    }
  }

  /**
   * @description If set to true all check methods will always return void, and never throw exceptions.
   * 				This should really only be set to true if an app-wide setting to disable in-apex
   * 				FLS and CRUD checks exists and is enabled.
   * 				Per security best practices setting BYPASS should be an a opt-in, and not the default behavior.
   */
  public static Boolean BYPASS_INTERNAL_FLS_AND_CRUD = false;

  /**
   * @description Check{Insert,Read,Update} methods check both FLS and CRUD
   *
   * @param objType as input
   * @param fieldNames as inputs
   */

  /**
   * @description Checks both insert FLS and CRUD for the specified object type and fields.
   * @exception FlsException if the running user does not have insert rights to any fields in {@code fieldNames}.
   * @exception CrudException if the running user does not have insert rights to {@code objType}
   *
   * @param objType as input
   * @param fieldNames as inputs
   */
  public static void checkInsert(SObjectType objType, List<String> fieldNames) {
    checkObjectIsInsertable(objType);

    for (String fieldName : fieldNames) {
      checkFieldIsInsertable(objType, fieldName);
    }
  }

  /**
   * @description Identical to {@link #checkInsert(SObjectType,List<String>)}, except with SObjectField instead of String field references.
   * @exception FlsException if the running user does not have insert rights to any fields in {@code fieldTokens}.
   * @exception CrudException if the running user does not have insert rights to {@code objType}
   *
   * @param objType as input
   * @param fieldTokens as input
   */
  public static void checkInsert(
    SObjectType objType,
    List<SObjectField> fieldTokens
  ) {
    checkObjectIsInsertable(objType);
    for (SObjectField fieldToken : fieldTokens) {
      checkFieldIsInsertable(objType, fieldToken);
    }
  }

  /**
   * @description Checks both read FLS and CRUD for the specified object type and fields.
   * @exception FlsException if the running user does not have read rights to any fields in {@code fieldNames}.
   * @exception CrudException if the running user does not have read rights to {@code objType}
   *
   * @param objType as input
   * @param fieldNames as inputs
   */
  public static void checkRead(SObjectType objType, List<String> fieldNames) {
    checkObjectIsReadable(objType);
    for (String fieldName : fieldNames) {
      checkFieldIsReadable(objType, fieldName);
    }
  }

  /**
   * @description Identical to {@link #checkRead(SObjectType,List<String>)}, except with SObjectField instead of String field references.
   * @exception FlsException if the running user does not have read rights to any fields in {@code fieldTokens}.
   * @exception CrudException if the running user does not have read rights to {@code objType}
   *
   * @param objType as input
   * @param fieldTokens as input
   */
  public static void checkRead(
    SObjectType objType,
    List<SObjectField> fieldTokens
  ) {
    checkObjectIsReadable(objType);
    for (SObjectField fieldToken : fieldTokens) {
      checkFieldIsReadable(objType, fieldToken);
    }
  }

  /**
   * @description Checks both update FLS and CRUD for the specified object type and fields.
   * @exception FlsException if the running user does not have update rights to any fields in {@code fieldNames}.
   * @exception CrudException if the running user does not have update rights to {@code objType}
   *
   * @param objType as input
   * @param fieldNames as inputs
   */
  public static void checkUpdate(SObjectType objType, List<String> fieldNames) {
    checkObjectIsUpdateable(objType);
    for (String fieldName : fieldNames) {
      checkFieldIsUpdateable(objType, fieldName);
    }
  }

  /**
   * @description Identical to {@link #checkUpdate(SObjectType,List<String>)}, except with SObjectField instead of String field references.
   * @exception FlsException if the running user does not have update rights to any fields in {@code fieldTokens}.
   * @exception CrudException if the running user does not have update rights to {@code objType}
   *
   * @param objType as input
   * @param fieldTokens as input
   */
  public static void checkUpdate(
    SObjectType objType,
    List<SObjectField> fieldTokens
  ) {
    checkObjectIsUpdateable(objType);
    for (SObjectField fieldToken : fieldTokens) {
      checkFieldIsUpdateable(objType, fieldToken);
    }
  }

  /**
   * @description CheckFieldIs* method check only FLS
   *
   * @param objType as input
   * @param fieldName as input
   */

  /**
   * @description Checks insert field level security only (no CRUD) for the specified fields on {@code objType}
   * @exception FlsException if the running user does not have insert rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldName as input
   */
  public static void checkFieldIsInsertable(
    SObjectType objType,
    String fieldName
  ) {
    checkFieldIsInsertable(
      objType,
      CMN_UTIL_SObjectDescribe.getDescribe(objType).getField(fieldName)
    );
  }

  /**
   * @description Identical to {@link #checkFieldIsInsertable(SObjectType,String)}, except with SObjectField instead of String field reference.
   * @exception FlsException if the running user does not have insert rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldToken as input as input
   */
  public static void checkFieldIsInsertable(
    SObjectType objType,
    SObjectField fieldToken
  ) {
    checkFieldIsInsertable(objType, fieldToken.getDescribe());
  }

  /**
   * @description Identical to {@link #checkFieldIsInsertable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
   * @exception FlsException if the running user does not have insert rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldDescribe as input
   */
  public static void checkFieldIsInsertable(
    SObjectType objType,
    DescribeFieldResult fieldDescribe
  ) {
    if (!BYPASS_INTERNAL_FLS_AND_CRUD && !fieldDescribe.isCreateable()) {
      throw new FlsException(
        OperationType.CREATE,
        objType,
        fieldDescribe.getSobjectField()
      );
    }
  }

  /**
   * @description Checks read field level security only (no CRUD) for the specified fields on {@code objType}
   * @exception FlsException if the running user does not have read rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldName as input
   */
  public static void checkFieldIsReadable(
    SObjectType objType,
    String fieldName
  ) {
    checkFieldIsReadable(
      objType,
      CMN_UTIL_SObjectDescribe.getDescribe(objType).getField(fieldName)
    );
  }

  /**
   * @description Identical to {@link #checkFieldIsReadable(SObjectType,String)}, except with SObjectField instead of String field reference.
   * @exception FlsException if the running user does not have read rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldToken as input
   */
  public static void checkFieldIsReadable(
    SObjectType objType,
    SObjectField fieldToken
  ) {
    checkFieldIsReadable(objType, fieldToken.getDescribe());
  }

  /**
   * @description Identical to {@link #checkFieldIsReadable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
   * @exception FlsException if the running user does not have read rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldDescribe as input
   */
  public static void checkFieldIsReadable(
    SObjectType objType,
    DescribeFieldResult fieldDescribe
  ) {
    if (!BYPASS_INTERNAL_FLS_AND_CRUD && !fieldDescribe.isAccessible()) {
      throw new FlsException(
        OperationType.READ,
        objType,
        fieldDescribe.getSobjectField()
      );
    }
  }

  /**
   * @description Checks update field level security only (no CRUD) for the specified fields on {@code objType}
   * @exception FlsException if the running user does not have update rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldName as input
   */
  public static void checkFieldIsUpdateable(
    SObjectType objType,
    String fieldName
  ) {
    checkFieldIsUpdateable(
      objType,
      CMN_UTIL_SObjectDescribe.getDescribe(objType).getField(fieldName)
    );
  }

  /**
   * @description Identical to {@link #checkFieldIsUpdateable(SObjectType,String)}, except with SObjectField instead of String field reference.
   * @exception FlsException if the running user does not have update rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldToken as input as input
   */
  public static void checkFieldIsUpdateable(
    SObjectType objType,
    SObjectField fieldToken
  ) {
    checkFieldIsUpdateable(objType, fieldToken.getDescribe());
  }

  /**
   * @description Identical to {@link #checkFieldIsUpdateable(SObjectType,String)}, except with DescribeFieldResult instead of String field reference.
   * @exception FlsException if the running user does not have update rights to the {@code fieldName} field.
   *
   * @param objType as input
   * @param fieldDescribe as input
   */
  public static void checkFieldIsUpdateable(
    SObjectType objType,
    DescribeFieldResult fieldDescribe
  ) {
    if (!BYPASS_INTERNAL_FLS_AND_CRUD && !fieldDescribe.isUpdateable()) {
      throw new FlsException(
        OperationType.MODIFY,
        objType,
        fieldDescribe.getSobjectField()
      );
    }
  }

  /**
   * @description CheckObjectIs* methods check only CRUD
   *
   * @param objType as input
   */

  /**
   * @description Checks insert CRUD for the specified object type.
   * @exception CrudException if the running uder does not have insert rights to the {@code objType} SObject.
   *
   * @param objType as input
   */
  public static void checkObjectIsInsertable(SObjectType objType) {
    if (
      !BYPASS_INTERNAL_FLS_AND_CRUD && !objType.getDescribe().isCreateable()
    ) {
      throw new CrudException(OperationType.CREATE, objType);
    }
  }

  /**
   * @description Checks read CRUD for the specified object type.
   * @exception CrudException if the running uder does not have read rights to the {@code objType} SObject.
   *
   * @param objType as input
   */
  public static void checkObjectIsReadable(SObjectType objType) {
    if (
      !BYPASS_INTERNAL_FLS_AND_CRUD && !objType.getDescribe().isAccessible()
    ) {
      throw new CrudException(OperationType.READ, objType);
    }
  }

  /**
   * @description Checks update CRUD for the specified object type.
   * @exception CrudException if the running uder does not have update rights to the {@code objType} SObject.
   *
   * @param objType as input
   */
  public static void checkObjectIsUpdateable(SObjectType objType) {
    if (
      !BYPASS_INTERNAL_FLS_AND_CRUD && !objType.getDescribe().isUpdateable()
    ) {
      throw new CrudException(OperationType.MODIFY, objType);
    }
  }

  /**
   * @description Checks delete CRUD for the specified object type.
   * @exception CrudException if the running uder does not have delete rights to the {@code objType} SObject.
   *
   * @param objType as input
   */
  public static void checkObjectIsDeletable(SObjectType objType) {
    if (!BYPASS_INTERNAL_FLS_AND_CRUD && !objType.getDescribe().isDeletable()) {
      throw new CrudException(OperationType.DEL, objType);
    }
  }
}