/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
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
@IsTest(SeeAllData=false)
private class CMN_UTIL_Security_TEST {
  private static final String ERROR_CRUD_EXCEPTION = 'Expected an CrudException, got ';
  private static final String ERROR_FLS_EXCEPTION = 'Expected an FlsException, got ';

  /**
   * @description Method is use to test Read Only access of the fields with throwing
   * an exception if not a have proper access.
   */
  @IsTest
  private static void readonlyFieldAccess() {
    User testUser = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_READ_ONLY
    );

    System.runAs(testUser) {
      try {
        CMN_UTIL_Security.checkFieldIsInsertable(Account.SObjectType, 'naMe');
        System.assert(
          false,
          'Read only profile should not be able to insert Account.Name'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.FlsException,
          ERROR_FLS_EXCEPTION + error.getTypeName()
        );
      }

      try {
        CMN_UTIL_Security.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
      } catch (Exception error) {
        System.assert(
          false,
          'Read only profile should be able to read Contact.LastName'
        );
      }

      try {
        CMN_UTIL_Security.checkFieldIsUpdateable(
          Contact.SObjectType,
          'LastNAME'
        );
        System.assert(
          false,
          'Read only profile should not be able to update Contact.LastName'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.FlsException,
          ERROR_FLS_EXCEPTION + error.getTypeName()
        );
      }

      CMN_UTIL_Security.BYPASS_INTERNAL_FLS_AND_CRUD = true;

      CMN_UTIL_Security.checkFieldIsInsertable(Account.SObjectType, 'naMe');
      CMN_UTIL_Security.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
      CMN_UTIL_Security.checkFieldIsUpdateable(Contact.SObjectType, 'LastNAME');
    }
  }

  /**
   * @description Method is use to test Read Only access of the Object with throwing
   * an exception if not a have proper access.
   */
  @IsTest
  private static void readonlyObjectAccess() {
    User testUser = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_READ_ONLY
    );

    System.runAs(testUser) {
      try {
        CMN_UTIL_Security.checkObjectIsInsertable(Account.SObjectType);
        System.assert(
          false,
          'Read only profile should not be able to insert Account'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.CrudException,
          ERROR_CRUD_EXCEPTION + error.getTypeName()
        );
      }

      try {
        CMN_UTIL_Security.checkObjectIsReadable(Contact.SObjectType);
      } catch (Exception error) {
        System.assert(
          false,
          'Read only profile should be able to read Contact'
        );
      }

      try {
        CMN_UTIL_Security.checkObjectIsUpdateable(Contact.SObjectType);
        System.assert(
          false,
          'Read only profile should not be able to update Contact'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.CrudException,
          ERROR_CRUD_EXCEPTION + error.getTypeName()
        );
      }

      try {
        CMN_UTIL_Security.checkObjectIsDeletable(Contact.SObjectType);
        System.assert(
          false,
          'Read only profile should not be able to delete Contact'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.CrudException,
          ERROR_CRUD_EXCEPTION + error.getTypeName()
        );
      }
    }
  }

  /**
   * @description Method is use to test access of Object and field with throwing
   * an exception if not a have proper access for test user.
   */
  @IsTest
  private static void readonlyObjectAndFieldAccess() {
    User testUser = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_READ_ONLY
    );

    System.runAs(testUser) {
      try {
        CMN_UTIL_Security.checkInsert(
          Account.SObjectType,
          new List<String>{ 'Name', 'ParentId', 'OwnerId' }
        );
        System.assert(
          false,
          'Read only profile should not be able to insert Account'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.CrudException,
          ERROR_CRUD_EXCEPTION + error.getTypeName()
        );
      }

      try {
        CMN_UTIL_Security.checkRead(
          Contact.SObjectType,
          new List<String>{ 'LastName', 'accountId', 'OwnerId' }
        );
      } catch (Exception error) {
        System.assert(
          false,
          'Read only profile should be able to read Contact'
        );
      }

      try {
        CMN_UTIL_Security.checkUpdate(
          Contact.SObjectType,
          new List<String>{ 'LastName', 'accountId', 'OwnerId' }
        );
        System.assert(
          false,
          'Read only profile should not be able to update Lead'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.CrudException,
          ERROR_CRUD_EXCEPTION + error.getTypeName()
        );
      }

      CMN_UTIL_Security.BYPASS_INTERNAL_FLS_AND_CRUD = true;

      CMN_UTIL_Security.checkInsert(
        Account.SObjectType,
        new List<String>{ 'Name', 'Type', 'OwnerId' }
      );
      CMN_UTIL_Security.checkRead(
        Account.SObjectType,
        new List<String>{ 'Name', 'Type', 'OwnerId' }
      );
      CMN_UTIL_Security.checkUpdate(
        Account.SObjectType,
        new List<String>{ 'Name', 'Type', 'OwnerId' }
      );
    }
  }

  /**
   * @description Method is use to test access of Object and field with throwing
   * an exception if not a have proper access for Sys Admin user.
   */
  @IsTest
  private static void sysadminObjectAndFieldAccess() {
    User testUser = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
    );

    System.runAs(testUser) {
      CMN_UTIL_Security.checkInsert(
        Account.SObjectType,
        new List<Schema.SObjectField>{
          Account.Name,
          Account.ParentId,
          Account.OwnerId
        }
      );
      CMN_UTIL_Security.checkRead(
        Contact.SObjectType,
        new List<Schema.SObjectField>{
          Contact.LastName,
          Contact.AccountId,
          Contact.OwnerId
        }
      );
      CMN_UTIL_Security.checkUpdate(
        Contact.SObjectType,
        new List<Schema.SObjectField>{
          Contact.LastName,
          Contact.AccountId,
          Contact.OwnerId
        }
      );
      CMN_UTIL_Security.checkObjectIsDeletable(Account.SObjectType);
    }
  }

  /**
   * @description Tests that error is thrown if user's profile doesn't have access to object for field
   */
  @IsTest
  private static void noAccess() {
    User testUser = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER
    );

    System.runAs(testUser) {
      try {
        CMN_UTIL_Security.checkFieldIsReadable(Contact.SObjectType, 'LastNAME');
        System.assert(
          false,
          'Chatter Free profile should not be able to read Contact.LastName'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.FlsException,
          ERROR_FLS_EXCEPTION + error.getTypeName()
        );
      }

      try {
        CMN_UTIL_Security.checkRead(
          Contact.SObjectType,
          new List<String>{ 'LastName', 'accountId', 'OwnerId' }
        );
        System.assert(
          false,
          'Chatter Free profile should be able to read Contact'
        );
      } catch (Exception error) {
        System.assert(
          error instanceof CMN_UTIL_Security.CrudException,
          ERROR_CRUD_EXCEPTION + error.getTypeName()
        );
      }
    }
  }
}