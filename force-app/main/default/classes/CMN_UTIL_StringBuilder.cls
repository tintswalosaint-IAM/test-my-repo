/**
 * @description Helper class, roughly based on the Java version, but subclassed to assist in a number of use cases in this library
 * <p/>
 * NOTE: Aspects of this where developed before recent improvements to String handling, as such could likely be enhanced at this stage.
 * <p/>
 * <p>VCCC-378</p>
 **/
public virtual class CMN_UTIL_StringBuilder {
  protected List<String> buffer = new List<String>();

  /**
   * @description Construct an empty StringBuilder
   **/
  public CMN_UTIL_StringBuilder() {
  }

  /**
   * @description Construct a StringBuilder with the given values
   *
   * @param values as input
   **/
  public CMN_UTIL_StringBuilder(List<String> values) {
    add(values);
  }

  /**
   * @description Add the given values to the StringBuilder
   *
   * @param values as input
   **/
  public virtual void add(List<String> values) {
    buffer.addAll(values);
  }

  /**
   * @description Add the given value to the StringBuilder
   *
   * @param value as input
   **/
  public virtual void add(String value) {
    buffer.add(value);
  }

  public virtual override String toString() {
    return String.join(buffer, '');
  }

  /**
   * @description Return the state of the StringBuilder
   *
   * @return string
   **/
  public virtual String getStringValue() {
    return toString();
  }

  /**
   * @description Subclasses the StringBuilder to produce a comma delimited concatenation of strings
   **/
  public virtual with sharing class CommaDelimitedListBuilder extends CMN_UTIL_StringBuilder {
    String itemPrefix = '';
    String delimiter = ',';

    public CommaDelimitedListBuilder() {
    }

    public CommaDelimitedListBuilder(List<String> values) {
      super(values);
    }

    public void setItemPrefix(String itemPrefix) {
      this.itemPrefix = itemPrefix;
    }

    public void setDelimiter(String delimiter) {
      this.delimiter = delimiter;
    }

    public String getStringValue(String itemPrefix) {
      setItemPrefix(itemPrefix);
      return toString();
    }

    public override String toString() {
      return itemPrefix + String.join(buffer, delimiter + itemPrefix);
    }
  }

  /**
   * @description Subclasses the StringCommaDelimitedBuilder to accept native SObjectField tokens and optional FieldSet definitions to concatinate when building queries
   **/
  public virtual with sharing class FieldListBuilder extends CommaDelimitedListBuilder {
    public FieldListBuilder(List<Schema.SObjectField> values) {
      this(values, null);
    }

    public FieldListBuilder(
      List<Schema.SObjectField> values,
      List<Schema.FieldSet> fieldSets
    ) {
      // Create a distinct set of fields (or field paths) to select
      for (Schema.SObjectField value : values) {
        add(String.valueOf(value));
      } // Alternative to value.getDescribe().getName()

      if (fieldSets != null) {
        for (Schema.FieldSet fieldSet : fieldSets) {
          for (Schema.FieldSetMember fieldSetMember : fieldSet.getFields()) {
            add(fieldSetMember.getFieldPath());
          }
        }
      }
    }
  }
}