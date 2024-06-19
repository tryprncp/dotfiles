def calculate_mean():
    scores = []
    
    while True:
        user_input = input("Enter a score (or 'done' to finish): ")
        
        if user_input.lower() == 'done':
            if len(scores) == 0:
                print("No scores entered.")
                return
            break
        
        try:
            score = int(user_input)
            if score < 1 or score > 5:
                print("Score must be between 1 and 5.")
            else:
                scores.append(score)
        except ValueError:
            print("Please enter a valid integer score.")
    
    mean_score = sum(scores) / len(scores)
    print(f"The mean score is: {mean_score:.2f}")

calculate_mean()

