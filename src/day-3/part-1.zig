const std = @import("std");

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer gpa.deinit();
    //const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var buffer: [256]u8 = undefined;

    var total: u64 = 0;

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var ind1: usize = line.len - 2;

        var i: usize = 2;
        while(i <= line.len) : (i += 1) {
            if(line[line.len - i] - '0' >= line[ind1] - '0'){
                ind1 = line.len - i;
            }
        }

        i = ind1 + 1;
        var ind2: usize = ind1 + 1;
        while(i < line.len) : (i += 1) {
            if(line[i] - '0' > line[ind2] - '0'){
                ind2 = i;
            }
        }

        total += ((line[ind1] - '0') * 10) + line[ind2] - '0';
    }

    std.debug.print("{d}\n", .{total});
}
