#import "Basic";
#import "String";
#import "File";
#import "Math";

Sensor_Info :: struct {
	x: int;
	y: int;
	range: int;
}

Beacon_Info :: struct {
    x: int;
    y: int;
}

Range_Info :: struct {
    min: int;
    max: int;
    vertical_position: int;
}

Range_Bucket :: struct {
    ranges: [..] Range_Info;
}

get_max :: (a: int, b: int) -> int {
    if a > b {
        return a;
    }
    return b;
}

get_min :: (a: int, b: int) -> int {
    if a < b {
        return a;
    }
    return b;
}

main :: () {
	// input := read_entire_file("test_input.txt");
    input := read_entire_file("input.txt");
    data := split(input, "\r\n");
	sensors: [..] Sensor_Info;
    beacons: [..] Beacon_Info;
	defer array_free(sensors);
    defer array_free(beacons);
	min_x :: 0;
    min_y :: 0;
    max_x :: 4_000_000;
    max_y :: 4_000_000;
    // max_x :: 20;
    // max_y :: 20;
	for line : data {
		if line.count == 0 {
			continue;
		}

		sensor: Sensor_Info;
        beacon: Beacon_Info;
		is_success := scan2(line, "Sensor at x=%, y=%: closest beacon is at x=%, y=%", *sensor.x, *sensor.y, *beacon.x, *beacon.y);
		if is_success {
			distance_x := abs(sensor.x - beacon.x);
			distance_y := abs(sensor.y - beacon.y);
			sensor.range = distance_x + distance_y;
			array_add(*sensors, sensor);
            array_add(*beacons, beacon);
		}
	}

    range_buckets: [..] Range_Bucket;
    defer {
        for range_buckets {
            array_free(it.ranges);
        }
        array_free(range_buckets);
    }
    array_resize(*range_buckets, max_y + 1);

	for sensor : sensors {
		for y: sensor.y - sensor.range..sensor.y + sensor.range {
            if y < min_y || y > max_y {
                continue;
            }

            horizontal_range := sensor.range - abs(sensor.y - y);
            range: Range_Info;
            range.min = get_max(min_x, sensor.x - horizontal_range);
            range.min = get_min(range.min, max_x);
            range.max = get_max(min_x, sensor.x + horizontal_range);
            range.max = get_min(range.max, max_x);
            range.vertical_position = y;
            array_add(*range_buckets[y].ranges, range);
        }
	}

    for bucket : range_buckets  {
        idx := 0;
        min_iterations_to_verify := bucket.ranges.count * bucket.ranges.count;
        current_iteration := 0;
        while bucket.ranges.count > 1 {
            j := 0;
            while j <= bucket.ranges.count-1 {
                if idx == j {
                    j += 1;
                } 
                // case 1: --a----b--------x-----y-------
                // case 2: ---a---------x----b----------y
                // case 3: ---a-----------x------y-----b-
                else if bucket.ranges[idx].max < bucket.ranges[j].min {
                    // case 1
                    j += 1;
                } else if bucket.ranges[idx].max >= bucket.ranges[j].min 
                            && bucket.ranges[idx].max <= bucket.ranges[j].max 
                            && bucket.ranges[idx].min <= bucket.ranges[j].min {
                    // case 2
                    bucket.ranges[idx].max = bucket.ranges[j].max;
                    array_ordered_remove_by_index(*bucket.ranges, j);
                    current_iteration = 0;
                    min_iterations_to_verify = bucket.ranges.count * bucket.ranges.count;
                    break;
                } else if bucket.ranges[idx].min <= bucket.ranges[j].min && bucket.ranges[idx].max >= bucket.ranges[j].max {
                    array_ordered_remove_by_index(*bucket.ranges, j);
                    current_iteration = 0;
                    min_iterations_to_verify = bucket.ranges.count * bucket.ranges.count;
                    break;
                } else {
                    j += 1;
                }

                current_iteration += 1;
            }

            if current_iteration >= min_iterations_to_verify {
                if bucket.ranges.count == 2 {
                    target_y := bucket.ranges[0].vertical_position;
                    target_x: int = 0;
                    if bucket.ranges[0].max < bucket.ranges[1].min {
                        target_x = bucket.ranges[0].max + 1;
                    } else {
                        target_x = bucket.ranges[1].max + 1;
                    }
                    print("spot is at (%, %)\n", target_x, target_y);

                    freq :: 4_000_000;
                    solution := freq * target_x + target_y;
                    print("solution is %\n", solution);
                    return;
                }
            }

            idx += 1;
            idx = idx % bucket.ranges.count;
        }
    }
}