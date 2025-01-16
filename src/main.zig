const std = @import("std");

const server = @import("server.zig");

pub fn main() !void {
    const srv = try server.Server.init(server.Options{ .address = "127.0.0.1", .port = 1234 });
    std.debug.print("{}\n", .{srv});

    try srv.listen();
}
