#import "Basic";
#import "String";
#import "File";

Position :: struct {
	x: int = 0;
	y: int = 0;
}

new_position :: (x: int, y: int) -> Position {
	p: Position;
	p.x = x;
	p.y = y;
	return p;
}

can_sand_move :: (sand_position: Position, path_points: [] Position) -> bool, Position {
	move_candidate := new_position(sand_position.x, sand_position.y + 1);
	is_valid := true;
	for p: path_points {
		if move_candidate.x == p.x && move_candidate.y == p.y {
			is_valid = false;
			break;
		}
	}
	
	if is_valid {
		return true, move_candidate;
	}
	
	move_candidate.x -= 1;
	is_valid = true;
	for p: path_points {
		if move_candidate.x == p.x && move_candidate.y == p.y {
			is_valid = false;
			break;
		}
	}
	
	if is_valid {
		return true, move_candidate;
	}
	
	move_candidate.x += 2;
	is_valid = true;
	for p: path_points {
		if move_candidate.x == p.x && move_candidate.y == p.y {
			is_valid = false;
			break;
		}
	}
	
	if is_valid {
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
	points: [..] Position;
	defer array_free(points);
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
					array_add(*points, current_position);
				}
			} else {
				start_x := min(p1.x, p2.x);
				end_x := max(p1.x, p2.x);
				for x: start_x..end_x {
					current_position.x = x;
					array_add(*points, current_position);
				}
			}
		}
	}
	
	bounds_min := new_position(999999, 9999999);
	bounds_max := new_position(-1, -1);
	for point : points {
		if point.x < bounds_min.x {
			bounds_min.x = point.x;
		}
		if point.y < bounds_min.y {
			bounds_min.y = point.y;
		}
		if point.x > bounds_max.x {
			bounds_max.x = point.x;
		}
		if point.y > bounds_max.y {
			bounds_max.y = point.y;
		}
	}
	
	// This is sand start position so it must be part of the map bounds even if there is
	// no path at this height.
	bounds_min.y = 0;
	
	sand_start_position := new_position(500, 0);
	current_sand_position := sand_start_position;
	units_processed := 0;
	is_processing := true;
	while is_processing {
		is_processing, current_sand_position = can_sand_move(current_sand_position, points);
		if !is_processing {
			array_add(*points, current_sand_position);
			units_processed += 1;
			current_sand_position = sand_start_position;
			is_processing = true;
		} else {
			if !is_within_map_bounds(current_sand_position, bounds_min, bounds_max) {
				is_processing = false;
			}
		}
	}
	
	print("units processed: %\n", units_processed);
}