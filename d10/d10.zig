const std = @import("std");
const input = @embedFile("./input.txt");

const directions = &[4]Point{
    .{ .x = 0, .y = -1 },
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = 1 },
    .{ .x = -1, .y = 0 },
};

const Point = struct {
    x: i32,
    y: i32,

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

pub inline fn parseDigit(char: u8) u8 {
    return char - '0';
}

pub inline fn valid(pnt: Point, xlen: i32, ylen: i32) bool {
    return pnt.x >= 0 and pnt.y >= 0 and pnt.x < xlen and pnt.y < ylen;
}

const Set = std.AutoHashMap(Point, void);
const List = std.ArrayList([]u8);

pub fn dfs(cur: Point, visited: *Set, list: *List) !u32 {
    var count: u32 = 0;
    for (directions) |dir| {
        const val = list.items[@intCast(cur.y)][@intCast(cur.x)];
        const new = cur.add(dir);
        if (valid(new, @intCast(list.items[0].len), @intCast(list.items.len)) and !visited.contains(new)) {
            const new_val = list.items[@intCast(new.y)][@intCast(new.x)];
            if (new_val == val + 1) {
                if (new_val == 9) {
                    count += 1;
                }
                try visited.put(new, {});
                count += try dfs(new, visited, list);
            }
        }
    }
    return count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var it = std.mem.tokenizeScalar(u8, input, '\n');

    var list_y = std.ArrayList([]u8).init(alloc);
    defer {
        for (list_y.items) |item| {
            alloc.free(item);
        }
        list_y.deinit();
    }

    var result: u64 = 0;

    // find all 0s. DFS from each 0 to find the place where there is a 9. Keep track of visited.
    // add all 9s per trailhead up to get result.

    while (it.next()) |line| {
        const xlen = line.len;
        const ln = try alloc.alloc(u8, xlen);
        for (line, 0..) |char, i| {
            ln[i] = parseDigit(char);
        }
        try list_y.append(ln);
    }

    for (list_y.items, 0..) |line, y0| {
        for (line, 0..) |val, x0| {
            if (val == 0) {
                var visited: Set = std.AutoHashMap(Point, void).init(alloc);
                defer visited.deinit();
                result += try dfs(.{ .x = @intCast(x0), .y = @intCast(y0) }, &visited, &list_y);
            }
        }
    }

    std.debug.print("\nresult: {d}\n", .{result});
}
