trigger RefreshEventFlowafterdelete on OpportunityLineItem (after delete) {
  List<RefreshEvent__e> refreshEvents = new List<RefreshEvent__e>();
  for(OpportunityLineItem  tmp:trigger.old){
     refreshEvents.add(new RefreshEvent__e(IDOpportunity__c=tmp.OpportunityId));
  }
  if(refreshEvents.size()>0)EventBus.publish(refreshEvents);
}