#import "Basic";
#import "File";
#import "String";
#import "Text_File_Handler";
#import "Hash_Table";
#import "Sort";

Directory_Info :: struct {
    path: string;
    dirs: [..] string;
    size: int = 0;
}

main :: () {
    h: Text_File_Handler;
    h.do_version_number = false;
    test_file := "input.txt";
    start_file(*h, test_file, test_file);
    current_path := "";
    directory_info: Table(string, Directory_Info);
    defer {
        for dir: directory_info {
            array_free(dir.dirs);
        }
        uninit(*directory_info);
    }
    line, found := consume_next_line(*h);
    while found {
        if begins_with(line, "$") {
            values := split(line, " ");
            command := values[1];
            if command == "cd" {
                parameter := values[2];
                if parameter == ".." {
                    current_path.count -= 1;
                    current_path = path_strip_filename(current_path);
                } else if parameter == "/" {
                    current_path = "/";
                } else {
                    builder: String_Builder;
                    init_string_builder(*builder);
                    append(*builder, current_path);
                    append(*builder, parameter);
                    append(*builder, "/");
                    current_path = builder_to_string(*builder);
                }
                if !table_find_pointer(*directory_info, current_path) {
                    new_info := Directory_Info.{};
                    new_info.path = current_path;
                    table_add(*directory_info, current_path, new_info);
                }
            }
        } else {
            // listing
            current_directory_info := table_find_pointer(*directory_info, current_path);
            values := split(line, " ");
            file_size := to_integer(values[0]);
            file_name := values[1];
            if file_size == 0 {
                // new directory
                builder: String_Builder;
                append(*builder, current_path);
                append(*builder, file_name);
                append(*builder, "/");
                new_file_path := builder_to_string(*builder);
                array_add(*current_directory_info.dirs, new_file_path);
            } else {
                // file
                current_directory_info.size += file_size;
            }
        }

        line, found = consume_next_line(*h);
    }

    get_dir_sum :: (directory_info: *Table, dir: string) -> int {
        dir_info, success := table_find(directory_info, dir);
        if !success {
            return 0;
        }

        if dir_info.dirs.count == 0 {
            return dir_info.size;
        } else {
            size := dir_info.size;
            for sub_dir: dir_info.dirs {
                size += get_dir_sum(directory_info, sub_dir);
            }
            return size;
        }

    }

    DISK_SPACE :: 70_000_000;
    REQUIRED_SPACE :: 30_000_000;
    free_space := DISK_SPACE - get_dir_sum(*directory_info, "/");
    min_memory_free := REQUIRED_SPACE - free_space;

    dir_candidates: [..] int;
    defer array_free(dir_candidates);
    for entry: directory_info {
        size := get_dir_sum(*directory_info, entry.path);
        if size >= min_memory_free {
            array_add(*dir_candidates, size);
        }   
    }

    min_size_dir := dir_candidates[0];
    for candidate: dir_candidates {
        if candidate < min_size_dir {
            min_size_dir = candidate;
        }
    }

    print("minimum size directory: %\n", min_size_dir);
}