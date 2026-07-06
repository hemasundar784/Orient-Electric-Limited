public class BankAccount {
    public String accountHolderName,accountNumber ;
    public Decimal balance;


    public Integer deposit(Integer amount) {
        balance = balance+amount;
        System.debug('account Holdername --> '+accountHolderName+'accountNumber -->'+accountNumber+'Balance -->'+balance);

        return 1;
    }
    public Integer withdraw(Integer amount){
        if((balance-amount) < 0){
            System.debug('❌ Failure: Balance less than 0');
            return 0;
        }
        else{
            balance=balance-amount;
            System.debug('account Holdername --> '+accountHolderName+'accountNumber -->'+accountNumber+'Balance -->'+balance);
            return 1;
        }
    }
    public Integer showBalance(){
        System.debug('account Holdername --> '+accountHolderName+'accountNumber -->'+accountNumber+'Balance -->'+balance);
        return 1;
    }

}