#import "Basic";
#import "String";
#import "File";
#import "Math";

Sensor_Info :: struct {
	x: int;
	y: int;
	range: int;
}

Range_Info :: struct {
    min: int;
    max: int;
}

main :: () {
	input := read_entire_file("input.txt");
    data := split(input, "\r\n");
	sensors: [..] Sensor_Info;
    beacons_horizontal_positions: [..] int;
	defer array_free(sensors);
    defer array_free(beacons_horizontal_positions);
	min_x := 9999999999;
	max_x := -9999999999;
    desired_y := 2_000_000;
	for line : data {
		if line.count == 0 {
			continue;
		}

		sensor: Sensor_Info;
        beacon_x: int;
        beacon_y: int;
		is_success := scan2(line, "Sensor at x=%, y=%: closest beacon is at x=%, y=%", *sensor.x, *sensor.y, *beacon_x, *beacon_y);
		if is_success {
			distance_x := abs(sensor.x - beacon_x);
			distance_y := abs(sensor.y - beacon_y);
			sensor.range = distance_x + distance_y;
			array_add(*sensors, sensor);
            if beacon_y ==  desired_y {
                array_add_if_unique(*beacons_horizontal_positions, beacon_x);
            }
			
			if beacon_x < min_x {
				min_x = beacon_x;
			}
			if sensor.x < min_x {
				min_x = sensor.x;
			}
			if beacon_x > max_x {
				max_x = beacon_x;
			}
			if sensor.x > max_x {
				max_x = sensor.x;
			}
		}
	}

	ranges: [..] Range_Info;
    defer array_free(ranges);
	for sensor : sensors {
		// print("checking sensor %\n", it_index);
		vertical_distance := abs(desired_y - sensor.y);
		// print("\tdistance to y: %, sensor range: %\n", vertical_distance, sensor.range);
		if vertical_distance <= sensor.range {
			horizontal_range := sensor.range - vertical_distance;
            range: Range_Info;
            range.min = sensor.x - horizontal_range;
            range.max = sensor.x + horizontal_range;
            array_add(*ranges, range);
		}
	}

    idx := 0;
    while ranges.count > 1 {
        j := 0;
        while j <= ranges.count-1 {
            if idx == j {
                j += 1;
            } 
            // case 1: --a----b--------x-----y-------
            // case 2: ---a---------x----b----------y
            // case 3: ---a-----------x------y-----b-
            else if ranges[idx].max < ranges[j].min {
                // case 1
                j += 1;
            } else if ranges[idx].max >= ranges[j].min && ranges[idx].max <= ranges[j].max && ranges[idx].min <= ranges[j].min {
                // case 2
                ranges[idx].max = ranges[j].max;
                array_ordered_remove_by_index(*ranges, j);
                break;
            } else if ranges[idx].min <= ranges[j].min && ranges[idx].max >= ranges[j].max {
                array_ordered_remove_by_index(*ranges, j);
                break;
            } else {
                j += 1;
            }
        }

        idx += 1;
        idx = idx % ranges.count;
    }

    invalid_positions := 0;
    for ranges {
        print("%: min=%, max=%\n", it_index, it.min, it.max);
        invalid_positions += (it.max - it.min + 1);
        for beacon_x : beacons_horizontal_positions {
            if beacon_x >= it.min && beacon_x <= it.max {
                invalid_positions -= 1;
            }
        }
    }

    print("invalid positions: %\n", invalid_positions);
}