
def fibonacci(num1, num2, count):
    print(num1 + num2)
    if count <= 1:
        pass
    else:
        fibonacci(num2, num1+num2, count-1)
    
    if count <= 1:
        output = print (num1 + num2)
        return output 

steps_input = int(input('Enter number of steps: '))

fibonacci(0,1,steps_input-2)