trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    // Delegate execution to handler (single entry point)
    new ContactTriggerHandler().run();
}