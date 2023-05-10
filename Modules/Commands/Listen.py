import sys
import time


def colorize_string(string):
    reset_code = "\033[0m"
    if "INFO" in string:
        return "\033[32m" + string + reset_code  # green
    elif "ERROR" in string:
        return "\033[31m" + string + reset_code  # yellow
    elif "WARNING" in string:
        return "\033[33m" + string + reset_code  # red
    else:
        return string


File = sys.argv[1]

try:
    with open(File, 'r') as file:
        while True:
            line = file.readline()

            if not line:
                time.sleep(1)
            else:
                print(colorize_string(line.strip()))
except KeyboardInterrupt:
    # Handle the keyboard interrupt
    print("Keyboard interrupt detected. Exiting...")
    sys.exit(0)
