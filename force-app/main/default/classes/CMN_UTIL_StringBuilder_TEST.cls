/**
 * @description : Copyright (c), FinancialForce.com, inc
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
 * <p>VCCC-378</p>
 **/
@IsTest(SeeAllData=false)
private class CMN_UTIL_StringBuilder_TEST {
  @IsTest
  private static void testStringBuilder1() {
    CMN_UTIL_StringBuilder sb = new CMN_UTIL_StringBuilder();
    sb.add('this is a string');
    sb.add(
      new List<String>{
        ', which is made',
        ' up from\r ',
        'a number of smaller strings',
        '. 5 in this case!'
      }
    );

    System.assertEquals(
      sb.getStringValue(),
      'this is a string, which is made up from\r a number of smaller strings. 5 in this case!'
    );
  }

  @IsTest
  private static void testStringBuilder2() {
    CMN_UTIL_StringBuilder sb = new CMN_UTIL_StringBuilder(
      new List<String>{ 'apples', ' and ', 'pears', ': stairs. ' }
    );
    sb.add('this is a string');
    sb.add(
      new List<String>{
        ', which is made',
        ' up from\r ',
        'a number of smaller strings',
        '. 5 in this case!'
      }
    );

    System.assertEquals(
      sb.getStringValue(),
      'apples and pears: stairs. this is a string, which is made up from\r a number of smaller strings. 5 in this case!'
    );
  }

  @IsTest
  private static void testCommaDelimitedBuilder1() {
    CMN_UTIL_StringBuilder.CommaDelimitedListBuilder sb = new CMN_UTIL_StringBuilder.CommaDelimitedListBuilder();
    sb.add('a');
    sb.add(new List<String>{ 'b', 'c', 'd' });

    System.assertEquals(sb.getStringValue(), 'a,b,c,d');
  }

  @IsTest
  private static void testCommaDelimitedBuilder2() {
    CMN_UTIL_StringBuilder.CommaDelimitedListBuilder sb = new CMN_UTIL_StringBuilder.CommaDelimitedListBuilder(
      new List<String>{ 'x', 'y' }
    );
    sb.add('a');
    sb.add(new List<String>{ 'b', 'c', 'd' });

    System.assertEquals(sb.getStringValue(), 'x,y,a,b,c,d');
  }

  @IsTest
  private static void testCommaDelimitedBuilderWithItemPrefix() {
    CMN_UTIL_StringBuilder.CommaDelimitedListBuilder sb = new CMN_UTIL_StringBuilder.CommaDelimitedListBuilder(
      new List<String>{ 'x', 'y' }
    );
    sb.add('a');
    sb.add(new List<String>{ 'b', 'c', 'd' });

    System.assertEquals(sb.getStringValue('$'), '$x,$y,$a,$b,$c,$d');
  }

  @IsTest
  private static void testCommaDelimitedBuilderWithAlternativeDelimiter() {
    CMN_UTIL_StringBuilder.CommaDelimitedListBuilder sb = new CMN_UTIL_StringBuilder.CommaDelimitedListBuilder(
      new List<String>{ 'x', 'y' }
    );
    sb.setDelimiter(';');
    sb.add('a');
    sb.add(new List<String>{ 'b', 'c', 'd' });

    System.assertEquals(sb.getStringValue(), 'x;y;a;b;c;d');
  }

  @IsTest
  private static void testCommaDelimitedBuilderWithAlternativeDelimiterAndPrefix() {
    CMN_UTIL_StringBuilder.CommaDelimitedListBuilder sb = new CMN_UTIL_StringBuilder.CommaDelimitedListBuilder(
      new List<String>{ 'x', 'y' }
    );
    sb.setItemPrefix('#');
    sb.setDelimiter(':');
    sb.add('a');
    sb.add(new List<String>{ 'b', 'c', 'd' });

    System.assertEquals(sb.getStringValue(), '#x:#y:#a:#b:#c:#d');
  }

  @IsTest
  private static void testFieldListBuilder() {
    List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
      Account.Name,
      Account.Id,
      Account.AccountNumber,
      Account.AccountNumber,
      Account.AnnualRevenue
    };
    CMN_UTIL_StringBuilder.FieldListBuilder sb = new CMN_UTIL_StringBuilder.FieldListBuilder(
      fields
    );
    List<String> fieldList = sb.getStringValue().split(',');
    Set<String> fieldSet = new Set<String>(fieldList);

    System.assertEquals(4, fieldSet.size());
    System.assert(fieldSet.contains('Name'));
    System.assert(fieldSet.contains('Id'));
    System.assert(fieldSet.contains('AccountNumber'));
    System.assert(fieldSet.contains('AnnualRevenue'));
  }

  @IsTest
  private static void testFieldSetBuilder() {
    List<Schema.SObjectField> fields = new List<Schema.SObjectField>{
      CMN_Foobar__c.Id
    };
    List<Schema.FieldSet> fieldSets = SObjectType.CMN_Foobar__c.fieldSets.getMap()
      .values();
    CMN_UTIL_StringBuilder.FieldListBuilder sb = new CMN_UTIL_StringBuilder.FieldListBuilder(
      fields,
      fieldSets
    );
    List<String> fieldList = sb.getStringValue().split(',');
    Set<String> fieldSet = new Set<String>(fieldList);

    System.assert(fieldSet.contains('Name'));
    System.assert(fieldSet.contains('Id'));
    System.assert(fieldSet.contains('CMN_Email__c'));
    System.assert(fieldSet.contains('CMN_Phone__c'));
  }
}