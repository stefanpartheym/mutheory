//! Library

pub const Note = @import("Note.zig");
pub const Key = @import("Key.zig");
pub const fifths = @import("fifths.zig");
pub const Question = @import("Question.zig");
pub const Quiz = @import("Quiz.zig");

//
// Tests
//

test {
    @import("std").testing.refAllDecls(@This());
}
