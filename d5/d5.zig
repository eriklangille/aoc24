const std = @import("std");
const input = @embedFile("./input.txt");

var map = [_]u128{0} ** 100;

const bit_128: u128 = 1;
const bit_0_128: u128 = 0;

pub fn mark(num: u8, dep: u8) void {
    map[num] |= bit_128 << @truncate(dep);
}

pub fn remove(num: u8, dep: u8) void {
    map[num] &= bit_0_128 << @truncate(dep);
}

pub fn main() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    while (it.peek().?[2] == '|') {
        const line = it.next().?;
        var num_it = std.mem.tokenizeScalar(u8, line, '|');
        const first_token = num_it.next().?;
        const second_token = num_it.next().?;
        const first = try std.fmt.parseInt(u8, first_token, 10);
        const second = try std.fmt.parseInt(u8, second_token, 10);
        mark(second, first);
    }

    var result: u64 = 0;
    var line_count: u32 = 0;
    line_loop: while (it.next()) |line| {
        line_count += 1;
        var line_list = std.ArrayList(u8).init(alloc);
        defer line_list.deinit();
        var used: u128 = 0;

        var num_it = std.mem.tokenizeScalar(u8, line, ',');
        while (num_it.next()) |num_buf| {
            const num = try std.fmt.parseInt(u8, num_buf, 10);
            try line_list.append(num);
        }

        for (line_list.items) |num| {
            used |= bit_128 << @truncate(num);
            // std.debug.print("line: {d} num: {d}\n", .{ line_count, num });
            for (line_list.items) |i_num| {
                const i_7: u7 = @truncate(i_num);
                if (map[@intCast(num)] >> i_7 & bit_128 == bit_128) {
                    if ((used >> i_7) & bit_128 == bit_0_128) {
                        // std.debug.print("line: {d} not found: {d} for {d}\n", .{ line_count, i_num, num });
                        continue :line_loop;
                    }
                }
            }
        }
        result += line_list.items[line_list.items.len / 2];
    }

    std.debug.print("result: {d}\n", .{result});
}
