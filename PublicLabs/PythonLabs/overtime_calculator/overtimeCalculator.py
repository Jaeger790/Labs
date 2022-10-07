hours_worked= 0.0
rate= 0.0

def over_calc():
    hours_worked= float(input("Enter Hours:"))
    rate= float(input("Enter Rate:"))
    if float(hours_worked) <= 40:
        pay = float(hours_worked) * float(rate)
        print('Your total pay for this period is:',pay,'\nYou do not qualify for overtime pay this period.')

    else:
        pay = ((float(hours_worked) - 40) * float(rate) * 1.5) + float(rate) * 40
        overtime = float((hours_worked) - 40) * (float(rate) * 1.5)
        print('Your total pay for this period is: ',pay, '\nYour overtime pay is:',overtime)


def exit_program():
    quit = input('Do you wish to continue?: [y , n]\n')
    if quit == 'n':
        exit()
    else:
        over_calc()
        exit_program()


over_calc()
exit_program()

