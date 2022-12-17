#import "Basic";
#import "File";
#import "String";
#import "Sort";
#import "Math";
#import "Hash_Table";
#import "Hash";

Position :: struct {
    x: int;
    y: int;
}

Node_Info :: struct {
    position: Position;
    height: u8 = 0;
}

get_hash :: (node: Node_Info) -> u32 {
    hash := get_hash(node.height);
    hash = get_hash(node.position.x, hash);
    hash = get_hash(node.position.y, hash);
    return hash;
}

main :: () {
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
    nodes: [..] Node_Info;
    defer array_free(nodes);
    start_nodes: [..] Node_Info;
    defer array_free(start_nodes);
    goal_node: Node_Info;
    map_width := data[0].count;
    map_height := data.count - 1;
    for y: 0..data.count-1 {
        if data[y].count == 0 {
            continue;
        }

        for x: 0..data[y].count-1 {
            new_node: Node_Info;
            new_node.position.x = x;
            new_node.position.y = y;

            if data[y][x] == #char "S" {
                new_node.height = #char "a";
                array_add(*start_nodes, new_node);
            } else if data[y][x] == #char "E" {
                new_node.height = #char "z";
                goal_node.height = #char "z";
                goal_node.position.x = x;
                goal_node.position.y = y;
            } else if data[y][x] == #char "a" {
                new_node.height = data[y][x];
                array_add(*start_nodes, new_node);
            } else {
                new_node.height = data[y][x];
            }

            array_add(*nodes, new_node);
        }
    }

    get_neighbors_positions :: (node: Node_Info) -> [] Position {
        neighbors_position := NewArray(4, Position, initialized = false);
        neighbors_position[0].x = node.position.x - 1;
        neighbors_position[0].y = node.position.y;
        neighbors_position[1].x = node.position.x + 1;
        neighbors_position[1].y = node.position.y;
        neighbors_position[2].x = node.position.x;
        neighbors_position[2].y = node.position.y - 1;
        neighbors_position[3].x = node.position.x;
        neighbors_position[3].y = node.position.y + 1;
        return neighbors_position;
    }

    is_node_in_array :: (node: Node_Info, nodes: [] Node_Info) -> bool {
        for n : nodes {
            if n.position.x == node.position.x && n.position.y == node.position.y {
                return true;
            }
        }

        return false;
    }

    node_compare_function :: (a: Node_Info, b: Node_Info) -> bool {
        return a.position.x == b.position.x && a.position.y == b.position.y;
    }

    heuristic :: (a: Node_Info,  b: Node_Info) -> int {
        x := abs(a.position.x - b.position.x);
        y := abs(a.position.y - b.position.y);
        return x + y;
    }

    path_lenghts: [..] int;
    defer array_free(path_lenghts);
    for start_node : start_nodes {
        open_nodes: [..] Node_Info;
        defer array_free(open_nodes);
        array_add(*open_nodes, start_node);

        came_from: Table(
            Node_Info, 
            Node_Info, 
            given_hash_function=get_hash, 
            given_compare_function=node_compare_function
        );
        defer uninit(*came_from);
        g_score: Table(
            Node_Info,
            int,
            given_hash_function=get_hash,
            given_compare_function=node_compare_function
        );
        defer uninit(*g_score);
        f_score: Table(
            Node_Info,
            int,
            given_hash_function=get_hash,
            given_compare_function=node_compare_function
        );
        defer uninit(*f_score);

        table_set(*g_score, start_node, 0);
        table_set(*f_score, start_node, heuristic(start_node, goal_node));

        iterations := 0;
        while open_nodes.count > 0 {
            iterations += 1;
            lowest_cost := <<table_find_pointer(*f_score, open_nodes[0]);
            current_node := open_nodes[0];
            node_idx := 0;
            for node : open_nodes {
                c := table_find_pointer(*f_score, node);
                if <<c < lowest_cost { 
                    lowest_cost = <<c;
                    current_node = node;
                    node_idx = it_index;
                }
            }

            if node_compare_function(current_node, goal_node) {
                path_length := 0;
                node := *current_node;
                while node {
                    path_length += 1;
                    node = table_find_pointer(*came_from, <<node);
                }
                array_add(*path_lenghts, path_length - 1);
                break;
            }

            array_unordered_remove_by_index(*open_nodes, node_idx);

            for pos : get_neighbors_positions(current_node) {
                if pos.x < 0 || pos.y < 0 || pos.x >= map_width || pos.y >= map_height {
                    continue;
                }

                neighbor_node := nodes[pos.y * map_width + pos.x];
                height_diff := cast(int)neighbor_node.height - cast(int)current_node.height;
                if height_diff > 1 {
                    continue;
                }

                current_node_g_score, a_success := table_find(*g_score, current_node);
                if !a_success {
                    print("g_score not present, something has gone wrong!\n");
                    continue;
                }

                tentative_g_score := current_node_g_score + 1;
                neighbor_g_score, b_success := table_find(*g_score, neighbor_node);
                if !b_success || tentative_g_score < neighbor_g_score {
                    table_set(*g_score, neighbor_node, tentative_g_score);
                    table_set(*came_from, neighbor_node, current_node);
                    table_set(*f_score, neighbor_node, tentative_g_score + heuristic(neighbor_node, goal_node));
                    if !is_node_in_array(neighbor_node, open_nodes) {
                        array_add(*open_nodes, neighbor_node);
                    }
                }
            }
        }
    }

    shortest_path := path_lenghts[0];
    print("found % paths:\n", path_lenghts.count);
    for path_lenghts {
        print("path % is % long\n", it_index, it);
        if it < shortest_path {
            shortest_path = it;
        }
    }
    print("shortest path is %\n", shortest_path);
}
