public  class Mobile {
    public String Brand,Model;
    public Decimal price,Balance;
    public Boolean is56;


    public void call() {
        System.debug('Now the Mobile.call() method is executing');
        System.debug(Brand+' '+Model+' '+Price+' '+Balance+' '+is56);
    }
    
    public void sendMessage() {
        System.debug('Now the Mobile.sendMesage() method is executing');
        System.debug(Brand+' '+Model+' '+Price+' '+Balance+' '+is56);
    }

    public void showDetails(){
        System.debug('Now the Mobile.showDetails() method is executing');
        System.debug(Brand+' '+Model+' '+Price+' '+Balance+' '+is56);
    }

}