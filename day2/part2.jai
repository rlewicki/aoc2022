#import "Basic";
#import "File";
#import "String";

// A - Rock, 1 point
// B - Paper, 2 points
// C - Scissors, 3 points
// Lose 0 points, draw 3 points, win 6 points
// X - lose
// Y - draw
// Z - win

main :: () {
    input := read_entire_file("input.txt");
    games := split(input, "\r\n");

    total_points := 0;
    for game : games {
        result := split(game, " ");
        if result.count != 2 {
            continue;
        }

        shape := result[0][0] - 65;
        if result[1] == "X" {
            shape = (shape + 2) % 3;
        } else if result[1] == "Z" {
            shape = (shape + 1) % 3;
            total_points += 6;
        } else {
            total_points += 3;
        }

        total_points += (cast(int)shape + 1);
    }

    print("total points: %\n", total_points);
}