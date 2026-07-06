public class Calci {

    private Boolean isDenominatorValid(Integer num1, Integer num2){
        return !(num1 == 0 || num1 == null || num2 == 0 || num2 == null);
    }

    public void sum(Integer num1, Integer num2) {
        if (!isDenominatorValid(num1, num2)) { System.debug('⚠️ Please enter valid non-zero values'); return; }
        System.debug(num1 + ' + ' + num2 + ' = ' + (num1 + num2));
    }

    public void difference(Integer num1, Integer num2){
        if (!isDenominatorValid(num1, num2)) { System.debug('⚠️ Please enter valid non-zero values'); return; }
        System.debug(num1 + ' - ' + num2 + ' = ' + (num1 - num2));
    }

    public void product(Integer num1, Integer num2){
        if (!isDenominatorValid(num1, num2)) { System.debug('⚠️ Please enter valid non-zero values'); return; }
        System.debug(num1 + ' * ' + num2 + ' = ' + (num1 * num2));
    }

    public void quotient(Integer num1, Integer num2){
        if (!isDenominatorValid(num1, num2)) { System.debug('⚠️ Please enter valid non-zero values'); return; }
        
        Decimal quotientVal;
        if(num1 > num2) {
            quotientVal = (Decimal)num1 / num2;
        } else {
            quotientVal = (Decimal)num2 / num1;
        }
        System.debug('Quotient Result = ' + quotientVal);
    }

    public void remainder(Integer num1, Integer num2){
        if (!isDenominatorValid(num1, num2)) { System.debug('⚠️ Please enter valid non-zero values'); return; }
        
        Integer remainderVal;
        if(num1 > num2) {
            remainderVal = Math.mod(num1, num2);
        } else {
            remainderVal = Math.mod(num2, num1);
        }
        System.debug('Remainder Result = ' + remainderVal);
    }
    
    public void square(Integer num1, Integer num2){
        // Changed = to ==, added matching braces
        if(num1 > 0 && num2 == 0){
            System.debug('square is ' + (num1 * num1));
        } else if(num2 > 0 && num1 == 0){
            System.debug('square is ' + (num2 * num2));
        } else {
            System.debug('square of num1 is ' + (num1 * num1) + ' | square of num2 is ' + (num2 * num2));
        }
    }

    public void cube(Integer num1, Integer num2){
        // Changed = to ==, added matching braces
        if(num1 > 0 && num2 == 0){
            System.debug('cube is ' + (num1 * num1 * num1));
        } else if(num2 > 0 && num1 == 0){
            System.debug('cube is ' + (num2 * num2 * num2));
        } else {
            System.debug('cube of num1 is ' + (num1 * num1 * num1) + ' | cube of num2 is ' + (num2 * num2 * num2));
        }
    }
}