global class QueueableAC2 implements Queueable{
    BankAccount__c bank;
    public QueueableAC2(BankAccount__c bank){ this.bank = bank; }
    global void execute(QueueableContext qc){
        
   DepositAccount__c  dep = new DepositAccount__c(
            Name = bank.Name + '_D1',
            Amount__c = 50000,
            bankId__c = bank.Id
        );
        insert dep;
    }
}