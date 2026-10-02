const Letter = @import("note.zig").Letter;
const Accidental = @import("note.zig").Accidental;
const Note = @import("note.zig").Note;

/// Tonics of the major keys around the circle of fifths, clockwise from C.
/// Enharmonic positions use B, F♯ and D♭.
pub const majors = [12]Note{
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
pub const minors = [12]Note{
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

//
// Tests
//

const std = @import("std");

fn expectFifths(fifths: [12]Note) !void {
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
