const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const inputFile = try std.fs.cwd().openFile("input", .{});
    const input = try inputFile.reader().readAllAlloc(alloc, 10_000_000);
    inputFile.close();
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

        lowest = @min(lowest, cur);
    }

    std.debug.print("part 1: {}\n", .{lowest});

    var ranges = ArrayList(Range).init(alloc);
    defer ranges.deinit();

    var i: usize = 0;
    while (i < seeds.items.len) : (i += 2) {
        try ranges.append(Range.from_len(seeds.items[i], seeds.items[i + 1]));
    }

    for (mappings.items) |mapping| {
        var out = ArrayList(Range).init(alloc);
        for (ranges.items) |range| {
            try mapping.get_range(range, &out);
        }
        ranges.deinit();
        ranges = out;
    }

    lowest = std.math.maxInt(u64);

    for (ranges.items) |range| {
        lowest = @min(lowest, range.lo);
    }

    std.debug.print("part 2: {}\n", .{lowest});
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

const Range = struct {
    lo: u64,
    hi: u64,

    pub fn from_len(lo: u64, len: u64) Range {
        return .{
            .lo = lo,
            .hi = lo + len - 1,
        };
    }

    pub fn contains(self: Range, n: u64) bool {
        return self.lo <= n and n <= self.hi;
    }

    pub fn is_empty(self: Range) bool {
        return self.lo > self.hi;
    }

    pub fn intersect(self: Range, other: Range) ?Range {
        const out = Range{
            .lo = @max(self.lo, other.lo),
            .hi = @min(self.hi, other.hi),
        };

        if (out.is_empty()) {
            return null;
        } else {
            return out;
        }
    }
};

const Entry = struct {
    dst: u64,
    src: Range,

    pub fn apply(self: Entry, n: u64) ?u64 {
        if (self.src.contains(n)) {
            return n - self.src.lo + self.dst;
        }

        return null;
    }

    pub fn isBefore(_: void, a: Entry, b: Entry) bool {
        return a.src.lo < b.src.lo;
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
                .src = Range.from_len(nums.items[1], nums.items[2]),
            });
        }

        std.sort.pdq(Entry, entries.items, {}, Entry.isBefore);

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

    pub fn get_range(self: Mapping, range: Range, out: *ArrayList(Range)) !void {
        var leftover = range;
        for (self.entries.items) |entry| {
            if (entry.src.intersect(leftover)) |intersect| {
                try out.append(.{
                    .lo = entry.apply(intersect.lo) orelse unreachable,
                    .hi = entry.apply(intersect.hi) orelse unreachable,
                });

                if (leftover.lo < intersect.lo) {
                    try out.append(.{
                        .lo = leftover.lo,
                        .hi = intersect.lo - 1,
                    });
                }

                leftover.lo = intersect.hi + 1;
            }
        }

        if (!leftover.is_empty()) {
            try out.append(leftover);
        }
    }
};
