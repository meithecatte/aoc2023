const std = @import("std");
const io = std.io;
const fs = std.fs;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const InputLines = struct {
    stdin: io.BufferedReader(4096, fs.File.Reader),
    buffer: ArrayList(u8),

    pub fn init(alloc: Allocator) InputLines {
        return .{
            .stdin = io.bufferedReader(io.getStdIn().reader()),
            .buffer = ArrayList(u8).init(alloc),
        };
    }

    pub fn next(self: *InputLines) !?[]u8 {
        self.buffer.clearRetainingCapacity();
        self.stdin.reader().streamUntilDelimiter(self.buffer.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => {
                return null;
            },
            else => return err,
        };

        return self.buffer.items;
    }

    pub fn deinit(self: *InputLines) void {
        self.buffer.deinit();
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = InputLines.init(allocator);
    defer lines.deinit();

    var score: u32 = 0;
    var win_counts = ArrayList(u32).init(allocator);

    while (try lines.next()) |line| {
        var parts = std.mem.splitAny(u8, line, ":|");
        _ = parts.next() orelse @panic("expected card number");
        const winning = parts.next() orelse @panic("expected winning list");
        const actual = parts.next() orelse @panic("expected actual list");

        var winning_set = try std.DynamicBitSet.initEmpty(allocator, 0);
        var winning_iter = std.mem.tokenizeScalar(u8, winning, ' ');

        while (winning_iter.next()) |num| {
            const n = try std.fmt.parseInt(usize, num, 10);

            if (n >= winning_set.unmanaged.bit_length) {
                try winning_set.resize(n + 1, false);
            }

            winning_set.set(n);
        }

        var actual_iter = std.mem.tokenizeScalar(u8, actual, ' ');
        var num_winning: u5 = 0;

        while (actual_iter.next()) |num| {
            const n = try std.fmt.parseInt(usize, num, 10);

            if (n < winning_set.unmanaged.bit_length and winning_set.isSet(n)) {
                num_winning += 1;
            }
        }

        score += (@as(u32, 1) << num_winning) >> 1;
        try win_counts.append(num_winning);
    }

    std.debug.print("part 1: {}\n", .{score});

    var copies = ArrayList(u32).init(allocator);
    try copies.resize(win_counts.items.len);
    @memset(copies.items, 1);

    var total: u32 = 0;

    for (win_counts.items, copies.items, 0..) |win, count, i| {
        total += count;
        for (copies.items[i + 1 .. i + 1 + win]) |*card| {
            card.* += count;
        }
    }

    std.debug.print("part 2: {}\n", .{total});
}
