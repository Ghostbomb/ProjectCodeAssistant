import os
import time

triggerFilePath = './microservice_IO.txt'
triggerWord = "run_microservice"


# Check if file exists, if not create it
def check_file():
    if not os.path.exists(triggerFilePath):
        with open(triggerFilePath, 'w') as file:
            file.write("")


# Check if keyword is in first word of line and only the first word
def check_keyword(keyword):
    with open(triggerFilePath, 'r') as file:
        lines = file.readlines()
        first_words = [line.split()[0] for line in lines]
        if keyword in first_words:
            return True
        else:
            return False


# Write string to file function
def write_file(string):
    with open(triggerFilePath, 'w') as file:
        file.write(string)
        file.close()


# Microservice function
def microservice():
    write_file('Microservice is running...')


def main():
    check_file()
    while True:
        if check_keyword(triggerWord):
            print('Keyword found!')
            # write_file("")
            microservice()
        time.sleep(2)


# Run main function
if __name__ == '__main__':
    main()
