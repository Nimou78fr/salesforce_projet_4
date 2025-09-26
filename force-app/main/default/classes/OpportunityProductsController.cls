public with sharing class OpportunityProductsController {
    @AuraEnabled(cacheable=true)
    //Methode statique pour récupérer les OpportunityLineItems associés à une opportunité//
    //Prend en paramètre une requete SOQL afin de recuperer les champs ci-dessous//
    public static List<OpportunityLineItem> getOpportunityLineItems(Id opportunityId) {
        return [
            SELECT Id, UnitPrice, TotalPrice, Quantity,
                   Product2.Name, Product2.QuantityInStock__c,Diff_quantite_stock__c
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];
    }
}