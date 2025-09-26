public with sharing class DeleteOpportunityLineItem { //Classe Apex pour supprimer un produit d'une opportunité//
    @AuraEnabled //Methode accessible depuis un composant Lightning//
    //Methode statique prenant en paramètre l'ID de l'OpportunityLineItem à supprimer//
    public static void deleteOpportunityLineItem(Id oliId) { 
        if (oliId == null) { //Vérification que l'ID n'est pas null//
            throw new AuraHandledException('ID manquant.'); //Lance une exception si l'ID est null//
        }

        try { //Bloc try-catch pour gérer les erreurs potentielles//
            OpportunityLineItem oli = [ //Déclaration de la variable oli de type OpportunityLineItem//
                SELECT Id FROM OpportunityLineItem WHERE Id = :oliId //Requête SOQL pour récupérer l'OpportunityLineItem à supprimer//
            ];
            delete oli; //Suppression de l'OpportunityLineItem//
        } catch (Exception e) { //Capture de toute exception pouvant survenir lors de la suppression//
            throw new AuraHandledException('Erreur de suppression : ' + e.getMessage()); //Lance une exception avec le message d'erreur//
        }
    }
}