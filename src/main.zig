const std = @import("std");
const Io = std.Io;

const mutheory = @import("mutheory");

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

    try stdout.print("Fifths:\n", .{});
    try stdout.print("  Majors:\n", .{});
    for (mutheory.Fifths.majors, 0..) |major, i| {
        try stdout.print("    {d:2}: {s}\n", .{ i, major.name() });
    }
    try stdout.print("  Minors:\n", .{});
    for (mutheory.Fifths.minors, 0..) |minor, i| {
        try stdout.print("    {d:2}: {s}\n", .{ i, minor.name() });
    }

    try stdout.flush();
}
