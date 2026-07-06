public class Student {
    public string name;
    public Integer marks,totalMarks;


    public void calculateResult(Integer salesforce,Integer Apex ,Integer LWC) {
        totalMarks=salesforce+apex+LWC;
        System.debug('salesforce marks --> ' +salesforce+', Apex marks --> '+Apex+', LWC -->'+LWC+' || TotalMarks --> '+totalMarks);
        if(totalMarks >= 230){
            System.debug(name+' got Destinction');
        }
        else if(totalMarks>=180){
            System.debug(name+' is pass');
        }
        else{
            System.debug(name+' is fail');
        }

    }
}