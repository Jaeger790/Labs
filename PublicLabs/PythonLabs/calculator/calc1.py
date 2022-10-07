
#define operations
def add(x , y):
  return x + y

def subtract(x, y):
    return x-y

def multiply(x, y):
    return x * y

def divide(x, y):
    return x / y

#Give user instructions
def instructions():
   
    return print('Select an operation: +, -, *, /' '\n'
                 'addition: 1' '\n'
                 'subtraction: 2' '\n'
                 'multiplication: 3' '\n'
                 'division: 4')


#get user input
def selection(choice):
   
    choice = input('Enter choice: ' )
    if choice in ('1', '2', '3', '4'):
        num1 = float(input('Enter first number: '))
        num2 = float(input('Enter second number: '))

        if choice == '1':
            print(num1, '+', num2, '=', subtract(num1, num2))
        elif choice == '2':
            print(num1, '-', num2, '=', add(num1, num2))
        elif choice == '3':
            print(num1, '*', num2, '=', multiply(num1, num2))
        elif choice == '4':
            print(num1, '/', num2, '=', divide(num1, num2))
    else:
        print('Invalid input')
    return(choice)


instructions()
selection(selection)

Keep_going = input('do you want to continue?  (y/n): ')

while Keep_going == 'y':
    instructions()
    selection(selection)
    Keep_going = input('do you want to continue?  (y/n): ')
    