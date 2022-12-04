package Labs;


public class Dog extends Animal{

    //Declare fields
    private String breed;
    private int lifespan;
    private String behavior;
    private double price;

    //Constructors
    public Dog()
    {super();
       breed = "German Shepherd";
       lifespan = 400;
       behavior = "Awesome";
       price = 8008008;
    }
    //Constructor with full parameter listing
    public Dog(String breed, int lifespan, String behavior, double price)
    {super(breed, lifespan, behavior ,price);
        this.breed = breed;
        this.lifespan = lifespan;
        this.behavior = behavior;
        this.price = price;
    }

    //print all dog info
    public void printDog(){
        System.out.println("Breed: " + breed + '\n' +
                            "Lifespan: " + lifespan + '\n' +
                            "Behavior: " + behavior + '\n' +
                            "Price: $" + price);
    }

}
