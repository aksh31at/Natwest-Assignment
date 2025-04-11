import csv

try:
    threshold = float(input("Enter grade threshold: "))
except ValueError:
    print("Please enter a valid number.")
    exit(1)

with open("students.csv", mode="r") as file:
    reader = csv.DictReader(file)
    print(f"\nStudents with grades above {threshold}:\n")
    found = False
    for row in reader:
        try:
            grade = float(row['grade'])
            if grade > threshold:
                print(f"{row['name']} (Grade: {grade})")
                found = True
        except ValueError:
            continue

    if not found:
        print("No students found above the threshold.")
