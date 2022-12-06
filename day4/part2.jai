#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    total := 0;
    for line : data {
        if (line.count == 0) {
            continue;
        }

        ranges := split(line, ",");
        first_elf := split(ranges[0], "-");
        second_elf := split(ranges[1], "-");
        f_a := to_integer(first_elf[0]);
        f_b := to_integer(first_elf[1]);
        s_a := to_integer(second_elf[0]);
        s_b := to_integer(second_elf[1]);
        if  f_a >= s_a && f_a <= s_b || 
            f_b >= s_a && f_b <= s_b || 
            s_a >= f_a && s_a <= f_b || 
            s_b >= f_a && s_b <= f_b {
            total += 1;
        }
    }

    print("total: %\n", total);
}