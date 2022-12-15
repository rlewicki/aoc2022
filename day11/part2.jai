#import "Basic";
#import "File";
#import "String";
#import "Sort";

Monkey_Info :: struct {
    items: [..] int;
    lhs_operator: string;
    rhs_operator: string;
    op: u8;
    divider: int;
    if_true_target: int;
    if_false_target: int;
    items_processed: int = 0;
}

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    line_num := 0;
    monkeys: [..] Monkey_Info;
    defer {
        for m: monkeys {
            array_free(m.items);
        }
        array_free(monkeys);
    }

    while line_num < data.count {
        line_num += 1;
        new_monkey: Monkey_Info;
        // Get starting items
        {
            v := split(data[line_num], ":");
            v_trimmed := trim(v[1]);
            items := split(v_trimmed, ",");
            for i: items {
                array_add(*new_monkey.items, to_integer(i));
            }
            line_num += 1;
        }

        // Worry formula
        {
            v := split(data[line_num], "=");
            v_trimmed := trim(v[1]);
            operators := split(v_trimmed, " ");
            new_monkey.lhs_operator = operators[0];
            new_monkey.op = operators[1][0];
            new_monkey.rhs_operator = operators[2];
            line_num += 1;
        }

        // Test divider
        {
            v := split(data[line_num], "by");
            v_trimmed := trim(v[1]);
            new_monkey.divider = to_integer(v_trimmed);
            line_num += 1;
        }

        // If test true
        {
            v := split(data[line_num], "monkey");
            v_trimmed := trim(v[1]);
            new_monkey.if_true_target = to_integer(v_trimmed);
            line_num += 1;
        }

        // If test false
        {
            v := split(data[line_num], "monkey");
            v_trimmed := trim(v[1]);
            new_monkey.if_false_target = to_integer(v_trimmed);
            line_num += 1;
        }

        line_num += 1;

        array_add(*monkeys, new_monkey);
    }

    get_new_worry_value :: (old_value: int, lhs: string, rhs: string, op: u8) -> int {
        lhs_value := 0;
        rhs_value := 0;
        if lhs == "old" {
            lhs_value = old_value;
        } else {
            lhs_value = to_integer(lhs);
        }

        if rhs == "old" {
            rhs_value = old_value;
        } else {
            rhs_value = to_integer(rhs);
        }

        if op == #char "+" {
            return lhs_value + rhs_value;
        } else if op == #char "-" {
            return lhs_value - rhs_value;
        } else if op == #char "*" {
            return lhs_value * rhs_value;
        } else if op == #char "/" {
            return lhs_value / rhs_value;
        }

        return -1;
    }

    common_divider := 1;
    for monkey : monkeys {
        common_divider *= monkey.divider;
    }

    ROUNDS :: 10000;
    for round : 1..ROUNDS {
        for *monkey : monkeys {
            for item : monkey.items {
                new_worry := get_new_worry_value(
                    item, 
                    monkey.lhs_operator, 
                    monkey.rhs_operator, 
                    monkey.op);
                new_worry %= common_divider;
                if new_worry % monkey.divider == 0 {
                    array_add(*monkeys[monkey.if_true_target].items, new_worry);
                } else {
                    array_add(*monkeys[monkey.if_false_target].items, new_worry);
                }
            }

            monkey.items_processed += monkey.items.count;
            array_reset(*monkey.items);
        }
    }

    compare_monkeys :: (a: Monkey_Info, b: Monkey_Info) -> int {
        return b.items_processed - a.items_processed;
    }
    quick_sort(monkeys, compare_monkeys);

    final_value := monkeys[0].items_processed * monkeys[1].items_processed;
    print("monkey business value: %\n", final_value);
}
