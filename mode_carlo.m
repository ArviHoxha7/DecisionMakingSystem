% Define the random index (RI) for different matrix sizes
RI = [0, 0, 0.58, 0.9, 1.12, 1.24, 1.32, 1.41, 1.45];

% Function to calculate the maximum eigenvalue (λ_max) and consistency index (CI)
function [lambda_max, CI] = calculate_consistency(matrix)
    [V, D] = eig(matrix);
    lambda_max = max(diag(D));
    n = size(matrix, 1);
    CI = (lambda_max - n) / (n - 1);
end

% Function to check consistency and return a consistent matrix
function consistent_matrix = ensure_consistency(matrix, RI)
    n = size(matrix, 1);
    [lambda_max, CI] = calculate_consistency(matrix);
    CR = CI / RI(n);
    while CR > 0.1
        matrix = randi([1, 9], n, n); % Replace with new random matrix
        for i = 1:n
            for j = 1:n
                if i == j
                    matrix(i, j) = 1;
                elseif i < j
                    matrix(i, j) = randi([1, 9]);
                    matrix(j, i) = 1 / matrix(i, j);
                end
            end
        end
        [lambda_max, CI] = calculate_consistency(matrix);
        CR = CI / RI(n);
    end
    consistent_matrix = matrix;
end

% Define comparison matrices for criteria by each expert (15 experts)
num_experts = 15;
num_criteria = 4;
expert_comparisons = cell(num_experts, 1);

% Initialize variables for sensitivity analysis
N = 1000; % Number of repetitions
s_values = 0.2:0.1:0.6; % Perturbation strengths
num_s = length(s_values);

% Function to perturb the matrix with given strength s
function perturbed_matrix = perturb_matrix(matrix, s)
    perturbed_matrix = matrix .* (1 + s * randn(size(matrix)));
    perturbed_matrix(perturbed_matrix < 1) = 1 ./ perturbed_matrix(perturbed_matrix < 1);
end

% Monte Carlo simulation with sensitivity analysis
PRR_probabilities = zeros(num_s, 1);
initial_priorities = zeros(num_criteria, num_s); % Initial priorities of players
final_priorities = zeros(num_criteria, num_s);   % Final priorities after perturbation

for s_idx = 1:num_s
    s = s_values(s_idx);
    PRR_count = 0;

    for rep = 1:N
        % Generate random expert comparisons
        for k = 1:num_experts
            expert_comparisons{k} = NaN(num_criteria, num_criteria);
            for i = 1:num_criteria
                for j = 1:num_criteria
                    if i == j
                        expert_comparisons{k}(i, j) = 1;
                    elseif i < j
                        expert_comparisons{k}(i, j) = randi([1, 9]);
                        expert_comparisons{k}(j, i) = 1 / expert_comparisons{k}(i, j);
                    end
                end
            end
            expert_comparisons{k} = ensure_consistency(expert_comparisons{k}, RI);
        end

        % Handle missing values by taking the average from other experts
        for i = 1:num_criteria
            for j = 1:num_criteria
                if i ~= j
                    values = [];
                    for k = 1:num_experts
                        if ~isnan(expert_comparisons{k}(i, j))
                            values = [values, expert_comparisons{k}(i, j)];
                        end
                    end
                    avg_value = mean(values);
                    for k = 1:num_experts
                        if isnan(expert_comparisons{k}(i, j))
                            expert_comparisons{k}(i, j) = avg_value;
                            expert_comparisons{k}(j, i) = 1 / avg_value;
                        end
                    end
                end
            end
        end

        % Calculate the average comparison matrix for criteria
        average_comparison = zeros(num_criteria, num_criteria);
        for k = 1:num_experts
            average_comparison = average_comparison + expert_comparisons{k};
        end
        average_comparison = average_comparison / num_experts;

        % Perturb the average comparison matrix
        perturbed_comparison = perturb_matrix(average_comparison, s);

        % Calculate fuzzy weights for each criterion
        function fuzzy_weights = calculate_fuzzy_weights(avg_comparison, num_criteria)
            % Fuzzification with triangular membership function
            fuzzy_weights = cell(num_criteria, 1);
            for i = 1:num_criteria
                if avg_comparison(i, i) == 1
                    fuzzy_weights{i} = [1, 1, 1];
                elseif avg_comparison(i, i) == 9
                    fuzzy_weights{i} = [9, 9, 9];
                elseif avg_comparison(i, i) < 1
                    x = 1 / avg_comparison(i, i);
                    fuzzy_weights{i} = [1 / (x + 1), avg_comparison(i, i), 1 / (x - 1)];
                else
                    fuzzy_weights{i} = [max((avg_comparison(i, i) - 1), 0), avg_comparison(i, i), avg_comparison(i, i) + 1];
                end
            end
        end

        % Calculate normalized weights using Monte Carlo
        defuzzified_weights = zeros(num_criteria, 1);
        fuzzy_weights = calculate_fuzzy_weights(perturbed_comparison, num_criteria);
        for i = 1:num_criteria
            defuzzified_weights(i) = (fuzzy_weights{i}(1) + fuzzy_weights{i}(2) + fuzzy_weights{i}(3)) / 3;
        end
        normalized_weights = defuzzified_weights / sum(defuzzified_weights);

        % Define player scores for each criterion (Performance, Skills, Age, Cost)
        player_scores = [
            9, 10, 6, 7; % Cristiano Ronaldo
            9, 10, 7, 8; % Lionel Messi
            7, 8, 9, 6  % Kylian Mbappe
        ];

        % Calculate weighted scores for each player
        weighted_scores = player_scores * normalized_weights;

        % Determine the best player index based on weighted scores
        [~, initial_best_player] = max(weighted_scores);

        % Store initial priorities
        if rep == 1
            initial_priorities(:, s_idx) = normalized_weights;
        end

        % Perturb the matrix again to calculate final priorities
        perturbed_comparison = perturb_matrix(average_comparison, s);
        fuzzy_weights = calculate_fuzzy_weights(perturbed_comparison, num_criteria);
        for i = 1:num_criteria
            defuzzified_weights(i) = (fuzzy_weights{i}(1) + fuzzy_weights{i}(2) + fuzzy_weights{i}(3)) / 3;
        end
        normalized_weights = defuzzified_weights / sum(defuzzified_weights);

        % Calculate weighted scores for each player
        weighted_scores = player_scores * normalized_weights;

        % Determine the best player index based on weighted scores after perturbation
        [~, final_best_player] = max(weighted_scores);

        % Check for priority ranking reversal (PRR)
        if initial_best_player ~= final_best_player
            PRR_count = PRR_count + 1;
        end
    end

    % Calculate probability of PRR
    PRR_probability = PRR_count / N;
    PRR_probabilities(s_idx) = PRR_probability;

    % Store final priorities
    final_priorities(:, s_idx) = normalized_weights;
end

% Display results
disp('Initial Priorities:');
disp(initial_priorities);
disp('Final Priorities:');
disp(final_priorities);
disp('PRR Probabilities:');
disp(PRR_probabilities);

% Plot PRR probabilities as a function of perturbation strength
figure;
plot(s_values, PRR_probabilities, '-o', 'LineWidth', 2);
title('Probability of Priority Ranking Reversal (PRR) vs. Perturbation Strength');
xlabel('Perturbation Strength (s)');
ylabel('Probability of PRR');
grid on;

