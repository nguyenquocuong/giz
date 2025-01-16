const std = @import("std");

const posix = std.posix;

pub fn init(socket: posix.socket_t, address: std.net.Address) Client {
    return Client{ .socket = socket, .address = address };
}

const Client = struct {
    socket: posix.socket_t,
    address: std.net.Address,

    pub fn handle(self: Client) !void {
        const socket = self.socket;

        defer {
            posix.close(socket);
            std.debug.print("{} closed\n", .{self.address});
        }

        std.debug.print("{} connected\n", .{self.address});

        const timeout = posix.timeval{ .sec = 2, .usec = 500_000 };
        try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.RCVTIMEO, &std.mem.toBytes(timeout));
        try posix.setsockopt(socket, posix.SOL.SOCKET, posix.SO.SNDTIMEO, &std.mem.toBytes(timeout));

        var buf: [1024]u8 = undefined;
        var reader = Reader{ .pos = 0, .buf = &buf, .socket = socket };

        while (true) {
            const msg = reader.readMessage() catch |err| switch (err) {
                error.Closed => break,
                else => return err,
            };
            std.debug.print("Got: {s}\n", .{msg});
        }
    }
};

const Reader = struct {
    buf: []u8,
    pos: usize = 0,
    start: usize = 0,
    socket: posix.socket_t,

    fn readMessage(self: *Reader) ![]u8 {
        var buf = self.buf;

        const n = try posix.read(self.socket, buf);
        if (n == 0) {
            return error.Closed;
        }

        return buf[0..n];
    }
};
