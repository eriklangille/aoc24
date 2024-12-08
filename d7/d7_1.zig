const std = @import("std");
const input = @embedFile("./input.txt");

const bit_1: u32 = 1;
const bit_0: u32 = 0;

pub fn main() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var result: u64 = 0;
    var buf: [128]u8 = undefined;

    while (it.next()) |line| {
        var it_line = std.mem.tokenizeScalar(u8, line, ' ');
        const first_token = it_line.next().?;
        const ans = try std.fmt.parseInt(u64, first_token[0 .. first_token.len - 1], 10);

        var list = std.ArrayList(u64).init(alloc);
        defer list.deinit();
        while (it_line.next()) |token| {
            try list.append(try std.fmt.parseInt(u64, token, 10));
        }

        const options: u64 = std.math.pow(u64, 3, list.items.len - 1);
        var count: u32 = 0;
        while (count < options) : (count += 1) {
            var cur = list.items[0];
            var cursor = count;
            var i: u32 = 1;
            while (i < list.items.len) : (i += 1) {
                const op = cursor % 3;
                switch (op) {
                    1 => cur += list.items[i],
                    0 => cur *= list.items[i],
                    2 => {
                        const res = try std.fmt.bufPrint(&buf, "{d}{d}", .{ cur, list.items[i] });
                        cur = try std.fmt.parseInt(u64, res, 10);
                    },
                    else => unreachable,
                }
                if (cur > ans) {
                    break;
                }
                cursor /= 3;
            }
            if (cur == ans) {
                result += ans;
                break;
            }
        }
    }

    std.debug.print("result: {d}\n", .{result});
}
