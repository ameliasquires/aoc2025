const std = @import("std");

//returns index
pub fn largest(line: []const u8, start: usize, end: usize) usize {
    var idx: usize = start;

    for(start..end) |i| {
        if(line[i] > line[idx]){
            idx = i;
        }
    }

    return idx;
} 

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

    const need = 12;
    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var lastidx: usize = 0;
        var n: u64 = 0;

        for(1 .. need + 1) |i| {
            lastidx = largest(line, lastidx, line.len - (need - i));
            n += std.math.pow(u64, 10, need - i) * (line[lastidx] - '0');
            lastidx += 1;
        }

        total += n;
    }

    std.debug.print("{d}\n", .{total});
}
