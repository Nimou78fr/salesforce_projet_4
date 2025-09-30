@isTest
private class DeleteOpportunityLineItemTest {

    @isTest
    static void deleteOpportunityLineItemSuccesstest() {
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today().addDays(7));
        insert opp;

        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = pb.Id, UnitPrice = 100, IsActive = true);
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 1, TotalPrice = 100);
        insert oli;

        Test.startTest();
        DeleteOpportunityLineItem.deleteOpportunityLineItem(oli.Id);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM OpportunityLineItem WHERE Id = :oli.Id]);
    }

    @isTest
    static void deleteOpportunityLineItemNullIdtest() {
        Test.startTest();
        try {
            DeleteOpportunityLineItem.deleteOpportunityLineItem(null);
            System.assert(false, 'Exception expected');
        } catch (AuraHandledException e) {
            System.assertEquals('ID manquant.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void deleteOpportunityLineItemNotFoundtest() {
        Test.startTest();
        try {
            DeleteOpportunityLineItem.deleteOpportunityLineItem('00k000000000000AAA');
            System.assert(false, 'Exception expected');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Erreur'));
        }
        Test.stopTest();
    }
} 