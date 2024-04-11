function [average_capacity_filled, average_value, NFE, elapsed_time] = run_genetic_algorithm()

tic; % Start the timer
close all; clear; clc;

% Data
values = [
    41 46 42 35 28 39 29 27 45 35 20 28 23 33 50 21 45 26 40 21 34 24 38 45 32;
    27 37 49 33 41 23 32 21 24 38 45 32 25 47 35 40 42 47 50 43 44 20 28 23 33;
    41 30 38 25 37 25 22 47 38 43 42 44 46 42 46 33 40 34 24 28 56 46 41 37 50;
    48 44 27 46 38 21 41 46 41 37 50 28 44 41 27 20 26 50 34 39 33 48 50 37 44;
    35 27 37 46 27 44 37 48 21 34 22 42 47 48 27 23 21 41 26 48 34 46 41 37 50;
    32 26 23 25 29 28 26 33 28 44 49 28 32 39 34 24 24 30 48 42 26 50 21 45 26;
    22 49 21 29 42 34 35 33 44 47 41 34 35 48 50 37 44 48 49 24 45 26 40 21 34
];

durations = [6 3 4 8 6 8 10 10 3 6 5 9 10 5 8 9 5 9 4 8 9 7 6 9 4];
capacities = [21 22 23 21 22 24 20];

% Number of jobs and weeks
n_jobs = length(durations);
n_weeks = length(capacities);

% Genetic algorithm parameters
pop_size = 5000;
num_generations = 5000;
mutation_rate = 0.15;
selection_rate = 0.7;

% Initialize population
pop = zeros(pop_size, n_jobs, n_weeks);

% Main loop
remaining_jobs_indices = 1:n_jobs;
total_capacity_filled = 0;
total_value = 0;
filled_weeks = 0;

capacity_filled_history = zeros(n_weeks, 1);
value_history = zeros(n_weeks, 1);
convergence_history = zeros(num_generations, 1);

