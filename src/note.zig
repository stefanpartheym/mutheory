//! Letter, Accidental and Note

/// Note letters
/// Values are the letter offset from C.
pub const Letter = enum(i8) {
    C = 0,
    D = 1,
    E = 2,
    F = 3,
    G = 4,
    A = 5,
    B = 6,

    pub fn semitone(self: @This()) i8 {
        return switch (self) {
            .C => 0,
            .D => 2,
            .E => 4,
            .F => 5,
            .G => 7,
            .A => 9,
            .B => 11,
        };
    }
};

/// Note accidentals
/// Values are the number of semitones offset from natural note.
pub const Accidental = enum(i8) {
    flat = -1,
    natural = 0,
    sharp = 1,

    pub fn symbol(self: Accidental) []const u8 {
        return switch (self) {
            .flat => "♭",
            .natural => "",
            .sharp => "♯",
        };
    }
};

pub const Note = struct {
    const Self = @This();

    letter: Letter,
    accidental: Accidental,

    /// Pitch class in semitones above C, from 0 to 11.
    pub fn semitone(self: Self) i8 {
        return @mod(self.letter.semitone() + @intFromEnum(self.accidental), 12);
    }

    /// Note name such as "C", "F♯" or "B♭".
    pub fn name(self: Self) []const u8 {
        return switch (self.letter) {
            inline else => |l| switch (self.accidental) {
                inline else => |a| @tagName(l) ++ comptime a.symbol(),
            },
        };
    }
};
