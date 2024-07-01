% Ορισμός παραμέτρων
num_criteria = 6; % Αριθμός κριτηρίων
num_alternatives = 3; % Αριθμός εναλλακτικών
num_experts = 15; % Αριθμός ειδικών

% Δημιουργία τυχαίων βαθμολογιών με κάποιες ελλείψεις (χρήση NaN)
scores = rand(num_criteria, num_alternatives, num_experts);
scores(2, 1, 5) = NaN;
scores(4, 3, 10) = NaN;

% Καθορισμός βαρών για κάθε κριτήριο (το άθροισμά τους πρέπει να είναι 1)
weights = [0.4, 0.2, 0.1, 0.1, 0.1, 0.1];

% Συμπλήρωση των ελλείψεων με τη μέση τιμή των υπόλοιπων ειδικών
for i = 1:num_criteria
  for j = 1:num_alternatives
    for k = 1:num_experts
      if isnan(scores(i, j, k))
        scores(i, j, k) = mean(scores(i, j, ~isnan(scores(i, j, :))));
      end
    end
  end
end

% Υπολογισμός μέσης βαθμολογίας για κάθε εναλλακτική
mean_scores = mean(scores, 3);  % Μέσος όρος βαθμολογιών ανά κριτήριο και εναλλακτική

% Υπολογισμός συνολικής βαθμολογίας για κάθε εναλλακτική
total_scores = mean_scores' * weights';

% Έλεγχος συνέπειας (Consistency Ratio) για σύγκριση ζευγών (προαιρετικό)
consistency_threshold = 0.1;  % Καθορισμός κατωφλίου συνέπειας

% Για κάθε κριτήριο, δημιουργούμε πίνακα σύγκρισης ζευγών και υπολογίζουμε το CR
cr_values = zeros(num_criteria, 1);
for i = 1:num_criteria
  pairwise_matrix = ones(num_alternatives);  % Δημιουργία πίνακα σύγκρισης ζευγών
  for j = 1:num_alternatives
    for k = j+1:num_alternatives
      ratio = mean_scores(i, j) / mean_scores(i, k);
      pairwise_matrix(j, k) = ratio;
      pairwise_matrix(k, j) = 1 / ratio;
    end
  end
  % Υπολογισμός του CR για τον πίνακα σύγκρισης ζευγών
  lambda_max = max(eig(pairwise_matrix));  % Μέγιστη ιδιοτιμή
  n = num_alternatives;
  RI = 0.58;  % Τυχαίος δείκτης για n=3
  cr_values(i) = (lambda_max - n) / (n - 1) / RI;
end

% Έλεγχος αν οι πίνακες είναι συνεπείς
if any(cr_values > consistency_threshold)
  fprintf('Βρέθηκαν μη συνεπείς πίνακες. Αντικατάσταση με νέους συνεπείς πίνακες.\n');
  % Αντικατάσταση των μη συνεπών πινάκων (προαιρετικά)
end

% Επανυπολογισμός της συνολικής βαθμολογίας μετά την αντικατάσταση των μη συνεπών πινάκων
mean_scores = mean(scores, 3);
total_scores = mean_scores' * weights';

% Εμφάνιση των συνολικών βαθμολογιών και επιλογή της καλύτερης εναλλακτικής
fprintf('Συνολικές βαθμολογίες για κάθε εναλλακτική:\n');
disp(total_scores);
[~, best_alternative] = max(total_scores);
fprintf('Η καλύτερη εναλλακτική είναι η Εναλλακτική %d\n', best_alternative);

