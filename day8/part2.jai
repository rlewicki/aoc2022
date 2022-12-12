#import "Basic";
#import "File";
#import "String";

Coords :: struct {
    x: int = 0;
    y: int = 0;
}

DIRS :: Coords.[
    Coords.{x=1,y=0}, 
    Coords.{x=-1,y=0}, 
    Coords.{x=0,y=1}, 
    Coords.{x=0,y=-1}
];

char_to_int :: (c: u8) -> int {
    return c - 48;
}

is_within_bounds :: (data: [] string, coords: Coords) -> bool {
    return coords.y >= 0 && coords.y <= data.count - 1 && coords.x >= 0 && coords.x <= data[coords.y].count - 1;
}

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    highest_score := -1;
    for y: 1..data.count - 2 {
        if data[y].count == 0 {
            continue;
        }

        for x: 1..data[y].count - 1 {
            tree_height := char_to_int(data[y][x]);
            current_location: Coords;
            current_location.x = x;
            current_location.y = y;
            score_per_dir: [4] int;
            for dir, idx: DIRS {
                is_visible := true;
                score_per_dir[idx] = 0;
                test_location := current_location;
                test_location.x += dir.x;
                test_location.y += dir.y;
                while is_within_bounds(data, test_location) {
                    test_tree_height := char_to_int(data[test_location.y][test_location.x]);
                    score_per_dir[idx] += 1;
                    if test_tree_height >= tree_height {
                        break;
                    }

                    test_location.x += dir.x;
                    test_location.y += dir.y;
                }
            }

            tree_score := 1;
            for i: 0..3 {
                tree_score *= score_per_dir[i];
            }

            if tree_score > highest_score {
                highest_score = tree_score;
            }

            // print("tree score: %\n", tree_score);
        }
    }

    print("highest score: %\n", highest_score);
}