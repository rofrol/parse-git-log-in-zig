const std = @import("std");

pub fn main() anyerror!void {
    // Note that info level log messages are by default printed only in Debug
    // and ReleaseSafe build modes.
    std.log.info("All your codebase are belong to us.\n", .{});

    var file = try std.fs.cwd().openFile("data.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var al = std.ArrayList(u8).init(gpa.allocator());
    defer al.deinit();

    try al.appendSlice("one");
    try al.appendSlice("two");
    std.debug.print("al: {s}\n", .{al.toOwnedSlice()});
    al.clearAndFree();
    try al.appendSlice("four");
    try al.appendSlice("five");
    std.debug.print("al: {s}\n", .{al.toOwnedSlice()});
    al.clearAndFree();
    const delim = "|";

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.startsWith(u8, line, "commit ")) {
            std.debug.print("---- block: {s}\n", .{al.toOwnedSlice()});
            al.clearAndFree();
            std.debug.print(">>>{s}\n", .{line});
            var e = try std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ line, delim });
            try al.appendSlice(e);
        } else if (std.mem.eql(u8, line, "")) {
            std.debug.print("empty\n", .{});
        } else {
            std.debug.print("{s}\n", .{line});
            var e = try std.fmt.allocPrint(std.heap.page_allocator, "{s}{s}", .{ line, delim });
            try al.appendSlice(e);
        }
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
