% Βασικές παράμετροι
num_experts = 15;
num_criteria = 6;
num_players = 3;
criteria_weights = [0.25, 0.20, 0.20, 0.10, 0.15, 0.10]; % Βάρη κριτηρίων

% Τυχαία δεδομένα βαθμολογιών από ειδικούς (με μερικές ελλείπουσες τιμές)
scores = randi([50, 100], num_experts, num_criteria, num_players);
% Προσθήκη μερικών ελλείπουσων τιμών (NaN) τυχαία
scores(1,1,1) = NaN;
scores(3,2,2) = NaN;
scores(5,3,3) = NaN;

% Αντικατάσταση ελλείπουσων τιμών με τη μέση τιμή των άλλων ειδικών
for i = 1:num_criteria
    for j = 1:num_players
        missing_values = isnan(scores(:, i, j));
        scores(missing_values, i, j) = mean(scores(~missing_values, i, j));
    end
end

% Υπολογισμός μέσης βαθμολογίας για κάθε κριτήριο και παίκτη
mean_scores = mean(scores, 1);

% Υπολογισμός συνολικής βαθμολογίας για κάθε παίκτη
total_scores = zeros(1, num_players);
for i = 1:num_players
    total_scores(i) = sum(mean_scores(:, :, i) .* criteria_weights);
end

% Εμφάνιση αποτελεσμάτων
disp('Μέσες βαθμολογίες για κάθε κριτήριο και παίκτη:');
disp(mean_scores);

disp('Συνολικές βαθμολογίες των παικτών:');
disp(total_scores);

% Ο παίκτης με την υψηλότερη συνολική βαθμολογία είναι η προτιμώμενη επιλογή
[~, best_player_index] = max(total_scores);
disp(['Ο προτιμώμενος παίκτης είναι ο Παίκτης ', num2str(best_player_index)]);
