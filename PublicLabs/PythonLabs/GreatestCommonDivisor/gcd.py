def gcd(num1, num2):
    greatest_common_divisor = 0

    if num1 == num2:
        greatest_common_divisor = num1
    else:
        if num1 > num2:
            greatest_common_divisor = gcd(num1 - num2, num2)
        else:
            greatest_common_divisor = gcd(num1, num2 - num1)
    return greatest_common_divisor

print("Enter two numbers to determine the\ngreatest common divisor.")

number1 = int(input('First Number: '))
number2 = int(input('Second Number: '))

if (number1 < 1) or (number2 < 1):
    print('Input must be 1 or greater')
else:
    calc_gcd = gcd(number1, number2)
    print("GCD is: ", calc_gcd)