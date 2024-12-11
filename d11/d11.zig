const std = @import("std");
const input = @embedFile("./input.txt");

pub inline fn parseDigit(char: u8) u8 {
    return char - '0';
}

const Stone = struct {
    total_mem: []u8,
    mem: []u8,
    num: u64,

    pub fn init(alloc: std.mem.Allocator, buf: []const u8) !Stone {
        var total_mem = try alloc.alloc(u8, 16);
        @memcpy(total_mem[0..buf.len], buf);
        const mem = total_mem[0..buf.len];
        const num = try std.fmt.parseInt(u64, buf, 10);
        return .{
            .total_mem = total_mem,
            .mem = mem,
            .num = num,
        };
    }

    pub fn blink(self: *Stone, alloc: std.mem.Allocator) !?Stone {
        if (self.num == 0) {
            self.num = 1;
            self.mem[0] = '1';
            return null;
        }
        if (self.mem.len % 2 == 0) {
            const split: usize = self.mem.len / 2;
            const left = self.mem[0..split];
            var right = self.mem[split..self.mem.len];
            var i: usize = 0;
            while (i < right.len - 1 and right[i] == '0') : (i += 1) {}
            right = right[i..right.len];
            const num = try std.fmt.parseInt(u64, left, 10);
            const right_stone = try Stone.init(alloc, right);
            self.mem = left;
            self.num = num;
            return right_stone;
        }
        self.num *= 2024;
        self.mem = try std.fmt.bufPrint(self.total_mem, "{d}", .{self.num});
        return null;
    }

    pub fn deinit(self: *const Stone, alloc: std.mem.Allocator) void {
        alloc.free(self.total_mem);
    }
};

const List = std.ArrayList(Stone);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var it = std.mem.tokenizeAny(u8, input, " \n");

    var list = List.init(alloc);
    defer {
        for (list.items) |item| {
            item.deinit(alloc);
        }
        list.deinit();
    }

    while (it.next()) |token| {
        try list.append(try Stone.init(alloc, token));
    }

    const total_blinks = 25;

    var index: u64 = 0;
    while (index < total_blinks) : (index += 1) {
        var i: u64 = 0;
        while (i < list.items.len) : (i += 1) {
            var stone = list.items[i];
            const right_stone = try stone.blink(alloc);
            list.items[i] = stone;
            if (right_stone) |new_stone| {
                try list.insert(i + 1, new_stone);
                i += 1;
            }
        }
    }

    const result = list.items.len;

    std.debug.print("\nresult: {d}\n", .{result});
}
