const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const inputFile = try std.fs.cwd().openFile("input", .{});
    defer inputFile.close();

    const input = try inputFile.reader().readAllAlloc(alloc, 10_000_000);
    defer alloc.free(input);

    var input_parts = std.mem.splitSequence(u8, input, "\n\n");
    const seeds_line = input_parts.next() orelse @panic("what");
    const seeds = try parseLine(alloc, skipDescr(seeds_line));
    defer seeds.deinit();

    var mappings = ArrayList(Mapping).init(alloc);
    defer mappings.deinit();

    while (input_parts.next()) |part| {
        try mappings.append(try Mapping.parse(alloc, skipDescr(part)));
    }

    defer for (mappings.items) |mapping| {
        mapping.deinit();
    };

    var lowest: u64 = std.math.maxInt(u64);

    for (seeds.items) |seed| {
        var cur = seed;
        for (mappings.items) |mapping| {
            cur = mapping.get(cur);
        }

        std.debug.print("{} -> {}\n", .{ seed, cur });
        lowest = @min(lowest, cur);
    }

    std.debug.print("part 1: {}\n", .{lowest});
}

fn skipDescr(part: []const u8) []const u8 {
    const where = std.mem.indexOfScalar(u8, part, ':') orelse return part;
    return part[where + 1 ..];
}

fn parseLine(alloc: Allocator, line: []const u8) !ArrayList(u64) {
    var out = ArrayList(u64).init(alloc);
    var nums = std.mem.tokenizeScalar(u8, line, ' ');
    while (nums.next()) |num| {
        const n = try std.fmt.parseInt(u64, num, 10);
        try out.append(n);
    }

    return out;
}

const Entry = struct {
    dst: u64,
    src: u64,
    len: u64,

    pub fn apply(self: Entry, n: u64) ?u64 {
        if (self.src <= n and n < self.src + self.len) {
            return n - self.src + self.dst;
        }

        return null;
    }
};

const Mapping = struct {
    entries: ArrayList(Entry),

    pub fn parse(alloc: Allocator, input: []const u8) !Mapping {
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        var entries = ArrayList(Entry).init(alloc);
        while (lines.next()) |line| {
            const nums = try parseLine(alloc, line);
            defer nums.deinit();

            if (nums.items.len != 3) {
                @panic("malformed input");
            }

            try entries.append(.{
                .dst = nums.items[0],
                .src = nums.items[1],
                .len = nums.items[2],
            });
        }

        return .{ .entries = entries };
    }

    pub fn deinit(self: Mapping) void {
        self.entries.deinit();
    }

    pub fn get(self: Mapping, n: u64) u64 {
        for (self.entries.items) |entry| {
            return entry.apply(n) orelse continue;
        }

        return n;
    }
};
