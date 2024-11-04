const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;

pub fn main() !void {
    // var file = try std.fs.cwd().openFile("C:\\Users\\mike\\Downloads\\paths.txt", .{});
    var file = try std.fs.cwd().openFile("/home/ham/Pictures/paths.txt", .{});
    defer file.close();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const a = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    var picList = std.ArrayList([]const u8).init(allocator);
    defer picList.deinit();
    var picListLen: usize = 0;
    var b = std.mem.splitSequence(u8, a, "\n");
    // I need to intialise this here so its not potenntial unitiliased later
    var fullVal = try std.fmt.allocPrint(allocator, "", .{});
    defer allocator.free(fullVal);
    // Read through all the lines in the file
    // These lines contain paths separated by \n
    // Try to open the paths and find all image files
    // Handle errors like invalid paths, and a file ending in a newline

    // making this while condition a try gives me this error
    // imPathGetter.zig:22:22: error: expected error union type, found '?[]const u8'
    // while (try b.next()) |line| {
    // ~~~~~~^~
    while (b.next()) |line| { // iterate over the lines in the file
        if (line.len == 0) {break;}
        var iter = (std.fs.openDirAbsolute(
            line, // Open the path on the current line of the document
            .{ .iterate = true },
        ) catch {
            print("Skipping {s}\n",.{line});
            continue;
        }).iterate();
        while (try iter.next()) |entry|{
            if (entry.kind == .file){
                if (try supportedExtension(entry.name)){
                    // So if i dont do this, the memory goes out of scope when i try to access it later
                    fullVal = try std.fmt.allocPrint(
                        allocator,
                        "{s}/{s}",
                        .{line, entry.name}
                    );
                    try picList.append(fullVal);
                    print("Appended {s}\n", .{entry.name});
                    print("List contents {s}\n", .{picList.items[picListLen]});
                    picListLen += 1;
                }
            }
        }
    }
    var count: usize = 0;
    // for (picList.items) |item| {
    while (count < picListLen) {
        std.debug.print("{d}) {s}\n", .{count, picList.items[count]});
        count += 1;
    }
    print("picList len: {d}\n", .{picListLen});
    std.debug.print("Index 1: {s}\n",.{picList.items[1]});
    // Now we need to read the list of folders and perform an LS on each of them.
    // Check to see if path is folder or file
    // https://zig.guide/standard-library/filesystem/
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