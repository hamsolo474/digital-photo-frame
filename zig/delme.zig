const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("/home/ham/Pictures/paths.txt", .{});
    defer file.close();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const a = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    var picList = std.ArrayList([]const u8).init(allocator);
    defer picList.deinit();
    var picListLen: usize = 0;
    var b= std.mem.splitSequence(u8, a, "\n");
    while (b.next()) |line| { // iterate over the lines in the file
        if (line.len == 0) {break;} //skip newline at the end of file
        var iter = (std.fs.openDirAbsolute( // Opens the folder like ls and returns an iterator of each object found
            line, // Open the path on the current line of the document
            .{ .iterate = true },
        ) catch {
            // print("Skipped", .{});
            print("Skipping {s}\n",.{line});
            continue;
        }).iterate();
        while (try iter.next()) |entry| { // for object in folder
            try picList.append(entry.name);
            print("Appended {s}\n", .{entry.name});
            print("List contents {s}\n", .{picList.items[picListLen]});
            picListLen += 1;
        }
    }
    var count: usize = 0;
    while (count < picListLen) {
        std.debug.print("{d}) {s}\n", .{count, picList.items[count]});
        count += 1;
    }
    print("picList len: {d}\n", .{picListLen});
    std.debug.print("Index 1: {s}\n",.{picList.items[1]});
}