//SampleQueueableAC.apxc
global class SampleQueueableAC implements Queueable{
    Contact con; // Contact to insert
    global SampleQueueableAC(Contact con){ this.con = con; }
    global void execute(QueueableContext qc){ insert con; }
}


// Contact c = new Contact(FirstName='Queueable', LastName='Test_'+System.now().format(), Phone='73465835345');
// String jobId = System.enqueueJob(new SampleQueueableAC(c));
// AsyncApexJob aJob = [
//     SELECT Id, Status, JobType, NumberOfErrors, CompletedDate
//     FROM AsyncApexJob WHERE Id = :jobId
// ];
// System.debug('Async Apex Job → ' + aJob);