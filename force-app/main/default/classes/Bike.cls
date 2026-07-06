public class Bike {
    public String Brand;
    public Integer engineCC ;
    public Boolean hasGear;



    public void start(Boolean petrol, Boolean TurnKey,Boolean hasGear) {
        if(petrol==true && TurnKey==true && hasGear==true){
            System.debug(brand +' Bike started');
        }
        else if((petrol == true && TurnKey == false && hasGear == true) || (petrol == false && TurnKey == true && hasGear == true) || (petrol == false && TurnKey == true && hasGear == false)){
            System.debug(brand +' Bike not started');
        }
        else{
            System.debug(brand +' bike not started');
        }
    }
    public void stop(Boolean petrol,Boolean TurnKey){
        if(((petrol==true && TurnKey==false) || hasGear==false) ||  ((petrol==false && TurnKey==true)  || hasGear==true)){
            System.debug('Bike not started');
        }
        else{
            system.debug(brand+' started');
        }
    }
    public void showInfo(){
        System.debug('Brand --> '+Brand+' engineCC --> '+engineCC+' hasGear --> '+true);
    }
}