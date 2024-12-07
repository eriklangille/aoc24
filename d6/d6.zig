const std = @import("std");
const input = @embedFile("./input.txt");

const Point = struct {
    x: i32,
    y: i32,
};

const directions = &[4]Point{
    .{ .x = 0, .y = -1 },
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = 1 },
    .{ .x = -1, .y = 0 },
};

pub inline fn valid(x: i32, y: i32, xlen: i32, ylen: i32) bool {
    return x >= 0 and y >= 0 and x < xlen and y < ylen;
}

pub fn main() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var list = std.ArrayList([]u8).init(alloc);
    defer list.deinit();
    var result: u32 = 1;

    var pos: Point = .{ .x = 0, .y = 0 };

    var y: usize = 0;
    var xlen: usize = 0;
    while (it.next()) |line| {
        xlen = line.len;
        const line_arr = try alloc.alloc(u8, xlen);
        for (0..xlen) |x| {
            switch (line[x]) {
                '.' => line_arr[x] = 0,
                '#' => line_arr[x] = 2,
                '^' => {
                    line_arr[x] = 1;
                    pos = .{ .x = @intCast(x), .y = @intCast(y) };
                },
                else => unreachable,
            }
        }
        try list.append(line_arr);
        y += 1;
    }

    var direction: usize = 0;
    while (true) {
        const add = directions[direction];
        const next: Point = .{ .x = pos.x + add.x, .y = pos.y + add.y };
        if (!valid(next.x, next.y, @intCast(xlen), @intCast(y))) {
            break;
        }
        const item: *u8 = &list.items[@intCast(next.y)][@intCast(next.x)];
        switch (item.*) {
            0 => {
                result += 1;
                item.* = 1;
                pos = next;
            },
            1 => pos = next,
            2 => {
                direction += 1;
                direction %= directions.len;
            },
            else => unreachable,
        }
    }

    std.debug.print("result: {d}\n", .{result});
}
