/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 *  Provides an implementation of the Enterprise Application Architecture Unit Of Work, as defined by Martin Fowler
 *   http://martinfowler.com/eaaCatalog/unitOfWork.html
 * <p/>
 * "When you're pulling data in and out of a database, it's important to keep track of what you've changed; otherwise,
 *  that data won't be written back into the database. Similarly you have to insert new objects you create and
 *  remove any objects you delete."
 * <p/>
 * "You can change the database with each change to your object model, but this can lead to lots of very small database calls,
 *  which ends up being very slow. Furthermore it requires you to have a transaction open for the whole interaction, which is
 *  impractical if you have a business transaction that spans multiple requests. The situation is even worse if you need to
 *  keep track of the objects you've read so you can avoid inconsistent reads."
 * <p/>
 * "A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done,
 *  it figures out everything that needs to be done to alter the database as a result of your work."
 * <p/>
 * In an Apex context this pattern provides the following specific benefits
 *  - Applies bulkfication to DML operations, insert, update and delete
 *  - Manages a business transaction around the work and ensures a rollback occurs (even when exceptions are later handled by the caller)
 *  - Honours dependency rules between records and updates dependent relationships automatically during the commit
 * <p/>
 * Please refer to the testMethod's in this class for example usage
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
 *  <p>VCCC-378</p>
 */
