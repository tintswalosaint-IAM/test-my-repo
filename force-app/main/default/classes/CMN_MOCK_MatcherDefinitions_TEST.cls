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
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 * <p>VCCC-378</p>
 **/
@IsTest(SeeAllData=true)
private class CMN_MOCK_MatcherDefinitions_TEST {
  private static final List<CMN_MOCK_IMatcher> INTERNAL_MATCHERS = new List<CMN_MOCK_IMatcher>{
    new CMN_MOCK_MatcherDefinitions.StringContains('bob'),
    new CMN_MOCK_MatcherDefinitions.StringContains('tom'),
    new CMN_MOCK_MatcherDefinitions.StringContains('fred')
  };

  private static final Date TODAY = System.today();
  private static final Datetime NOW = System.now();

  private static final SObject ACCOUNT_RECORD;
  private static final Schema.SObjectType ACCOUNT_OBJECT_TYPE;
  private static final Schema.SObjectType OPPORTUNITY_OBJECT_TYPE;
  private static final Schema.SObjectType GROUP_OBJECT_TYPE;
  private static final SObject[] GROUP_RECORDS;

  static {
    Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

    ACCOUNT_OBJECT_TYPE = globalDescribe.get('Account');
    OPPORTUNITY_OBJECT_TYPE = globalDescribe.get('Opportunity');
    GROUP_OBJECT_TYPE = globalDescribe.get('Group');

    SObject accountRecord = ACCOUNT_OBJECT_TYPE.newSObject();
    accountRecord.put('Name', 'MatcherDefinitionTestAccount' + System.now());
    accountRecord.Id = CMN_DAL_SObjectDomain.generateIncrementalId(
      Account.SObjectType
    );
    ACCOUNT_RECORD = accountRecord;

    GROUP_RECORDS = new List<Group>{
      new Group(
        Name = 'MatcherDefnTestGroup0' + System.now(),
        DeveloperName = 'MatcherDefnTestGroup0' + System.now().getTime(),
        Type = 'Queue'
      ),
      new Group(
        Name = 'MatcherDefnTestGroup1' + System.now(),
        DeveloperName = 'MatcherDefnTestGroup1' + System.now().getTime(),
        Type = 'Queue'
      )
    };
    insert GROUP_RECORDS;
  }

  @IsTest
  private static void whenConstructingCombinedWithNullConnectiveExpressionShouldThrowException() {
    try {
      new CMN_MOCK_MatcherDefinitions.Combined(null, INTERNAL_MATCHERS);
      System.assert(false, 'Expecting exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals(
        'Invalid connective expression: null',
        e.getMessage()
      );
    }
  }

  @IsTest
  private static void whenConstructingCombinedWithNullInternalMatchersShouldThrowException() {
    try {
      new CMN_MOCK_MatcherDefinitions.Combined(
        CMN_MOCK_MatcherDefinitions.Connective.ALL,
        null
      );
      System.assert(false, 'Expecting exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Invalid inner matchers: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenConstructingCombinedWithEmptyInternalMatchersShouldThrowException() {
    try {
      new CMN_MOCK_MatcherDefinitions.Combined(
        CMN_MOCK_MatcherDefinitions.Connective.ALL,
        new List<CMN_MOCK_IMatcher>()
      );
      System.assert(false, 'Expecting exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Invalid inner matchers: ()', e.getMessage());
    }
  }

  @IsTest
  private static void whenCombinedMatchesWithAllExpressionShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.Combined(
      CMN_MOCK_MatcherDefinitions.Connective.ALL,
      INTERNAL_MATCHERS
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('ted'));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches('tomfred'));
    System.assert(matcher.matches('bobtomfred'));
  }

