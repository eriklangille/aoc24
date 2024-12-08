const std = @import("std");
const input = @embedFile("./input.txt");

const Point = struct {
    x: i32,
    y: i32,

    pub fn distance(self: Point, other: Point) Point {
        return .{
            .x = self.x - other.x,
            .y = self.y - other.y,
        };
    }

    pub fn invert(self: Point) Point {
        return .{
            .x = -self.x,
            .y = -self.y,
        };
    }

    pub fn add(self: Point, other: Point) Point {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }

    pub fn eql(self: Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }

    pub fn hash(self: Point) u64 {
        return @as(u64, @bitCast(self.x)) << 32 | @as(u64, @bitCast(self.y));
    }
};

const Antenna = struct {
    loc: Point,
    char: u8,
};

pub inline fn abs_dis(a: i32, b: i32) i32 {
    const diff = a - b;
    return if (diff > 0) diff else -diff;
}

pub inline fn valid(x: i32, y: i32, xlen: i32, ylen: i32) bool {
    return x >= 0 and y >= 0 and x < xlen and y < ylen;
}

// we care about unique antinode locations!

pub fn main() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var list = std.MultiArrayList(Antenna){};
    defer list.deinit(alloc);

    var antinodes = std.AutoHashMap(Point, void).init(alloc);
    defer antinodes.deinit();

    var result: u32 = 0;

    var y: usize = 0;
    var xlen: usize = 0;
    while (it.next()) |line| {
        xlen = line.len;
        for (0..xlen) |x| {
            switch (line[x]) {
                '.' => {},
                '#' => {},
                else => {
                    try list.append(alloc, .{
                        .char = line[x],
                        .loc = .{
                            .x = @intCast(x),
                            .y = @intCast(y),
                        },
                    });
                },
            }
        }
        y += 1;
    }

    std.debug.print("xlen: {d} ylen: {d}\n", .{ xlen, y });

    var cnt: u32 = 0;
    for (0..list.len) |i| {
        const first = list.get(i);
        for (i + 1..list.len) |j| {
            const second = list.get(j);
            if (first.char == second.char) {
                const dist = first.loc.distance(second.loc);
                const antinode = first.loc.add(dist);
                if (valid(antinode.x, antinode.y, @intCast(xlen), @intCast(y))) {
                    cnt += 1;
                    try antinodes.put(antinode, {});
                }
                const antinode2 = second.loc.add(dist.invert());
                if (valid(antinode2.x, antinode2.y, @intCast(xlen), @intCast(y))) {
                    cnt += 1;
                    try antinodes.put(antinode2, {});
                }
            }
        }
    }

    var keys = antinodes.keyIterator();
    while (keys.next()) |key| {
        _ = key;
        // std.debug.print("antinode: ({d}, {d})\n", .{ key.x, key.y });
        result += 1;
    }

    std.debug.print("result: {d}, cnt: {d}\n", .{ result, cnt });
    for (0..y) |y0| {
        for (0..xlen) |x0| {
            const antinode = antinodes.getKey(.{ .x = @intCast(x0), .y = @intCast(y0) });
            if (antinode != null) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}
