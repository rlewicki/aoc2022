#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    sum_of_signals := 0;
    x := 1;
    cycle_number := 1;
    previous_cycle_number := 0;
    for line : data {
        if line.count == 0 {
            continue;
        }

        values := split(line, " ");
        instruction := values[0];
        previous_cycle_number = cycle_number;
        previous_x := x;
        if instruction != "noop" {
            value := to_integer(values[1]);
            x += value;
            cycle_number += 2;
        } else {
            cycle_number += 1;
        }

        prev := (previous_cycle_number + 20) / 40;
        current := (cycle_number + 20) / 40;
        cycle_value := current * 40 - 20;
        reminder := (cycle_number + 20) % 40;
        value := x;
        if reminder != 0 {
            value = previous_x;
        }
        if prev != current {
            sum_of_signals += (value * cycle_value);
        }
    }

    print("sum of all signals is %\n", sum_of_signals);
}