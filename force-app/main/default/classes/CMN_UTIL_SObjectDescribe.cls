/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 * A semi-intelligent wrapper for standard apex Schema methods.
 * It provides an internal caching layer, to avoid hitting describe limits from repeated use,
 * as well as wrapper classes and methods to make common tasks like working with relationship field name oddities
 * as well namespace handling.
 * <p/>
 *  * Of particular note for use in contexts that may be released as managed packages are the #getFields and get #getGlobalDescribe methods
 * These return special immutable wrapper objects that automatically imply the current namespace (detected as the one this class is contained in)
 * and allow an older API style of omitting the namespace when working with fields or global describe maps.
 * This allows both upgrading old code to APIv29 by making use of these as a nearly drop in replacement, as well as keeping
 * namespace detection logic encapsulated.
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
public inherited sharing class CMN_UTIL_SObjectDescribe {
  //internal implementation details
  private Schema.SObjectType token;
  private Schema.SObjectField nameField;
  private Schema.DescribeSObjectResult describe { //lazy load - keep this light weight until we need more data
    get {
      if (describe == null) {
        describe = token.getDescribe();
      }
      return describe;
    }
    set;
  }
  private Map<String, Schema.SObjectField> fields {
    get {
      if (fields == null) {
        fields = describe.fields.getMap();
      }
      return fields;
    }
    set;
  }
  private Map<String, Schema.FieldSet> fieldSets {
    get {
      if (fieldSets == null) {
        fieldSets = describe.fieldSets.getMap();
      }
      return fieldSets;
    }
    set;
  }
  private FieldsMap wrappedFields {
    get {
      if (wrappedFields == null) {
        wrappedFields = new FieldsMap(this.fields);
      }
      return wrappedFields;
    }
    set;
  }

  private CMN_UTIL_SObjectDescribe(Schema.SObjectType token) {
    this.token = token;
    instanceCache.put(String.valueOf(token).toLowerCase(), this);
  }

  /**
   * @description he Schema.SObjectType this CMN_UTIL_SObjectDescribe instance is based on.
   *
   * @return sobject type
   */
  public Schema.SObjectType getSObjectType() {
    return token;
  }
  /**
   * @description This method is a convenient shorthand for calling getField(name, true)
   *
   * @param name as input
   *
   * @return sobject field
   */
  public Schema.SObjectField getField(String name) {
    return this.getField(name, true);
  }
  /**
   * @description This method provides a simplified shorthand for calling #getFields and getting the provided field.
   * Additionally it handles finding the correct SObjectField for relationship notation,
   * e.g. getting the Account field on Contact would fail without being referenced as AccountId - both work here.
   *
   * @param fieldName as input
   * @param implyNamespace as input
   *
   * @return sobject field
   */
  public Schema.SObjectField getField(
    String fieldName,
    Boolean implyNamespace
  ) {
    //resolve custom field cross-object (__r) syntax
    Schema.SObjectField result = wrappedFields.get(
      (fieldName.endsWithIgnoreCase('__r')
        ? (fieldName.removeEndIgnoreCase('__r') + '__c')
        : fieldName),
      implyNamespace
    );

    result = result == null
      ? wrappedFields.get(fieldName + 'Id', implyNamespace)
      : result;

    return result;
  }

  /**
   * @description Method to get the field name
   *
   * @return the field where isNameField() is true (if any); otherwise returns null
   */
  public Schema.SObjectField getNameField() {
    if (nameField == null) {
      for (Schema.SObjectField field : wrappedFields.values()) {
        if (field.getDescribe().isNameField()) {
          nameField = field;
          break;
        }
      }
    }
    return nameField;
  }

  /**
   * @description the raw Schema.DescribeSObjectResult an CMN_UTIL_SObjectDescribe instance wraps.
   *
   * @return describe
   */
  public Schema.DescribeSObjectResult getDescribe() {
    return describe;
  }
  /**
   * @description This method returns the raw data and provides no namespace handling.
   * 				Due to this, __use of this method is discouraged__ in favor of getFields().
   *
   * @return fields
   */
  public Map<String, Schema.SObjectField> getFieldsMap() {
    return fields;
  }

  /**
   * @description This method returns the wrappedFields
   *
   * @return wrappedFields
   */
  public FieldsMap getFields() {
    return wrappedFields;
  }

  /**
   * @description This method returns the field map
   *
   * @return fieldSets
   */
  public Map<String, Schema.FieldSet> getFieldSetsMap() {
    return fieldSets;
  }

  /**
   * @description This method is use to get the map of global describe
   */
  private static Map<String, Schema.SObjectType> rawGlobalDescribe {
    get {
      if (rawGlobalDescribe == null) {
        rawGlobalDescribe = Schema.getGlobalDescribe();
      }
      return rawGlobalDescribe;
    }
    set;
  }
  /**
   * @description This method is use to get the of global describe
   */
  private static GlobalDescribeMap wrappedGlobalDescribe {
    get {
      if (wrappedGlobalDescribe == null) {
        wrappedGlobalDescribe = new GlobalDescribeMap(rawGlobalDescribe);
      }

      return wrappedGlobalDescribe;
    }
    set;
  }
  /**
   * @description This is used to cache CMN_UTIL_SObjectDescribe instances as they're consutrcted
   * to prevent repeatedly re-constructing the same type.
   * These instances are not guaranteed to be, but typically will be, unique per SObject type due to the presence of flushCache.
   */
  private static Map<String, CMN_UTIL_SObjectDescribe> instanceCache {
    get {
      if (instanceCache == null) {
        instanceCache = new Map<String, CMN_UTIL_SObjectDescribe>();
      }

      return instanceCache;
    }
    set;
  }
  /**
   * @description This is used to cache CMN_UTIL_SObjectDescribe describe
   * This is describe the token of Sobject
   *
   * @param sObjectName as input
   *
   * @return result wrapper
   */
  public static CMN_UTIL_SObjectDescribe getDescribe(String sObjectName) {
    if (String.isBlank(sObjectName)) {
      return null;
    }

    CMN_UTIL_SObjectDescribe result = instanceCache.get(
      sObjectName.toLowerCase()
    );

    if (result == null) {
      Schema.SObjectType token = wrappedGlobalDescribe.get(
        sObjectName.toLowerCase()
      );

      result = token == null ? null : new CMN_UTIL_SObjectDescribe(token);
    }

    return result;
  }

  /**
   * @description This is used to describe the token of SObject
   *
   * @param token as input
   *
   * @return result
   */
  public static CMN_UTIL_SObjectDescribe getDescribe(Schema.SObjectType token) {
    CMN_UTIL_SObjectDescribe wrapper = null;

    if (token != null) {
      wrapper = instanceCache.get(String.valueOf(token).toLowerCase());
    }

    return wrapper == null &
      token != null
      ? new CMN_UTIL_SObjectDescribe(token)
      : wrapper;
  }

  /**
   * @description This is used to describe the SObject nativly
   *
   * @param nativeDescribe as input
   *
   * @return result
   */
  public static CMN_UTIL_SObjectDescribe getDescribe(
    Schema.DescribeSObjectResult nativeDescribe
  ) {
    CMN_UTIL_SObjectDescribe result;

    if (nativeDescribe != null) {
      result = instanceCache.get(nativeDescribe.getName().toLowerCase());
      result = result == null
        ? new CMN_UTIL_SObjectDescribe(nativeDescribe.getSObjectType())
        : result;
    }

    return result;
  }

  /**
   * @description This is used to describe the instance of SObject
   *
   * @param instance as input
   *
   * @return instance
   */
  public static CMN_UTIL_SObjectDescribe getDescribe(SObject instance) {
    return instance == null ? null : getDescribe(instance.getSObjectType());
  }

  /**
   * @description This is used to returns the same results as the native method,
   * just with caching built in to avoid limits
   *
   * @return rawGlobalDescribe
   */
  public static Map<String, SObjectType> getRawGlobalDescribe() {
    return rawGlobalDescribe;
  }

  /**
   * @description This is used to returns the same results as the native method,
   * just with warpperd built in to avoid limits
   *
   * @return wrappedGlobalDescribe
   */
  public static GlobalDescribeMap getGlobalDescribe() {
    return wrappedGlobalDescribe;
  }

  /**
   * @description Useful when working in heap space constrained environments.
   * Existing references to SObjectDescribe instances will continue to work.
   */
  public static void flushCache() {
    rawGlobalDescribe = null;
    instanceCache = null;
  }

  /**
   * @description This class handles emulating a Map<String,Object>'s non-mutating instance methods and helps navigate the complex topic of
   * 				handling implicit namespace behavior like pre-APIv29 did, while also allowing fully qualified references.
   * 				Note that this requires the API version of CMN_UTIL_SObjectDescribe to be 29 or higher to function properly.
   * <p/>
   * 	Due to the lack of language support for covariant return types sublasses are responsible for implementing the get methods.
   * 	A minimal implementation of these would be a cast and returning getObject's result.
   */
  private abstract class NamespacedAttributeMap {
    @TestVisible
    protected String currentNamespace;
    protected Map<String, Object> values;

    protected NamespacedAttributeMap(Map<String, Object> values) {
      currentNamespace = CMN_UTIL_SObjectDescribe.class
        .getName()
        .substringBefore('CMN_UTIL_SObjectDescribe')
        .removeEnd('.')
        .toLowerCase();
      this.values = values;
    }

    /**
     * @description This method is use to get the Object details
     *
     * @param name as input
     * @param implyNamespace as input
     *
     * @return object
     */
    protected virtual Object getObject(String name, Boolean implyNamespace) {
      Object returnObject = null;

      if (String.isNotBlank(name)) {
        String preferredValue = ((implyNamespace
            ? currentNamespace + '__'
            : CMN_UTIL_String.EMPTY) + name)
          .toLowerCase();

        if (values.containsKey(preferredValue)) {
          return values.get(preferredValue);
        } else if (implyNamespace) {
          return values.get(name.toLowerCase());
        }
      }

      return returnObject;
    }

    /**
     * @description This method is use to check the contains key
     *
     * @param name as input
     *
     * @return boolean contains key or not
     */
    public virtual Boolean containsKey(String name) {
      return this.containsKey(name, true);
    }

    /**
     * @description This method is use to check the contains key
     *
     * @param name as input
     * @param implyNamespace as input
     *
     * @return boolean contains key or not
     */
    public virtual Boolean containsKey(String name, Boolean implyNamespace) {
      Boolean containsKey = null;

      if (name != null) {
        String preferredValue = ((implyNamespace
            ? currentNamespace + '__'
            : CMN_UTIL_String.EMPTY) + name)
          .toLowerCase();
        containsKey = (values.containsKey(preferredValue) ||
        implyNamespace && values.containsKey(name.toLowerCase()));
      }

      return containsKey;
    }

    /**
     * @description This method is use to return size of value
     *
     * @return size
     */
    public virtual Integer size() {
      return values.size();
    }

    /**
     * @description This method is use to returns the key set of the map.
     * Note: unlike other NamespacedAttributeMap methods keySet defaults implyNamespace to false if not specified.
     *
     * @return keyset
     */
    public virtual Set<String> keySet() {
      return this.keySet(false);
    }

    /**
     * @description This method is use to returns the key set of the map.
     * Note: unlike other NamespacedAttributeMap methods keySet defaults implyNamespace to false if not specified.
     *
     * @param implyNamespace as input
     *
     * @return keyset
     */
    public virtual Set<String> keySet(Boolean implyNamespace) {
      if (implyNamespace) {
        Set<String> result = new Set<String>();
        for (String key : values.keySet()) {
          result.add(key.removeStartIgnoreCase(currentNamespace + '__'));
        }

        return result;
      } else {
        return values.keySet();
      }
    }
  }

  /**
   * @description A subclass of NamespacedAttributeMap for handling the data returned by #Schema.DescribeSObjectResult.fields.getMap
   */
  public class FieldsMap extends NamespacedAttributeMap {
    @TestVisible
    private FieldsMap(Map<String, Schema.SObjectField> values) {
      super(values);
    }

    /**
     * @description A subclass method use to return the name
     *
     * @param name as input
     *
     * @return sobject field
     */
    public Schema.SObjectField get(String name) {
      return this.get(name, true);
    }

    /**
     * @description A subclass method use to return the name with namespace
     *
     * @param name as input
     * @param implyNamespace as input
     *
     * @return sobject field
     */
    public Schema.SObjectField get(String name, Boolean implyNamespace) {
      return (Schema.SObjectField) this.getObject(name, implyNamespace);
    }

    /**
     * @description A subclass method use to return value of SObject
     *
     * @return sobject fields
     */
    public List<Schema.SObjectField> values() {
      return (List<Schema.SObjectField>) values.values();
    }
  }
  /**
   * @description A subclass of NamespacedAttributeMap for handling the data returned
   * by #Schema.getGlobalDescribe
   */
  public class GlobalDescribeMap extends NamespacedAttributeMap {
    @TestVisible
    private GlobalDescribeMap(Map<String, Schema.SObjectType> values) {
      super(values);
    }

    /**
     * @description A subclass method use to return name
     *
     * @param name as input
     *
     * @return sobject field
     */
    public Schema.SObjectType get(String name) {
      return this.get(name, true);
    }

    /**
     * @description A subclass method use to return name with name space
     *
     * @param name as input
     * @param implyNamespace as input
     *
     * @return sobject type
     */
    public Schema.SObjectType get(String name, Boolean implyNamespace) {
      return (Schema.SObjectType) this.getObject(name, implyNamespace);
    }
  }
}