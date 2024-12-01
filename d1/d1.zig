const std = @import("std");
const input = @embedFile("./input.txt");

pub fn main() !void {
    std.debug.print("hello advent of code\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var it = std.mem.tokenizeAny(u8, input, "\n ");

    var list1 = std.ArrayList(i32).init(alloc);
    var list2 = std.ArrayList(i32).init(alloc);

    var index: u32 = 0;
    while (it.next()) |token| {
        const number = try std.fmt.parseInt(i32, token, 10);
        switch (index % 2) {
            0 => try list1.append(number),
            1 => try list2.append(number),
            else => unreachable,
        }
        index += 1;
    }
    const buf1 = try list1.toOwnedSlice();
    const buf2 = try list2.toOwnedSlice();

    std.mem.sort(i32, buf1, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, buf2, {}, comptime std.sort.asc(i32));

    var total_distance: u64 = 0;

    for (buf1, buf2) |val1, val2| {
        const distance: i32 = val1 - val2;
        const abs_distance: u32 = @intCast(if (distance < 0) -1 * distance else distance);
        total_distance += abs_distance;
    }

    std.debug.print("total_distance {d}\n", .{total_distance});
}
