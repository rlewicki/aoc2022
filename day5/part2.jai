#import "Basic";
#import "File";
#import "String";

Stack :: struct {
    containers: [..] u8;
}

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    stacks: [..] Stack;
    defer {
        for stack : stacks {
            array_free(stack.containers);
        }

        array_free(stacks);
    }
    stacks_num := (data[0].count + 1) / 4;
    array_reserve(*stacks, stacks_num);
    for i: 0..stacks_num - 1 {
        new_stack := array_add(*stacks);
    }
    line_index := 0;
    while data[line_index].count != 0 {
        for i: 0..stacks_num - 1 {
            stack_index := 1 + i * 4;
            if stack_index < data[line_index].count {
                if is_digit(data[line_index][stack_index]) {
                    break;
                }

                if !is_space(data[line_index][stack_index]) {
                    array_add(*stacks[i].containers, data[line_index][stack_index]);
                }
            }
        }
        line_index += 1;
    }

    for stack : stacks  {
        half := cast(int)(cast(float)stack.containers.count / 2.0);
        for i: 0..half - 1 {
            temp := stack.containers[i];
            stack.containers[i] = stack.containers[stack.containers.count - 1 - i];
            stack.containers[stack.containers.count - 1 - i] = temp;
        }
    }

    line_index += 1;
    while line_index < data.count {
        if data[line_index].count == 0 {
            break;
        }

        instructions := split(data[line_index], " ");
        num := to_integer(instructions[1]);
        from := to_integer(instructions[3]) - 1;
        to := to_integer(instructions[5]) - 1;
        source_container := stacks[from].containers;
        for i: 0..num - 1 {
            array_add(*stacks[to].containers, source_container[source_container.count - num + i]);
        }
        
        array_resize(*stacks[from].containers, source_container.count - num);
        line_index += 1;
    }

    for stack : stacks {
        top_container := peek(stack.containers);
        print("%", to_string(*top_container, 1));
    }

    print("\n");
}