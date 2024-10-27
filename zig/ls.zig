const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const folder = "C:\\users\\mike\\Downloads";
    var iter = (try std.fs.openDirAbsolute(
        folder,
        .{ .iterate = true },
    )).iterate();
    var file_count: usize = 0;
    var jpg_count: usize = 0;
    print()
    while (try iter.next()) |entry| {
        if (entry.kind == .file){
            file_count += 1;
            if (extension(entry.name, ".jpg")) {
                jpg_count += 1;
            }

        }
        print("{s}\n",.{entry.name});

    }

    print("{d}, JPGS: {d}\n", .{file_count, jpg_count});
}

fn extension(filename : []const u8, target: []const u8) bool{
    // I want to do an r.find on the string and see if the target is at the end of the string
    var i = 0;
    while (i < target.len):(i += 1)  {
        var fc = filename[filename.len - i];
        if (fc < 64 and fc > 91) { // is upper case
            fc -= 32; //converts to lower case
        }
        var tc = target[target.len - i];
        if (tc < 64 and tc > 91) { // is upper case
            tc -= 32; //converts to lower case
        }
        print("{c} == {c}? {b}", .{tc, fc, tc==fc});
        if (tc == fc){
            // print("{c} == {c}? {b}", .{tc, fc, tc==fc});
        }
        else { return false;}
    }
    return true;
}