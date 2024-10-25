const std = @import("std");
const net = std.net;
const print = std.debug.print;
const sleep = std.time.sleep;

pub fn main() !void {
    // var args = std.process.args();
    // The first (0 index) Argument is the path to the program.
    // _ = args.skip();
    // const port_value = args.next() orelse {
    //     print("expect port as command line argument\n", .{});
    //     return error.NoPort;
    // };
    const port: usize = 4744;

    const peer = try net.Address.parseIp4("127.0.0.1", port);
    // Connect to peer
    const stream = try net.tcpConnectToAddress(peer);
    defer stream.close();
    print("Connecting to {}\n", .{peer});

    // Sending data to peer
    const data1 = "hello zig";
    var writer = stream.writer();
    _ = try writer.write(data1);
    // print("Sent First message", .{});
    // const delay = 10 * 1_000_000_000; //Nanosecond conversion
    // sleep(delay);
    // const data2 = "hello world";
    // _ = try writer.write(data2);
    // print("Sent Second message", .{});
    // Or just using `writer.writeAll`
    // try writer.writeAll("hello zig");
}
