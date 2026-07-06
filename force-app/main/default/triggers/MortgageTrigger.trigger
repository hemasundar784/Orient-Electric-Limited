trigger MortgageTrigger on Mortgage__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    // Code that executes when any of the above events occur.
          switch on Trigger.operationType{
        /* 
        🎯 TRIAGING USING SWITCH & operationType
        - Cleaner and more readable than multiple if-else statements.
        - Here we preserve your original debug-style messages inside the switch as well.
        */
        when BEFORE_INSERT {
            System.debug('Triggered before inserting '+Trigger.size+' mortgage(s).');
        }
        when BEFORE_UPDATE {
            System.debug('Triggered before updating '+Trigger.size+' mortgage(s).');
        }
        when BEFORE_DELETE {
            System.debug('Triggered before deleting '+Trigger.size+' mortgage(s).');
        }
        when AFTER_INSERT {
            System.debug('Triggered after inserting '+Trigger.size+' mortgage(s).');
        }
        when AFTER_UPDATE {
            System.debug('Triggered after updating '+Trigger.size+' mortgage(s).');
        }
        when AFTER_DELETE {
            System.debug('Triggered after deleting '+Trigger.size+' mortgage(s).');
        }
        when AFTER_UNDELETE {
            System.debug('Triggered after undeleting '+Trigger.size+' mortgage(s).');
        }
    }
    // Print trigger execution details and context variable states.
    System.debug(
        '\n***** OPERATION TYPE → '+Trigger.operationType +
        '\n***** NEW            → '+Trigger.new +       // Records being inserted or updated
        '\n***** NEW MAP        → '+Trigger.newMap +    // Map<Id, SObject> of new records
        '\n***** OLD            → '+Trigger.old +       // Records before update or delete
        '\n***** OLD MAP        → '+Trigger.oldMap      // Map<Id, SObject> of old records
    );
}