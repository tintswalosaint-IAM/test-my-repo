/**
 * @description Class use to store the JSON content and generates indented content using the pretty-print format.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
global virtual class CMN_DTO_Json {
  /**
   * @description Suppresses null values when serializing Apex objects JSON Conenct
   *
   * @param prettyPrint If set to true generates indented content using the pretty-print format
   *
   * @return JSON string
   */
  public String serialize(Boolean prettyPrint) {
    return prettyPrint
      ? JSON.serializePretty(this, true)
      : JSON.serialize(this, true);
  }

  /**
   * @description serialise the string
   *
   * @return pretty serialised string
   */
  public String serialize() {
    return serialize(true);
  }

  /**
   * @description Will transform the DTO provided into the current dto, its up to the class to check the type being passed an transform appropriately
   *
   * @param dtoJson Input dto for transformation
   */
  public virtual void populate(CMN_DTO_Json dtoJson) {
  }
}