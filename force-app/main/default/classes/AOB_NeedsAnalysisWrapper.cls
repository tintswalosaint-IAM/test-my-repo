/**
 * @description       : Wrapper class for AOB_CTRL_NeedsAnalysisGeneratePDF class
 * @author            : Madito Tsilo
 * @UserStory         : SFP-53079
 * @date              : 08-01-2026
 **/
public with sharing class AOB_NeedsAnalysisWrapper {
    public DataDependents dataDependents { get; set; }
    public DataFuture dataFuture { get; set; }
    public Long totalCover { get; set; }

    public class DataDependents {
        public Decimal total_value_debts { get; set; }
        public Decimal monthly_financial_obligations { get; set; }
        public String Financially_dependants { get; set; }
        public Decimal Estimated_Income_family_per_month { get; set; }
        public Integer family_income_replacement_years { get; set; }
        public String has_mortgage_or_large_debts { get; set; }
    }

    public class DataFuture {
        public Decimal Estimated_education { get; set; }
        public Decimal estimated_amount_for_expenses { get; set; }
        public Decimal current_life_insurance_cover { get; set; }
        public String Provide_children_education { get; set; }
        public String plan_future_expenses { get; set; }
        public String have_life_insurance { get; set; }
        public String more_insurance_debts_commitment { get; set; }
    }
}