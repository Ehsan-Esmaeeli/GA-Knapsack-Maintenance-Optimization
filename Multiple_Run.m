close all; clear; clc;

% Set the number of times you want to run the function with the same parameters
num_runs = 20;

% Initialize the results array
results = zeros(num_runs, 4);

% Loop through each run
for i = 1:num_runs
    % Call the run_genetic_algorithm function
    [average_capacity_filled, average_value, NFE, elapsed_time] = run_genetic_algorithm();

    % Store the results
    results(i, :) = [average_capacity_filled, average_value, NFE, elapsed_time];
end

% Display the results in a table
result_table = array2table(results, 'VariableNames', {'AverageCapacityFilled', 'AverageValue', 'NFE', 'ElapsedTime'});
disp(result_table);
