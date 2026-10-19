/**
 * @description Container for SObjects, indexed by one or more of the SObject's fields. Fields can be references to
 * related objects, and a case-insensitive mode is available.
 * <p/>
 * MIT License
 * <p/>
 * Copyright (c) 2018 Aidan Harding, Nebula Consulting
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * <p/>
 * https://nebulaconsulting.co.uk/insights/sobjectindex-the-class-you-can-use-everywhere/
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author aidan@nebulaconsulting.co.uk
 *
 * @date 06/11/2018
 */
public inherited sharing class CMN_UTIL_SObjectIndex implements CMN_INT_SObjectIndex {
  @TestVisible
  private static final String ERROR_CASE_INSENSITIVE = 'setIsCaseInsensitive(Boolean isCaseInsensitive) can only be called on an empty CMN_UTIL_SObjectIndex';

  public CMN_UTIL_SObjectIndex(String fieldName) {
    this(new List<String>{ fieldName }, 0);
  }
  public CMN_UTIL_SObjectIndex(List<String> indexFields) {
    this(indexFields, 0);
  }

  public CMN_UTIL_SObjectIndex setIsCaseInsensitive(Boolean isCaseInsensitive) {
    SerializerInterface keySerializer = isCaseInsensitive
      ? (SerializerInterface) new ToLowerCaseSerializer()
      : (SerializerInterface) new StringValueOfSerializer();
    return setKeySerializer(keySerializer);
  }

  private CMN_UTIL_SObjectIndex setKeySerializer(
    SerializerInterface keySerializer
  ) {
    if (isEmpty()) {
      this.keySerializer = keySerializer;
    } else {
      throw new IllegalStateException(ERROR_CASE_INSENSITIVE);
    }

    return this;
  }

  private final List<String> allIndexFields;
  private final Integer thisIndexDepth;
  private final String thisIndexField;
  private final Boolean isLastIndexLayer;
  private SerializerInterface keySerializer;

  private Map<String, CMN_INT_SObjectIndex> children;

  private CMN_UTIL_SObjectIndex(
    List<String> allIndexFields,
    Integer fieldDepth
  ) {
    this.thisIndexDepth = fieldDepth;
    this.allIndexFields = allIndexFields;
    this.thisIndexField = allIndexFields[fieldDepth];
    this.isLastIndexLayer = fieldDepth == allIndexFields.size() - 1;

    this.keySerializer = new StringValueOfSerializer();
    this.children = new Map<String, CMN_INT_SObjectIndex>();
  }

  public CMN_UTIL_SObjectIndex putAll(List<SObject> newObjects) {
    for (Integer i = 0, size = newObjects.size(); i < size; i++) {
      put(newObjects[i]);
    }

    return this;
  }

  private CMN_INT_SObjectIndex getOrCreateIndexFor(String key) {
    CMN_INT_SObjectIndex existingIndex = children.get(key);

    if (existingIndex != null) {
      return existingIndex;
    }

    CMN_INT_SObjectIndex newIndex;

    if (isLastIndexLayer) {
      newIndex = new SObjectIndexLeaf();
    } else {
      newIndex = new CMN_UTIL_SObjectIndex(allIndexFields, thisIndexDepth + 1)
        .setKeySerializer(keySerializer);
    }

    children.put(key, newIndex);
    return newIndex;
  }

  public CMN_UTIL_SObjectIndex put(SObject newObj) {
    getOrCreateIndexFor(getKeyFrom(newObj)).put(newObj);
    return this;
  }

  /**
   * @description Get a single object in the index where the indexed field is equal to key.
   *
   * @param key a value for the indexed field
   *
   * @return a matching object (if more than one match, it picks the first one in the index,
   * in the same order that they were added). null, if there is no match
   */
  public SObject get(Object key) {
    List<SObject> returnVal = getAll(key);
    return returnVal.isEmpty() ? null : returnVal[0];
  }

  /**
   * @description Get all objects in the index where the indexed field is equal to objVal
   *
   * @param key a value for the indexed field
   *
   * @return a list of matching objects. If there is no match, an empty list is returned
   */
  public List<SObject> getAll(Object key) {
    CMN_INT_SObjectIndex thisIndex = children.get(keySerializer.serialize(key));
    return thisIndex == null ? new List<SObject>() : thisIndex.values();
  }

  /**
   * @description Get an object in the index which matches the spec object on all indexed fields. Note that a
   * null value for an indexed field in the spec object will only match against null in the index
   *
   * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
   *
   * @return a matching object (if more than one match, it picks the first one in the index,
   * in the same order that they were added). null, if there is no match
   */
  public SObject get(SObject spec) {
    List<SObject> returnVal = getAll(spec);
    return returnVal.isEmpty() ? null : returnVal[0];
  }

  /**
   * @description Get all objects in the index which match the spec object on all indexed fields. Note that a
   * null value for an indexed field in the spec object will only match against null in the index
   *
   * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
   *
   * @return a list of matching objects. If there is no match, an empty list is returned
   */
  public List<SObject> getAll(SObject spec) {
    CMN_INT_SObjectIndex thisIndex = children.get(getKeyFrom(spec));
    return thisIndex != null ? thisIndex.getAll(spec) : new List<SObject>();
  }

  /**
   * @description Get all objects in the index which match the spec map on all fields which are both indexed, and also
   * mentioned in the map. Note that the absence of an indexed field in the map means select all values on that field
   *
   * @param spec a map of field names to values
   *
   * @return a list of matching objects. If there is no match, an empty list is returned
   */
  public List<SObject> getAll(Map<String, Object> spec) {
    if (spec.containsKey(thisIndexField)) {
      CMN_INT_SObjectIndex thisIndex = children.get(getKeyFrom(spec));
      return thisIndex != null ? thisIndex.getAll(spec) : new List<SObject>();
    } else {
      List<CMN_INT_SObjectIndex> subIndices = children.values();
      List<SObject> returnVal = new List<SObject>();
      for (Integer i = 0, size = subIndices.size(); i < size; i++) {
        returnVal.addAll(subIndices[i].getAll(spec));
      }

      return returnVal;
    }
  }

  public Boolean isEmpty() {
    return children.isEmpty();
  }

  public Set<String> keySet() {
    return children.keySet();
  }

  public Set<String> keySet(String field) {
    if (thisIndexField == field) {
      return children.keySet();
    } else {
      Set<String> keySet = new Set<String>();

      List<CMN_INT_SObjectIndex> subIndices = children.values();
      for (Integer i = 0, size = subIndices.size(); i < size; i++) {
        keySet.addAll(subIndices[i].keySet(field));
      }

      return keySet;
    }
  }

  public List<SObject> values() {
    List<SObject> values = new List<SObject>();

    List<CMN_INT_SObjectIndex> subIndices = children.values();
    for (Integer i = 0, size = subIndices.size(); i < size; i++) {
      values.addAll(subIndices[i].values());
    }

    return values;
  }

  /**
   * @description CMN_UTIL_SObjectIndex is internally structured as a tree of indexes, with one level for
   * each field that you have indexed on. Given a value on the current top-level, this returns the
   * subtree matching that value
   *
   * @param key a value on the first field indexed in the CMN_UTIL_SObjectIndex
   *
   * @return a CMN_UTIL_SObjectIndex for entries matching val, and indexed on the remainder of the fields after
   * the current top-level. null if there is no match
   */
  public CMN_UTIL_SObjectIndex getSubIndex(Object key) {
    return (CMN_UTIL_SObjectIndex) children.get(keySerializer.serialize(key));
  }

  /**
   * @description Removes some entries from the index, based on the same matching criteria as getAll(sObject spec)
   *
   * @param spec an sObject which has all of the indexed fields (not necessarily the same object as stored in the index)
   *
   * @return the list of objects removed, or an empty list if there were no matches
   */
  public List<SObject> remove(SObject spec) {
    CMN_INT_SObjectIndex thisIndex = children.get(getKeyFrom(spec));
    return thisIndex != null ? thisIndex.remove(spec) : new List<SObject>();
  }

  /**
   * @description Removes some entries from the index, based on the same matching criteria as getAll(Map<String, Object> spec)
   *
   * @param spec a map of field names to values
   *
   * @return the list of objects removed, or an empty list if there were no matches
   */
  public List<SObject> remove(Map<String, Object> spec) {
    if (spec.containsKey(thisIndexField)) {
      CMN_INT_SObjectIndex thisIndex = children.get(getKeyFrom(spec));
      return thisIndex != null ? thisIndex.remove(spec) : new List<SObject>();
    } else {
      List<SObject> removedValues = new List<SObject>();
      List<CMN_INT_SObjectIndex> subIndices = children.values();
      for (Integer i = 0, size = subIndices.size(); i < size; i++) {
        removedValues.addAll(subIndices[i].remove(spec));
      }

      return removedValues;
    }
  }

  private String getKeyFrom(SObject obj) {
    return keySerializer.serialize(
      CMN_UTIL_System.getFieldValue(obj, thisIndexField)
    );
  }

  private String getKeyFrom(Map<String, Object> aMap) {
    return keySerializer.serialize(aMap.get(thisIndexField));
  }

  @TestVisible
  private class IllegalStateException extends Exception {
  }

  public class SObjectIndexLeaf implements CMN_INT_SObjectIndex {
    private List<SObject> objects;

    public SObjectIndexLeaf() {
      objects = new List<SObject>();
    }

    public CMN_INT_SObjectIndex put(SObject newObj) {
      objects.add(newObj);
      return this;
    }

    public List<SObject> getAll(Object key) {
      return objects;
    }

    public List<SObject> values() {
      return objects;
    }

    private List<SObject> remove() {
      List<SObject> returnVal = objects;

      objects = new List<SObject>();

      return returnVal;
    }

    public List<SObject> remove(SObject spec) {
      return remove();
    }

    public List<SObject> remove(Map<String, Object> spec) {
      return remove();
    }

    public Set<String> keySet(String field) {
      return new Set<String>();
    }

    public List<SObject> getAll(Map<String, Object> spec) {
      return objects;
    }

    public List<SObject> getAll(SObject spec) {
      return objects;
    }
  }

  /**
   * @description Interface for CMN_INT_Serializer's
   *
   * @author aidan@nebulaconsulting.co.uk
   *
   * @date 19/11/2018
   */
  public interface SerializerInterface {
    /**
     * @description Will serialize the given object
     *
     * @param o the object to serialize
     *
     * @return String containing object
     */
    String serialize(Object o);
  }

  /**
   * @description CMN_INT_Serializer that converts non-null values to lower case
   *
   * @author aidan@nebulaconsulting.co.uk
   *
   * @date 19/11/2018
   */
  public class ToLowerCaseSerializer implements SerializerInterface {
    /**
     * @description Will serialize the given object to lower case
     *
     * @param o Object to serialize
     *
     * @return A string of the object in lower case
     */
    public String serialize(Object o) {
      return o == null ? null : String.valueOf(o).toLowerCase();
    }
  }

  /**
   * @description Null-safe serializer that calls String.valueOf()
   *
   * @author aidan@nebulaconsulting.co.uk
   *
   * @date 19/11/2018
   */
  public class StringValueOfSerializer implements SerializerInterface {
    public String serialize(Object o) {
      return String.valueOf(o);
    }
  }
}