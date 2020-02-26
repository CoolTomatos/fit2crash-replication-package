import os
from sys import argv


######## Methods
def appeared_in_other_format(project_package, splited_line):
    result = False
    for part in splited_line:
        if ''.join([i for i in project_package if not i.isdigit()]) == ''.join([i for i in part if not i.isdigit()]):
            result = True
    return result


application = argv[1]
package = argv[2]
case = argv[3]
dir_path = os.path.dirname(os.path.realpath(__file__))
log_path = os.path.join(dir_path, "..", "..", "crashes", application, case, case + ".log")

log_file = open(log_path, "r")

valid_frames = ""

exceptionType_line_passed = False

counter = 0
for line in log_file:
    # print line
    if counter == 0:
        splited_line = line.split(':')
        ExceptionName = splited_line[0]
        counter += 1
        continue

    splited_line = line.split('.')
    if len(splited_line) > 1 and (package in splited_line or appeared_in_other_format(package, splited_line)):
        valid_frames = valid_frames + str(counter) + "|"

    counter += 1

valid_frames = valid_frames[:-1]
print (valid_frames)
