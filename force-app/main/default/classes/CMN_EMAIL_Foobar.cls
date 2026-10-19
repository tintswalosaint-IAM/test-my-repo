/**
 * @description Demonstrates the use of Email Handler, used in unit tests to cover base code
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
global class CMN_EMAIL_Foobar extends CMN_EMAIL_BaseHandler {
  /**
   * @description Override of base method as Salesforce doesn't see the base class method for some reason
   *
   * @param email Inbound Email
   * @param envelope Inbound Email Envelope
   *
   * @return Result of processing the email
   */
  global override Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    return super.handleInboundEmail(email, envelope);
  }

  /**
   * @description Will create a Foobar object
   *
   * @param email Inbound Email
   * @param envelope Inbound Email Envelope
   *
   * @return The Foo that was either created
   */
  protected override SObject saveEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    super.saveEmail(email, envelope);

    CMN_Foobar__c newFoo = CMN_DAL_DataFactory.newFoobar();

    newFoo.CMN_Email__c = envelope.fromAddress;
    newFoo.Name = email.subject;
    newFoo.CMN_TextAreaLong__c = email.plainTextBody;
    newFoo.CMN_Text__c = email.fromName;

    CMN_DAL_SObjectDomain.insertDBObject(newFoo);

    return newFoo;
  }
}