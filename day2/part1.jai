#import "Basic";
#import "File";
#import "String";

// A, X - Rock, 1 point
// B, Y - Paper, 2 points
// C, Z - Scissors, 3 points
// Lose 0 points, draw 3 points, win 6 points

main :: () {
    input := read_entire_file("input.txt");
    games := split(input, "\r\n");

    total_points := 0;
    for game : games {
        result := split(game, " ");
        if result.count != 2 {
            continue;
        }

        total_points += result[1][0] - 87;
        if result[0][0] + 23 == result[1][0] {
            total_points += 3;
        } else if result[0] == "A" && result[1] == "Y" || 
                  result[0] == "B" && result[1] == "Z" || 
                  result[0] == "C" && result[1] == "X" {
            total_points += 6;
        }
    }

    print("total points: %\n", total_points);
}