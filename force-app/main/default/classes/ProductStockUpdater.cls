public with sharing class ProductStockUpdater {
    @AuraEnabled
    public static void updateProductStockFromOpportunity(Id opportunityId) {
        // 1. Récupérer les lignes d'opportunité associées à opportunityId
        List<OpportunityLineItem> lineItems = [
            SELECT Quantity, Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];

        // 2. Regrouper les quantités par produit
        Map<Id, Integer> quantityMap = new Map<Id, Integer>(); //Map pour stocker les quantités par Product2Id
        for (OpportunityLineItem oli : lineItems) { //Boucle for sur chaque ligne d'opportunitylineitem dans la liste lineitems//
            if (quantityMap.containsKey(oli.Product2Id)) { //Vérifie si le Product2Id est déjà dans la map//
                quantityMap.put(oli.Product2Id, quantityMap.get(oli.Product2Id) + Integer.valueOf(oli.Quantity));
            } else {
                quantityMap.put(oli.Product2Id, Integer.valueOf(oli.Quantity));
            }
        }

        // 3. Récupérer les produits à mettre à jour
        List<Product2> productsToUpdate = [
            SELECT Id, QuantityInStock__c
            FROM Product2
            WHERE Id IN :quantityMap.keySet() //Récupère les produits d 'ID de produits pour mettre à jour la quantité en stock//
        ];

        // 4. Mettre à jour la quantité en stock
        for (Product2 p : productsToUpdate) {
            Integer usedQty = quantityMap.get(p.Id);
            p.QuantityInStock__c = Math.max(0, p.QuantityInStock__c - usedQty); // garantit que la quantité en stock ne devient pas négative//
        }

        update productsToUpdate;
    }
}