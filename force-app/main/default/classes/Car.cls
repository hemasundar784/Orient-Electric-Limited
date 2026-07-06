public class Car {
    // What does a Car have? (Properties / Data / Variables)
    public String brand;
    public String color;
    public Integer noOfAirbags;
    public Boolean hasSunRoof;
    // What does a Car do? (Actions / Functions / Methods)
    public void drive(){
        System.debug(brand + ' car is driving on the road.');
    }
    public void park(){
        System.debug(brand + ' car is parked in the garage.');
    }
    public void showSpecifications(){
        System.debug('Brand → ' + brand);
        System.debug('Color → ' + color);
        System.debug('Number of Airbags → ' + noOfAirbags);
        System.debug('Is sunroof available? → ' + hasSunRoof);
    }
}