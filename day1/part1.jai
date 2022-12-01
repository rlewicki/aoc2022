#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    numbers := split(input, "\r\n");
    current_sum := 0;
    highest_sum := -1;
    for number : numbers {
        if number.count == 0 {
            if current_sum > highest_sum {
                highest_sum = current_sum;
            }

            current_sum = 0;
        }

        current_sum += to_integer(number);
    }

    print("%\n", highest_sum);
}