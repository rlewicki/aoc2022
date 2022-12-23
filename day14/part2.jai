#import "Basic";
#import "String";
#import "File";
#import "Hash_Table";
#import "Hash";

Position :: struct {
	x: int = 0;
	y: int = 0;
}

get_hash :: (p: Position) -> u32 {
	hash := get_hash(p.x);
	hash = get_hash(p.y, hash);
	return hash;
}

new_position :: (x: int, y: int) -> Position {
	p: Position;
	p.x = x;
	p.y = y;
	return p;
}

position_equals :: (a: Position, b: Position) -> bool {
	return a.x == b.x && a.y == b.y;
}

can_sand_move :: (sand_position: Position, points: Table, floor_height: int) -> bool, Position {
	move_candidate := new_position(sand_position.x, sand_position.y + 1);
	
	if move_candidate.y == floor_height {
		return false, sand_position;
	}
	
	tmp := false;
	is_occupied := false;
	tmp, is_occupied = table_find(*points, move_candidate);
	if !is_occupied {
		return true, move_candidate;
	}
	
	move_candidate.x -= 1;
	tmp, is_occupied = table_find(*points, move_candidate);
	if !is_occupied {
		return true, move_candidate;
	}
	
	move_candidate.x += 2;
	tmp, is_occupied = table_find(*points, move_candidate);
	if !is_occupied {
		return true, move_candidate;
	}
	
	return false, sand_position;
}

is_within_map_bounds :: (p: Position, bounds_min: Position, bounds_max: Position) -> bool {
	return p.x >= bounds_min.x && p.y >= bounds_min.y && p.x <= bounds_max.x && p.y <= bounds_max.y;
}

max :: (a: int, b: int) -> int {
	if a > b {
		return a;
	}
	return b;
}

min :: (a: int, b: int) -> int {
	if a < b {
		return a;
	}
	return b;
}

main :: () {
	input := read_entire_file("input.txt");
    data := split(input, "\r\n");
	points: Table(
		Position, 
		bool, 
		given_hash_function=get_hash, 
		given_compare_function=position_equals);
	defer uninit(*points);
	for path : data {
		path_points := split(path, " -> ");
		for i: 0..path_points.count - 2 {
			p1_coordinates := split(path_points[i], ",");
			p2_coordinates := split(path_points[i+1], ",");
			p1 := new_position(to_integer(p1_coordinates[0]), to_integer(p1_coordinates[1]));
			p2 := new_position(to_integer(p2_coordinates[0]), to_integer(p2_coordinates[1]));
			current_position := p1;
			if p1.x == p2.x {
				start_y := min(p1.y, p2.y);
				end_y := max(p1.y, p2.y);
				for y: start_y..end_y {
					current_position.y = y;
					table_set(*points, current_position, true);
				}
			} else {
				start_x := min(p1.x, p2.x);
				end_x := max(p1.x, p2.x);
				for x: start_x..end_x {
					current_position.x = x;
					table_set(*points, current_position, true);
				}
			}
		}
	}
	
	bounds_min := new_position(999999, 9999999);
	bounds_max := new_position(-1, -1);
	for points {
		if it_index.x < bounds_min.x {
			bounds_min.x = it_index.x;
		}
		if it_index.y < bounds_min.y {
			bounds_min.y = it_index.y;
		}
		if it_index.x > bounds_max.x {
			bounds_max.x = it_index.x;
		}
		if it_index.y > bounds_max.y {
			bounds_max.y = it_index.y;
		}
	}
	
	// This is sand start position so it must be part of the map bounds even if there is
	// no path at this height.
	bounds_min.y = 0;
	bounds_max.y += 2;
	
	sand_start_position := new_position(500, 0);
	current_sand_position := sand_start_position;
	units_processed := 0;
	is_processing := true;
	while is_processing {
		is_processing, current_sand_position = can_sand_move(current_sand_position, points, bounds_max.y);
		if !is_processing {
			units_processed += 1;
			if 	current_sand_position.x != sand_start_position.x 
				|| current_sand_position.y != sand_start_position.y {			
				table_set(*points, current_sand_position, true);
				current_sand_position = sand_start_position;
				is_processing = true;
			}
		}
	}
	
	print("units processed: %\n", units_processed);
}