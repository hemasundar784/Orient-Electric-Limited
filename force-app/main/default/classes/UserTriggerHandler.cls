public class UserTriggerHandler extends TriggerHandler{
    protected override void beforeUpdate(){
        List<User> newUsers = (List<User>)Trigger.new;
        Map<Id, User> oldUsersMap = (Map<Id, User>)Trigger.oldMap;
        UserService.validateSupervisorRequiredForFirstDeactivation(newUsers, oldUsersMap);
    }
    protected override void afterUpdate(){
        List<User> newUsers = (List<User>)Trigger.new;
        Map<Id, User> oldUsersMap = (Map<Id, User>)Trigger.oldMap;
        UserService.handleFirstTimeDeactivations(newUsers, oldUsersMap);
    }
}