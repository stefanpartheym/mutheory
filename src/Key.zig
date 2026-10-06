const std = @import("std");
const Note = @import("Note.zig");
const Letter = Note.Letter;
const Accidental = Note.Accidental;

pub const ParseError = error{InvalidInput};

const Self = @This();

tonic: Note,
mode: Mode,

pub const Mode = enum {
    major,
    minor,

    pub fn symbol(self: @This()) []const u8 {
        return switch (self) {
            .major => "",
            .minor => "m",
        };
    }

    pub fn inverse(self: @This()) Mode {
        return switch (self) {
            .major => .minor,
            .minor => .major,
        };
    }
};

/// Parses a key string like "C", "F#m", "Gb", etc.
pub fn parse(input: []const u8) ParseError!Self {
    if (input.len == 0) {
        // TODO: This should be a separate `EmptyInput` error.
        // This way, we can keep the input prompt when the user presses [Enter]
        // on an empty line.
        return ParseError.InvalidInput;
    }
    // Longest valid input is letter, accidental and mode, e.g. "F#m".
    if (input.len > 3) {
        return ParseError.InvalidInput;
    }

    const letter = std.meta.stringToEnum(Letter, input[0..1]) orelse return ParseError.InvalidInput;
    var accidental: ?Accidental = null;
    var mode: ?Mode = null;

    if (input.len > 1) {
        switch (input[1]) {
            '#' => accidental = .sharp,
            'b' => accidental = .flat,
            'm' => mode = .minor,
            else => return ParseError.InvalidInput,
        }

        if (input.len > 2) {
            switch (input[2]) {
                'm' => {
                    if (mode != null) return ParseError.InvalidInput;
                    mode = .minor;
                },
                else => return ParseError.InvalidInput,
            }
        }
    }

    return Self{
        .tonic = Note{
            .letter = letter,
            .accidental = accidental orelse .natural,
        },
        .mode = mode orelse .major,
    };
}

pub fn eql(self: Self, other: Self) bool {
    return self.tonic.eql(other.tonic) and self.mode == other.mode;
}

pub fn format(self: Self, w: *std.Io.Writer) std.Io.Writer.Error!void {
    try w.print("{s}{s}", .{ self.tonic.name(), self.mode.symbol() });
}

//
// Tests
//

test parse {
    const key = try parse("F#m");
    try std.testing.expectEqual(Self{
        .tonic = .{ .letter = .F, .accidental = .sharp },
        .mode = .minor,
    }, key);
}

test "parse: valid keys" {
    const cases = [_]struct { []const u8, Letter, Accidental, Mode }{
        .{ "C", .C, .natural, .major },
        .{ "Cm", .C, .natural, .minor },
        .{ "C#", .C, .sharp, .major },
        .{ "C#m", .C, .sharp, .minor },
        .{ "Cbm", .C, .flat, .minor },
        .{ "D", .D, .natural, .major },
        .{ "E", .E, .natural, .major },
        .{ "F", .F, .natural, .major },
        .{ "G", .G, .natural, .major },
        .{ "A", .A, .natural, .major },
        .{ "B", .B, .natural, .major },
    };
    for (cases) |case| {
        const input, const letter, const accidental, const mode = case;
        errdefer std.debug.print("failed input: \"{s}\"\n", .{input});

        const expected =
            Self{
                .tonic = .{ .letter = letter, .accidental = accidental },
                .mode = mode,
            };
        try std.testing.expectEqual(expected, try parse(input));
    }
}

test "parse: rejects invalid input" {
    const inputs = [_][]const u8{
        "",
        "X",
        "c",
        "C ",
        "C##",
        "Cbb",
        "Cmm",
        "C#mm",
        "C#mx",
        "Cbm ",
        "#",
        "b",
    };
    for (inputs) |input| {
        errdefer std.debug.print("failed input: \"{s}\"\n", .{input});
        try std.testing.expectError(ParseError.InvalidInput, parse(input));
    }
}
