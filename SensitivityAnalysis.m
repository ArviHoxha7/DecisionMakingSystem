load('fuzzy_AHP_results.mat');

% Define the perturbation strengths
s_values = [0.2, 0.3, 0.4, 0.5, 0.6];

N = 10^4;

% Store results
initial_ranks = zeros(3, 1); % To store initial ranks
final_ranks = zeros(3, length(s_values)); % To store final ranks for each s
PRR = zeros(length(s_values), 1); % To store PRR for each s

% Determine initial ranks
[~, initial_ranks] = sort(weighted_scores, 'descend');

% Function to perturb the weights
function perturbed_weights = perturb_weights(weights, s)
    perturbed_weights = weights + s * (2 * rand(size(weights)) - 1);
    perturbed_weights = max(0, perturbed_weights); % Ensure weights are non-negative
    perturbed_weights = perturbed_weights / sum(perturbed_weights); % Normalize weights
end

% Monte Carlo simulation
for idx = 1:length(s_values)
    s = s_values(idx);
    rank_reversals = 0;
    
    for iter = 1:N
        % Perturb the weights
        perturbed_weights = perturb_weights(normalized_weights, s);
        
        % Calculate new weighted scores
        perturbed_scores = player_scores * perturbed_weights;
        
        % Determine new ranks
        [~, new_ranks] = sort(perturbed_scores, 'descend');
        
        % Check for rank reversal
        if ~isequal(new_ranks, initial_ranks)
            rank_reversals += 1;
        end
    end
    
    % Calculate PRR for current s
    PRR(idx) = rank_reversals / N;
    
    % Store final ranks for the current s
    final_ranks(:, idx) = new_ranks;
end

disp('Initial Ranks:');
disp(initial_ranks);

disp('Final Ranks for each s:');
for idx = 1:length(s_values)
    fprintf('s = %.1f:\n', s_values(idx));
    disp(final_ranks(:, idx));
end

disp('Probability of Rank Reversal (PRR) for each s:');
for idx = 1:length(s_values)
    fprintf('s = %.1f: PRR = %.4f\n', s_values(idx), PRR(idx));
end

% Plot PRR
figure;
plot(s_values, PRR, '-o');
xlabel('Perturbation Strength (s)');
ylabel('Probability of Rank Reversal (PRR)');
title('PRR as a Function of Perturbation Strength');
grid on;

save('sensitivity_analysis_results.mat', 'initial_ranks', 'final_ranks', 'PRR', 's_values');
