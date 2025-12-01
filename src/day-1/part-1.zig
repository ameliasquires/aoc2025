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

    var at: i32 = 50;
    var z: u64 = 0;

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const num = line[1..];

        var spin = try std.fmt.parseInt(i32, num, 10);
        spin = @mod(spin, 100);
        if(line[0] == 'L') spin = -spin;
        at += spin;
        if(at < 0) at = 100 - -at;
        if(at > 99) at = at - 100;
        
        if(at == 0) z += 1;
        //std.debug.print("{s} {d} {d}\n", .{line, spin, at});         
    }
    std.debug.print("{d}\n", .{z});
}
