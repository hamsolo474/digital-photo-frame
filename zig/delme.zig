const std = @import("std");
const print = std.debug.print;
const eql = std.mem.eql;

pub fn main() !void {
    const a: u8 = 'a';
    const A:u8  = 'A';
    const dot:u8  = '.';
    print("a is {d}, A is {d}, diff is {d}, a - 32 = {c}, fullstop is {d}\n",
        .{a, A, a-A, a-32, dot});
    // const extension = extensionSlice;
    // const check = extension("amy.jpg", ".jpg");
    const check = supportedExtension("amy.jpg");
    if (check) {
        print("Success!",.{});
    }
    print("{any}.\n", .{check});
}

fn supportedExtension(filename : []const u8) bool{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var extensions = std.ArrayList([]const u8).init(allocator);
    defer extensions.deinit();
    extensions.append(".jpeg") catch return false;
    extensions.append(".JPEG") catch return false;
    extensions.append(".jpg") catch return false;
    extensions.append(".JPG") catch return false;
    extensions.append(".png") catch return false;
    extensions.append(".PNG") catch return false;
    extensions.append(".bmp") catch return false;
    extensions.append(".BMP") catch return false;

    for (extensions.items) |i| {
        const check = extensionSlice(filename, i);
        if (check) {
            return true;
        }
    }
    return false;
}

fn extensionSlice(filename : []const u8, target: []const u8) bool{
    print("Does \"{s}\" contain \"{s}\"?", .{filename, target});
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