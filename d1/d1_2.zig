const std = @import("std");
const input = @embedFile("./input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var it = std.mem.tokenizeAny(u8, input, "\n ");

    var list1 = std.ArrayList(u32).init(alloc);
    var list2 = std.ArrayList(u32).init(alloc);
    var map = std.AutoHashMap(u32, u32).init(alloc);

    var index: u32 = 0;
    while (it.next()) |token| {
        const number = try std.fmt.parseInt(u32, token, 10);
        switch (index % 2) {
            0 => try list1.append(number),
            1 => try list2.append(number),
            else => unreachable,
        }
        index += 1;
    }
    const buf1 = try list1.toOwnedSlice();
    const buf2 = try list2.toOwnedSlice();

    var total_sim: u64 = 0;

    for (buf1) |val1| {
        try map.put(val1, 0);
    }

    for (buf2) |val2| {
        if (map.get(val2)) |count| {
            try map.put(val2, count + 1);
        }
    }

    var map_it = map.iterator();

    while (map_it.next()) |entry| {
        total_sim += (entry.key_ptr.*) * (entry.value_ptr.*);
    }

    std.debug.print("total_simularity {d}\n", .{total_sim});
}
