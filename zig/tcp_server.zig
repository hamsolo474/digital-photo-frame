//! Start a TCP server at an unused port.
//!
//! Test with
//! echo "hello zig" | nc localhost <port>

const std = @import("std");
const net = std.net;
const print = std.debug.print;
const eql = std.mem.eql;
var run: bool = true;

fn converti64to64(val: i64) u64 {
    if (val < 0) {
        return 0;
    }
    return @intCast(val);
}
pub fn main() !void{
    const tcp_thread = try std.Thread.spawn(.{}, tcp_server,.{});
    defer tcp_thread.join();
    // const delay = 10 * std.time.ns_per_s;
    while (run) {
    //     const ctime = std.time.timestamp() * std.time.ns_per_s;
    //     const ctime1 = converti64to64(ctime);
    //     const ctimeSTR = std.fmt.fmtDuration(ctime1);
    //     print("Time: {s}\n", .{ctimeSTR});
    //
    //     std.time.sleep(delay);
    }
    defer print("Exiting main",.{});
}

fn tcp_server() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const loopback = try net.Ip4Address.parse("127.0.0.1", 4744);
    const localhost = net.Address{ .in = loopback };
    var server = try localhost.listen(.{
        .reuse_port = true,
    });
    defer server.deinit();
    const addr = server.listen_address;
    print("Listening on {}, access this port to end the program\n", .{addr.getPort()});

    const t = "1234567890";
    const z: *const[5]u8 = "ABC";
    // const l1 = len(t);
    // const l2 = len(z);
    print("t is {d} chars long \n", .{t.len});
    print("z is {d} chars long \n", .{z.len});
    print("z[4] is {d} \"{c}\"\n", .{z[3],z[3]});

    while (run) {
        var client = try server.accept();
        defer client.stream.close();

        print("Connection received! {} is sending data.\n", .{client.address});

        const message = try client.stream.reader().readAllAlloc(allocator, 1024);
        defer allocator.free(message);
        // message = message[0..len(message)-1];
        // var msg: [1024]u8 = undefined;
        // var msg = undefined;


        print("{} says {s} | chars {d} | {s}\n", .{ client.address, message, message.len, message[0..message.len-1] });
        if (eql(u8,message, "TEST")) {
            const response = "it was a test";
            print("{s}\n", .{response});
            // msg[0..len(response)] = response;
        }
        else if (eql(u8,message, "Hi")) {
            const response = "Hello :)";
            print("{s}\n", .{response});
            // msg[0..len(response)] = response;
        }
        else if (eql(u8,message, "quit")) {
            run = false;
            // break;
        }
        else {
            const response = message;
            print("{s}\n", .{response});
            // msg = buf;
        }
    }
}

fn len(collection: anytype) usize {
    var count: usize = 0;
    count += 0;
    _ = collection;
    // for (collection) |element| {
    // while (true) : (count += 1){
        // try collection[count];
        // errdefer count;
        // element;
        // if (element != 0) { break; }
        // count += 1;
        // if (count > 100){print("\n Count: {d}\n", .{count});}
    // }
    // for (_) |_| str[count] != 0 {
    //     count += 1;
    // }
    return count;
}
