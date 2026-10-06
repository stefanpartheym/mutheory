const std = @import("std");
const Note = @import("Note.zig");
const Mode = @import("Key.zig").Mode;

const Circle = [12]Note;

/// Tonics of the major keys around the circle of fifths, clockwise from C.
/// Enharmonic positions use B, F♯ and D♭.
pub const majors = Circle{
    .{ .letter = .C, .accidental = .natural },
    .{ .letter = .G, .accidental = .natural },
    .{ .letter = .D, .accidental = .natural },
    .{ .letter = .A, .accidental = .natural },
    .{ .letter = .E, .accidental = .natural },
    .{ .letter = .B, .accidental = .natural },
    .{ .letter = .F, .accidental = .sharp },
    .{ .letter = .D, .accidental = .flat },
    .{ .letter = .A, .accidental = .flat },
    .{ .letter = .E, .accidental = .flat },
    .{ .letter = .B, .accidental = .flat },
    .{ .letter = .F, .accidental = .natural },
};

/// Tonics of the minor keys around the circle of fifths, clockwise from A.
/// Enharmonic positions use G♯, D♯ and B♭.
pub const minors = Circle{
    .{ .letter = .A, .accidental = .natural },
    .{ .letter = .E, .accidental = .natural },
    .{ .letter = .B, .accidental = .natural },
    .{ .letter = .F, .accidental = .sharp },
    .{ .letter = .C, .accidental = .sharp },
    .{ .letter = .G, .accidental = .sharp },
    .{ .letter = .D, .accidental = .sharp },
    .{ .letter = .B, .accidental = .flat },
    .{ .letter = .F, .accidental = .natural },
    .{ .letter = .C, .accidental = .natural },
    .{ .letter = .G, .accidental = .natural },
    .{ .letter = .D, .accidental = .natural },
};

pub fn byMode(mode: Mode) Circle {
    return switch (mode) {
        .major => majors,
        .minor => minors,
    };
}

/// Returns the key at the given index in the circle.
/// Allows negative indices.
pub fn at(mode: Mode, index: i8) Note {
    return byMode(mode)[@intCast(@mod(index, 12))];
}

/// Returns the relative key at the given index in the circle.
/// Allows negative indices.
pub fn relative(mode: Mode, index: i8) Note {
    return at(mode.inverse(), index);
}

pub fn print(writer: *std.Io.Writer) std.Io.Writer.Error!void {
    try writer.print("Fifths:\n", .{});
    try writer.print("  Majors:\n", .{});
    for (majors, 0..) |major, i| {
        try writer.print("    {d:2}: {s}\n", .{ i, major.name() });
    }
    try writer.print("  Minors:\n", .{});
    for (minors, 0..) |minor, i| {
        try writer.print("    {d:2}: {s}\n", .{ i, minor.name() });
    }
}

//
// Tests
//

fn expectFifths(fifths: Circle) !void {
    for (fifths, 0..) |key, i| {
        const next = fifths[(i + 1) % 12];
        const offset = @mod(next.semitone() - key.semitone(), 12);
        // Fifths are 7 semitones apart
        try std.testing.expectEqual(7, offset);
    }
}

test "majors ascend by fifths" {
    try expectFifths(majors);
}

test "minors ascend by fifths" {
    try expectFifths(minors);
}

test "minors are the relative minors of the majors" {
    for (majors, minors) |major, minor| {
        // Minor third is 3 semitones down:
        const semitones = @mod(major.semitone() - minor.semitone(), 12);
        try std.testing.expectEqual(3, semitones);

        // The relative minor is 2 letters down:
        const letters = @mod(@intFromEnum(major.letter) - @intFromEnum(minor.letter), 7);
        try std.testing.expectEqual(2, letters);
    }
}

test "byMode: returns the circle for the given mode" {
    try std.testing.expectEqual(majors, byMode(.major));
    try std.testing.expectEqual(minors, byMode(.minor));
}

test "at: returns the tonic at the index in the circle" {
    const cases = [_]struct { Note, Mode, i8 }{
        // major
        .{ Note.new(.C, .natural), .major, 0 },
        .{ Note.new(.C, .natural), .major, 12 },
        .{ Note.new(.C, .natural), .major, 24 },
        .{ Note.new(.G, .natural), .major, 1 },
        .{ Note.new(.G, .natural), .major, 13 },
        .{ Note.new(.G, .natural), .major, 25 },
        .{ Note.new(.F, .natural), .major, 11 },
        .{ Note.new(.F, .natural), .major, -1 },
        .{ Note.new(.F, .natural), .major, -13 },
        // minor
        .{ Note.new(.A, .natural), .minor, 0 },
        .{ Note.new(.A, .natural), .minor, 12 },
        .{ Note.new(.A, .natural), .minor, 24 },
        .{ Note.new(.E, .natural), .minor, 1 },
        .{ Note.new(.E, .natural), .minor, 13 },
        .{ Note.new(.E, .natural), .minor, 25 },
        .{ Note.new(.D, .natural), .minor, 11 },
        .{ Note.new(.G, .natural), .minor, -2 },
    };
    for (cases) |case| {
        const expected, const mode, const index = case;
        errdefer std.debug.print("failed input: mode={s}, index={d}\n", .{ @tagName(mode), index });
        try std.testing.expectEqual(expected, at(mode, index));
    }
}
