const std = @import("std");
const input = @embedFile("./input.txt");

pub fn main() !void {
    var line = std.mem.tokenizeScalar(u8, input, '\n');

    var count: u32 = 0;
    while (line.next()) |line_str| {
        var it = std.mem.tokenizeScalar(u8, line_str, ' ');
        var increasing: ?bool = null;
        var prev_token_opt = it.next();
        while (prev_token_opt) |prev_token| {
            const cur_token_opt = it.next();
            if (cur_token_opt) |cur_token| {
                const prev_number = try std.fmt.parseInt(i32, prev_token, 10);
                const cur_number = try std.fmt.parseInt(i32, cur_token, 10);
                const diff: i32 = prev_number - cur_number;
                const neg: bool = diff < 0;
                const abs: i32 = if (diff > 0) diff else -diff;
                if (abs == 0 or abs > 3) {
                    break;
                }
                if (increasing != null and increasing.? == neg) {
                    break;
                }
                increasing = !neg;
                if (it.peek() == null) {
                    count += 1;
                    break;
                }
            }
            prev_token_opt = cur_token_opt;
        }
    }
    std.debug.print("result: {d}\n", .{count});
}
