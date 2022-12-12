#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    PIXELS :: 240;
    x: [PIXELS] int;
    x[0] = 1;
    cycle := 1;
    for line : data {
        if line.count == 0 {
            continue;
        }

        if cycle >= PIXELS {
            break;
        }

        values := split(line, " ");
        instruction := values[0];
        if instruction != "noop" {
            value := to_integer(values[1]);
            current_x := x[cycle - 1];
            x[cycle] = current_x;
            cycle += 1;
            new_value := x[cycle - 1] + value;
            for i: cycle..PIXELS-1 {
                x[i] = new_value;
            }

            cycle += 1;
        } else {
            if cycle < 240 {
                x[cycle] = x[cycle - 1];
            }
            cycle += 1;
        }
    }

    for i: 0..PIXELS-1 {
        if i % 40 == 0 {
            print("\n");
        }

        crt_position := i % 40;

        if crt_position >= x[i] - 1 && crt_position <= x[i] + 1 {
            print("#");
        } else {
            print(".");
        }
    }
}