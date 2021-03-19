# python calculator to find average CMEE marks thus far

tbd = 0

### Input Marks:  Weight    Marks
# Term 1
computing =       (14.75,   84)
miniproj_code =   (3,       80)
miniproj_report = (3,       77)
HPC =             (4,       tbd)
seminar_diary =   (0.25,    tbd)
# Final Project
final_report =    (45,      tbd)
viva =            (18.75,   tbd)
presentation =    (7.5,     tbd)
supervisor_mark = (3.75,    tbd)

### Creats list of components
components = [computing, miniproj_code, miniproj_report, HPC, seminar_diary, final_report, viva, presentation, supervisor_mark]

### Calculator
max, sum = 0, 0
for component in components:
    if component[1] != 0:
        max += component[0]
        sum += component[0]*component[1]/100

print("Current average mark:", round(sum/max*100, 2))

