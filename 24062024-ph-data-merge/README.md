# Data Merge Project - Philippines

Created: June 24, 2024

Completed: June 25, 2024

## Task

Merge Phillipine data from `Criminalization data Anna` to the original data set `Uwazi-2024-02-12T12 03 44`

## Directories

-   dataraw: contains raw/input data files
    -   `Criminalization data Anna.xlsx` contains data on specific cases in the Philippines (and other countries), often referred to as the "data to merge"
    -   `Uwazi-2024-02-12T12 03 44.csv` contains broader data on LEDs, often referred to as the "main data"
-   dataout: contains output data files from the merge/matching task
    -   `Criminalization data Anna - modified.xlsx` is a modified version of the raw data used to browse through the data
    -   `philippines_criminalization_data_matched.xlsx` is the **main output** of this task, contains all observations from `Uwazi-2024-02-12T12 03 44.csv` and matched to observations in `Criminalization data Anna.xlsx` where possible [also available in a CSV version]

## Process

Rough steps on matching process:

1.  In the main data, create a unique ID corresponding to the observation's row number. Do this because there's no unique identifier in this data set, and it makes our lives easier to matching later down the line.

    -   Note, an initial thought was to match based on the source (i.e. the link to the article), but the links don't really match up between the two data sets

2.  From the data to merge, standardize the dates and names as best as possible

3.  Using a long `case_when` statement, search the names and dates in the main data, assign the relevant ID number and match

    -   Not the best way to do it (i.e. not DRY, requires manual checking) but is the quickest way

4.  Output the resulting data set.

## Output

The output data is `dataout > philippines_criminalization_data_matched.xlsx` which contains *all* variables from the main data and data to merge as well as a few new ones:

-   id = unique identifier for each row, based on the row number
-   not_enough_info = equals 1 if there was not enough info on the case from the data to merge to match with the main data. If the value is 0, that means the row appeared in the data to merge file and was able to match to the main data (i.e. nothing to worry about). If the value is blank, that means the row did not appear in the data to merge file (i.e. also nothing to worry about)
    -   **Make sure** to check the data that have not_enough_info == 1
