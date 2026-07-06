public class TestTriggerAC {
    // Demonstrates Trigger context variable: isExecuting
    public static void run(){
        System.debug('Trigger.isExecuting → '+Trigger.isExecuting);
        if(Trigger.isExecuting){
            System.debug('This logic will execute only when invoked by a trigger.');
        }
        System.debug('This logic will execute in all contexts.');
    }
}