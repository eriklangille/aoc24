const std = @import("std");
const input = @embedFile("./input.txt");

const Point = struct {
    x: i32,
    y: i32,
};

const directions = &[8]Point{
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = 1 },
    .{ .x = -1, .y = 0 },
    .{ .x = 0, .y = -1 },
    .{ .x = 1, .y = 1 },
    .{ .x = -1, .y = -1 },
    .{ .x = -1, .y = 1 },
    .{ .x = 1, .y = -1 },
};

pub inline fn valid(x: i32, y: i32, xlen: i32, ylen: i32) bool {
    return x >= 0 and y >= 0 and x < xlen and y < ylen;
}

const mas = "MAS";

pub fn main() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var result: u64 = 0;

    var list_y = std.ArrayList([]const u8).init(alloc);
    defer list_y.deinit();

    while (it.next()) |token| {
        try list_y.append(token);
    }

    const ylen: usize = list_y.items.len;

    for (0..ylen) |y| {
        const xlen: usize = list_y.items[y].len;
        const y0: i32 = @intCast(y);
        for (0..xlen) |x| {
            const char: u8 = list_y.items[y][x];
            const x0: i32 = @intCast(x);
            if (char == 'X') {
                dir_loop: for (directions) |dir| {
                    var x1 = x0;
                    var y1 = y0;
                    for (mas) |mas_char| {
                        if (valid(x1 + dir.x, y1 + dir.y, @intCast(xlen), @intCast(ylen))) {
                            const xu: usize = @intCast(x1 + dir.x);
                            const yu: usize = @intCast(y1 + dir.y);
                            const next_char = list_y.items[yu][xu];
                            if (next_char != mas_char) {
                                continue :dir_loop;
                            }
                            x1 = x1 + dir.x;
                            y1 = y1 + dir.y;
                        } else {
                            continue :dir_loop;
                        }
                    }
                    result += 1;
                }
            }
        }
    }

    std.debug.print("result: {d}\n", .{result});
}
