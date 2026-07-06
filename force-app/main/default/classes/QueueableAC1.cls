//QueueableAC1.apxc
global class QueueableAC1 implements Queueable{
    BankAccount__c bank;
    public QueueableAC1(BankAccount__c bank){ this.bank = bank; }
    global void execute(QueueableContext qc){
        insert bank;
        executeQueueableAC2();
    }
    global void executeQueueableAC2(){
        System.enqueueJob(new QueueableAC2(bank));
    }
}


// //Anonymous Window (Start Queueable Chain):
// BankAccount__c bank = new BankAccount__c(Name='Deepak', amount__c=400000);
// System.enqueueJob(new QueueableAC1(bank));