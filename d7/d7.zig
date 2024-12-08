const std = @import("std");
const input = @embedFile("./input.txt");

const bit_1: u32 = 1;
const bit_0: u32 = 0;

pub fn main() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var result: u64 = 0;

    while (it.next()) |line| {
        var it_line = std.mem.tokenizeScalar(u8, line, ' ');
        const first_token = it_line.next().?;
        const ans = try std.fmt.parseInt(u64, first_token[0 .. first_token.len - 1], 10);

        var list = std.ArrayList(u64).init(alloc);
        defer list.deinit();
        while (it_line.next()) |token| {
            try list.append(try std.fmt.parseInt(u64, token, 10));
        }

        const bits = list.items.len - 1;
        var count: u32 = 0;
        while (count >> @intCast(bits) & bit_1 == bit_0) : (count += 1) {
            var cur = list.items[0];
            for (0..bits) |i| {
                const op = count >> @intCast(i) & bit_1 == bit_1;
                switch (op) {
                    false => cur += list.items[i + 1],
                    true => cur *= list.items[i + 1],
                }
                if (cur > ans) {
                    break;
                }
            }
            if (cur == ans) {
                result += ans;
                break;
            }
        }
    }

    std.debug.print("result: {d}\n", .{result});
}
