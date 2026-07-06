public class UserCredentials {
    /* Private members are marked as @testVisible only for teaching/demo purposes
    This allows test classes to access them directly while still demonstrating encapsulation */
    @testVisible private String loginName;
    @testVisible private String loginPassword;
    // Setter methods: used to assign values to private variables
    public void setLoginName(String loginName){
        this.loginName = loginName;
    }
    public void setLoginPassword(String loginPassword){
        this.loginPassword = loginPassword;
    }
    // Getter methods: used to retrieve values of private variables
    public String getLoginName(){
        return loginName;
    }
    public String getLoginPassword(){
        return loginPassword;
    }
}