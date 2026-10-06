const std = @import("std");
const fifths = @import("fifths.zig");
const Key = @import("Key.zig");
const Mode = Key.Mode;

const Self = @This();

pub const Direction = enum { left, right, relative };

/// Creates `count` random questions.
/// Caller needs to free the memory.
pub fn createQuestionsAlloc(allocator: std.mem.Allocator, rng: std.Random, count: u8) ![]Self {
    var questions = try allocator.alloc(Self, count);
    errdefer allocator.free(questions);

    for (questions, 0..) |_, i| {
        questions[i] = Self.random(rng);
        if (i > 0) {
            while (questions[i].index == questions[i - 1].index) {
                questions[i] = Self.random(rng);
            }
        }
    }

    return questions;
}

index: u8,
direction: Direction,
mode: Mode,

pub fn random(rng: std.Random) Self {
    return .{
        .index = rng.intRangeAtMost(u8, 0, 11),
        .direction = rng.enumValue(Direction),
        .mode = rng.enumValue(Mode),
    };
}

pub fn answer(self: Self) Key {
    const index_signed: i8 = @intCast(self.index);
    const tonic = switch (self.direction) {
        .left => fifths.at(self.mode, index_signed - 1),
        .right => fifths.at(self.mode, index_signed + 1),
        .relative => fifths.relative(self.mode, index_signed),
    };
    const mode = switch (self.direction) {
        .left, .right => self.mode,
        .relative => self.mode.inverse(),
    };

    return Key{ .tonic = tonic, .mode = mode };
}

pub fn format(self: Self, w: *std.Io.Writer) std.Io.Writer.Error!void {
    const note = fifths.at(self.mode, @intCast(self.index));
    const key = Key{ .tonic = note, .mode = self.mode };

    try switch (self.direction) {
        .left, .right => w.print("What is the {s} neighbor to {f}", .{ @tagName(self.direction), key }),
        .relative => w.print("What is the relative {s} to {f}", .{ @tagName(self.mode.inverse()), key }),
    };
}

//
// Tests
//

test "answer: relative minor to C is Am" {
    const question = Self{
        .index = 0,
        .direction = .relative,
        .mode = .major,
    };
    const a = question.answer();
    const expected = Key{
        .tonic = .{ .letter = .A, .accidental = .natural },
        .mode = .minor,
    };
    try std.testing.expectEqual(expected, a);
}

test "answer: relative minor to E is C#m" {
    const question = Self{
        .index = 4,
        .direction = .relative,
        .mode = .major,
    };
    const a = question.answer();
    const expected = Key{
        .tonic = .{ .letter = .C, .accidental = .sharp },
        .mode = .minor,
    };
    try std.testing.expectEqual(expected, a);
}

test "answer: neighbors wrap around the circle" {
    const cases = [_]struct { Mode, u8, Direction, Key }{
        .{ .major, 0, .left, try Key.parse("F") },
        .{ .major, 0, .right, try Key.parse("G") },
        .{ .major, 11, .left, try Key.parse("Bb") },
        .{ .major, 11, .right, try Key.parse("C") },
        .{ .minor, 0, .left, try Key.parse("Dm") },
        .{ .minor, 0, .right, try Key.parse("Em") },
        .{ .minor, 11, .left, try Key.parse("Gm") },
        .{ .minor, 11, .right, try Key.parse("Am") },
    };
    for (cases) |case| {
        const mode, const index, const direction, const expected = case;
        errdefer std.debug.print("failed input: mode={s}, index={d}, direction={s}\n", .{ @tagName(mode), index, @tagName(direction) });
        const question = Self{ .index = index, .direction = direction, .mode = mode };
        try std.testing.expectEqual(expected, question.answer());
    }
}

test "answer: relative major of a minor key" {
    const cases = [_]struct { u8, Key }{
        .{ 0, try Key.parse("C") },
        .{ 7, try Key.parse("Db") },
        .{ 11, try Key.parse("F") },
    };
    for (cases) |case| {
        const index, const expected = case;
        errdefer std.debug.print("failed input: index={d}\n", .{index});
        const question = Self{ .index = index, .direction = .relative, .mode = .minor };
        try std.testing.expectEqual(expected, question.answer());
    }
}
