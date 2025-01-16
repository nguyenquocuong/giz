const std = @import("std");
const client = @import("client.zig");

const posix = std.posix;

pub const Options = struct { address: []const u8 = "0.0.0.0", port: u16 = 1234 };

pub const Server = struct {
    address: std.net.Address,

    pub fn init(options: Options) !Server {
        const address = try std.net.Address.parseIp(options.address, options.port);

        return Server{ .address = address };
    }

    pub fn listen(self: Server) !void {
        const listener = try std.posix.socket(self.address.any.family, posix.SOCK.STREAM, posix.IPPROTO.TCP);
        defer posix.close(listener);

        try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));
        try posix.bind(listener, &self.address.any, self.address.getOsSockLen());
        try posix.listen(listener, 128);

        try self.printAddress(listener);

        while (true) {
            var client_address: std.net.Address = undefined;
            var client_address_len: posix.socklen_t = @sizeOf(std.net.Address);

            const socket = posix.accept(listener, &client_address.any, &client_address_len, 0) catch |err| {
                std.debug.print("error: accept: {}\n", .{err});
                continue;
            };

            const c = client.Client.init(socket, client_address);
            try c.handle();
        }
    }

    fn printAddress(_: Server, socket: posix.socket_t) !void {
        var address: std.net.Address = undefined;
        var len: posix.socklen_t = @sizeOf(std.net.Address);

        try posix.getsockname(socket, &address.any, &len);
        std.debug.print("Listening on {}\n", .{address});
    }
};
