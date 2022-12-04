package Labs;

public class Main {

    public static void main(String[] args) {
        Dog dog = new Dog();
        Dog dog2 = new Dog("Golden Retriever", 12,"Gentle",1000.00);
        Cat cat = new Cat("Russian Boue", 15,"Fiesty",1000.00);

        dog.printDog();
        dog2.printDog();
        System.out.println(cat.getBehavior() + " " + cat.getBreed());

    }
}