const std = @import("std");
const Key = @import("Key.zig");
const Question = @import("Question.zig");

const Self = @This();

/// Questions
questions: []Question,
/// Current question index
index: u8,

pub fn init(questions: []Question) Self {
    return .{
        .questions = questions,
        .index = 0,
    };
}

pub fn next(self: *Self) ?Question {
    if (self.index < self.questions.len) {
        defer self.index += 1;
        return self.questions[self.index];
    }
    return null;
}

pub fn run(self: *Self, writer: *std.Io.Writer, reader: *std.Io.Reader) !void {
    while (self.next()) |question| {
        try writer.print("{f}?\n", .{question});

        while (true) {
            try writer.print("> ", .{});
            try writer.flush();
            const line = try reader.takeDelimiter('\n') orelse return; // null = EOF (Ctrl-D)
            const input = std.mem.trim(u8, line, " \t\r");
            if (Key.parse(input)) |key| {
                const answer = question.answer();
                if (key.eql(answer)) {
                    try writer.print("CORRECT\n", .{});
                } else {
                    try writer.print("WRONG, the correct answer is {f}\n", .{answer});
                }
                break;
            } else |_| {
                try writer.print("invalid input, try again...\n", .{});
            }
        }
    }
}

//
// Tests
//

fn expectRun(questions: []Question, input: []const u8, expected: []const u8) !void {
    var reader: std.Io.Reader = .fixed(input);
    var output: std.Io.Writer.Allocating = .init(std.testing.allocator);
    defer output.deinit();

    var quiz = Self.init(questions);
    try quiz.run(&output.writer, &reader);
    try std.testing.expectEqualStrings(expected, output.written());
}

test "run: reports correct and wrong answers" {
    var questions = [_]Question{
        .{ .index = 0, .direction = .relative, .mode = .major },
        .{ .index = 0, .direction = .right, .mode = .minor },
    };
    try expectRun(&questions, "Am\nBm\n",
        \\What is the relative minor to C?
        \\> CORRECT
        \\What is the right neighbor to Am?
        \\> WRONG, the correct answer is Em
        \\
    );
}

test "run: rejects an enharmonic spelling" {
    var questions = [_]Question{
        .{ .index = 6, .direction = .relative, .mode = .minor },
    };
    try expectRun(&questions, "Gb\n",
        \\What is the relative major to D♯m?
        \\> WRONG, the correct answer is F♯
        \\
    );
}

test "run: asks again after invalid input" {
    var questions = [_]Question{
        .{ .index = 0, .direction = .relative, .mode = .major },
    };
    try expectRun(&questions, "X\n  Am \r\n",
        \\What is the relative minor to C?
        \\> invalid input, try again...
        \\> CORRECT
        \\
    );
}

test "run: accepts a last answer without trailing newline" {
    var questions = [_]Question{
        .{ .index = 0, .direction = .relative, .mode = .major },
    };
    try expectRun(&questions, "Am",
        \\What is the relative minor to C?
        \\> CORRECT
        \\
    );
}

test "run: end of input stops the quiz" {
    var questions = [_]Question{
        .{ .index = 0, .direction = .relative, .mode = .major },
        .{ .index = 1, .direction = .relative, .mode = .major },
    };
    try expectRun(&questions, "", "What is the relative minor to C?\n> ");
}
