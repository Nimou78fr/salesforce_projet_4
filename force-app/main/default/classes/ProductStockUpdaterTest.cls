@isTest
private class ProductStockUpdaterTest {

    @isTest
    static void testUpdateProductStockFromOpportunity() {
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        Product2 prod = new Product2(Name = 'Produit', IsActive = true, QuantityInStock__c = 10);
        insert prod;

        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = pb.Id, UnitPrice = 50, IsActive = true);
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 3, TotalPrice = 150);
        insert oli;

        Test.startTest();
        ProductStockUpdater.updateProductStockFromOpportunity(opp.Id);
        Test.stopTest();

        Product2 updatedProd = [SELECT QuantityInStock__c FROM Product2 WHERE Id = :prod.Id];
        System.assertEquals(7, updatedProd.QuantityInStock__c);
    }

    @isTest
    static void testNullOpportunityId() {
        Test.startTest();
        try {
            ProductStockUpdater.updateProductStockFromOpportunity(null);
            System.assert(false, 'Exception attendue');
        } catch (AuraHandledException e) {
            System.assertEquals('ID de l\'opportunité manquant.', e.getMessage());
        }
        Test.stopTest();
    }
}
