public class Rectangle {
	public Decimal length,breadth ;

	public void area() {
		Decimal Area1 =(length*breadth);
		System.debug('area of rectangle = '+area1);
	}
	public void perimeter() {
		Decimal Perimeter1=2*(length+breadth);
		System.debug('perimeter of rectangle is '+perimeter1 );
	}

}