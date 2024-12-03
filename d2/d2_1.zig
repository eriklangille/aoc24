const std = @import("std");
const input = @embedFile("./input.txt");

pub fn pass(buf: []i32) bool {
    var inc: bool = false;
    for (1..buf.len) |i| {
        const prev = buf[i - 1];
        const cur = buf[i];
        const diff: i32 = prev - cur;
        const neg: bool = diff < 0;
        if (i == 1) {
            inc = !neg;
        }
        const abs: i32 = if (diff > 0) diff else -diff;
        if (abs == 0 or abs > 3 or inc == neg) {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    var line = std.mem.tokenizeScalar(u8, input, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var count: u32 = 0;
    while (line.next()) |line_str| {
        var it = std.mem.tokenizeScalar(u8, line_str, ' ');

        var line_list = std.ArrayList(i32).init(alloc);
        defer line_list.deinit();

        while (it.next()) |token| {
            try line_list.append(try std.fmt.parseInt(u8, token, 10));
        }
        if (pass(line_list.items)) {
            count += 1;
        } else {
            for (0..line_list.items.len) |i| {
                const pop = line_list.orderedRemove(i);
                if (pass(line_list.items)) {
                    count += 1;
                    break;
                }
                try line_list.insert(i, pop);
            }
        }
    }
    std.debug.print("result: {d}\n", .{count});
}
