/**
 * @description       : Apex Test class for AOB_NeedsAnalysisWrapper
 * @author            : Madito Tsilo
 * @UserStory         : SFP-53079
 * @date              : 08-01-2026
 **/
@IsTest
public class AOB_NeedsAnalysisWrapper_Test {
 @IsTest
    static void testNeedsAnalysisWrapperInitialization() {
        
        final String agreement_text = 'Yes';
        final String disagreement_text = 'No';

        // Create DataDependents instance
        AOB_NeedsAnalysisWrapper.DataDependents dependents =
            new AOB_NeedsAnalysisWrapper.DataDependents();
        dependents.total_value_debts = 500000;
        dependents.monthly_financial_obligations = 15000;
        dependents.Financially_dependants = agreement_text;
        dependents.Estimated_Income_family_per_month = 30000;
        dependents.family_income_replacement_years = 5;
        dependents.has_mortgage_or_large_debts = agreement_text;

        // Create DataFuture instance
        AOB_NeedsAnalysisWrapper.DataFuture future =
            new AOB_NeedsAnalysisWrapper.DataFuture();
        future.Estimated_education = 200000;
        future.estimated_amount_for_expenses = 100000;
        future.current_life_insurance_cover = 250000;
        future.Provide_children_education = agreement_text;
        future.plan_future_expenses = agreement_text;
        future.have_life_insurance = agreement_text;
        future.more_insurance_debts_commitment = disagreement_text;

        // Create main wrapper
        AOB_NeedsAnalysisWrapper wrapper = new AOB_NeedsAnalysisWrapper();
        wrapper.dataDependents = dependents;
        wrapper.dataFuture = future;
        wrapper.totalCover = 1000000;

        // Assertions
        Assert.areNotEqual(null, wrapper, 'Wrapper should not be null');
        Assert.areEqual(1000000, wrapper.totalCover);

        // Validate DataDependents values
        Assert.areEqual(500000, wrapper.dataDependents.total_value_debts);
        Assert.areEqual(15000, wrapper.dataDependents.monthly_financial_obligations);
        Assert.areEqual(agreement_text, wrapper.dataDependents.Financially_dependants);
        Assert.areEqual(30000, wrapper.dataDependents.Estimated_Income_family_per_month);
        Assert.areEqual(5, wrapper.dataDependents.family_income_replacement_years);
        Assert.areEqual(agreement_text, wrapper.dataDependents.has_mortgage_or_large_debts);

        // Validate DataFuture values
        Assert.areEqual(200000, wrapper.dataFuture.Estimated_education);
        Assert.areEqual(100000, wrapper.dataFuture.estimated_amount_for_expenses);
        Assert.areEqual(250000, wrapper.dataFuture.current_life_insurance_cover);
        Assert.areEqual(agreement_text, wrapper.dataFuture.Provide_children_education);
        Assert.areEqual(agreement_text, wrapper.dataFuture.plan_future_expenses);
        Assert.areEqual(agreement_text, wrapper.dataFuture.have_life_insurance);
        Assert.areEqual(disagreement_text, wrapper.dataFuture.more_insurance_debts_commitment);
    }
}