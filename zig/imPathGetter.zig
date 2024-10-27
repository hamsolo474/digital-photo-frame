const std = @import("std");
const print = std.debug.print;


pub fn main() !void {
    var file = try std.fs.cwd().openFile("C:\\Users\\mike\\Downloads\\paths.txt", .{});
    defer file.close();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const a = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    var folderList = std.ArrayList([]const u8).init(allocator);
    defer folderList.deinit();
    var picList = std.ArrayList([]const u8).init(allocator);
    defer picList.deinit();
    var b= std.mem.splitSequence(u8, a, "\n");
    while (b.next()) |line| {
        try folderList.append(line);
        std.fs.
    }
    for (folderList.items) |item| {
        std.debug.print("{s}\n", .{item});
    }
    std.debug.print("Index 1: {s}\n",.{folderList.items[1]});
    // Now we need to read the list of folders and perform an LS on each of them.
    // Check to see if path is folder or file
    // https://zig.guide/standard-library/filesystem/
}
