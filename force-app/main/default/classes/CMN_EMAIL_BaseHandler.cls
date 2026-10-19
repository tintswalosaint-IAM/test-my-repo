/**
 * @description Base handler to inherit from for building Inbound Email Handlers
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
global virtual class CMN_EMAIL_BaseHandler implements Messaging.InboundEmailHandler {
  /**
   * @description Implements the Messaging.InboundEmailHandler interface to be implemented by descendant classes. Will log inbound email
   *
   * @param email Inbound Email
   * @param envelope Inbound Email Envelope
   *
   * @return Result of processing the email
   */
  global virtual Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

    try {
      log(email, envelope);
      SObject linkToObject = saveEmail(email, envelope);
      saveAttachments(linkToObject == null ? null : linkToObject.Id, email);
    } catch (Exception error) {
      CMN_UTIL_Logger.error(error, 'CMN_EMAIL_BaseHandler.handleInboundEmail');

      result.success = false;
      result.message = error.getMessage();
    }

    return result;
  }

  /**
   * @description Implement this method on descendant classes to process incoming email and potentially create, update existing object
   *
   * @param email Inbound Email
   * @param envelope Inbound Email Envelope
   *
   * @return The object that was either created or updated
   */
  protected virtual SObject saveEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    return null;
  }

  /**
   * @description Method will save Email attachments as Content Versions
   *
   * @param linkToObjectId If set, this will ensure content version is linked to relevant object
   * @param email The inbound email containing attachments
   *
   * @return A list of newly inserted Content Versions
   */
  private List<ContentVersion> saveAttachments(
    Id linkToObjectId,
    Messaging.InboundEmail email
  ) {
    List<ContentVersion> newContentVersions = new List<ContentVersion>();

    if (mustSaveAttachments()) {
      newContentVersions.addAll(
        CMN_DAL_DataFactory.newContentVersionsFromBinaryAttachments(
          linkToObjectId,
          email.binaryAttachments
        )
      );
      newContentVersions.addAll(
        CMN_DAL_DataFactory.newContentVersionsFromTextAttachments(
          linkToObjectId,
          email.textAttachments
        )
      );

      CMN_DAL_SObjectDomain.insertDBObjects(newContentVersions);
    }

    return newContentVersions;
  }

  /**
   * @description Override this method to indicate if inbound email's attachments must be saved
   *
   * @return Flag indicating whether to save email attachments
   */
  protected virtual Boolean mustSaveAttachments() {
    return true;
  }

  /**
   * @description Allows class to log required information from Email and it's Envelope, can be overridden
   *
   * @param email Inbound Email
   * @param envelope Inbound Email Envelope
   */
  protected virtual void log(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    CMN_UTIL_Logger.info(
      '\n InboundEmail Envelope:' +
      '\n' +
      'from:' +
      envelope.fromAddress +
      ' to: ' +
      envelope.toAddress +
      '\n' +
      '\n  subject    :' +
      email.subject +
      '\n  ccAddresses:' +
      email.ccAddresses +
      '\n  toAddresses:' +
      email.toAddresses +
      '\n  fromAddress:' +
      email.fromAddress +
      '\n  fromName   :' +
      email.fromName +
      '\n  #binAtch:' +
      (email.binaryAttachments != null ? email.binaryAttachments.size() : 0) +
      '\n  #textAtch:' +
      (email.textAttachments != null ? email.textAttachments.size() : 0) +
      '\n  plaintextBody:' +
      email.plainTextBody +
      '\n  htmlBody:' +
      email.htmlBody,
      'CMN_EMAIL_BaseHandler/log'
    );
  }
}