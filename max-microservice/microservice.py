import os
import random
import time

triggerFilePath = './microservice_IO.txt'
triggerWord = "run_microservice"
dataFilePath = './data.txt'
numberOfLineToPrint = 1


# Random Number Generator from 1 to #
def random_number_generator(max_num):
    return random.randint(1, max_num-1)


# Check if file exists, if not create it
def check_file(file_path):
    if not os.path.exists(file_path):
        with open(file_path, 'w') as file:
            file.write("")
            print("File created: " + file_path)


# Check if keyword is in first word of line and only the first word
def check_keyword(keyword):
    with open(triggerFilePath, 'r') as file:
        lines = file.readlines()
        first_words = [line.split()[0] for line in lines]
        if keyword in first_words:
            return True
        else:
            return False


# Open file and return number of lines in it
def get_number_of_lines():
    with open(dataFilePath, 'r') as file:
        lines = file.readlines()
        return len(lines)


# Write string to file function
def write_file(string):
    # Check if string is string or list
    if isinstance(string, list):
        string = ''.join(string)
    # Write string to file
    with open(triggerFilePath, 'w') as file:
        file.write(string)
        file.close()


# Append string to file function
def append_file(string):
    with open(triggerFilePath, 'a') as file:
        file.write(string)
        file.close()


# Read certain number of lines from data file and return them as a list
def read_data_file(line_number, number_of_lines):
    with open(dataFilePath, 'r') as file:
        lines = file.readlines()
        lines_to_return = lines[line_number:line_number + number_of_lines]
        return lines_to_return


# Microservice function
def microservice():
    random_number = random_number_generator(get_number_of_lines())
    lines = read_data_file(random_number, numberOfLineToPrint)
    write_file(lines)
    append_file("microservice_finished\n")


def main():
    check_file(triggerFilePath)
    check_file(dataFilePath)
    while True:
        if check_keyword(triggerWord):
            print('Keyword found!')
            microservice()
        time.sleep(2)


# Run main function
if __name__ == '__main__':
    main()
