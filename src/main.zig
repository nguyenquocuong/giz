const std = @import("std");

const server = @import("server.zig");

const net = std.net;
const posix = std.posix;

pub fn main() !void {
    const srv = try server.Server.init(server.Options{ .address = "127.0.0.1", .port = 1234 });
    std.debug.print("{}\n", .{srv});

    try srv.listen();
}

fn printAddress(socket: posix.socket_t) !void {
    var address: std.net.Address = undefined;
    var len: posix.socklen_t = @sizeOf(net.Address);

    try posix.getsockname(socket, &address.any, &len);
    std.debug.print("Listening on {}\n", .{address});
}

fn write(socket: posix.socket_t, msg: []const u8) !void {
    var pos: usize = 0;
    while (pos < msg.len) {
        const written = try posix.write(socket, msg[pos..]);
        if (written == 0) {
            return error.Closed;
        }
        pos += written;
    }
}
