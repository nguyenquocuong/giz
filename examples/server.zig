const std = @import("std");

const giz = @import("giz");

pub fn main() !void {
    const server = try giz.Server.init(.{ .address = "127.0.0.1", .port = 1234 });
    std.debug.print("{}\n", .{server});

    try server.listen();
}