  @IsTest
  private static void whenCombinedMatchesWithAtLeastOneExpressionShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.Combined(
      CMN_MOCK_MatcherDefinitions.Connective.AT_LEAST_ONE,
      INTERNAL_MATCHERS
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('ted'));
    System.assert(matcher.matches('bob'));
    System.assert(matcher.matches('tomfred'));
    System.assert(matcher.matches('bobtomfred'));
  }

  @IsTest
  private static void whenCombinedMatchesWithNoneExpressionShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.Combined(
      CMN_MOCK_MatcherDefinitions.Connective.NONE,
      INTERNAL_MATCHERS
    );
    System.assert(matcher.matches(null));
    System.assert(matcher.matches('ted'));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches('tomfred'));
    System.assert(!matcher.matches('bobtomfred'));
  }

  @IsTest
  private static void constructEq_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.Eq(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenEqMatchesShouldReturnCorrectResults() {
    List<String> s1 = new List<String>{ 'bob', 'tom' };
    List<String> s2 = new List<String>{ 'bob', 'tom' };
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.Eq(s1);
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(new List<String>{ 'bob' }));
    System.assert(matcher.matches(s2));
    System.assert(matcher.matches(s1));
  }

  @IsTest
  private static void constructRefEq_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.RefEq(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenRefEqMatchesShouldReturnCorrectResults() {
    List<String> s1 = new List<String>{ 'bob', 'tom' };
    List<String> s2 = new List<String>{ 'bob', 'tom' };
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.RefEq(s1);
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(s2));
    System.assert(matcher.matches(s1));
  }

  @IsTest
  private static void whenAnyBooleanMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyBoolean();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(9));
    System.assert(matcher.matches(true));
    System.assert(matcher.matches(false));
  }

  @IsTest
  private static void whenAnyDateMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyDate();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(NOW));
    System.assert(matcher.matches(TODAY));
  }

  @IsTest
  private static void whenAnyDatetimeMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyDatetime();
    System.assert(!matcher.matches(null));
    System.assert(matcher.matches(NOW));
    System.assert(matcher.matches(TODAY));
  }

  @IsTest
  private static void whenAnyDecimalMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyDecimal();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(matcher.matches(9));
    System.assert(matcher.matches(9L));
    System.assert(matcher.matches(9.99));
  }

  @IsTest
  private static void whenAnyDoubleMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyDouble();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(matcher.matches(9));
    System.assert(matcher.matches(9L));
    System.assert(matcher.matches(9.99));
  }

  @IsTest
  private static void whenAnyFieldSetMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyFieldSet();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));

    Schema.FieldSet anyFieldSet = CMN_MOCK_ApexMocksUtils_TEST.findAnyFieldSet();
    if (anyFieldSet != null) {
      System.assert(matcher.matches(anyFieldSet));
    }
  }

  @IsTest
  private static void whenAnyIdMatchesShouldReturnCorrectResults() {
    String idString = CMN_DAL_SObjectDomain.generateIncrementalId(
      Account.SObjectType
    );
    Id accountId = CMN_DAL_SObjectDomain.generateIncrementalId(
      Account.SObjectType
    );
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyId();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(matcher.matches(idString));
    System.assert(matcher.matches(accountId));
  }

  @IsTest
  private static void whenAnyIntegerMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyInteger();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(9L));
    System.assert(!matcher.matches(9.99));
    System.assert(matcher.matches(9));
  }

  @IsTest
  private static void whenAnyListMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyList();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(matcher.matches(new List<String>()));
    System.assert(matcher.matches(new List<Integer>()));
    System.assert(matcher.matches(new List<Object>()));
  }

  @IsTest
  private static void whenAnyLongMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyLong();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(9.99));
    System.assert(matcher.matches(9));
    System.assert(matcher.matches(9L));
  }

  @IsTest
  private static void whenAnyObjectMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyObject();
    System.assert(!matcher.matches(null));
    System.assert(matcher.matches('bob'));
    System.assert(matcher.matches(9));
    System.assert(matcher.matches(new List<String>()));
  }

  @IsTest
  private static void whenAnyStringMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnyString();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(9));
    System.assert(matcher.matches('bob'));
  }

  @IsTest
  private static void whenAnySObjectMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnySObject();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(matcher.matches(new Account()));
  }

  @IsTest
  private static void whenAnySObjectFieldMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnySObjectField();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(new Account()));
    System.assert(matcher.matches(Account.Id));
  }

  @IsTest
  private static void whenAnySObjectTypeMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.AnySObjectType();
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(new Account()));
    System.assert(matcher.matches(Account.SObjectType));
  }

  @IsTest
  private static void constructDatetimeAfter_WithNullFromDatetime_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeAfter(null, true);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDatetimeAfter_WithNullInclusive_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeAfter(System.now(), null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenDatetimeAfterMatchesWithoutInclusiveShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.DatetimeAfter(
      NOW,
      false
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(NOW.addSeconds(-1)));
    System.assert(!matcher.matches(NOW));
    System.assert(matcher.matches(NOW.addSeconds(1)));
  }

  @IsTest
  private static void whenDatetimeAfterMatchesWithInclusiveShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.DatetimeAfter(
      NOW,
      true
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(NOW.addSeconds(-1)));
    System.assert(matcher.matches(NOW));
    System.assert(matcher.matches(NOW.addSeconds(1)));
  }

  @IsTest
  private static void constructDatetimeBefore_WithNullToDatetime_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeBefore(null, true);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDatetimeBefore_WithNullInclusive_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeBefore(System.now(), null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenDatetimeBeforeMatchesWithoutInclusiveShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.DatetimeBefore(
      NOW,
      false
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(NOW.addSeconds(1)));
    System.assert(!matcher.matches(NOW));
    System.assert(matcher.matches(NOW.addSeconds(-1)));
  }

  @IsTest
  private static void whenDatetimeBeforeMatchesWithInclusiveShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.DatetimeBefore(
      NOW,
      true
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(NOW.addSeconds(1)));
    System.assert(matcher.matches(NOW));
    System.assert(matcher.matches(NOW.addSeconds(-1)));
  }

  @IsTest
  private static void constructDatetimeBetween_WithNullFromDatetime_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
        null,
        true,
        System.now(),
        true
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDatetimeBetween_WithNullToDatetime_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
        System.now(),
        true,
        null,
        true
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDatetimeBetween_WithNullInclusiveFrom_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
        System.now(),
        null,
        System.now(),
        true
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDatetimeBetween_WithNullInclusiveTo_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
        System.now(),
        true,
        System.now(),
        null
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenDatetimeBetweenMatchesWithInclusiveFromWithoutInclusiveToShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
      NOW.addSeconds(-1),
      true,
      NOW.addSeconds(1),
      false
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(NOW.addSeconds(-2)));
    System.assert(!matcher.matches(NOW.addSeconds(1)));
    System.assert(matcher.matches(NOW.addSeconds(-1)));
    System.assert(matcher.matches(NOW));
  }

  @IsTest
  private static void whenDatetimeBetweenMatchesWithInclusiveToWithoutInclusiveFromShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
      NOW.addSeconds(-1),
      false,
      NOW.addSeconds(1),
      true
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bob'));
    System.assert(!matcher.matches(NOW.addSeconds(2)));
    System.assert(!matcher.matches(NOW.addSeconds(-1)));
    System.assert(matcher.matches(NOW));
    System.assert(matcher.matches(NOW.addSeconds(1)));
  }

  @IsTest
  private static void constructDecimalBetween_WithNullLower_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(null, true, 123, true);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDecimalBetween_WithNullInclusiveLower_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(123, null, 123, true);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDecimalBetween_WithNullUpper_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(123, true, null, true);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDecimalBetween_WithNullInclusiveUpper_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(123, true, 123, null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenDecimalBetweenMatchesShouldReturnCorrectResults() {
    Integer lower = 5;
    Integer upper = 10;

    CMN_MOCK_IMatcher exLowerExUpper = new CMN_MOCK_MatcherDefinitions.DecimalBetween(
      lower,
      false,
      upper,
      false
    );
    CMN_MOCK_IMatcher exLowerInUpper = new CMN_MOCK_MatcherDefinitions.DecimalBetween(
      lower,
      false,
      upper,
      true
    );
    CMN_MOCK_IMatcher inLowerExUpper = new CMN_MOCK_MatcherDefinitions.DecimalBetween(
      lower,
      true,
      upper,
      false
    );
    CMN_MOCK_IMatcher inLowerInUpper = new CMN_MOCK_MatcherDefinitions.DecimalBetween(
      lower,
      true,
      upper,
      true
    );

    //Exclusive lower, exclusive upper
    System.assert(!exLowerExUpper.matches(lower - 1));
    System.assert(!exLowerExUpper.matches(lower));
    System.assert(exLowerExUpper.matches(lower + 1));
    System.assert(exLowerExUpper.matches(upper - 1));
    System.assert(!exLowerExUpper.matches(upper));
    System.assert(!exLowerExUpper.matches(upper + 1));
    System.assert(!exLowerExUpper.matches(null));
    System.assert(!exLowerExUpper.matches('NotADecimal'));

    //Exclusive lower, inclusive upper
    System.assert(!exLowerInUpper.matches(lower - 1));
    System.assert(!exLowerInUpper.matches(lower));
    System.assert(exLowerInUpper.matches(lower + 1));
    System.assert(exLowerInUpper.matches(upper - 1));
    System.assert(exLowerInUpper.matches(upper));
    System.assert(!exLowerInUpper.matches(upper + 1));
    System.assert(!exLowerInUpper.matches(null));
    System.assert(!exLowerInUpper.matches('NotADecimal'));

    //Inclusive lower, exclusive upper
    System.assert(!inLowerExUpper.matches(lower - 1));
    System.assert(inLowerExUpper.matches(lower));
    System.assert(inLowerExUpper.matches(lower + 1));
    System.assert(inLowerExUpper.matches(upper - 1));
    System.assert(!inLowerExUpper.matches(upper));
    System.assert(!inLowerExUpper.matches(upper + 1));
    System.assert(!inLowerExUpper.matches(null));
    System.assert(!inLowerExUpper.matches('NotADecimal'));

    //Inclusive lower, inclusive upper
    System.assert(!inLowerInUpper.matches(lower - 1));
    System.assert(inLowerInUpper.matches(lower));
    System.assert(inLowerInUpper.matches(lower + 1));
    System.assert(inLowerInUpper.matches(upper - 1));
    System.assert(inLowerInUpper.matches(upper));
    System.assert(!inLowerInUpper.matches(upper + 1));
    System.assert(!inLowerInUpper.matches(null));
    System.assert(!inLowerInUpper.matches('NotADecimal'));
  }

  @IsTest
  private static void constructDecimalLessThan_WithNullToMatch_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalLessThan(null, true);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDecimalLessThan_WithNullInclusive_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalLessThan(123, null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenDecimalLessThanMatchesShouldReturnCorrectResults() {
    Integer toMatch = 5;

    CMN_MOCK_IMatcher exclusive = new CMN_MOCK_MatcherDefinitions.DecimalLessThan(
      toMatch,
      false
    );
    CMN_MOCK_IMatcher inclusive = new CMN_MOCK_MatcherDefinitions.DecimalLessThan(
      toMatch,
      true
    );

    //Exclusive
    System.assert(exclusive.matches(toMatch - 1));
    System.assert(!exclusive.matches(toMatch));
    System.assert(!exclusive.matches(toMatch + 1));
    System.assert(!exclusive.matches(null));
    System.assert(!exclusive.matches('NotADecimal'));

    //Inclusive
    System.assert(inclusive.matches(toMatch - 1));
    System.assert(inclusive.matches(toMatch));
    System.assert(!inclusive.matches(toMatch + 1));
    System.assert(!inclusive.matches(null));
    System.assert(!inclusive.matches('NotADecimal'));
  }

  @IsTest
  private static void constructDecimalMoreThan_WithNullToMatch_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(null, true);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructDecimalMoreThan_WithNullInclusive_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(123, null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenDecimalMoreThanMatchesShouldReturnCorrectResults() {
    Integer toMatch = 5;

    CMN_MOCK_IMatcher exclusive = new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(
      toMatch,
      false
    );
    CMN_MOCK_IMatcher inclusive = new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(
      toMatch,
      true
    );

    //Exclusive
    System.assert(!exclusive.matches(toMatch - 1));
    System.assert(!exclusive.matches(toMatch));
    System.assert(exclusive.matches(toMatch + 1));
    System.assert(!exclusive.matches(null));
    System.assert(!exclusive.matches('NotADecimal'));

    //Inclusive
    System.assert(!inclusive.matches(toMatch - 1));
    System.assert(inclusive.matches(toMatch));
    System.assert(inclusive.matches(toMatch + 1));
    System.assert(!inclusive.matches(null));
    System.assert(!inclusive.matches('NotADecimal'));
  }

  @IsTest
  private static void constructFieldSetEquivalentTo_WithNullFieldSet_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.FieldSetEquivalentTo(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenFieldSetEquivalentToWithoutFieldSetShouldNeverMatch() {
    //Cheap test to maintain 100% code coverage, even in orgs without field sets defined.
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.FieldSetEquivalentTo();
    System.assert(!matcher.matches(null));
  }

  @IsTest
  private static void whenFieldSetEquivalentToMatchesShouldReturnCorrectResults() {
    Schema.FieldSet anyFieldSet = CMN_MOCK_ApexMocksUtils_TEST.findAnyFieldSet();
    if (anyFieldSet == null) {
      return;
    }

    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.FieldSetEquivalentTo(
      anyFieldSet
    );
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('hello'));
    System.assert(matcher.matches(anyFieldSet));
  }

  @IsTest
  private static void whenIsNullMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.IsNull();
    System.assert(!matcher.matches('bob'));
    System.assert(matcher.matches(null));
  }

  @IsTest
  private static void whenIsNotNullMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.IsNotNull();
    System.assert(!matcher.matches(null));
    System.assert(matcher.matches('bob'));
  }

  @IsTest
  private static void whenListContainsMatchesShouldReturnCorrectResults() {
    List<String> names = new List<String>{ 'bob', 'tom', 'fred' };
    List<String> empty = new List<String>();

    System.assert(
      !new CMN_MOCK_MatcherDefinitions.ListContains('fred').matches(null)
    );
    System.assert(
      !new CMN_MOCK_MatcherDefinitions.ListContains('fred').matches(empty)
    );
    System.assert(
      !new CMN_MOCK_MatcherDefinitions.ListContains('jack').matches(names)
    );
    System.assert(
      new CMN_MOCK_MatcherDefinitions.ListContains('fred').matches(names)
    );
    System.assert(
      !new CMN_MOCK_MatcherDefinitions.ListContains('fred').matches('NotAList')
    );
  }

  @IsTest
  private static void whenListIsEmptyMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.ListIsEmpty();

    List<String> names = new List<String>{ 'bob', 'tom', 'fred' };
    List<String> empty = new List<String>();

    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(names));
    System.assert(matcher.matches(empty));
    System.assert(!matcher.matches('NotAList'));
  }

  @IsTest
  private static void constructSObjectOfType_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.SObjectOfType(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenSObjectOfTypeMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.SObjectOfType(
      ACCOUNT_OBJECT_TYPE
    );

    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(OPPORTUNITY_OBJECT_TYPE.newSObject()));
    System.assert(!matcher.matches('NotASObject'));

    System.assert(matcher.matches(ACCOUNT_OBJECT_TYPE.newSObject()));
    System.assert(matcher.matches(ACCOUNT_RECORD));
  }

  @IsTest
  private static void constructSObjectWith_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.SObjectWith(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null/empty: null', e.getMessage());
    }
  }

  @IsTest
  private static void constructSObjectWith_WithEmptyArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.SObjectWith(
        new Map<Schema.SObjectField, Object>()
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null/empty: {}', e.getMessage());
    }
  }

  @IsTest
  private static void whenSObjectWithMatchesShouldReturnCorrectResults() {
    Map<String, Schema.SObjectField> fields = ACCOUNT_OBJECT_TYPE.getDescribe()
      .fields.getMap();
    Schema.SObjectField idField = fields.get('Id');
    Schema.SObjectField nameField = fields.get('Name');
    Schema.SObjectField createdDateField = fields.get('CreatedDate');

    Map<Schema.SObjectField, Object> queriedFieldValues = new Map<Schema.SObjectField, Object>{
      idField => ACCOUNT_RECORD.Id,
      nameField => ACCOUNT_RECORD.get('Name')
    };

    Map<Schema.SObjectField, Object> notQueriedFieldValues = new Map<Schema.SObjectField, Object>{
      createdDateField => System.now()
    };

    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.SObjectWith(
      queriedFieldValues
    );

    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(OPPORTUNITY_OBJECT_TYPE.newSObject()));
    System.assert(!matcher.matches(ACCOUNT_OBJECT_TYPE.newSObject()));
    System.assert(!matcher.matches('NotASObject'));

    System.assert(matcher.matches(ACCOUNT_RECORD));

    System.assert(
      !new CMN_MOCK_MatcherDefinitions.SObjectWith(notQueriedFieldValues)
        .matches(ACCOUNT_RECORD)
    );
  }

  @IsTest
  private static void whenSObjectsWithInOrderMatchesShouldReturnCorrectResults() {
    Map<String, Schema.SObjectField> fields = GROUP_OBJECT_TYPE.getDescribe()
      .fields.getMap();
    Schema.SObjectField idField = fields.get('Id');
    Schema.SObjectField nameField = fields.get('Name');
    Schema.SObjectField createdDateField = fields.get('CreatedDate');

    List<Map<Schema.SObjectField, Object>> queriedFieldValues = new List<Map<Schema.SObjectField, Object>>{
      new Map<Schema.SObjectField, Object>{
        idField => GROUP_RECORDS[0].Id,
        nameField => GROUP_RECORDS[0].get('Name')
      },
      new Map<Schema.SObjectField, Object>{
        idField => GROUP_RECORDS[1].Id,
        nameField => GROUP_RECORDS[1].get('Name')
      }
    };

    List<Map<Schema.SObjectField, Object>> failingFieldValues = new List<Map<Schema.SObjectField, Object>>{
      new Map<Schema.SObjectField, Object>{
        idField => GROUP_RECORDS[0].Id,
        nameField => GROUP_RECORDS[0].get('Name')
      },
      new Map<Schema.SObjectField, Object>{
        idField => GROUP_RECORDS[1].Id,
        nameField => GROUP_RECORDS[1].get('Name') + 'test'
      }
    };

    List<Map<Schema.SObjectField, Object>> notQueriedFieldValues = new List<Map<Schema.SObjectField, Object>>{
      new Map<Schema.SObjectField, Object>{ createdDateField => System.now() },
      new Map<Schema.SObjectField, Object>{ createdDateField => System.now() }
    };

    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.SObjectsWith(
      queriedFieldValues
    );

    System.assert(!matcher.matches(null));
    System.assert(
      !matcher.matches(
        new List<SObject>{
          OPPORTUNITY_OBJECT_TYPE.newSObject(),
          OPPORTUNITY_OBJECT_TYPE.newSObject()
        }
      )
    );
    System.assert(
      !matcher.matches(
        new List<SObject>{
          GROUP_OBJECT_TYPE.newSObject(),
          GROUP_OBJECT_TYPE.newSObject()
        }
      ),
      'sObjectsWith arity agrees but arg doesn\'t'
    );
    System.assert(!matcher.matches('NotAListofSObject'));

    System.assert(
      matcher.matches(GROUP_RECORDS),
      'toMatch and args have same arity and in same order'
    );
    System.assert(
      !matcher.matches(new List<SObject>{ GROUP_RECORDS[1], GROUP_RECORDS[0] }),
      'sObjectsWith toMatch and args have same arity but args are in different order than toMatch'
    );

    System.assert(
      !new CMN_MOCK_MatcherDefinitions.SObjectsWith(notQueriedFieldValues)
        .matches(GROUP_RECORDS)
    );
    System.assert(
      !new CMN_MOCK_MatcherDefinitions.SObjectsWith(failingFieldValues)
        .matches(GROUP_RECORDS)
    );

    System.assert(
      !new CMN_MOCK_MatcherDefinitions.SObjectsWith(failingFieldValues)
        .matches(GROUP_RECORDS)
    );
  }

  @IsTest
  private static void whenSObjectsInAnyOrderWithMatchesShouldReturnCorrectResults() {
    Map<String, Schema.SObjectField> fields = GROUP_OBJECT_TYPE.getDescribe()
      .fields.getMap();
    Schema.SObjectField idField = fields.get('Id');
    Schema.SObjectField nameField = fields.get('Name');
    Schema.SObjectField createdDateField = fields.get('CreatedDate');

    List<Map<Schema.SObjectField, Object>> queriedFieldValues = new List<Map<Schema.SObjectField, Object>>{
      new Map<Schema.SObjectField, Object>{
        idField => GROUP_RECORDS[0].Id,
        nameField => GROUP_RECORDS[0].get('Name')
      },
      new Map<Schema.SObjectField, Object>{
        idField => GROUP_RECORDS[1].Id,
        nameField => GROUP_RECORDS[1].get('Name')
      }
    };

    List<Map<Schema.SObjectField, Object>> notQueriedFieldValues = new List<Map<Schema.SObjectField, Object>>{
      new Map<Schema.SObjectField, Object>{ createdDateField => System.now() },
      new Map<Schema.SObjectField, Object>{ createdDateField => System.now() }
    };

    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.SObjectsWith(
      queriedFieldValues,
      false
    ); // any order

    System.assert(!matcher.matches(null));

    System.assert(
      !matcher.matches(
        new List<SObject>{
          OPPORTUNITY_OBJECT_TYPE.newSObject(),
          OPPORTUNITY_OBJECT_TYPE.newSObject()
        }
      )
    );

    System.assert(
      !matcher.matches(
        new List<SObject>{
          GROUP_OBJECT_TYPE.newSObject(),
          GROUP_OBJECT_TYPE.newSObject()
        }
      ),
      'sObjectsWith arity agrees but arg doesn\'t match matcher'
    );

    System.assert(!matcher.matches('NotAListofSObject'));

    System.assert(
      matcher.matches(GROUP_RECORDS),
      'toMatch and args have same arity and in same order. Match should be OK'
    );
    System.assert(
      matcher.matches(new List<SObject>{ GROUP_RECORDS[1], GROUP_RECORDS[0] }),
      'sObjectsWith toMatch and args have same arity but args are in diff order than matcher. Should be OK'
    );

    System.assert(
      !new CMN_MOCK_MatcherDefinitions.SObjectsWith(
          notQueriedFieldValues,
          false
        )
        .matches(new List<SObject>{ new CMN_Foobar__c(Name = 'frank') })
    );

    try {
      new CMN_MOCK_MatcherDefinitions.SObjectsWith(notQueriedFieldValues, false)
        .validate(null);
      System.assert(false);
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assert(true);
    }
  }

  @IsTest
  private static void constructSObjectWithId_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.SObjectWithId(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenSObjectWithIdMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.SObjectWithId(
      ACCOUNT_RECORD.Id
    );

    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(OPPORTUNITY_OBJECT_TYPE.newSObject()));
    System.assert(!matcher.matches(ACCOUNT_OBJECT_TYPE.newSObject()));
    System.assert(!matcher.matches('NotASObject'));

    System.assert(matcher.matches(ACCOUNT_RECORD));
  }

  @IsTest
  private static void constructSObjectWithName_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.SObjectWithName(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenSObjectWithNameMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.SObjectWithName(
      (String) ACCOUNT_RECORD.get('Name')
    );

    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(OPPORTUNITY_OBJECT_TYPE.newSObject()));
    System.assert(!matcher.matches(ACCOUNT_OBJECT_TYPE.newSObject()));
    System.assert(!matcher.matches('NotASObject'));

    System.assert(matcher.matches(ACCOUNT_RECORD));
  }

  @IsTest
  private static void whenStringContainsMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.StringContains(
      'bob'
    );
    System.assert(!matcher.matches(7));
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(''));
    System.assert(!matcher.matches('blob'));
    System.assert(matcher.matches('bob'));
    System.assert(matcher.matches('bobby'));
  }

  @IsTest
  private static void constructStringContains_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.StringContains(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenStringEndsWithMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.StringEndsWith(
      'bob'
    );
    System.assert(!matcher.matches(7));
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(''));
    System.assert(!matcher.matches('bobby'));
    System.assert(matcher.matches('bob'));
    System.assert(matcher.matches('jimbob'));
  }

  @IsTest
  private static void constructStringEndsWith_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.StringEndsWith(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenIsBlankWithMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.StringIsBlank();
    System.assert(!matcher.matches(7));
    System.assert(!matcher.matches('bob'));
    System.assert(matcher.matches(null));
    System.assert(matcher.matches(''));
  }

  @IsTest
  private static void whenIsNotBlankWithMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.StringIsNotBlank();
    System.assert(!matcher.matches(7));
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(''));
    System.assert(matcher.matches('bob'));
  }

  @IsTest
  private static void whenStringMatchesMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.StringMatches(
      '(b|m)o[a-z]*'
    );
    System.assert(!matcher.matches(7));
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches('bib'));
    System.assert(!matcher.matches('jimbob'));
    System.assert(!matcher.matches('tom'));
    System.assert(!matcher.matches('bob1'));
    System.assert(matcher.matches('bobby'));
    System.assert(matcher.matches('mo'));
  }

  @IsTest
  private static void constructStringMatches_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.StringMatches(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void whenStringStartsWithMatchesShouldReturnCorrectResults() {
    CMN_MOCK_IMatcher matcher = new CMN_MOCK_MatcherDefinitions.StringStartsWith(
      'bob'
    );
    System.assert(!matcher.matches(7));
    System.assert(!matcher.matches(null));
    System.assert(!matcher.matches(''));
    System.assert(!matcher.matches('jimbob'));
    System.assert(matcher.matches('bob'));
    System.assert(matcher.matches('bobby'));
  }

  @IsTest
  private static void constructStringStartsWith_WithNullArg_ThrowsException() {
    try {
      new CMN_MOCK_MatcherDefinitions.StringStartsWith(null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }
}