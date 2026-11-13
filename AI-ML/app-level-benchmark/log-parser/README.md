## Parsing and Validating DeepCAM Run Logs

This README describes how to use the provided `parse-mllog.py` script to parse and validate DeepCAM runs. The output of this script is a CSV file in the format `{jobid}-{total_accs}GPUs-Scenario{scenario}.csv` in the desired output folder. Note that this script operates on one log file at a time. All results can be compiled in a single table by aggregating individual Scenario 1 or Scenario 2 run results together.

### Environment creation

First, create a small Python virtual environment:

```
bash build-parse-env.sh
```

Run `python log-parser/parse-mllog.py --help` for more information.

### Scenario 1 example

This parses a Scenario 1 baseline submission into the parsed-outputs folder:

```
python parse-mllog.py --logfile scen1-example.log --output_folder test-scen --scenario 1 --submission_type baseline
```

### Scenario 2 example

This parses a Scenario 2 baseline submission into the parsed-outputs folder:

```
python parse-mllog.py --logfile scen2-example.log --output_folder test-scen --scenario 2 --submission_type baseline
```

### Workflow

The intention is that submitters run the Python script on one logfile at a time, and then aggregate Scenario 1 and Scenario 2 results into separate CSVs, named "Scenario1_ReportingTable.csv" and "Scenario2_ReportingTable.csv". Submitters may use the provided "aggregate-deepcam-results.sh" script to accomplish this:

```
cd </path/to/parsed/files>
bash /path/to/aggregate-deepcam-results.sh
```