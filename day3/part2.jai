#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    rucksacks := split(input, "\r\n");
    total_points := 0;
    items: [3] u64;
    idx := 0;
    while idx < rucksacks.count - 1 {
        if rucksacks[idx].count == 0 {
            continue;
        }

        for offset: 0..2 {
            items[offset] = 0;
            for i: 0..rucksacks[idx + offset].count - 1 {
                shift_value: u64 = 0;
                if rucksacks[idx + offset][i] >= #char "a" {
                    shift_value = rucksacks[idx + offset][i] - 97;
                } else {
                    shift_value = rucksacks[idx + offset][i] - 39;
                }

                items[offset] |= (cast(u64)1 << shift_value);
            }
        }

        common_item := items[0];
        for offset: 1..2 {
            common_item &= items[offset];
        }

        for i : 0..63 {
            if common_item == 1 {
                total_points += i + 1;
                break;
            }

            common_item >>= 1;
        }

        idx += 3;
    }

    print("total points: %\n", total_points);
}