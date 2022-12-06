#import "Basic";
#import "File";
#import "String";

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    for line : data {
        if line.count == 0 {
            continue;
        }

        SEQUENCE_LEN :: 14;
        sequence: [SEQUENCE_LEN] u8;
        for i: 0..line.count - 1 {
            sequence[i % SEQUENCE_LEN] = line[i];
            are_same := false;
            for j: 0..SEQUENCE_LEN - 1 {
                for q: (j+1)..SEQUENCE_LEN - 1 {
                    if sequence[j] == sequence[q] {
                        are_same = true;
                        break j;
                    }
                }
            }

            if !are_same && i >= SEQUENCE_LEN {
                print("sequence found after % characters\n", i + 1);
                break;
            }
        }
    }
}