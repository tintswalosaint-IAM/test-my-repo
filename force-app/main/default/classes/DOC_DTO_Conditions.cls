/**
 * This class is used as DTO class for SetConditions API
 *
 * <p>DBP-2295</p>
 *
 * @author (mark.bailey2@standardbank.co.za)
 *
 * @date Feb 15th 2021
 */

public class DOC_DTO_Conditions {
  public DOC_DTO_conditions() {
    input = new List<Input>();
  }

  public List<Input> input { get; set; }

  public class Input {
    @AuraEnabled
    public String partner { get; set; }
    public List<Conditions> conditions;

    public Input() {
      partner = '0';
      conditions = new List<Conditions>();
    }
  }

  public class ConditionKey {
    public String partnerFunction { get; set; }
    public String itemGuid { get; set; }
    public String recordId { get; set; }

    public ConditionKey() {
      partnerFunction = '0';
      itemGuid = '0';
      recordId = '0';
    }
  }

  public class Conditions {
    public String conditionCode { get; set; }
    public String documentGuid { get; set; }
    public String uploadedDate { get; set; }
    public List<ConditionKey> conditionKey;

    public Conditions() {
      conditionCode = '0';
      documentGuid = '0';
      uploadedDate = System.Today().format();
      conditionKey = new List<ConditionKey>();
    }
  }
}