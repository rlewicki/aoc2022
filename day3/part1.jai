#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    rucksacks := split(input, "\r\n");
    total_points := 0;
    for rucksack : rucksacks {
        if rucksack.count == 0 {
            continue;
        }

        half := rucksack.count / 2;
        first_compartment := slice(rucksack, 0, half);
        second_compartment := slice(rucksack, half, half);

        first_rucksack_items: u64 = 0;
        for i : 0..first_compartment.count - 1 {
            shift_value: u64 = 0;
            if first_compartment[i] >= #char "a" {
                shift_value = first_compartment[i] - 97;
            } else {
                shift_value = first_compartment[i] - 39;
            }

            first_rucksack_items |= (cast(u64)1 << shift_value);
        }

        second_rucksack_items: u64 = 0;
        for i : 0..second_compartment.count - 1 {
            shift_value: u64 = 0;
            if second_compartment[i] >= #char "a" {
                shift_value = second_compartment[i] - 97;
            } else {
                shift_value = second_compartment[i] - 39;
            }

            second_rucksack_items |= (cast(u64)1 << shift_value);
        }

        common_item := first_rucksack_items & second_rucksack_items;
        for i : 0..63 {
            if common_item == 1 {
                total_points += i + 1;
                break;
            }

            common_item >>= 1;
        }
    }

    print("total points: %\n", total_points);
}