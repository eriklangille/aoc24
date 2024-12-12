const std = @import("std");
const input = @embedFile("./input.txt");

const directions = &[4]Point{
    .{ .x = 0, .y = -1 },
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = 1 },
    .{ .x = -1, .y = 0 },
};

const directions2 = &[2]Point{
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = 1 },
};

const PointTuple = struct {
    p1: Point,
    p2: Point,

    pub fn eql(self: PointTuple, other: PointTuple) bool {
        return self.p1.eql(other.p1) and self.p2.eql(other.p2);
    }

    pub fn hash(self: PointTuple) u64 {
        return self.p1 ^ self.p2;
    }
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

pub inline fn valid(pnt: Point, xlen: i32, ylen: i32) bool {
    return pnt.x >= 0 and pnt.y >= 0 and pnt.x < xlen and pnt.y < ylen;
}

const Set = std.AutoHashMap(Point, void);
const TupleSet = std.AutoHashMap(PointTuple, void);
const List = std.ArrayList([]u8);

pub fn dfs(cur: Point, visited: *Set, per: *TupleSet, list: *List) !u64 {
    var area: u64 = 1;
    for (directions) |dir| {
        const val = list.items[@intCast(cur.y)][@intCast(cur.x)];
        const new = cur.add(dir);
        const xlen: i32 = @intCast(list.items[0].len);
        const ylen: i32 = @intCast(list.items.len);
        if (valid(new, xlen, ylen)) {
            const new_val = list.items[@intCast(new.y)][@intCast(new.x)];
            if (new_val == val and !visited.contains(new)) {
                try visited.put(new, {});
                area += try dfs(new, visited, per, list);
            } else if (new_val != val) {
                try per.put(.{ .p1 = cur, .p2 = new }, {});
            }
        } else {
            try per.put(.{ .p1 = cur, .p2 = new }, {});
        }
    }
    return area;
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
            ln[i] = char;
        }
        try list_y.append(ln);
    }

    var visited: Set = Set.init(alloc);
    defer visited.deinit();
    for (list_y.items, 0..) |line, y0| {
        for (line, 0..) |val, x0| {
            const pnt: Point = .{ .x = @intCast(x0), .y = @intCast(y0) };
            if (visited.contains(pnt)) continue;
            try visited.put(pnt, {});
            var per: TupleSet = TupleSet.init(alloc);
            defer per.deinit();

            const area = try dfs(pnt, &visited, &per, &list_y);

            var per_it = per.keyIterator();
            var sides: u64 = 0;
            while (per_it.next()) |key| {
                var contains: bool = false;
                for (directions2) |dir| {
                    const new1 = key.p1.add(dir);
                    const new2 = key.p2.add(dir);
                    if (per.contains(.{ .p1 = new1, .p2 = new2 })) {
                        contains = true;
                    }
                }
                if (!contains) {
                    sides += 1;
                }
            }
            std.debug.print("{c}: area {d}, sides {d}\n", .{ val, area, sides });
            result += area * sides;
        }
    }

    std.debug.print("\nresult: {d}\n", .{result});
}
