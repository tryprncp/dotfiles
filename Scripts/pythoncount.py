def count_scores(scores):
    counts = {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0}
    for score in scores:
        counts[score] += 1
    return counts

scores = []
print("Enter the scores (enter 'done' when finished):")
while True:
    score = input()
    if score.lower() == 'done':
        break
    scores.append(score)

score_counts = count_scores(scores)

for score, count in score_counts.items():
    print(f'Number of "{score}": {count}')

total_scores = sum(score_counts.values())
print(f'Total number of scores: {total_scores}')

