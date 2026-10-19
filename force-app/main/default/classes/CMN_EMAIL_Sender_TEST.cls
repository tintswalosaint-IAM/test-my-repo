/**
 * @description This code is part of the "apex-lang" open-source project release 1.18 available at:
 * <p/>
 * http://code.google.com/p/apex-lang/
 * <p/>
 * Copyright (2012) richard van hook
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * <p/>
 * This project code has been forked and to update the latest salesforce APIs.
 * <p/>
 * <p>VCCC-378</p>
 */
@IsTest(SeeAllData=false)
private class CMN_EMAIL_Sender_TEST {
  private static final String TEST_SUBJECT = 'Test method';
  private static final String TEST_BODY = 'This is to test the sendTextNotificationEmail method';

  @IsTest
  private static void testSendEmailTest() {
    List<String> recipients = new List<String>{
      'test@test.com',
      'test2@test.com'
    };
    CMN_EMAIL_Sender.sendTextEmail(recipients, TEST_SUBJECT, TEST_BODY);
    CMN_EMAIL_Sender.sendHTMLEmail(recipients, TEST_SUBJECT, TEST_BODY);
    Assert.isTrue(true, 'Expected no exception when sending emails to valid recipients');
  }

  @IsTest
  private static void testSendEmailNoRecipientsTest() {
    List<String> recipients = null;
    CMN_EMAIL_Sender.sendTextEmail(recipients, TEST_SUBJECT, TEST_BODY);

    recipients = new List<String>();
    CMN_EMAIL_Sender.sendHTMLEmail(recipients, TEST_SUBJECT, TEST_BODY);
    Assert.isTrue(true, 'Expected no exception when sending emails with no recipients');
  }

  @IsTest
  private static void testSendEmailWithAttachmentTest() {
    List<String> recipients = new List<String>{
      'test@test.com',
      'test2@test.com'
    };
    List<Attachment> stdAttachments = new List<Attachment>();
    Attachment a = new Attachment();
    a.Name = 'Test';
    a.Body = EncodingUtil.base64Decode('Test Body');
    stdAttachments.add(a);
    CMN_EMAIL_Sender.sendEmailWithStandardAttachments(recipients, TEST_SUBJECT, TEST_BODY, false, stdAttachments);
    Assert.isTrue(true, 'Expected no exception when sending emails with standard attachments');
  }

  @IsTest
  private static void testSendEmailWithAttachmentIDsTest() {
    List<String> recipients = new List<String>{
      'test@test.com',
      'test2@test.com'
    };
    List<Id> stdAttachments = new List<Id>();

    CMN_Foobar__c foo = new CMN_Foobar__c(Name = 'Test Foo__c');
    foo.Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType);
    //insert foo;

    Attachment a = new Attachment();
    a.ParentId = foo.Id;
    a.Name = 'Test';
    a.Body = EncodingUtil.base64Decode('Test Body');
    a.Id = CMN_UTIL_Random.randomSObjectId(Attachment.SObjectType);
    //insert a;
    stdAttachments.add(a.Id);
    CMN_EMAIL_Sender.sendEmailWithStandardAttachments(recipients, TEST_SUBJECT, TEST_BODY, false, stdAttachments);
    Assert.isTrue(true, 'Expected no exception when sending emails with attachment IDs');
  }

  @IsTest
  private static void testIsNotValidEmailAddress() {
    System.assertEquals(true, CMN_EMAIL_Sender.isNotValidEmailAddress(null));
    System.assertEquals(true, CMN_EMAIL_Sender.isNotValidEmailAddress('  '));
    System.assertEquals(true, CMN_EMAIL_Sender.isNotValidEmailAddress('x'));
    System.assertEquals(true, CMN_EMAIL_Sender.isNotValidEmailAddress('x@'));
    System.assertEquals(true, CMN_EMAIL_Sender.isNotValidEmailAddress('x@x'));
    System.assertEquals(
      false,
      CMN_EMAIL_Sender.isNotValidEmailAddress('x@x.x')
    );
  }
}