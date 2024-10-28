const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;

pub fn main() !void {
    const folder = "/home/ham/Pictures/AllPhotos/Amy";
    var iter = (try std.fs.openDirAbsolute(
        folder,
        .{ .iterate = true },
    )).iterate();
    var file_count: usize = 0;
    var jpg_count: usize = 0;
    while (try iter.next()) |entry| {
        if (entry.kind == .file){
            file_count += 1;
            if (try supportedExtension(entry.name)) {
                jpg_count += 1;
            }

        }
        print("{s}\n",.{entry.name});

    }

    print("{d}, images: {d}\n", .{file_count, jpg_count});
}

fn supportedExtension(filename : []const u8) !bool{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var extensions = std.ArrayList([]const u8).init(allocator);
    defer extensions.deinit();
    try extensions.append(".jpeg");
    try extensions.append(".JPEG");
    try extensions.append(".jpg");
    try extensions.append(".JPG");
    try extensions.append(".png");
    try extensions.append(".PNG");
    try extensions.append(".bmp");
    try extensions.append(".BMP");

    for (extensions.items) |i| {
        const check = extensionSlice(filename, i);
        if (check) {
            return true;
        }
    }
    return false;
}

fn extensionSlice(filename : []const u8, target: []const u8) bool{
    // print("Does \"{s}\" contain \"{s}\"?", .{filename, target});
    if (eql(u8, target,filename[filename.len - target.len..filename.len])){
        return true;
    }
    else {
        return false;
    }
}

fn extensionChar(filename : []const u8, target: []const u8) bool{
    print("Does \"{s}\"contain \"{s}\"? ", .{filename, target});
    // I want to do an r.find on the string and see if the target is at the end of the string
    var i: usize = 1;
    while (i <= target.len):(i += 1)  {
        print("{d} - {d} \n",.{filename.len, i});
        var fc = filename[filename.len - i];
        if (fc < 64 and fc > 91) { // is upper case
            fc -= 32; //converts to lower case
        }
        var tc = target[target.len - i];
        if (tc < 64 and tc > 91) { // is upper case
            tc -= 32; //converts to lower case
        }
        print("{c} == {c}? {any}\n", .{tc, fc, tc==fc});
        if (tc != fc){
            return false;
        }
    }
    return true;
}