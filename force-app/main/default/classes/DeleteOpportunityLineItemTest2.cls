@isTest
public class DeleteOpportunityLineItemTest2 {

    @TestSetup
    static void setup() {
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today().addDays(7));
        insert opp;

        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

       // Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 100, IsActive = true);
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, TotalPrice = 100);
        insert oli;
    }
    @isTest
    static void deleteOpportunityLineItemNullIdtest() {
        Test.startTest();
        try {
            DeleteOpportunityLineItem.deleteOpportunityLineItem(null);
            //System.assert(false, 'Exception attendue');
        } catch (AuraHandledException e) {
            Assert.areEqual(e.getMessage()!=null,true);
        }
        Test.stopTest();
    }
    @isTest
    static void deleteOpportunityLineItemNullIdtest2() {
        OpportunityLineItem oli=[Select id from OpportunityLineItem limit 1];
        Test.startTest();
            DeleteOpportunityLineItem.deleteOpportunityLineItem(oli.Id);
            list<OpportunityLineItem> result=[Select id from OpportunityLineItem limit 1];
        Test.stopTest();
        Assert.areEqual(result.size(),0);
    }
}