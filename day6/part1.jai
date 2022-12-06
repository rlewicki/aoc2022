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

        sequence: [4] u8;
        for i: 0..line.count - 1 {
            sequence[i % 4] = line[i];
            are_same := false;
            for j: 0..3 {
                for q: (j+1)..3 {
                    if sequence[j] == sequence[q] {
                        are_same = true;
                        break j;
                    }
                }
            }

            if !are_same && i >= 4 {
                print("sequence found after % characters\n", i + 1);
                break;
            }
        }
    }
}