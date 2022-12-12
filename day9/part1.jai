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
    head_position := Position.{x=0, y=0};
    tail_position := Position.{x=0, y=0};
    tail_positions: [..] Position;
    defer array_free(tail_positions);
    array_add(*tail_positions, tail_position);
    for line: data {
        if line.count == 0 {
            continue;
        }

        instructions := split(line, " ");
        direction := instructions[0];
        steps := to_integer(instructions[1]);
        direction_idx := instruction_to_dir_idx(direction);
        for step: 1..steps {
            head_position.x += DIRECTIONS[direction_idx].x;
            head_position.y += DIRECTIONS[direction_idx].y;
            x_diff := abs(head_position.x - tail_position.x);
            y_diff := abs(head_position.y - tail_position.y);
            distance := x_diff * x_diff + y_diff * y_diff;
            if distance > 3 {
                opposite_direction_idx := get_opposite_direction(direction_idx);
                opposite_direction := DIRECTIONS[opposite_direction_idx];
                tail_position.x = head_position.x + opposite_direction.x;
                tail_position.y = head_position.y + opposite_direction.y;

                // It would be much better to use set for this instead array
                // but I'm too lazy at the moment to deal with all the 
                // hash for a custom struct shenanigans.
                is_unique := true;
                for pos: tail_positions {
                    if pos.x == tail_position.x && pos.y == tail_position.y {
                        is_unique = false;
                        break;
                    }
                }

                if is_unique {
                    array_add(*tail_positions, tail_position);
                }
            }
        }
    }

    print("there were % tail locations\n", tail_positions.count);
}