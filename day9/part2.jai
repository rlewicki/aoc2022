#import "Basic";
#import "File";
#import "String";
#import "Math";

Position :: struct {
    x: int = 0;
    y: int = 0;
}

operator == :: inline (a: Position, b: Position) -> bool {
    return true;
}

DIRECTIONS :: Position.[
    Position.{x=1,y=0}, 
    Position.{x=-1,y=0}, 
    Position.{x=0,y=1}, 
    Position.{x=0,y=-1}
];

instruction_to_dir_idx :: (c: string) -> int {
    if c == "R" {
        return 0;
    } else if c == "L" {
        return 1;
    } else if c == "U" {
        return 2;
    } else if c == "D" {
        return 3;
    }

    return -1;
}

get_opposite_direction :: (direction_idx: int) -> int {
    if direction_idx == 0 {
        return 1;
    } else if direction_idx == 1 {
        return 0;
    } else if direction_idx == 2 {
        return 3;
    } else if direction_idx == 3 {
        return 2;
    }

    return -1;
}

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    knots: [10] Position;
    tail_positions: [..] Position;
    defer array_free(tail_positions);
    array_add(*tail_positions, Position.{x=0, y=0});
    for line: data {
        if line.count == 0 {
            continue;
        }

        instructions := split(line, " ");
        direction := instructions[0];
        steps := to_integer(instructions[1]);
        direction_idx := instruction_to_dir_idx(direction);
        for step: 1..steps {
            knots[0].x += DIRECTIONS[direction_idx].x;
            knots[0].y += DIRECTIONS[direction_idx].y;
            for knot_idx: 1..knots.count - 1 {
                x_sign := 1;
                x_diff := knots[knot_idx - 1].x - knots[knot_idx].x;
                if x_diff < 0 {
                    x_sign = -1;
                }

                y_sign := 1;
                y_diff := knots[knot_idx - 1].y - knots[knot_idx].y;
                if y_diff < 0 {
                    y_sign = -1;
                }

                distance := x_diff * x_diff + y_diff * y_diff;
                if distance > 3 {
                    if x_diff != 0 {
                        knots[knot_idx].x += (1 * x_sign);
                    }

                    if y_diff != 0 {
                        knots[knot_idx].y += (1 * y_sign);
                    }

                    // It would be much better to use set for this instead array
                    // but I'm too lazy at the moment to deal with all the 
                    // hash for a custom struct shenanigans.
                    if knot_idx == knots.count - 1 {
                        is_unique := true;
                        for pos: tail_positions {
                            if pos.x == knots[knot_idx].x && pos.y == knots[knot_idx].y {
                                is_unique = false;
                                break;
                            }
                        }

                        if is_unique {
                            array_add(*tail_positions, knots[knot_idx]);
                        }
                    }
                }
            }
        }
    }

    print("there were % tail locations\n", tail_positions.count);
}