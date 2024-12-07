const std = @import("std");
const input = @embedFile("./input.txt");

const Point = struct {
    x: i32,
    y: i32,
};

const Pointing = struct {
    pos: Point,
    direction: usize,

    pub fn eql(self: Pointing, other: Pointing) bool {
        return self.pos.x == other.pos.x and self.pos.y == other.pos.y and self.direction == other.direction;
    }

    pub fn init(pos: Point) Pointing {
        return .{ .pos = .{ .x = pos.x, .y = pos.y }, .direction = 0 };
    }

    pub fn step(point: *Pointing, list: [][]u8) bool {
        const ylen = list.len;
        const xlen = list[0].len;
        const add = directions[point.direction];
        const next: Point = .{ .x = point.pos.x + add.x, .y = point.pos.y + add.y };
        if (!valid(next.x, next.y, @intCast(xlen), @intCast(ylen))) {
            // std.debug.print("point: x: {d} y: {d}, lenx: {d}, leny: {d}\n", .{ next.x, next.y, xlen, ylen });
            return false;
        }
        const item: *u8 = &list[@intCast(next.y)][@intCast(next.x)];
        switch (item.*) {
            0 => {
                point.pos = next;
            },
            2 => {
                point.direction += 1;
                point.direction %= directions.len;
            },
            else => unreachable,
        }
        return true;
    }
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
    var result: u32 = 0;

    var start: Point = .{ .x = 0, .y = 0 };

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
                    line_arr[x] = 0;
                    start = .{ .x = @intCast(x), .y = @intCast(y) };
                },
                else => unreachable,
            }
        }
        try list.append(line_arr);
        y += 1;
    }

    for (0..xlen) |x_pot| {
        for (0..y) |y_pot| {
            const potential: *u8 = &list.items[y_pot][x_pot];
            if (potential.* != 0) {
                continue;
            }
            var pos = Pointing.init(start);
            var slow_pos = Pointing.init(start);
            potential.* = 2;
            var i: u64 = 0;
            while (true) : (i += 1) {
                if (!pos.step(list.items)) break;
                if (!pos.step(list.items)) break;
                if (!slow_pos.step(list.items)) break;
                if (pos.eql(slow_pos)) {
                    result += 1;
                    break;
                }
            }
            potential.* = 0;
        }
    }

    std.debug.print("result: {d}\n", .{result});
}
