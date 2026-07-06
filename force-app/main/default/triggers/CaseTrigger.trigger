trigger CaseTrigger on Case (after insert) {
    System.debug('CaseTrigger(' + Trigger.operationType + ').');
    switch on Trigger.operationType{
        when AFTER_INSERT {
            // List to store all FeedItem records to be posted.
            List<FeedItem> posts = new List<FeedItem>();
            // Loop through newly inserted cases.
            for(Case cs: Trigger.new){
                // Filter for “special cases”.
                if(cs.Priority == 'High' && cs.Status == 'New' && cs.Reason == 'Breakdown' && String.isNotBlank(cs.AccountId)){
                    // Prepare a Chatter post for the case & add it to the above list.
                    posts.add(new FeedItem(
                        ParentId = cs.Id,
                        Title = '🚨 High Priority Case. Resolve within 24 hours.',
                        Body = 'Dear Service Team,\n\n'+
                        '\t This is a high-priority breakdown case and required immediate attention. '+
                        '\n\n Case Number → '+cs.CaseNumber+
                        '\n Description → '+cs.Description+
                        '\n Reason      → '+cs.Reason+
                        '\n Origin      → '+cs.Origin+
                        '\n\nPlease resolve this within the next 6 hours.'+
                        '\n\n----Thank you, \nCaseTrigger.'
                    ));
                }
            }
            // Insert chatter posts only if records exist.
            if(!posts.isEmpty()){
                insert posts;
            }
        }
    }
}