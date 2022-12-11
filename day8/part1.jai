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
    return coords.y > 0 && coords.y < data.count - 2 && coords.x > 0 && coords.x < data[coords.y].count - 1;
}

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    total_visible := 0;
    for y: 1..data.count - 3 {
        if data[y].count == 0 {
            continue;
        }

        for x: 1..data[y].count - 2 {
            tree_height := char_to_int(data[y][x]);
            current_location: Coords;
            current_location.x = x;
            current_location.y = y;
            for dir: DIRS {
                is_visible := true;
                test_location := current_location;
                while is_within_bounds(data, test_location) {
                    test_location.x += dir.x;
                    test_location.y += dir.y;
                    test_tree_height := char_to_int(data[test_location.y][test_location.x]);
                    if test_tree_height >= tree_height {
                        is_visible = false;
                        break;
                    }
                }

                if is_visible {
                    total_visible += 1;
                    break;
                }
            }
        }
    }

    total_visible += ((data.count - 1) * 4 - 4);
    print("Total visible trees: %\n", total_visible);
}