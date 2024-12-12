const std = @import("std");
const input = @embedFile("./input.txt");

pub fn blink(num: u64) struct { a: u64, b: ?u64 } {
    if (num == 0) {
        return .{ .a = 1, .b = null };
    }
    var check_num: u64 = num;
    var div_rem_num: u64 = 1;
    var count: usize = 0;
    while (check_num != 0) : (count += 1) {
        check_num /= 10;
        if (count % 2 == 0) {
            div_rem_num *= 10;
        }
    }
    if (count % 2 == 0) {
        const left: u64 = num / div_rem_num;
        const right: u64 = num % div_rem_num;
        return .{ .a = left, .b = right };
    }
    return .{ .a = num * 2024, .b = null };
}

const Map = std.AutoHashMap(u64, u64);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var it = std.mem.tokenizeAny(u8, input, " \n");

    var set = Map.init(alloc);

    while (it.next()) |token| {
        const num = try std.fmt.parseInt(u64, token, 10);
        const val = set.get(num);
        if (val) |count| {
            try set.put(num, count + 1);
        } else {
            try set.put(num, 1);
        }
    }

    const total_blinks = 75;

    var cur_set = set;
    var index: u64 = 0;
    while (index < total_blinks) : (index += 1) {
        var new_set = Map.init(alloc);
        var set_it = cur_set.iterator();
        while (set_it.next()) |item| {
            const res = blink(item.key_ptr.*);
            const val = new_set.get(res.a);
            if (val) |count| {
                try new_set.put(res.a, count + item.value_ptr.*);
            } else {
                try new_set.put(res.a, item.value_ptr.*);
            }
            if (res.b) |new_val| {
                const val2 = new_set.get(new_val);
                if (val2) |count| {
                    try new_set.put(new_val, count + item.value_ptr.*);
                } else {
                    try new_set.put(new_val, item.value_ptr.*);
                }
            }
        }
        cur_set.deinit();
        cur_set = new_set;
    }

    var set_it = cur_set.iterator();
    var result: u64 = 0;
    while (set_it.next()) |entry| {
        result += entry.value_ptr.*;
    }

    std.debug.print("\nresult: {d}\n", .{result});
}
