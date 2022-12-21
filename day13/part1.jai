#import "Basic";
#import "File";
#import "String";
#import "Sort";
#import "Math";

Type :: enum {
    Array;
    Number;
}

Signal_Entry :: struct {
    entry_type: Type;
    number: int = -1;
    parent_index: int = -1;
    children_indicies: [..] int;
}

Signal_Info :: struct {
    signal_entries: [..] Signal_Entry;
}

parse_signal :: (signal: string) -> [] Signal_Info {
    // stores signal info per depth level, where index is the depth
    signal_info: [..] Signal_Info;
    array_add(*signal_info, .{});
    parent_index := 0;
    current_depth := 0;
    for i: 1..signal.count-2 {
        if is_digit(signal[i]) {
            new_entry: Signal_Entry;
            new_entry.entry_type = Type.Number;
            if is_digit(signal[i + 1]) {
                new_entry.number = 10;
                i += 1;
            } else {
                new_entry.number = signal[i] - 48;
            }

            new_entry.parent_index = parent_index;
            array_add(*signal_info[current_depth].signal_entries, new_entry);
            if current_depth - 1 >= 0 {
                array_add(
                    *signal_info[current_depth - 1].signal_entries[parent_index].children_indicies, 
                    signal_info[current_depth].signal_entries.count - 1);
            }
        } else if signal[i] == #char "[" {
            new_entry: Signal_Entry;
            new_entry.entry_type = Type.Array;
            new_entry.parent_index = parent_index;
            array_add(*signal_info[current_depth].signal_entries, new_entry);
            new_array_idx := signal_info[current_depth].signal_entries.count - 1;
            if current_depth > 0 {
                array_add(
                    *signal_info[current_depth - 1].signal_entries[parent_index].children_indicies,
                    new_array_idx);
            }

            parent_index = new_array_idx;
            current_depth += 1;

            if current_depth >= signal_info.count {
                array_add(*signal_info, .{});
            }
        } else if signal[i] == #char "]" {
            current_depth -= 1;
            if current_depth - 1 >= 0 {
                parent_index = signal_info[current_depth - 1].signal_entries.count - 1;
            } else {
                parent_index = -1;
            }
        }
    }
    return signal_info;
}


get_next_number :: (signal: [] Signal_Info, index_per_depth: [] int) -> int, [] int {
    depth := 0;
    entry := signal[depth].signal_entries[index_per_depth[depth]];
    while entry.entry_type != Type.Number {
        if entry.children_indicies.count == 0 {
            break;
        } else {
            old_idx := index_per_depth[depth];
            idx := index_per_depth[depth + 1];
            if idx < signal[depth + 1].signal_entries.count {
                depth += 1;
            } else {
                index_per_depth[depth] += 1;
                idx = index_per_depth[depth];
            }

            while idx >= signal[depth].signal_entries.count {
                if depth == 0 {
                    return depth, index_per_depth;
                }
                depth -= 1;
                index_per_depth[depth] += 1;
                idx = index_per_depth[depth];
            }

            entry = signal[depth].signal_entries[idx];
            i := depth - 1;
            while i >= 0 {
                p_idx := index_per_depth[i];
                if entry.parent_index != p_idx {
                    index_per_depth[i] += 1;
                    entry = signal[i].signal_entries[p_idx + 1];
                    depth = i;
                } else {
                    i = 0;
                }
                i -= 1;
            }
        }
    }

    return depth, index_per_depth;
}

resolve_signal :: (lhs: [] Signal_Info, rhs: [] Signal_Info) -> bool {
    lhs_index_per_depth: [..] int;
    rhs_index_per_depth: [..] int;
    max_depth := lhs.count;
    if max_depth < rhs.count {
        max_depth = rhs.count;
    }
    for i: 0..max_depth-1 {
        array_add(*lhs_index_per_depth, 0);
        array_add(*rhs_index_per_depth, 0);
    }

    result := true;
    is_resolved := false;
    while !is_resolved {
        if lhs_index_per_depth[0] >= lhs[0].signal_entries.count {
            break;
        } else if rhs_index_per_depth[0] >= rhs[0].signal_entries.count {
            result = false;
            break;
        }

        lhs_depth, lhs_index_per_depth := get_next_number(lhs, lhs_index_per_depth);
        rhs_depth, rhs_index_per_depth := get_next_number(rhs, rhs_index_per_depth);
        if lhs_index_per_depth[lhs_depth] >= lhs[lhs_depth].signal_entries.count {
            is_resolved = true;
            break;
        }

        current_max_depth := lhs_depth;
        if rhs_depth > current_max_depth {
            current_max_depth = rhs_depth;
        }
        for i: 0..current_max_depth-1 {
            if rhs_index_per_depth[i] > lhs_index_per_depth[i] {
                result = false;
                is_resolved = true;
                break;
            }
        }

        lhs_entry := lhs[lhs_depth].signal_entries[lhs_index_per_depth[lhs_depth]];
        rhs_entry := rhs[rhs_depth].signal_entries[rhs_index_per_depth[rhs_depth]];

        if lhs_entry.entry_type == Type.Array && rhs_entry.entry_type == Type.Array {
            if lhs_depth > rhs_depth {
                result = false;
                is_resolved = true;
                continue;
            }
        }

        if lhs_entry.number > rhs_entry.number {
            result = false;
            is_resolved = true;
        } else if lhs_entry.number < rhs_entry.number {
            is_resolved = true;
        }

        lhs_index_per_depth[lhs_depth] += 1;
        rhs_index_per_depth[rhs_depth] += 1;
    }

    return result;
}

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    current_line_num := 0;
    sum := 0;
    while current_line_num < data.count {
        left := data[current_line_num];
        right := data[current_line_num + 1];
        // print("comparing % and %\n", left, right);
        current_line_num += 3;
        idx := current_line_num / 3;
        left_signal := parse_signal(left);
        right_signal := parse_signal(right);

        if left_signal[0].signal_entries.count == 0 {
            print("[%] % and % are in right order\n", idx, left, right);
            sum += idx;
            continue;
        }

        result := resolve_signal(left_signal, right_signal);
        if result {
            print("[%] % and % are in right order\n", idx, left, right);
            sum += idx;
        } else {
            print("[%] % and % are in wrong order\n", idx, left, right);
        }
    }

    print("sum of all indicies: %\n", sum);
}
