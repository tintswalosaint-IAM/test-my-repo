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
 *  <p>VCCC-378</p>
 *
 * @see CMN_DAL_SObjectUnitOfWork
 **/
public interface CMN_INT_SObjectUnitOfWork
{
	/**
	 * @description Register a newly created SObject instance to be inserted when commitWork is called
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 */
	void registerNew(SObject record);

	/**
	 * @description Register a list of newly created SObject instances to be inserted when commitWork is called
	 *
	 * @param records A list of newly created SObject instances to be inserted during commitWork
	 */
	void registerNew(List<SObject> records);

	/**
	 * @description Register a newly created SObject instance to be inserted when commitWork is called,
	 *   you may also provide a reference to the parent record instance (should also be registered as new separately)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	void registerNew(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord);

	/**
	 * @description Register a relationship between two records that have yet to be inserted to the database. This information will be
	 *  used during the commitWork phase to make the references only when related records have been inserted to the database.
	 *
	 * @param record An existing or newly created record
	 * @param relatedToField A SObjectField reference to the lookup field that relates the two records together
	 * @param relatedTo A SObject instance (yet to be committed to the database)
	 */
	void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo);

	/**
	 * @description Register an existing record to be updated during the commitWork method
	 *
	 * @param record An existing record
	 */
	void registerDirty(SObject record);

	/**
	 * @description Register an existing record to be updated when commitWork is called,
	 *   you may also provide a reference to the parent record instance (should also be registered as new separately)
	 *
	 * @param record A newly created SObject instance to be inserted during commitWork
	 * @param relatedToParentField A SObjectField reference to the child field that associates the child record with its parent
	 * @param relatedToParentRecord A SObject instance of the parent record (should also be registered as new separately)
	 */
	void registerDirty(SObject record, Schema.SObjectField relatedToParentField, SObject relatedToParentRecord);

	/**
	 * @description Register a list of existing records to be updated during the commitWork method
	 *
	 * @param records A list of existing records
	 */
	void registerDirty(List<SObject> records);

	/**
	 * @description Register an existing record to be deleted during the commitWork method
	 *
	 * @param record An existing record
	 */
	void registerDeleted(SObject record);

	/**
	 * @description Register a list of existing records to be deleted during the commitWork method
	 *
	 * @param records A list of existing records
	 */
	void registerDeleted(List<SObject> records);

	/**
	 * @description Takes all the work that has been registered with the UnitOfWork and commits it to the database
	 */
	void commitWork();
}