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

Signal_Data :: struct {
    signal_info: [] Signal_Info;
    signal: string;
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

        if rhs_index_per_depth[rhs_depth] >= rhs[rhs_depth].signal_entries.count {
            is_resolved = true;
            result = false;
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
    signals: [..] Signal_Data;
    defer array_free(signals);
    while current_line_num < data.count {
        left := data[current_line_num];
        right := data[current_line_num + 1];
        current_line_num += 3;
        idx := current_line_num / 3;
        left_signal := parse_signal(left);
        right_signal := parse_signal(right);

        left_data: Signal_Data;
        left_data.signal_info = left_signal;
        left_data.signal = left;

        right_data: Signal_Data;
        right_data.signal_info = right_signal;
        right_data.signal = right;

        array_add(*signals, left_data);
        array_add(*signals, right_data);
    }

    signal_comparison :: (lhs: Signal_Data, rhs: Signal_Data) -> bool {
        if lhs.signal_info[0].signal_entries.count == 0 {
            return true;
        }

        result := resolve_signal(lhs.signal_info, rhs.signal_info);
        if result {
            return true;
        } else {
            return false;
        }
    }

    for i: 0..signals.count-1 {
        for j: 0..signals.count-1 {
            if signal_comparison(signals[i], signals[j]) {
                tmp := signals[i];
                signals[i] = signals[j];
                signals[j] = tmp;
            }
        }
    }

    distress_a := "[[2]]";
    distress_b := "[[6]]";
    distress_signal_a := parse_signal(distress_a);
    distress_signal_b := parse_signal(distress_b);
    signal_data_a: Signal_Data;
    signal_data_a.signal_info = distress_signal_a;
    signal_data_a.signal = distress_a;
    signal_data_b: Signal_Data;
    signal_data_b.signal_info = distress_signal_b;
    signal_data_b.signal = distress_b;

    a_idx := -1;
    b_idx := -1;
    for signal : signals {
        if !signal_comparison(signal, signal_data_a) {
            a_idx = it_index + 1;
            array_insert_at(*signals, signal_data_a, it_index);
            break;
        }
    }

    for signal : signals {
        if !signal_comparison(signal, signal_data_b) {
            b_idx = it_index + 1;
            break;
        }
    }

    solution := a_idx * b_idx;
    print("solution is %\n", solution);
}
