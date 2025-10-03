@IsTest 
public with sharing class PreventCloseWonIfStockInsufficientTest {
    @TestSetup
    static void setup() {
        // Création d'un produit
        Product2 prod = new Product2(Name = 'Test Product',QuantityInStock__c = 5, IsActive = true);
        insert prod;

        // Création d'une entrée de catalogue de prix pour le produit
        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 100, IsActive = true);
        insert pbe;

        // Création d'une opportunité
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today().addDays(7));
        insert opp;

        // Création d'un élément de ligne d'opportunité avec une quantité supérieure au stock disponible
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe.Id, Quantity = 10, TotalPrice = 1000);
        insert oli;
    }

    @IsTest
    static void testPreventCloseWonIfStockInsufficient() {
        // Récupération de l'opportunité créée dans le setup
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opp' LIMIT 1];

        // Tentative de mise à jour du stade de l'opportunité à "Closed Won"
        Test.startTest();
        try {
            opp.StageName = 'Closed Won';
            update opp;
            System.assert(false, 'Exception attendue');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), true );
        }
        Test.stopTest();
    }
}