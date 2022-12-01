#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    numbers := split(input, "\n");
    current_sum := 0;
    highest_sum := -1;
    for number : numbers {
        trimmed_number := trim_right(number, "\n\r");
        if trimmed_number.count == 0 {
            if current_sum > highest_sum {
                highest_sum = current_sum;
            }

            current_sum = 0;
        }

        current_sum += to_integer(trimmed_number);
    }

    print("%\n", highest_sum);
}