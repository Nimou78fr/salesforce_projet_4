trigger PreventCloseWonIfStockInsufficient on Opportunity (before update) {
    Set<Id> oppIdsToCheck = new Set<Id>();

    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
            oppIdsToCheck.add(opp.Id);
        }
    }

    if (!oppIdsToCheck.isEmpty()) {
        List<OpportunityLineItem> lineItems = [
            SELECT OpportunityId, Quantity,
                   PricebookEntry.Product2.QuantityInStock__c,
                   PricebookEntry.Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIdsToCheck
        ];

        Map<Id, List<String>> oppIdToStockErrors = new Map<Id, List<String>>();
        for (OpportunityLineItem oli : lineItems) {
            Decimal stock = oli.PricebookEntry.Product2.QuantityInStock__c != null ? oli.PricebookEntry.Product2.QuantityInStock__c : 0;
            if (oli.Quantity > stock) {
                if (!oppIdToStockErrors.containsKey(oli.OpportunityId)) {
                    oppIdToStockErrors.put(oli.OpportunityId, new List<String>());
                }
                oppIdToStockErrors.get(oli.OpportunityId).add(
                    oli.PricebookEntry.Product2.Name + ' (Demandé: ' + oli.Quantity + ', En stock: ' + stock + ')'
                );
            }
        }

        for (Opportunity opp : Trigger.new) {
            if (oppIdToStockErrors.containsKey(opp.Id)) {
                String message = 'Clôture impossible : produits avec stock insuffisant :\n' +
                                 String.join(oppIdToStockErrors.get(opp.Id), ', ');
                opp.addError(message);
            }
        }
    }
}