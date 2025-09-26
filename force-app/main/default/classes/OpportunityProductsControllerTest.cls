@isTest
private class OpportunityProductsControllerTest {

    @isTest
    static void testGetOpportunityLineItems() {
        // Étape 1 : Créer les données de test nécessaires

        // Création d’un compte
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Création d’une opportunité
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            AccountId = acc.Id
        );
        insert opp;

        // Création d’un Pricebook standard
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

        // Création d’un produit
        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true,
            QuantityInStock__c = 50 // Champ personnalisé
        );
        insert prod;

        // Création d’une entrée de Pricebook
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = pb.Id,
            UnitPrice = 200,
            IsActive = true
        );
        insert pbe;

        // Mise à jour de l'opportunité pour lier le Pricebook
        opp.Pricebook2Id = pb.Id;
        update opp;

        // Création d’un OpportunityLineItem avec un champ personnalisé fictif
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 2,
            UnitPrice = 200,
            TotalPrice = 400,
            PricebookEntryId = pbe.Id,
            Diff_quantite_stock__c = 48 // Champ personnalisé
        );
        insert oli;

        // Étape 2 : Appel de la méthode à tester
        Test.startTest();
        List<OpportunityLineItem> result = OpportunityProductsController.getOpportunityLineItems(opp.Id);
        Test.stopTest();

        // Étape 3 : Vérification des résultats
        System.assertNotEquals(null, result, 'Le résultat ne doit pas être null');
        System.assertEquals(1, result.size(), 'Il doit y avoir exactement 1 OpportunityLineItem');
        System.assertEquals(oli.Id, result[0].Id, 'L\'ID de l\'OLI retourné doit correspondre');
        System.assertEquals(prod.Name, result[0].Product2.Name, 'Le nom du produit doit correspondre');
        System.assertEquals(prod.QuantityInStock__c, result[0].Product2.QuantityInStock__c, 'La quantité en stock doit correspondre');
        System.assertEquals(oli.Diff_quantite_stock__c, result[0].Diff_quantite_stock__c, 'La différence de stock doit correspondre');
    }
}
