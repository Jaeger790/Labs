

    
import turtle

window = turtle.Screen()
window.bgcolor('green')

john = turtle.Turtle()
john.shape('turtle')
john.color('blue')
john.penup()

jane = turtle.Turtle()
jane.shape('turtle')
jane.color('maroon')
jane.penup()



for i in range(12):
    john.forward(50)
    john.shape('arrow')
    john.pendown()
    john.forward(10)
    john.penup()
    john.forward(20)
    john.shape('turtle')
    john.stamp()
    john.penup()
    john.right(180)
    john.forward(80)
    john.right(180 +30)
    

for i in range(12):
        jane.forward(150)
        jane.shape('arrow')
        jane.pendown()
        jane.forward(10)
        jane.penup()
        jane.forward(20)
        jane.shape('turtle')
        jane.stamp()
        jane.penup()
        jane.right(180)
        jane.forward(80)
        jane.right(180 +30)