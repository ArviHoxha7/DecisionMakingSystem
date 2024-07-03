% Octave script for Fuzzy AHP

% Define fuzzy comparison matrices for criteria
criteria_comparison = [
    1, 0.5, 2, 1.5;
    2, 1, 3, 2.5;
    0.5, 0.33, 1, 0.75;
    0.67, 0.4, 1.33, 1
];

% Fuzzification with triangular membership function
function fuzzy_value = fuzzify(value)
    if value == 1
        fuzzy_value = [1, 1, 1];
    elseif value == 9
        fuzzy_value = [9, 9, 9];
    elseif value < 1 
        x = 1 / value;
        fuzzy_value = [1 / (x + 1), value, 1 / (x - 1)]; 
    else
        fuzzy_value = [max((value - 1), 0), value, value + 1];
    end
end

% Initialize an empty cell array to store the fuzzified matrix
fuzzy_matrix = cell(size(criteria_comparison));

% Apply the fuzzification function to each element in the matrix
for i = 1:size(criteria_comparison, 1)
    for j = 1:size(criteria_comparison, 2)
        fuzzy_matrix{i, j} = fuzzify(criteria_comparison(i, j));
    end
end

% Display the fuzzified matrix
disp('Fuzzified Matrix:');
disp(fuzzy_matrix);

% Function to calculate fuzzy geometric mean for a row
function r_i = fuzzy_geometric_mean(row)
    n = length(row);
    l_values = zeros(1, n);
    m_values = zeros(1, n);
    u_values = zeros(1, n);
    
    for i = 1:n
        l_values(i) = row{i}(1);
        m_values(i) = row{i}(2);
        u_values(i) = row{i}(3);
    end
    
    l_mean = prod(l_values) ^ (1 / n);
    m_mean = prod(m_values) ^ (1 / n);
    u_mean = prod(u_values) ^ (1 / n);
    
    r_i = [l_mean, m_mean, u_mean];
end

% Calculate fuzzy geometric mean for each row
sum_l_mean = 0;
sum_m_mean = 0;
sum_u_mean = 0;
fuzzy_geometric_means = cell(size(fuzzy_matrix, 1), 1);

for i = 1:size(fuzzy_matrix, 1)
    fuzzy_geometric_means{i} = fuzzy_geometric_mean(fuzzy_matrix(i, :));
    sum_l_mean += fuzzy_geometric_means{i}(1);
    sum_m_mean += fuzzy_geometric_means{i}(2);
    sum_u_mean += fuzzy_geometric_means{i}(3);
end

% Display the fuzzy geometric means
disp('Fuzzy Geometric Means:');
disp(fuzzy_geometric_means);

% Calculate fuzzy weights for each criterion
fuzzy_weights = cell(size(fuzzy_geometric_means));
for i = 1:size(fuzzy_geometric_means, 1)
    fuzzy_weights{i} = [
        fuzzy_geometric_means{i}(1) / sum_l_mean,
        fuzzy_geometric_means{i}(2) / sum_m_mean,
        fuzzy_geometric_means{i}(3) / sum_u_mean
    ];
end

% Display the fuzzy weights
disp('Fuzzy Weights:');
disp(fuzzy_weights);

% Function to defuzzify fuzzy weights using Center of Gravity method
function crisp_value = defuzzify(fuzzy_value)
    crisp_value = (fuzzy_value(1) + fuzzy_value(2) + fuzzy_value(3)) / 3;
end

% Calculate defuzzified weights
defuzzified_weights = zeros(size(fuzzy_weights));
for i = 1:length(fuzzy_weights)
    defuzzified_weights(i) = defuzzify(fuzzy_weights{i});
end

% Display the defuzzified weights
disp('Defuzzified Weights:');
disp(defuzzified_weights);

% Function to normalize the defuzzified weights
function normalized_weights = normalize_weights(weights)
    total = sum(weights);  % Calculate the sum of all weights
    normalized_weights = weights / total;  % Divide each weight by the total sum
end

% Normalize the defuzzified weights
normalized_weights = normalize_weights(defuzzified_weights);

% Display the normalized weights
disp('Normalized Weights:');
disp(normalized_weights);

% Ensure normalized_weights is a column vector
normalized_weights = normalized_weights(:);

% Define player scores for each criterion (Performance, Skills, Age, Cost)
player_scores = [
    8, 9, 6, 7; % Cristiano Ronaldo
    9, 10, 7, 8; % Lionel Messi
    7, 8, 9, 6  % Kylian Mbappe
];

% Calculate weighted scores for each player
weighted_scores = player_scores * normalized_weights;

% Display the weighted scores
disp('Weighted Scores:');
disp(weighted_scores);

% Determine the best player
[~, best_player_index] = max(weighted_scores);
players = {'Cristiano Ronaldo', 'Lionel Messi', 'Kylian Mbappe'};
best_player = players{best_player_index};

% Display the best player
disp('Best Player to Acquire:');
disp(best_player);
