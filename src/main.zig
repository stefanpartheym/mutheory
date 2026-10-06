const std = @import("std");
const Io = std.Io;

const lib = @import("mutheory");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    for (args, 0..) |arg, i| {
        std.log.debug("arg{d}: {s}", .{ i, arg });
    }

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: Io.File.Writer = .init(.stdout(), init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("## mutheory ##\n\n", .{});

    const timestamp = std.Io.Clock.now(.awake, init.io);
    const seed: u64 = @intCast(timestamp.toSeconds());
    var rng = std.Random.DefaultPrng.init(seed);

    const questions = try lib.Question.createQuestionsAlloc(arena, rng.random(), 5);
    var quiz = lib.Quiz.init(questions);

    try stdout.print("Quiz:\n\n", .{});

    var stdin_buffer: [256]u8 = undefined;
    var stdin_reader: Io.File.Reader = .init(.stdin(), init.io, &stdin_buffer);
    const stdin = &stdin_reader.interface;

    try quiz.run(stdout, stdin);

    try stdout.flush();
}