public virtual inherited sharing class CMN_DAL_SObjectUnitOfWork implements CMN_INT_SObjectUnitOfWork
{
	private List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
	private Map<String, List<SObject>> newListByTypeMap = new Map<String, List<SObject>>();
	private Map<String, Map<Id, SObject>> deleteByTypeMap = new Map<String, Map<Id, SObject>>();
	private Map<String, Map<Id, SObject>> dirtyByTypeMap = new Map<String, Map<Id, SObject>>();
	private Map<String, Relationships> relationshipsMap = new Map<String, Relationships>();
	protected CMN_DAL_DmlHandler dmlHandler = new CMN_DAL_DmlHandler();

	private static final String ERROR_OBJECT_TYPE_NOT_SUPPORTED = 'SObject type {0} is not supported by this unit of work';

	/**
	 * @description Constructor of this class
	 */
	public CMN_DAL_SObjectUnitOfWork()
	{
	}

	public interface IDML
	{
		void dmlInsert(List<SObject> objList);
		void dmlUpdate(List<SObject> objList);
		void dmlDelete(List<SObject> objList);
	}

	/**
	 * @description class
	 */
	public inherited sharing class CMN_DAL_DmlHandler implements IDML
	{
		/**
		 * @description class for insert SObject list
		 *
		 * @param objList as input
		 */
		public void dmlInsert(List<SObject> objList)
		{
			insert objList;
		}

		/**
		 * @description class for update SObject list
		 *
		 * @param objList as input
		 */
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}

		/**
		 * @description class for delete SObject list
		 *
		 * @param objList as input
		 */
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
	}

	/**
	 * @description Constructs a new UnitOfWork to support work against the given object list
	 *
	 * @param sObjectTypes A list of objects given in dependency order (least dependent first)
	 */
	public CMN_DAL_SObjectUnitOfWork(List<Schema.SObjectType> sObjectTypes)
	{
		this();

		objectTypeList.addAll(sObjectTypes);

		for(Schema.SObjectType objectType : objectTypeList)
		{
			handleRegisterType(objectType);
		}
	}

	/**
	 * @description To add more SObjectTypes after instantiation
	 *
	 * @param sObjectTypes as input
	 */
	public void addSObjectTypes(List<Schema.SObjectType> sObjectTypes)
	{
		for(Schema.SObjectType objectType : sObjectTypes)
		{
			if(!objectTypeList.contains(objectType))
			{
				objectTypeList.add(objectType);
				handleRegisterType(objectType);
			}
		}
	}

	/**
	 * @description Will clear all registered updated from the UOW
	 */
	public void clear()
	{
		for(String key : deleteByTypeMap.keySet())
		{
			deleteByTypeMap.get(key).clear();
		}

		for(String key : dirtyByTypeMap.keySet())
		{
			dirtyByTypeMap.get(key).clear();
		}

		for(String key : newListByTypeMap.keySet())
		{
			newListByTypeMap.get(key).clear();
		}

		for(String key : relationshipsMap.keySet())
		{
			relationshipsMap.get(key).relationships.clear();
		}
	}

	/**
	 * @description default implementations for commitWork events
	 *
	 * @param objectType A list of objects given in dependency order (least dependent first)
	 */
	public virtual void onRegisterType(Schema.SObjectType objectType)
	{
	}

	/**
	 * @description NA
	 */
	public virtual void onCommitWorkStarting()
	{
	}

	/**
	 * @description NA
	 */
	public virtual void onDMLStarting()
	{
	}

	/**
	 * @description NA
	 */
	public virtual void onDMLFinished()
	{
	}

	/**
	 * @description NA
	 */
	public virtual void onCommitWorkFinishing()
	{
	}

	/**
	 * @description NA
	 *
	 * @param wasSuccessful as input
	 */
	public virtual void onCommitWorkFinished(Boolean wasSuccessful)
	{
	}

	/**
	 * @description Registers the type to be used for DML operations
	 *
	 * @param objectType - The type to register
	 */
	private void handleRegisterType(Schema.SObjectType objectType)
	{
		// add type to dml operation tracking
		newListByTypeMap.put(objectType.getDescribe().getName(), new List<SObject>());
		dirtyByTypeMap.put(objectType.getDescribe().getName(), new Map<Id, SObject>());
		deleteByTypeMap.put(objectType.getDescribe().getName(), new Map<Id, SObject>());
		relationshipsMap.put(objectType.getDescribe().getName(), new Relationships());
		// give derived class opportunity to register the type
		onRegisterType(objectType);
	}

	/**
	 * @description Method will ensure the correct register method is called based on whether the record  has an ID or not
	 *
	 * @param record The object that was changed
	 */
	public void registerChange(SObject record)
	{
		if(record.Id == null)
		{
			registerNew(record);
		}
		else
		{
			registerDirty(record);
		}
	}

	/**
	 * @description Register a newly created SObject instance to be inserted when commitWork is called
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 */
	public void registerNew(SObject record)
	{
		registerNew(record, null, null);
	}

	/**
	 * @description Register a list of newly created SObject instances to be inserted when commitWork is called
	 *
	 * @param records A list of newly created SObject instances to be inserted during commitWork
	 */
	public void registerNew(List<SObject> records)
	{
		for(SObject record : records)
		{
			registerNew(record);
		}
	}

	/**
	 * @description Register a newly created SObject instance to be inserted when commitWork is called,
	 *   			you may also provide a reference to the parent record instance (should also be registered as new separately)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	public void registerNew(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if(record.Id != null)
		{
			throw new UnitOfWorkException('Only new records can be registered as new');
		}
		String objectType = record.getSObjectType().getDescribe().getName();
		if(!newListByTypeMap.containsKey(objectType))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String>
			{
					objectType
			}));
		}
		newListByTypeMap.get(objectType).add(record);
		if(relatedToParentRecord != null && relatedToParentField != null)
		{
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		}
	}

	/**
	 * @description Register a relationship between two records that have yet to be inserted to the database. This information will be
	 *  			used during the commitWork phase to make the references only when related records have been inserted to the database.
	 *
	 * @param record An existing or newly created record
	 * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
	 * @param relatedTo A SOBject instance (yet to be commited to the database)
	 */
	public void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
	{
		String objectTypeName = record.getSObjectType().getDescribe().getName();
		if(!newListByTypeMap.containsKey(objectTypeName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String>
			{
					objectTypeName
			}));
		}
		relationshipsMap.get(objectTypeName).add(record, relatedToField, relatedTo);
	}

	/**
	 * @description Register an existing record to be updated during the commitWork method
	 *
	 * @param record An existing record
	 */
	public void registerDirty(SObject record)
	{
		if(record.Id == null)
		{
			throw new UnitOfWorkException('New records cannot be registered as dirty');
		}
		String objectTypeName = record.getSObjectType().getDescribe().getName();
		if(!dirtyByTypeMap.containsKey(objectTypeName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String>
			{
					objectTypeName
			}));
		}
		dirtyByTypeMap.get(objectTypeName).put(record.Id, record);
	}

	/**
	 * @description Register an existing record to be updated when commitWork is called,
	 *  			 you may also provide a reference to the parent record instance (should also be registered as new separately)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	public void registerDirty(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord)
	{
		if(record.Id == null)
		{
			throw new UnitOfWorkException('New records cannot be registered as dirty');
		}
		String objectTypeName = record.getSObjectType().getDescribe().getName();

		if(!dirtyByTypeMap.containsKey(objectTypeName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String>
			{
					objectTypeName
			}));
		}

		dirtyByTypeMap.get(objectTypeName).put(record.Id, record);
		if(relatedToParentRecord != null && relatedToParentField != null)
		{
			registerRelationship(record, relatedToParentField, relatedToParentRecord);
		}
	}

	/**
	 * @description Register a list of existing records to be updated during the commitWork method
	 *
	 * @param records A list of existing records
	 */
	public void registerDirty(List<SObject> records)
	{
		for(SObject record : records)
		{
			this.registerDirty(record);
		}
	}

	/**
	 * @description Register an existing record to be deleted during the commitWork method
	 *
	 * @param record An existing record
	 */
	public void registerDeleted(SObject record)
	{
		if(record.Id == null)
		{
			throw new UnitOfWorkException('New records cannot be registered for deletion');
		}
		String objectTypeName = record.getSObjectType().getDescribe().getName();

		if(!deleteByTypeMap.containsKey(objectTypeName))
		{
			throw new UnitOfWorkException(String.format(ERROR_OBJECT_TYPE_NOT_SUPPORTED, new List<String>
			{
					objectTypeName
			}));
		}

		deleteByTypeMap.get(objectTypeName).put(record.Id, record);
	}

	/**
	 * @description Register a list of existing records to be deleted during the commitWork method
	 *
	 * @param records A list of existing records
	 */
	public void registerDeleted(List<SObject> records)
	{
		for(SObject record : records)
		{
			this.registerDeleted(record);
		}
	}

	/**
	 * @description Will check if there are any items to create, edit or delete
	 *
	 * @return Returns true if there are items that are still not committed
	 */
	private Boolean hasItemsToCommit()
	{

		for(Map<Id, SObject> dirtyMap : dirtyByTypeMap.values())
		{
			if(!dirtyMap.values().isEmpty())
			{
				return true;
			}
		}

		for(List<SObject> newList : newListByTypeMap.values())
		{
			if(!newList.isEmpty())
			{
				return true;
			}
		}

		for(Map<Id, SObject> deletedMap : deleteByTypeMap.values())
		{
			if(!deletedMap.values().isEmpty())
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 */
	public virtual void commitWork()
	{
		//Do not do processing below if we don't have items to commit, prevents creation of unnecessary savepoint
		if(!hasItemsToCommit())
		{
			return;
		}

		// notify we're starting the commit work
		onCommitWorkStarting();

		Boolean wasSuccessful = false;
		Savepoint sp = Database.setSavepoint();// Wrap the work in its own transaction;
		try
		{
			// notify we're starting the DML operations
			onDMLStarting();

			// Insert by type
			for(Schema.SObjectType objectType : objectTypeList)
			{
				relationshipsMap.get(objectType.getDescribe().getName()).resolve();
				dmlHandler.dmlInsert(newListByTypeMap.get(objectType.getDescribe().getName()));
			}

			// Update by type
			for(Schema.SObjectType objectType : objectTypeList)
			{
				dmlHandler.dmlUpdate(dirtyByTypeMap.get(objectType.getDescribe().getName()).values());
			}

			// Delete by type (in reverse dependency order)
			Integer objectIdx = objectTypeList.size() - 1;

			while(objectIdx >= 0)
			{
				dmlHandler.dmlDelete(deleteByTypeMap.get(objectTypeList[objectIdx--].getDescribe().getName()).values());
			}

			// notify we're done with DML
			onDMLFinished();

			// notify we've completed all steps and are in the final stage of completing
			onCommitWorkFinishing();

			// mark tracker to indicate success
			wasSuccessful = true;
		}
		catch(Exception e)
		{
			// Rollback
			Database.rollback(sp);
			// Throw exception on to caller
			throw e;
		}
		finally
		{
			// notify we're done with commit work
			onCommitWorkFinished(wasSuccessful);
		}
	}

	/**
	 * @description This class to store the Relationship object
	 */
	private class Relationships
	{
		private List<Relationship> relationships = new List<Relationship>();

		/**
		 * @description NA
		 */
		public void resolve()
		{
			// Resolve relationships
			for(Relationship relationship : relationships)
			{
				relationship.record.put(relationship.relatedToField, relationship.relatedTo.Id);
			}
		}

		/**
		 * @description To add relationship
		 *
		 * @param record as input
		 * @param relatedToField as input
		 * @param relatedTo as input
		 */
		public void add(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
		{
			// Relationship to resolve
			Relationship relationship = new Relationship();
			relationship.record = record;
			relationship.relatedToField = relatedToField;
			relationship.relatedTo = relatedTo;
			relationships.add(relationship);
		}
	}

	private class Relationship
	{
		public SObject record;
		public Schema.SObjectField relatedToField;
		public SObject relatedTo;
	}

	/**
	 * @description UnitOfWork Exception
	 */
	public class UnitOfWorkException extends Exception
	{
	}
}