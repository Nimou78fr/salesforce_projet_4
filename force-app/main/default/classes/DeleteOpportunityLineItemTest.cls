@isTest
private class DeleteOpportunityLineItemTest {

    @isTest
    static void testDeleteOpportunityLineItem_Success() {
        // Création d’un Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Création d’un Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        // Création d’un Pricebook
        Pricebook2 pb = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert pb;

        // Création d’un Product
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        // Création d’un PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Mise à jour de l’Opportunity pour utiliser le Pricebook
        opp.Pricebook2Id = pb.Id;
        update opp;

        // Création d’un OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            TotalPrice = 100
        );
        insert oli;

        // Appel de la méthode de suppression
        Test.startTest();
        DeleteOpportunityLineItem.deleteOpportunityLineItem(oli.Id);
        Test.stopTest();

        // Vérification que l’OLI a bien été supprimé
        OpportunityLineItem oliCheck = [SELECT Id FROM OpportunityLineItem WHERE Id = :oli.Id LIMIT 1];
        System.assertEquals(null, oliCheck, 'L’OLI aurait dû être supprimé'); // Cette ligne va lancer une exception si OLI existe encore
    }

    @isTest
    static void testDeleteOpportunityLineItem_NullId() {
        Test.startTest();
        try {
            DeleteOpportunityLineItem.deleteOpportunityLineItem(null);
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (AuraHandledException e) {
            System.assertEquals('ID manquant.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteOpportunityLineItem_InvalidId() {
        Test.startTest();
        try {
            // ID inexistant
            DeleteOpportunityLineItem.deleteOpportunityLineItem('006000000000000AAA');
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Erreur de suppression'));
        }
        Test.stopTest();
    }
}