for week = 1:n_weeks
     
    % ????????? [I think it doesnt't weork properly] If there are no remaining jobs, skip the week
if isempty(remaining_jobs_indices)
    fprintf('No jobs remaining to assign.\n\n');
    continue;
end   

    % If there are no remaining jobs, skip the week
    if isempty(remaining_jobs_indices)
        fprintf('Week %d\n', week);
        fprintf('Values: %s\n', num2str(values(week, remaining_jobs_indices)));
        fprintf('Remaining Jobs: %s\n', num2str(remaining_jobs_indices));
        fprintf('Durations: %s\n', num2str(durations(remaining_jobs_indices)));
        fprintf('Capacities: %d\n', capacities(week));
        fprintf('Jobs assigned: %s\n', num2str(remaining_jobs_indices(assigned_jobs)));
        week_value = sum(values(week, remaining_jobs_indices(assigned_jobs)));
        fprintf('Gained value: %d\n', week_value);
        fprintf('Capacity filled: %.2f%%\n\n', best_capacity_filled);
        continue;
    end

    % Check if the remaining job duration summation is less than the capacity of the current week
    if sum(durations(remaining_jobs_indices)) <= capacities(week)
        fprintf('Week %d\n', week);
        fprintf('Values: %s\n', num2str(values(week, remaining_jobs_indices)));
        fprintf('Remaining Jobs: %s\n', num2str(remaining_jobs_indices));
        fprintf('Durations: %s\n', num2str(durations(remaining_jobs_indices)));
        fprintf('Capacities: %d\n', capacities(week));
        week_7_values = values(remaining_jobs_indices);
        week_7_value = sum(week_7_values);
        fprintf('Jobs assigned: %s\n', num2str(remaining_jobs_indices));
        fprintf('Gained value: %d\n', week_7_value);
        fprintf('Capacity filled: %.2f%%\n\n', best_capacity_filled);
        remaining_jobs_indices = [];
        continue;
    end

    % Update population for the current week with remaining jobs
    pop(:, remaining_jobs_indices, week) = randi([0, 1], pop_size, length(remaining_jobs_indices));
    
    best_solution = [];
    best_fitness = -Inf;
    best_capacity_filled = 0;

    % Run genetic algorithm for the current week
    for gen = 1:num_generations
        % Calculate fitness
        fitness = zeros(pop_size, 1);
        penalty_factor_under = 2000000;
        penalty_factor_over = 2000000;
        for i = 1:pop_size
            assignment = pop(i, remaining_jobs_indices, week);
            assignment_duration = assignment .* durations(remaining_jobs_indices);
                        capacity_filled = sum(assignment_duration) / capacities(week) * 100;
    
            if capacity_filled >= 80 && capacity_filled <= 100
                fitness(i) = sum(assignment .* values(week, remaining_jobs_indices));
            else
                if capacity_filled < 80
                    fitness(i) = sum(assignment .* values(week, remaining_jobs_indices)) - penalty_factor_under * (80 - capacity_filled);
                else
                    fitness(i) = sum(assignment .* values(week, remaining_jobs_indices)) - penalty_factor_over * (capacity_filled - 100);
                end
            end

            if fitness(i) > best_fitness && capacity_filled >= 80 && capacity_filled <= 100
                best_fitness = fitness(i);
                best_solution = pop(i, :, week);
                best_capacity_filled = capacity_filled;
            end
        end

        % Selection
        selected_indices = randperm(pop_size, round(selection_rate * pop_size));
        selected_pop = pop(selected_indices, :, week);

        % Crossover
        new_pop = zeros(pop_size, length(remaining_jobs_indices));
        for i = 1:2:size(selected_pop, 1)
            parent1 = selected_pop(i, remaining_jobs_indices);
            parent2 = selected_pop(i + 1, remaining_jobs_indices);
            crossover_point = randi([1, length(remaining_jobs_indices)]);
            offspring1 = [parent1(1:crossover_point), parent2(crossover_point + 1:end)];
            offspring2 = [parent2(1:crossover_point), parent1(crossover_point + 1:end)];
            new_pop(i, :) = offspring1;
            new_pop(i + 1, :) = offspring2;
        end

        % Mutation
        mutation_indices = rand(pop_size * length(remaining_jobs_indices), 1) < mutation_rate;
        mutation_pop = new_pop;
        mutation_pop(mutation_indices) = ~mutation_pop(mutation_indices);

        % Update population
        pop(:, remaining_jobs_indices, week) = mutation_pop;
    end

    % Display results for the current week  
    assigned_jobs = find(best_solution(remaining_jobs_indices));

    fprintf('Week %d\n', week);
    fprintf('Values: %s\n', num2str(values(week, remaining_jobs_indices)));
    fprintf('Remaining Jobs: %s\n', num2str(remaining_jobs_indices));
    fprintf('Durations: %s\n', num2str(durations(remaining_jobs_indices)));
    fprintf('Capacities: %d\n', capacities(week));
    fprintf('Jobs assigned: %s\n', num2str(remaining_jobs_indices(assigned_jobs)));
    week_value = sum(values(week, remaining_jobs_indices(assigned_jobs)));
    fprintf('Gained value: %d\n', week_value);
    fprintf('Capacity filled: %.2f%%\n\n', best_capacity_filled);

    % Update remaining jobs
    assigned_jobs_global_indices = remaining_jobs_indices(assigned_jobs);
    remaining_jobs_indices = setdiff(remaining_jobs_indices, assigned_jobs_global_indices);
    
    % Update total capacity filled, total value, and filled weeks count
if ~isempty(assigned_jobs) || (week == 7 && ~isempty(remaining_jobs_indices))
    filled_weeks = filled_weeks + 1;
    total_capacity_filled = total_capacity_filled + best_capacity_filled;
    total_value = total_value + week_value;
end

% Store the capacity filled and value history for the plots
    capacity_filled_history(week) = best_capacity_filled;
    value_history(week) = week_value;
end


% Display remaining unassigned jobs
if ~isempty(remaining_jobs_indices)
    fprintf('Remaining unassigned jobs: %s\n', num2str(remaining_jobs_indices));
else
    fprintf('All jobs have been assigned.\n');
end

% Calculate and display the averages and NFE

average_capacity_filled = total_capacity_filled / filled_weeks;
average_value = total_value / filled_weeks;
NFE = pop_size * num_generations
fprintf('Average capacity filled: %.2f%%\n', average_capacity_filled);
fprintf('Average value of filled weeks: %.2f\n', average_value);
fprintf('Number of Function Evaluations (NFE): %d\n', pop_size * num_generations);

elapsed_time = toc; % Stop the timer and store the elapsed time
fprintf('Time elapsed: %.2f seconds\n', elapsed_time);

end