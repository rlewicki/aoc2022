#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    numbers := split(input, "\r\n");
    current_sum := 0;
    highest_sums: [3] int;
    for number : numbers {
        if number.count == 0 {
            smallest_idx := 0;
            smallest_value := highest_sums[0];
            for v, i: highest_sums {
                if v < smallest_value {
                    smallest_value = v;
                    smallest_idx = i;
                }
            }
            
            if current_sum > smallest_value {
                highest_sums[smallest_idx] = current_sum;
            }

            current_sum = 0;
        }

        current_sum += to_integer(number);
    }

    total := 0;
    for v : highest_sums total += v;
    print("%\n", total);
}