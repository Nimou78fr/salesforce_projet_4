@isTest
private class OpportunityProductsControllerTest {

    @isTest
    static void testGetOpportunityLineItems() {
        Opportunity opp = new Opportunity(Name = 'Opp Test', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        Product2 prod = new Product2(Name = 'Produit test', IsActive = true);
        insert prod;

        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = pb.Id, UnitPrice = 100, IsActive = true);
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 2, TotalPrice = 200);
        insert oli;

        Test.startTest();
        List<OpportunityLineItem> results = OpportunityProductsController.getOpportunityLineItems(opp.Id);
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(prod.Name, results[0].Product2.Name);
    }
}
