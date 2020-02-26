import csv
import fcntl
import os
import re
import sys

# input arguments
execution_idx = sys.argv[1]
application = sys.argv[2]
case = sys.argv[3]
version = sys.argv[4]
frame_level = sys.argv[5]
search_budget = sys.argv[6]
dir_path = os.path.dirname(os.path.realpath(__file__))
log_dir = os.path.join(dir_path, "..", "logs", case +
                       "-" + frame_level + "-" + execution_idx + "-out.txt")
out_dir = os.path.join(dir_path, "..", "results", "results.csv")


# functions
def write_on_csv_file(csv_result, csv_file_dir):
    title_order = [
        "execution_idx",
        "application",
        "case",
        "version",
        "exception_name",
        "frame_level",
        "search_budget",
        "fitness_function_value",
        "number_of_fitness_evaluations",
        "fitness_function_evolution"
    ]

    fields = []

    for cell in title_order:
        if cell in csv_result.keys():
            fields.append(csv_result[cell])
        else:
            fields.append("")

    with open(csv_file_dir, "a") as g:
        fcntl.flock(g, fcntl.LOCK_EX)
        writer = csv.writer(g)
        writer.writerow(fields)
        fcntl.flock(g, fcntl.LOCK_UN)


###


csv_result = {"execution_idx": execution_idx,
              "application": application,
              "case": case,
              "version": version,
              "frame_level": frame_level,
              "search_budget": search_budget,
              "fitness_function_value": "-1",
              "fitness_function_evolution": "",
              "number_of_fitness_evaluations": 0}

with open(log_dir, "r") as ins:
    for stdout_line in ins:
        if "generation #" in stdout_line:
            split_line_1 = stdout_line.split("#")
            csv_result["number_of_fitness_evaluations"] = int(re.sub("[^0-9]", "", split_line_1[1]))
            distribution_ff = split_line_1[0].strip()
        elif "Exception type is detected:" in stdout_line:
            split_line_1 = stdout_line.split("Exception type is detected: ")
            csv_result["exception_name"] = split_line_1[1].replace(
                '\n', ' ').replace('\r', '').strip()
        elif "eu.stamp.botsing.fitnessfunction.ITFFForIndexedAccess@" in stdout_line:
            split_line_1 = stdout_line.split(": ")
            distribution_ff = split_line_1[1].strip()
            if distribution_ff != csv_result["fitness_function_value"]:
                csv_result["fitness_function_value"] = distribution_ff
                csv_result["fitness_function_evolution"] += "[" + distribution_ff + "," + str(
                    csv_result["number_of_fitness_evaluations"] + 1) + "]"
        elif "Stopping reason: ZeroFitness" in stdout_line:
            if csv_result["number_of_fitness_evaluations"] == 0:
                csv_result["number_of_fitness_evaluations"] = 1
            csv_result["fitness_function_value"] = "0.0"
            csv_result["fitness_function_evolution"] += "[" + "0.0" + "," + str(
                csv_result["number_of_fitness_evaluations"]) + "]"

write_on_csv_file(csv_result, out_dir)
